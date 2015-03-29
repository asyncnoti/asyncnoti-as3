package com.asyncnoti {
import flash.events.Event;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

public class AsyncnotiEvent extends Event {
    private var _event:String;
    private var _data:Object;
    private static const logger:ILogger = getLogger(AsyncnotiEvent);

    public function AsyncnotiEvent(event:String, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(event, bubbles, cancelable);
        logger.info('construct');

        _event = event;
        _data = {};
    }

    override public function clone():Event
    {
        return new AsyncnotiEvent(this._event, this.bubbles, this.cancelable);
    }

    public function get data():Object
    {
        return this._data;
    }

    public function set data(value:Object):void
    {
        this._data = value;
    }

    public function get event():String
    {
        return _event;
    }
}
}
