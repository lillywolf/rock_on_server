package multipart
{
	public class MultipartResponseHeader
	{
		private var _key:String;
		private var _value:String;
		public function MultipartResponseHeader(key:String,value:String,readOnly:Boolean=true) {
			this._key = key;
			this._value = value;
		}
		
		public function get key():String{
			return(this._key);
		}
		
		public function get value():String{
			return(this._value);
		}
	}
}