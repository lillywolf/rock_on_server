package multipart
{
	import flash.utils.ByteArray;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	public class MultipartResponseBuffer extends EventDispatcher
	{
		private var _memo:String;
		private var _lastLine:String;
		private var _locked:Boolean;
		private var _nextFlushSize:int;
		
		public function MultipartResponseBuffer() {
			this._memo = ""
			this._locked = false;
			_nextFlushSize = -1;
		}
		
		public function addChunk(chunk:String):void {
			_memo += chunk;
			memoChanged();
		}
		
		private function memoChanged():void {
			
			if (this._nextFlushSize != -1) {
				if (this._memo.length == this._nextFlushSize) {
					this._lastLine = this._memo;
					this._memo = '';
					this._nextFlushSize = -1;
					this.dispatchEvent(new ProgressEvent(ProgressEvent.SOCKET_DATA));
				}
			} else {
				var match:int = this._memo.indexOf("\r\n");
				if (match != -1) {
					this._lastLine = this._memo.slice(0,match+2);
					this._memo = this._memo.slice(match+2);
					this.dispatchEvent(new ProgressEvent(ProgressEvent.SOCKET_DATA));
				}
			}
		}
		
		public function flushBySize(size:int):void {
			this._nextFlushSize = size;
		}
		
		public function checkMemo():void {
			var match:int = this._memo.search("\r\n");
			if (match != -1)
				memoChanged();
		}
		
		public function readLastLine():String {
			var lastLine:String = this._lastLine;
			this._lastLine = "";
			return(lastLine);
		}
	}
	
}