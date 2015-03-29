package com.asyncnoti
{
import net.zedia.utils.StringUtils;

public final class AsyncnotiOptions
{
    private var _applicationKey:String;
    private var _origin:String;
    private var _secure:Boolean = false;
    private var _protocols:Array = [];
    private var _host:String = 'asyncnoti.com';
    private var _ws_port:uint = 80;
    private var _wss_port:uint = 443;
    private var _activity_timeout:uint = 120000;
    private var _pong_timeout:uint = 30000;
    private var _clusterId:Number;
    private var _sessionId:String;

    public function AsyncnotiOptions(applicationKey:String = null, origin:String = null):void
    {
        this._applicationKey = applicationKey;
        this._origin = origin;
        this._sessionId = StringUtils.generateRandomString(8);
        this._clusterId = int(Math.floor(Math.random() * 999));
    }

    public function get applicationKey():String
    {
        return this._applicationKey;
    }

    public function set applicationKey(value:String):void
    {
        this._applicationKey = value;
    }

    public function get origin():String
    {
        return this._origin;
    }

    public function set origin(value:String):void
    {
        this._origin = value;
    }

    public function get secure():Boolean
    {
        return this._secure;
    }

    public function set secure(value:Boolean):void
    {
        this._secure = value;
    }

    public function get protocols():Array
    {
        return this._protocols;
    }

    public function set protocols(value:Array):void
    {
        this._protocols = value;
    }

    public function get host():String
    {
        return this._host;
    }

    public function set host(value:String):void
    {
        this._host = value;
    }

    public function get ws_port():uint
    {
        return this._ws_port;
    }

    public function set ws_port(value:uint):void
    {
        this._ws_port = value;
    }

    public function get wss_port():uint
    {
        return this._wss_port;
    }

    public function set wss_port(value:uint):void
    {
        this._wss_port = value;
    }

    public function get activity_timeout():uint
    {
        return this._activity_timeout;
    }

    public function set activity_timeout(value:uint):void
    {
        this._activity_timeout = value;
    }

    public function get pong_timeout():uint
    {
        return this._pong_timeout;
    }

    public function set pong_timeout(value:uint):void
    {
        this._pong_timeout = value;
    }

    // Logic Getters

    public function get connectionPath():String
    {
        return ['', 'app', _applicationKey, _clusterId, _sessionId, 'websocket'].join('/');
    }

    public function get asyncnotiURL():String
    {
        return 'ws://' + _host + ":" + _ws_port + connectionPath;
    }

    public function get asyncnotiSecureURL():String
    {
        return 'wss://' + _host + ":" + _wss_port + connectionPath;
    }

}
}