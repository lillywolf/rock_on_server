package models
{
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;

	public class OwnedDwelling extends EssentialModel
	{
		public var _id:int;
		public var _user_id:int;
		public var _fancount:int;
		public var _last_showtime:String;
		public var _current_city:String;
		public var _dwelling:Dwelling;
		public var _dwelling_id:int;
		public var _created_at:String;
				
		public function OwnedDwelling(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			_id = params.id;
			updateProperties(params);			
		}
		
		public function updateProperties(params:Object):void
		{
			_dwelling_id = params.dwelling_id;
			_created_at = params.created_at;
			
			if (params.last_showtime)
			{
				_last_showtime = params.last_showtime;
			}
			else
			{
				throw new Error("No previous show time in listing");
			}
			
			setExtraProperties(params);
		}		

		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}

		public function set dwelling(val:Dwelling):void
		{
			_dwelling = val;
			var evt:DynamicEvent = new DynamicEvent('parentLoaded', true, true);
			evt.thinger = val;
			dispatchEvent(evt);
			
			if (_dwelling['mc'] != null)
			{
				var event:DynamicEvent = new DynamicEvent('parentMovieClipAssigned', true, true);
				dispatchEvent(event);
			}
			else
			{
				_dwelling.addEventListener('movieClipLoaded', onDwellingMovieClipAssigned);	
			}
		}
		
		private function setExtraProperties(params:Object):void
		{		
			if (params.fancount)
			{
				_fancount = params.fancount;
			}
		}
		
		private function onDwellingMovieClipAssigned(evt:DynamicEvent):void
		{
			_dwelling.removeEventListener('movieClipLoaded', onDwellingMovieClipAssigned);
			var evt:DynamicEvent = new DynamicEvent('parentMovieClipAssigned', true, true);
			dispatchEvent(evt);
		}
		
		public function get dwelling():Dwelling
		{
			return _dwelling;
		}
		
		public function set dwelling_id(val:int):void
		{
			_dwelling_id = val;
		}
		
		public function get dwelling_id():int
		{
			return _dwelling_id;
		}	
		
		public function set last_showtime(val:String):void
		{
			_last_showtime = val;
		}
		
		public function get last_showtime():String
		{
			return _last_showtime;
		}	
			
		public function set created_at(val:String):void
		{
			_created_at = val;
		}
		
		public function get created_at():String
		{
			return _created_at;
		}	
			
		public function set fancount(val:int):void
		{
			_fancount = val;
		}
		
		public function get fancount():int
		{
			return _fancount;
		}		
		
		public function set user_id(val:int):void
		{
			_user_id = val;
		}		
		
	}
}