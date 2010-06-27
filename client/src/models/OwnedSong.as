package models
{
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;
	
	public class OwnedSong extends EssentialModel
	{
		public var _id:int;
		public var _user_id:int;
		public var _song_id:int;
		public var _creature_group_id:int;
		public var _points_when_acquired:int;
		public var _song:Song;
		
		public function OwnedSong(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			setProperties(params);
		}
		
		public function setProperties(params:Object):void
		{
			_id = params.id;
			_user_id = params.user_id;
			_creature_group_id = params.creature_group_id;
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
		
		public function set creature_group_id(val:int):void
		{
			_creature_group_id = val;
		}
		
		public function get creature_group_id():int
		{
			return _creature_group_id;
		}

		public function set song_id(val:int):void
		{
			_song_id = val;
		}
		
		public function get song_id():int
		{
			return _song_id;
		}

		public function set points_when_acquired(val:int):void
		{
			_points_when_acquired = val;
		}
		
		public function get points_when_acquired():int
		{
			return _points_when_acquired;
		}
		
		public function get song():Song
		{
			return _song;
		}
		
		public function get id():int
		{
			return _id;
		}
	}

	
}