package rock_on
{
	import flash.events.IEventDispatcher;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.events.DynamicEvent;

	public class Booth extends OwnedStructure
	{
		public static const STOCKED_STATE:int = 1;
		public static const UNSTOCKED_STATE:int = 2;
		
		public var queueCapacity:Number;
		public var currentQueue:Number;
		public var actualQueue:Number;
		public var proxiedQueue:ArrayCollection;
		public var hasCustomerEnRoute:Boolean;
		public var state:int;
				
		public function Booth(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			currentQueue = 0;	
			actualQueue = 0;
			proxiedQueue = new ArrayCollection();

			checkForLoadedStructure(params);
		}
		
		public function checkForLoadedStructure(params:Object):void
		{
			if (params['structure'])
			{
				structure = params.structure;
			}			
		}
		
		public function addToProxiedQueue(cp:CustomerPerson, pathLength:Number):void
		{
			var obj:Object = {cp: cp, pathLength: pathLength};
			proxiedQueue.addItem(obj);
		}
		
		public function removeFromProxedQueue(cp:CustomerPerson):void
		{
			for each (var obj:Object in proxiedQueue)
			{
				if (obj.cp == cp)
				{
					var index:int = proxiedQueue.getItemIndex(obj);
					proxiedQueue.removeItemAt(index);
				}
			}
		}
		
		public function getTotalInventory():int
		{
			var totalInventory:int = ContentIndex.setBoothInventoryByName(structure.name);
			return totalInventory;
		}
		
		public function advanceState(destinationState:int):void
		{
			switch (state)
			{	
				case STOCKED_STATE:
					endStockedState();				
					break;	
				case UNSTOCKED_STATE:
					endUnstockedState();
					break;						
				default: throw new Error('no state to advance from!');
			}
			switch (destinationState)
			{
				case STOCKED_STATE:
					startStockedState();
					break;
				case UNSTOCKED_STATE:
					startUnstockedState();
					break;
				default: throw new Error('no state to advance to!');	
			}
		}	
		
		public function endStockedState():void
		{
			
		}	
		
		public function startStockedState():void
		{
			state = STOCKED_STATE;
		}
		
		public function startUnstockedState():void
		{
			state = UNSTOCKED_STATE;
			var evt:DynamicEvent = new DynamicEvent("unStockedState", true, true);
			dispatchEvent(evt);
		}
		
		public function endUnstockedState():void
		{
			
		}
		
	}
}