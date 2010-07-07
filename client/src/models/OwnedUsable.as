package models
{
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;
	
	public class OwnedUsable extends EssentialModel
	{
		public var _id:int;
		public var _user_id:int;
		public var _usable_id:int;
		public var _usable:Usable;
		public var _created_at:String;
		
		public function OwnedUsable(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			_id = params.id;
			_user_id = params.user_id;
			_usable_id = params.usable_id;
			_created_at = params.created_at;
			
			if (params.usable)
			{
				_usable = params.usable;
			}			
		}
		
		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set user_id(val:int):void
		{
			_user_id = val;
		}
		
		public function get user_id():int
		{
			return _user_id;
		}
		
		public function set usable_id(val:int):void
		{
			_usable_id = val;
		}
		
		public function get usable_id():int
		{
			return _usable_id;
		}
		
		public function set usable(val:Usable):void
		{
			_usable = val;
			var evt:DynamicEvent = new DynamicEvent("parentLoaded", true, true);
			evt.thinger = val;
			dispatchEvent(evt);
			
			if (_usable["mc"] != null)
			{
				var event:DynamicEvent = new DynamicEvent("parentMovieClipAssigned", true, true);
				dispatchEvent(event);
			}
			else
			{
				_usable.addEventListener("movieClipLoaded", onUsableMovieClipAssigned);	
			}			
		}
		
		public function get usable():Usable
		{
			return _usable;
		}
		
		private function onUsableMovieClipAssigned(evt:DynamicEvent):void
		{
			_usable.removeEventListener("movieClipLoaded", onUsableMovieClipAssigned);
			var evt:DynamicEvent = new DynamicEvent("parentMovieClipAssigned", true, true);
			dispatchEvent(evt);
		}		
	}
}