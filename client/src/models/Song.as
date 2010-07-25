package models
{
	import flash.events.IEventDispatcher;
	
	public class Song extends EssentialModel
	{
		public var _id:int;
		public var _title:String;
		public var _artist_name:String;
		public var _band_id:int;
		public var _genre:String;
		public var _artist_id:int;
		public var _points:int;
		
		public function Song(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			setProperties(params);
		}
		
		public function setProperties(params:Object):void
		{
			_id = params.id;
			_title = params.title;
			_artist_name = params.artist_name;
			_band_id = params.id;
			_genre = params.genre;
			_artist_id = params.artist_id;
			_points = params.points;
		}
		
		public function set title(val:String):void
		{
			_title = val;
		}
		
		public function get title():String
		{
			return _title;
		}
		
		public function set artist_name(val:String):void
		{
			_artist_name = val;
		}
		
		public function get artist_name():String
		{
			return _artist_name;
		}
		public function set genre(val:String):void
		{
			_genre = val;
		}
		
		public function get genre():String
		{
			return _genre;
		}
		
		public function set band_id(val:int):void
		{
			_band_id = val;
		}
		
		public function get band_id():int
		{
			return _band_id;
		}
		
		public function set points(val:int):void
		{
			_points = val;
		}
		
		public function get points():int
		{
			return _points;
		}
		
		public function set artist_id(val:int):void
		{
			_artist_id = val;
		}
		
		public function get artist_id():int
		{
			return _artist_id;
		}
		
		public function get id():int
		{
			return _id;
		}
	}
}