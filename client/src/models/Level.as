package models
{
	import flash.events.IEventDispatcher;

	public class Level extends EssentialModel
	{
		public var _id:int;
		public var _order:int;
		public var _xp_diff:int;
		public var _dwelling_expansion_x:int;
		public var _dwelling_expansion_y:int;
		public var _dwelling_expansion_z:int;
		public var _user:User;
		
		public function Level(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			setProperties(params);
		}
		
		private function setProperties(params:Object):void
		{
			_id = params.id;
			_order = params.order;
			_xp_diff = params.xp_diff;
			_dwelling_expansion_x = params.dwelling_expansion_x;
			_dwelling_expansion_y = params.dwelling_expansion_y;
			_dwelling_expansion_z = params.dwelling_expansion_z;
		}
		
		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}
				
		public function set order(val:int):void
		{
			_order = val;
		}
		
		public function get order():int
		{
			return _order;
		}	
			
		public function set xp_diff(val:int):void
		{
			_xp_diff = val;
		}
		
		public function get xp_diff():int
		{
			return _xp_diff;
		}
				
		public function set dwelling_expansion_z(val:int):void
		{
			_dwelling_expansion_z = val;
		}
		
		public function get dwelling_expansion_z():int
		{
			return _dwelling_expansion_z;
		}		
		
		public function set dwelling_expansion_y(val:int):void
		{
			_dwelling_expansion_y = val;
		}
		
		public function get dwelling_expansion_y():int
		{
			return _dwelling_expansion_y;
		}	
			
		public function set dwelling_expansion_x(val:int):void
		{
			_dwelling_expansion_x = val;
		}
		
		public function get dwelling_expansion_x():int
		{
			return _dwelling_expansion_x;
		}		
		
		public function set user(val:User):void
		{
			_user = val;
		}
		
	}
}