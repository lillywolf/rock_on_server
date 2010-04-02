package models
{
	import flash.events.IEventDispatcher;

	public class OwnedThinger extends EssentialModel
	{
		public var _thinger_id:int;
		public var _id:int;
		public var _thinger:Thinger;
				
		public function OwnedThinger(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			_id = params.id;
			_thinger_id = params.thinger_id;			
		}

		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}

		public function set thinger(val:Thinger):void
		{
			_thinger = val;
		}
		
		public function get thinger():Thinger
		{
			return _thinger;
		}
		
		public function set thinger_id(val:int):void
		{
			_thinger_id = val;
		}
		
		public function get thinger_id():int
		{
			return _thinger_id;
		}		
		
	}
}