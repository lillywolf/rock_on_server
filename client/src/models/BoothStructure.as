package models
{
	import flash.events.IEventDispatcher;

	public class BoothStructure extends EssentialModel
	{
		public var _id:int;
		public var _inventory_capacity:int;
		public var _item_price:int;
		public var _structure_id:int;		
		
		public function BoothStructure(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			_id = params.id;
			_item_price = params.item_price;
			_inventory_capacity = params.inventory_capacity;
		}

		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set structure_id(val:int):void
		{
			_structure_id = val;
		}
		
		public function get structure_id():int
		{
			return _structure_id;
		}
		
		public function set item_price(val:int):void
		{
			_item_price = val;
		}
		
		public function get item_price():int
		{
			return _item_price;
		}
		
		public function set inventory_capacity(val:int):void
		{
			_inventory_capacity = val;
		}
		
		public function get inventory_capacity():int
		{
			return _inventory_capacity;
		}
		
	}
}