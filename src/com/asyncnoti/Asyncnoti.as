package com.asyncnoti
{
import com.adobe.serialization.json.JSON2;
import com.asyncnoti.logger.WebSocketLogger;
import com.asyncnoti.utils.AsyncnotiQueue;

import flash.events.EventDispatcher;
import flash.utils.setTimeout;

import net.websocket.WebSocket;
import net.websocket.WebSocketEvent;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

public class Asyncnoti extends EventDispatcher
{
    private static const logger:ILogger = getLogger(Asyncnoti);
    private var _verboseLogging:Boolean = false;

    // connection states
    private var _connecting:Boolean = false;
    private var _connected:Boolean = false;
    private var _resubscribe:Boolean = false;

    // websocket vars
    private var _websocket:WebSocket;

    // instance options
    private var _asyncnotiOptions:AsyncnotiOptions;
    private var _channels:Array;
    private var _queue:AsyncnotiQueue; //Sended data in queue

    public function Asyncnoti(options:AsyncnotiOptions)
    {
        logger.info('construct');

        if (options == null)
            throw new Error('options cannot be null');

        _asyncnotiOptions = options;

        _channels = [];
        _queue = new AsyncnotiQueue();
    }

    public function connect():void
    {
        logger.info('connecting...');

        if (_connecting)
        {
            logger.debug('Already attempting connection');
            return;
        }

        if (_connected)
        {
            logger.debug('Connection is already established');
            return;
        }

        _connecting = true;

        var asyncnotiURL:String = _asyncnotiOptions.secure ? _asyncnotiOptions.asyncnotiSecureURL :
                _asyncnotiOptions.asyncnotiURL;

        // create websocket instance
        _websocket = new WebSocket(-1,
                asyncnotiURL,
                _asyncnotiOptions.protocols,
                _asyncnotiOptions.origin,
                '',
                0,
                '',
                '',
                new WebSocketLogger(_verboseLogging));

        _websocket.addEventListener(WebSocketEvent.OPEN, _websocket_OPEN);
        _websocket.addEventListener(WebSocketEvent.MESSAGE, _websocket_MESSAGE);
        _websocket.addEventListener(WebSocketEvent.ERROR, _websocket_ERROR);
        _websocket.addEventListener(WebSocketEvent.CLOSE, _websocket_ERROR);
    }

    protected function _websocket_OPEN(event:WebSocketEvent):void
    {
        logger.info('websocket open');
        _connected = true;

        //Added resubscribe application to the queue
        if (this._resubscribe)
        {
            this._resubscribe = false;
            for (var i:String in _channels)
            {
                if (!_channels.hasOwnProperty(i))
                    continue;

                var ch:AsyncnotiChannel = this._channels[i];
                this.sendData({'channel': ch.name, 'event': 'asyncnoti:subscribe'});
            }
        }

        this._sendQueue();
    }

    private function sendData(message:Object):void
    {
        _queue.enqueue(message);
        _sendQueue();
    }

    private function _sendQueue():void
    {
        if (!_connected || _queue.isEmpty())
            return;

        var msg:String = JSON.stringify(_queue.dequeue());
        logger.debug('-> snt: {0}', [msg]);
        _websocket.send(msg);

        this._sendQueue();
    }

    protected function _websocket_ERROR(event:WebSocketEvent):void
    {
        logger.error('Connection closed or caused an exception. Retry after two seconds');

        this._connected = false;
        this._connecting = false;
        this._resubscribe = true;

        _websocket.removeEventListener(WebSocketEvent.OPEN, _websocket_OPEN);
        _websocket.removeEventListener(WebSocketEvent.MESSAGE, _websocket_MESSAGE);
        _websocket.removeEventListener(WebSocketEvent.ERROR, _websocket_ERROR);
        _websocket.removeEventListener(WebSocketEvent.CLOSE, _websocket_ERROR);

        setTimeout(_reconnect, 2000);
    }

    private function _reconnect():void
    {
        if (!_connected)
            connect();
    }

    protected function _websocket_MESSAGE(event:WebSocketEvent):void
    {
        var originalMessage:String = decodeURIComponent(event.message);

        var msgType:String = originalMessage.substr(0, 2);
        if (msgType != 'a[')
            return;

        var message:String = originalMessage.substr(2, originalMessage.length - 3);
        logger.debug('<- rcd: {0}', [message]);

        var data:Object = JSON2.decode(message);

        if (typeof (data.data) == 'object')
        {
            bodyJsonData = data.data;
            bodyData = null;
        }
        else
        {
            var bodyData:String = data.data;
            var bodyJsonData:Object;

            try
            {
                bodyJsonData = JSON.parse(bodyData);
            } catch (err:Error)
            {
            }
        }

        var asyncnotiEvent:AsyncnotiEvent;
        if (data.hasOwnProperty('channel') && data.hasOwnProperty('event'))
        {
            asyncnotiEvent = new AsyncnotiEvent(data.event);
            asyncnotiEvent.data = bodyJsonData ? bodyJsonData : bodyData;

            //Ищем канал
            for (var i:String in _channels)
            {
                if (!_channels.hasOwnProperty(i))
                    continue;

                var ch:AsyncnotiChannel = this._channels[i];
                if (ch.name == data.channel)
                    ch.dispatchEvent(asyncnotiEvent);
            }
        }
    }


    public function subscribe(name:String):AsyncnotiChannel
    {
        var new_channel:AsyncnotiChannel = new AsyncnotiChannel(name);
        this._channels.push(new_channel);
        this.sendData({'channel': name, 'event': 'asyncnoti:subscribe'});

        return new_channel;
    }

    public function unsubscribe(name:String):void
    {
        var iterator:Number = _channels.length;

        while (iterator)
        {
            var ch:AsyncnotiChannel = _channels[--iterator];
            if (ch.name == name)
            {
                var item_position:Number = _channels.indexOf(ch);
                if (item_position >= 0)
                {
                    _channels.splice(item_position, 1);

                    this.sendData({'channel': name, 'event': 'asyncnoti:unsubscribe'})
                }
            }
        }
    }

    public function set verboseLogging(value:Boolean):void
    {
        _verboseLogging = value;
    }
}
}
