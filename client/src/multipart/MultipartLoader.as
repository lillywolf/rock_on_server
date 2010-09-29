/**
* @author Neer Friedman
*/
package multipart
{
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.events.ProgressEvent;
	
	
	/**
	* Dispatched when the server returned his response to the request.
	* When this event is dispatched the <code>responseBody</code> and <code>rawResponse</code> properties are populated,
	*
	* @eventType flash.events.Event.COMPLETE
	*/
	[Event(name="complete", type="flash.events.Event")]
	
		
	/**
	* Dispatched when the connection to the server is closed.
	*
	* @eventType flash.events.Event.CLOSE
	*/
	[Event(name="close", type="flash.events.Event")]
	
		
	/**
	* Dispatched when the socket object dispatches a IO_ERROR event.
	*
	* @eventType flash.events.IOErrorEvent.IO_ERROR
	*/
	[Event(name="io_error", type="flash.events.IOErrorEvent")]
	
		
	/**
	* Dispatched when the socket object dispatches a SECURITY_ERROR event.
 	* <b>Note:</b> the event object that is being dispatched is created in the socket object, this class only rolls on the error.
	*
	* @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
	*/
	[Event(name="security_error", type="flash.events.SecurityErrorEvent")]
	
		
	/**
	* The MultipartLoader class uploads data to a remote server as a multipart/form-data request.
	* It is useful for uploading files that were created in your program.<br/>
	* To upload files from the user's hard-disk use the built-in <a href="http://livedocs.adobe.com/flex/201/langref/flash/net/FileReference.html">FileReference</a>.<br/>
	* This class uses the built-in <a href="http://livedocs.adobe.com/flex/201/langref/flash/net/Socket.html">Socket</a> object to make the request, 
	* that means any security restrictions that apply for the <a href="http://livedocs.adobe.com/flex/201/langref/flash/net/Socket.html">Socket</a> class also apply here.
	* 		
	* @example <listing version="3.0">
	* public function startUpload():void {
	* 		loader = new MultipartLoader('http://my.uploads.server.com:3007/uploads/test');
	* 		var variables:MultipartVariables = new MultipartVariables();
	* 		var myByteArray:ByteArray = new ByteArray();
	* 		// we will create a fake file content here, you should replace this with th ebinary data you want to upload
	* 		for(var i:int=0; i<100000;i++) {
	* 			myByteArray.writeUTFBytes("123by\nAR\r\nRA\x65\x0156");
	* 		}
	* 		variables.add('file_data',myByteArray);
	* 		variables.add('another_var','extra data');
	* 		loader.variables = variables;
	* 		loader.addEventListener(Event.COMPLETE,fileUploaded);
	* 		loader.load();
	* }
	* 
	* private function fileUploaded(event:Event):void {
	* 		trace(MultipartLoader(event.target).responseBody);
	* }
	* </listing>
	*/
	public class MultipartLoader extends EventDispatcher
	{
		private var socket:Socket;
		private var _host:String;
		private var _port:int;
		private var _path:String;
		private var _request:MultipartRequest;
		private var _response:MultipartResponseParser;
		private var _responseRecieved:Boolean;
		
		
		
		/**
		 * Creates a MultipartLoader object.
		 * @param url The remote URL to send the request to, in the form of http://host.address:port/path/on/server.
		 * You must specify this parameter here otherwise the operation will fail.
		 * 
		 * @return 
		 * 
		 */		
		public function MultipartLoader(url:String=null) {
			if (url!=null)
				parseUrl(url);
			this.socket = new Socket();
			this._request = new MultipartRequest(this._host, this._path);
			this._response = new MultipartResponseParser();
			this._response.addEventListener(Event.COMPLETE,responseReceived);
			this._responseRecieved = false;
			registerDefaultEventHandlers();
		}
		
		/**
		 * Sends and loads data from the specified URL.
		 * <b>Note:</b> You must set the request's variables before calling load().
		 * 
		 */		
		public function load():void {
			this.socket.connect(this._host,this._port);
			this.socket.addEventListener(ProgressEvent.SOCKET_DATA,defaultDataHandler);			
		}
		
		/**
		 * The MultipartVariables object to use as the request's variables.
		 * @param variables
		 * 
		 */		
		public function set variables(variables:MultipartVariables):void {
			this._request.variables = variables;
		}
		
		/**
		 * The body part of the server's response, currently only text response is supported(not binary data). <br>
		 * This property will return <code>null</code> if read before the <code>COMPLETE</code> event is dispatched.
		 * @return 
		 * 
		 */		
		public function get responseBody():String {
			return((this._responseRecieved) ? new String(this._response.body) : null);
		}
		
		/**
		 * The raw server response string, currently only text response is supported(not binary data). <br>
		 * This property will return <code>null</code> if read before the <code>COMPLETE</code> event is dispatched.
		 * @return 
		 * 
		 */		
		public function get rawResponse():String {
			return((this._responseRecieved) ? new String(this._response.rawResponse) : null);
		}

		private function parseUrl(url:String):void {
			//TODO: validate the url via RegExp
			//var protocolRegExp:RegExp = new RegExp("^http://[a-zA-Z0-9]*.",'');
			if (url.indexOf("http://") == 0)
				url = url.slice(7);
			else
				throw new Error("Invalid url: " + url);
			var hostWithUser:String = (url.indexOf("/") != -1) ? url.slice(0,url.indexOf("/")) : url;
			this._path = (url.indexOf("/") != -1) ? url.slice(url.indexOf("/")) : '/';
			var hostWithPort:String = (hostWithUser.indexOf('@') != -1) ? hostWithUser.split('@')[1] : hostWithUser;
			this._host = (hostWithPort.indexOf(':') != -1) ? hostWithPort.split(':')[0] : hostWithPort;
			this._port = (hostWithPort.indexOf(':') != -1) ? int(hostWithPort.split(':')[1]) : 80;
			
			//trace("host: " + this._host, "port: " + this._port.toString(), "path: " + this._path)
		}
		
		private function registerDefaultEventHandlers():void {
			this.socket.addEventListener(Event.CONNECT,defaultConnectHandler);
			this.socket.addEventListener(Event.CLOSE,defaultCloseHandler);
			this.socket.addEventListener(IOErrorEvent.IO_ERROR,defaultIOErrorHandler);
			this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,defaultSecurityErrorHandler);
		}
		
		private function defaultConnectHandler(event:Event):void {
			trace("defaultConnectHandler");
			var request:ByteArray = this._request.constructRequest();
			request.position = 0;
			//trace("sent(" + request.bytesAvailable.toString() + "):\n" + request.readUTFBytes(request.bytesAvailable));
			this.socket.writeBytes(request);
		}
		
		private function defaultDataHandler(event:ProgressEvent):void {
			this._response.addChunk(Socket(event.target).readUTFBytes(event.target.bytesAvailable));
		}
		
		private function defaultCloseHandler(parent_event:Event):void {
			var event:Event = new Event(Event.CLOSE);
			this.dispatchEvent(event);
		}
		
		private function defaultIOErrorHandler(parent_event:IOErrorEvent):void {
			var event:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			this.dispatchEvent(event);
		}
		
		private function defaultSecurityErrorHandler(event:SecurityErrorEvent):void {
			this.dispatchEvent(event);
		}
		
		private function responseReceived(parent_event:Event):void {
			this._responseRecieved = true;
			var event:Event = new Event(Event.COMPLETE);
			this.dispatchEvent(event);
		}
	}
}