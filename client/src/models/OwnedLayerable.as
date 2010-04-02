package models
{
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;

	public class OwnedLayerable extends EssentialModel
	{
		public var _creature_id:int;
		public var _layerable_id:int;
		public var _id:int;
		public var _layerable:Layerable;
		public var _in_use:Boolean;
		public var _user_id:int;
		
		public function OwnedLayerable(params:Object, target:IEventDispatcher=null)
		{
			super(params, target);
			_id = params.id;
			_layerable_id = params.layerable_id;
			_creature_id = params.creature_id;
			_in_use = params.in_use;			
		}
		
		public function updateProperties(params:Object):void
		{
			_layerable_id = params.layerable_id;
			_creature_id = params.creature_id;
			_in_use = params.in_use;
		}

		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}

		public function set layerable(val:Layerable):void
		{
			_layerable = val;
			var evt:DynamicEvent = new DynamicEvent('parentLoaded', true, true);
			evt.thinger = val;
			dispatchEvent(evt);
		}
		
		public function get layerable():Layerable
		{
			return _layerable;
		}
		
		public function set in_use(val:Boolean):void
		{
			_in_use = val;
		}
		
		public function get in_use():Boolean
		{
			return _in_use;
		}		
		
		public function set layerable_id(val:int):void
		{
			_layerable_id = val;
		}
		
		public function get layerable_id():int
		{
			return _layerable_id;
		}

		public function set creature_id(val:int):void
		{
			_creature_id = val;
		}
		
		public function get creature_id():int
		{
			return _creature_id;
		}	
		
		public function set user_id(val:int):void
		{
			_user_id = val;
		}	
	}
}