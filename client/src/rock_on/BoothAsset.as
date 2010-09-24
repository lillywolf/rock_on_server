package rock_on
{
	import clickhandlers.UIBoss;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import game.GameClock;
	
	import models.Creature;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	
	import views.WorldView;
	
	import world.ActiveAssetStack;
	
	public class BoothAsset extends ActiveAssetStack
	{
		public static const STOCKED_STATE:int = 1;
		public static const UNSTOCKED_STATE:int = 2;
		
		public var currentQueue:Number;
		public var actualQueue:Number;
		public var proxiedQueue:ArrayCollection;
		public var hasCustomerEnRoute:Boolean;
		public var state:int;
		public var friendMirror:Boolean;
		
		public var _boothBoss:BoothBoss;
		[Bindable] public var _venue:Venue;		
		
		public function BoothAsset(boothBoss:BoothBoss, venue:Venue, creature:Creature, movieClip:MovieClip=null, layerableOrder:Array=null, scale:Number=1)
		{
			super(creature, movieClip, layerableOrder, scale);
			
			_boothBoss = boothBoss;
			_venue = venue;	
			
			currentQueue = 0;
			actualQueue = 0;
			proxiedQueue = new ArrayCollection();			
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
		
		public function checkInventoryCount():void
		{
			var newFrameNumber:int = getCurrentFrameNumber();
			if (newFrameNumber != this.currentFrameNumber)
			{
				this.currentFrameNumber = newFrameNumber;
				this.bitmapWithToppers();
			}
		}
		
		public function startStockedState():void
		{			
			state = STOCKED_STATE;
			(this.thinger as Booth).structure.mc.stop()
			this.currentFrameNumber = getCurrentFrameNumber();
			this.bitmapWithToppers();
		}
		
		public function startUnstockedState():void
		{
			state = UNSTOCKED_STATE;
			
			if (!friendMirror)
			{
//				_boothBoss.addBoothCollectionButton(this);
				var evt:VenueEvent = new VenueEvent(VenueEvent.BOOTH_UNSTOCKED, true, true);
				evt.venue = _venue;
				evt.booth = this;
				_venue.dispatchEvent(evt);	
			}
			
			this.addEventListener(MouseEvent.CLICK, onCollectionClick);
		}
		
		private function onCollectionClick(evt:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.CLICK, onCollectionClick);
			_venue.structureController.serverController.sendRequest({id: this.thinger.id}, "owned_structure", "add_booth_credits");
			UIBoss.createCollectible(new CoinsLeftover(), _venue.myWorld.getAssetFromOwnedStructure(this.thinger as OwnedStructure), _venue.myWorld);
		}
		
		public function endUnstockedState():void
		{
			
		}		
		
		public function getCurrentFrameNumber(booth:Booth=null):int
		{
			var rotated:int = 0;
			if (!booth)
				booth = this.thinger as Booth;
			if (booth.rotation == 1 || booth.rotation == 2)
				rotated = 1;
			if (booth.inventory_count / booth.structure.booth_structure.inventory_capacity > 2/3)
				return 7 + rotated;
			else if (booth.inventory_count / booth.structure.booth_structure.inventory_capacity > 1/3)
				return 5 + rotated;
			else if (booth.inventory_count / booth.structure.booth_structure.inventory_capacity > 0)
				return 3 + rotated;
			else
				return 1 + rotated;
		}
		
		public function updateState():void
		{
			if ((this.thinger as OwnedStructure).inventory_count > 0)
			{
				if (state != STOCKED_STATE)
					startStockedState();				
			}
			else
			{
				if (state != UNSTOCKED_STATE)
					startUnstockedState();				
			}			
		}
		
		public function updateInventoryCount():void
		{
			if (state == STOCKED_STATE)
			{
				var fanCount:int = _venue.fancount;
				var averagePurchaseTime:int = (CustomerPerson.ENTHRALLED_TIME + CustomerPerson.QUEUED_TIME + 
					(_venue.myWorld.tilesWide / (WorldView.PERSON_SPEED * 50) * 1000))/1000;
				var updatedAt:int = GameClock.convertStringTimeToUnixTime((this.thinger as OwnedStructure).updated_at);
				var currentDate:Date = new Date();	
				var currentTime:int = currentDate.getTime()/1000 + (currentDate.getTimezoneOffset() * 60);
				var timeElapsed:int = currentTime - updatedAt;
				var numPurchases:int = (timeElapsed / averagePurchaseTime) * fanCount;
				
				if (numPurchases > (this.thinger as OwnedStructure).inventory_count)
				{
					_boothBoss.decreaseInventoryCount(this.thinger as Booth, (this.thinger as Booth).inventory_count);
					(this.thinger as OwnedStructure).inventory_count = 0;
				}
				else
				{
					(this.thinger as OwnedStructure).inventory_count = (this.thinger as OwnedStructure).inventory_count - numPurchases;
					_boothBoss.decreaseInventoryCount(this.thinger as Booth, numPurchases);
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