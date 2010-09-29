package multipart
{
	import flash.utils.ByteArray;
	import flash.events.ProgressEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	public class MultipartResponseParser extends EventDispatcher
	{
		private var buffer:MultipartResponseBuffer;
		private var _headers:Array;
		private var _currentState:String="";
		private var _rawStatusLine:String="";
		private var _rawHeaders:String="";
		private var _rawBody:String="";
		
		private const StatusState:String = 'status';
		private const HeaderState:String = 'header';
		private const BodyState:String = 'body';
		
		public function MultipartResponseParser() {
			buffer = new MultipartResponseBuffer();
			this._headers = new Array();
			this._currentState = StatusState;
			buffer.addEventListener(ProgressEvent.SOCKET_DATA,readLine);
		}
		
		private function readLine(event:ProgressEvent):void {
			switch (this._currentState) {
				case StatusState:
					readStatusLine(event);
					break;
				case HeaderState:
					readHeaderLine(event);
					break;
				case BodyState:
					readBody(event);
					break;
			}
		}
		
		public function addChunk(chunk:String):void {
			buffer.addChunk(chunk);
		}
		
		private function readStatusLine(event:ProgressEvent):void {
			this._currentState = HeaderState;
			var statusLine:String = MultipartResponseBuffer(event.target).readLastLine();
			this._rawStatusLine += statusLine;
			//trace("status line:" + statusLine.replace("\r\n",''));
			var regExp:RegExp = new RegExp("HTTP[\/](...) (...) (.*)");
			var statusParts:Object = regExp.exec(statusLine);
			if (statusParts == null)
				throw("Invalid HTTP Response from server");
			var httpv:String = statusParts[1];
			var code:String = statusParts[2];
			var msg:String = statusParts[3];
			if (code != '200')
				throw("Server returned code " + code + ":" + msg);
			this.buffer.checkMemo();
		}
		
		private function readHeaderLine(event:ProgressEvent):void {
			var newLine:String = MultipartResponseBuffer(event.target).readLastLine();
			this._rawHeaders += newLine;
			var regExp:RegExp = new RegExp("(.*): (.*)");
			var headerParts:Object = regExp.exec(newLine);
			regExp = new RegExp("^\r\n");
			var endOfHeader:Object = regExp.exec(newLine);
			if (headerParts != null) {
				this._headers.push(new MultipartResponseHeader(headerParts[1],headerParts[2]));
				//trace("header line:" + headerParts[1] + ": " + headerParts[2]);
			}
			else if (endOfHeader != null)
				this.headerLinesReadComplete();
			else 
				throw("Invalid HTTP Response from server");
			this.buffer.checkMemo();
		}
		
		private function headerLinesReadComplete():void {
			this._currentState = BodyState;
			var findLengthHeader:Function = function callback(item:*, index:int, array:Array):Boolean {
														return(item.key == 'Content-Length')
													};
			var lengthHeader:MultipartResponseHeader = MultipartResponseHeader(this._headers.filter(findLengthHeader)[0]);
			this.buffer.flushBySize(int(lengthHeader.value));
			this.buffer.checkMemo();
		}
		
		private function readBody(event:ProgressEvent):void {
			var newLine:String = MultipartResponseBuffer(event.target).readLastLine();
			this._rawBody = newLine;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function get rawResponse():String {
			return(this._rawStatusLine + this._rawHeaders + this._rawBody);
		}
		
		public function get body():String {
			return(this._rawBody);
		}
		
	}
	
	
}