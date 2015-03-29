package com.asyncnoti.logger
{
	import net.websocket.IWebSocketLogger;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class WebSocketLogger implements IWebSocketLogger
	{
		private static const logger: ILogger = getLogger( WebSocketLogger );
		
		private var _verboseMode:Boolean = false;
		
		public function WebSocketLogger(verboseMode:Boolean = false)
		{
			_verboseMode = verboseMode;
		}
		
		public function log(message:String):void
		{
			if(_verboseMode)
				logger.info(message);
		}
		
		public function error(message:String):void
		{
			logger.error(message);
		}
	}
}