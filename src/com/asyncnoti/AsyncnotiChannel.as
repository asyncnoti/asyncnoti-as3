package com.asyncnoti
{

import flash.events.EventDispatcher;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

public class AsyncnotiChannel extends EventDispatcher
{
    private var _name:String;
    private static const logger:ILogger = getLogger(AsyncnotiChannel);

    public function AsyncnotiChannel(name:String)
    {
        logger.info('construct');
        this._name = name;
    }

    public function get name():String
    {
        return _name;
    }
}
}
