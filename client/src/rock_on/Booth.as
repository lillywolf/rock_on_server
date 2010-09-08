package rock_on
{
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	
	import game.GameClock;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.events.DynamicEvent;
	
	import views.WorldView;

	public class Booth extends OwnedStructure
	{
		public static const STOCKED_STATE:int = 1;
		public static const UNSTOCKED_STATE:int = 2;
		
		public var collectionButton:SpecialButton;
		public var queueCapacity:Number;
		public var currentQueue:Number;
		public var actualQueue:Number;
		public var proxiedQueue:ArrayCollection;
		public var hasCustomerEnRoute:Boolean;
		public var state:int;
		public var friendMirror:Boolean;
		public var editMirror:Boolean;
		
		public var _boothBoss:BoothBoss;
		[Bindable] public var _venue:Venue;
				
		public function Booth(boothBoss:BoothBoss, venue:Venue, params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			
			_boothBoss = boothBoss;
			_venue = venue;
			
			currentQueue = 0;	
			actualQueue = 0;
			proxiedQueue = new ArrayCollection();

			checkForLoadedStructure(params);
		}
		
		public function checkForLoadedStructure(params:Object):void
		{
			if (params['structure'])
				structure = params.structure;
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
//			structure.mc.gotoAndPlay(5);
			structure.mc.stop();
		}
		
		public function startUnstockedState():void
		{
			state = UNSTOCKED_STATE;
			
			if (!friendMirror)
			{
				_boothBoss.addBoothCollectionButton(this);
				var evt:VenueEvent = new VenueEvent(VenueEvent.BOOTH_UNSTOCKED, true, true);
				evt.venue = _venue;
				evt.booth = this;
				_venue.dispatchEvent(evt);	
			}
		}
		
		public function endUnstockedState():void
		{
//			if (collectionButton)
//			{
//				var btnParent:DisplayObjectContainer = collectionButton.parent;
//				btnParent.removeChild(collectionButton);
//			}
		}		
		
		public function updateState():void
		{
			if (inventory_count > 0)
			{
				if (state != STOCKED_STATE)
					startStockedState();				
			}
			else
			{
				if (state != UNSTOCKED_STATE)
					startUnstockedState();				
			}
			
			updateInventoryCount();
		}
		
		public function updateInventoryCount():void
		{
			if (state == STOCKED_STATE)
			{
				var fanCount:int = _venue.fancount;
				var averagePurchaseTime:int = (CustomerPerson.ENTHRALLED_TIME + CustomerPerson.QUEUED_TIME + 
					(_venue.myWorld.tilesWide / (WorldView.PERSON_SPEED * 50) * 1000))/1000;
				var updatedAt:int = GameClock.convertStringTimeToUnixTime(updated_at);
				var currentDate:Date = new Date();	
				var currentTime:int = currentDate.getTime()/1000 + (currentDate.getTimezoneOffset() * 60);
				var timeElapsed:int = currentTime - updatedAt;
				var numPurchases:int = (timeElapsed / averagePurchaseTime) * fanCount;
							
				if (numPurchases > inventory_count)
				{
					_boothBoss.decreaseInventoryCount(this, inventory_count);
					inventory_count = 0;
				}
				else
				{
					inventory_count = inventory_count - numPurchases;
					_boothBoss.decreaseInventoryCount(this, numPurchases);
				}
			}
		}
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}
		
		public function get boothBoss():BoothBoss
		{
			return _boothBoss;
		}
		
	}
}