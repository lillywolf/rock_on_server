package models
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	
	public class StoreOwnedThinger extends EssentialModel
	{
		public var _id:int;
		public var _store_id:int;
		public var _store:Store;
		public var _price:int;
		public var _premium_price:int;
		
		public var _layerable_id:int;
		public var _layerable:Layerable;
		public var _structure_id:int;
		public var _structure:Structure;
		public var _usable_id:int;
		public var _usable:Usable;
		public var _mc:MovieClip;
		
		public function StoreOwnedThinger(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			_id = params.id;		
		}
		
		public function setMovieClip():void
		{
			if (layerable)
			{
				_mc = layerable.mc;
			}
		}
		
		public function getMovieClip():MovieClip
		{
			if (layerable)
			{
				var newMC:MovieClip = new MovieClip();
				newMC = layerable.mc;
				return newMC;
			}
			return null;
		}

		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}
						
		public function set store_id(val:int):void
		{
			_store_id = val;
		}
		
		public function get store_id():int
		{
			return _store_id;
		}
			
		public function set layerable_id(val:int):void
		{
			_layerable_id = val;
		}
		
		public function get layerable_id():int
		{
			return _layerable_id;
		}	
		
		public function set store(val:Store):void
		{
			_store = val;
		}			
		
		public function get store():Store
		{
			return _store;
		}
		
		public function set layerable(val:Layerable):void
		{
			_layerable = val;
		}
		
		public function get layerable():Layerable
		{
			return _layerable;
		}
		
		public function set structure(val:Structure):void
		{
			_structure = val;
		}
		
		public function get structure():Structure
		{
			return _structure;
		}
		
		public function set usable(val:Usable):void
		{
			_usable = val;
		}
		
		public function get usable():Usable
		{
			return _usable;
		}
		
		public function set price(val:int):void
		{
			_price = val;
		}
		
		public function get price():int
		{
			return _price;
		}
		
		public function set premium_price(val:int):void
		{
			premium_price = val;
		}
		
		public function get premium_price():int
		{
			return premium_price;
		}
		
	}
}