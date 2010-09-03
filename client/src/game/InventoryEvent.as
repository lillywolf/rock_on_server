package game
{
	import flash.events.Event;
	
	public class InventoryEvent extends Event
	{
		public static const ADDED_TO_INVENTORY:String = "Inventory:AddedToInventory";		
		public static const REMOVED_FROM_INVENTORY:String = "Inventory:RemovedFromInventory";
		
		public var item:Object;
		
		public function InventoryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}