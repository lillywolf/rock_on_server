package multipart
{
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	public class MultipartRequest
	{
		
		private const CR:String = "\r";
		private const LF:String = "\n";
		private const EOL:String = CR + LF;
		private var _host:String;
		private var _variables:MultipartVariables;
		private var _boundary:String;
		private var _path:String;
		
		public function MultipartRequest(host:String,path:String) {
			this._variables = null;
			this._path = path;
			this._host = host;
		}
		
		public function set variables(variables:MultipartVariables):void {
			this._variables = variables;
		}
		
		public function constructRequest():ByteArray {
			if (this._variables == null)
				this._variables = new MultipartVariables();
			this._boundary = "gc0p4Jq0M2Yt08j34c0p"
			var body:ByteArray = constructRequestBody();
			var headers:ByteArray = constructRequestHeaders(body);
			var request:ByteArray = new ByteArray();
			request.writeBytes(headers);
			request.writeBytes(body);
			return(request);
		}
		
		private function constructRequestHeaders(body:ByteArray):ByteArray {
			var headers:ByteArray = new ByteArray();
			headers.writeMultiByte("POST " + this._path + " HTTP/1.1" + EOL,"utf-8");
			headers.writeMultiByte("Accept: */*" + EOL,"utf-8");
			headers.writeMultiByte("Content-Length: " + body.length + EOL,"utf-8");
			//headers.writeMultiByte("Content-Type: multipart/form-data; boundary=--" + this._boundary + EOL,"utf-8");
			headers.writeMultiByte("Content-Type: multipart/form-data; boundary=\"" + this._boundary + "\"" + EOL,"utf-8");
			headers.writeMultiByte("User-Agent: Shockwave Flash" + EOL,"utf-8");
			headers.writeMultiByte("Host: " + this._host + EOL,"utf-8");
			headers.writeMultiByte("Proxy-Connection: Keep-Alive" + EOL,"utf-8");
			headers.writeMultiByte(EOL,"utf-8");
			return(headers);
		}
		
		private function constructRequestBody():ByteArray {
			var body:ByteArray = new ByteArray();
			//trace("constructing body with vars:" + this._variables.variableNames);
			var isFirstField:Boolean = true;
			for each(var name:String in this._variables.variableNames) {
				//trace("adding " + name + " field to request");
				body.writeBytes(requestBodyField(name,this._variables.variables[name],isFirstField));
				isFirstField = false;
			}
			body.writeBytes(requestBodyCloseDelimiter(isFirstField));
			return(body);
		}
		
		private function requestBodyField(name:String,value:Object,isFirstField:Boolean = false):ByteArray {
			var field:ByteArray = new ByteArray();
			if (!isFirstField)
				field.writeMultiByte(EOL,"utf-8");
			field.writeMultiByte("--" + this._boundary + EOL,"utf-8");
			var test:Boolean = value.isPrototypeOf(String);
			if (getQualifiedClassName(value) == "String") {
				field.writeMultiByte("Content-Disposition: form-data; name=\"" + name +  "\"" + EOL,"utf-8");
				field.writeMultiByte(value + EOL,"utf-8");
			}
			if (getQualifiedClassName(value).search("ByteArray") != -1) {
				field.writeMultiByte("Content-Disposition: form-data; name=\"" + name +  "\"; filename=\"ruby.pdf\"" + EOL,"utf-8");
				field.writeMultiByte("Content-Type: application/octet-stream" + EOL,"utf-8");
				field.writeBytes(ByteArray(value));
			}
			return(field);
		}
		  
		private function requestBodyCloseDelimiter(SkipEOL:Boolean = false):ByteArray {
			var closeDelimiter:ByteArray = new ByteArray();
			if (!SkipEOL)
				closeDelimiter.writeMultiByte(EOL,"utf-8");
			closeDelimiter.writeMultiByte("--" + this._boundary + "--" + EOL,"utf-8");
			return(closeDelimiter);
		}
	}
}