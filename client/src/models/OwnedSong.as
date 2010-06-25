package models
{
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;
	
	public class OwnedSong extends EssentialModel
	{
		public var _user_id:int;
		public var _song_id:int;
		public var _band_id:int;
		public var _song:Song;
		
		public function OwnedSong(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			setProperties(params);
		}
		
		public function setProperties(params:Object):void
		{
			_user_id = params.user_id;
			_band_id = params.band_id;
			_song_id = params.song_id;
		}
		
		public function set song(val:Song):void
		{
			_song = val;
			var evt:DynamicEvent = new DynamicEvent('parentLoaded', true, true);
			evt.thinger = val;
			dispatchEvent(evt);
		}
		
		public function set user_id(val:int):void
		{
			_user_id = val;
		}
		
		public function get user_id():int
		{
			return _user_id;
		}
		
		public function set band_id(val:int):void
		{
			_band_id = val;
		}
		
		public function get band_id():int
		{
			return _band_id;
		}

		public function set song_id(val:int):void
		{
			_song_id = val;
		}
		
		public function get song_id():int
		{
			return _song_id;
		}
	}

	
}