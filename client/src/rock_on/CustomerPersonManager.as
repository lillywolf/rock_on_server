package rock_on
{
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.FlexGlobals;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class CustomerPersonManager extends ArrayCollection
	{	
		private var _myWorld:World;
		private var _concertStage:ConcertStage;
		private var _venue:Venue;
		public var customerCreatures:ArrayCollection;
		
		public function CustomerPersonManager(myWorld:World, venue:Venue, source:Array=null)
		{
			super(source);
			_venue = venue;
			_myWorld = myWorld;
			_myWorld.addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);				
			_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDestinationReached);			
		}
		
		public function addConvertedFan(cp:CustomerPerson, startPoint:Point3D, fanIndex:int):void
		{
			if (_myWorld)
			{
				cp.myWorld = _myWorld;
				cp.venue = _venue;
				cp.speed = 0.11;
				addEventListeners(cp);
				addItem(cp);
				_myWorld.addAsset(cp, startPoint);
				cp.timedConversion(fanIndex);
			}
		}
		
		public function add(cp:CustomerPerson, isMoving:Boolean=false, seatNumber:int=-1, bounds:Rectangle=null, avoid:Rectangle=null, worldToUpdate:World=null):void
		{
			if(_myWorld)
			{			
				cp.myWorld = _myWorld;
				if (isMoving)
				{
					addToWorldAsMoving(cp, bounds, avoid, worldToUpdate);
				}
				else
				{
					addToWorld(cp, seatNumber);				
				}
				
				addEventListeners(cp);
				cp.advanceState(CustomerPerson.ENTHRALLED_STATE);
			}
			else
			{
				throw new Error("you have to fill your pool before you dive");
			}
		}
		
		public function addAfterInitializing(cp:CustomerPerson):void
		{
			if (_myWorld)
			{
				remove(cp);
				cp.lastWorldPoint = null;
				cp.worldCoords = null;
				cp.proxiedDestination = null;
				cp.reInitialize();
				add(cp, true, -1, cp.venue.boothsRect, null, cp.myWorld);
//				cp.advanceState(CustomerPerson.ENTHRALLED_STATE);
			}
		}
		
		private function addToWorldAsMoving(cp:CustomerPerson, bounds:Rectangle, avoid:Rectangle=null, worldToUpdate:World=null):void
		{
			cp.venue = _venue;
			var destination:Point3D = cp.pickPointNearStructure(bounds, avoid, worldToUpdate);
			if (worldToUpdate)
			{
				worldToUpdate.addAsset(cp, destination);
			}
			else
			{
				_myWorld.addAsset(cp, destination);			
			}
			this.addItem(cp);			
		}
				
		private function addToWorld(cp:CustomerPerson, seatNumber:int = -1):void
		{
			cp.venue = _venue;
			cp.isBitmapped = true;
			var destination:Point3D;
			if (seatNumber != -1)
			{
				destination = _venue.assignedSeats[seatNumber];
				_venue.numAssignedSeats++;
			}
			else
			{
				destination = cp.pickPointNearStructure(_venue.mainCrowdRect);			
			}
			cp.worldCoords = destination;
			var standAnimation:Object = cp.standFacingObject(_concertStage, 0, true);
			_myWorld.addStaticBitmap(cp, destination, standAnimation.animation, standAnimation.frameNumber, standAnimation.reflection);
//			_myWorld.addAsset(cp, destination);
			this.addItem(cp);
		}	
		
		private function addEventListeners(cp:CustomerPerson):void
		{
			if (!cp.hasEventListener("customerRouted"))
			{
				cp.addEventListener("customerRouted", onCustomerRouted);			
			}
			if (!cp.hasEventListener("queueDecremented"))
			{
				cp.addEventListener("queueDecremented", decrementQueue);						
			}
		}
		
		private function decrementQueue(evt:DynamicEvent):void
		{
			var booth:Booth = evt.booth;
			updateQueuedCustomers(booth, evt.person);
			updateRoutedCustomers(booth);
			validateBoothPositions(booth);			
		}
		
		private function onCustomerRouted(evt:DynamicEvent):void
		{
			updateRoutedCustomers(evt.booth);	
			validateBoothPositions(evt.booth);					
		}
		
		private function updateBoothPosition(customer:CustomerPerson, index:int):void
		{
			if (customer.state == CustomerPerson.ROUTE_STATE)
			{
				customer.setQueuedPosition(customer.currentBooth.actualQueue + index);			
			}
			else if (customer.state == CustomerPerson.QUEUED_STATE)
			{
				customer.setQueuedPosition(index);
			}
		}
		
		private function validateBoothPositions(booth:Booth):void
		{
			for each (var cp:CustomerPerson in this)
			{
				for each (var cp2:CustomerPerson in this)
				{
					if (cp.currentBooth == booth && cp2.currentBooth == booth && cp != cp2 && cp.currentBoothPosition == cp2.currentBoothPosition)
					{
//						throw new Error("Houston, we have a problem");
					}
				}
			}			
		}
		
		private function updateQueuedCustomers(booth:Booth, excludePerson:CustomerPerson):void
		{
			var proxiedCustomers:ArrayCollection = new ArrayCollection();
			for each (var cp:CustomerPerson in this)
			{
				if (cp.currentBooth == booth && cp.state == CustomerPerson.QUEUED_STATE && cp != excludePerson)
				{
					var pathLength:int = cp.getPathToBoothLength(false, true);
					proxiedCustomers.addItem({cp: cp, pathLength: pathLength});
				}				
			}
			proxiedCustomers = sortProxiedCustomers(proxiedCustomers);
			updateProxiedCustomers(proxiedCustomers);			
		}
		
		private function updateRoutedCustomers(booth:Booth):void
		{
			var proxiedCustomers:ArrayCollection = new ArrayCollection();			
			for each (var cp:CustomerPerson in this)
			{
				if (cp.currentBooth == booth && cp.state == CustomerPerson.ROUTE_STATE)
				{
					var pathLength:int = cp.getPathToBoothLength(true, false);
					if (pathLength)
						proxiedCustomers.addItem({cp: cp, pathLength: pathLength});
					else
						cp.advanceState(CustomerPerson.ROAM_STATE);
				}
			}			
			proxiedCustomers = sortProxiedCustomers(proxiedCustomers);
			updateProxiedCustomers(proxiedCustomers);
		}
		
		private function sortProxiedCustomers(proxiedCustomers:ArrayCollection):ArrayCollection
		{
			var sortField:SortField = new SortField("pathLength");
			sortField.numeric = true;
			var numericSort:Sort = new Sort();
			numericSort.fields = [sortField];
			proxiedCustomers.sort = numericSort;
			proxiedCustomers.refresh();
			return proxiedCustomers;
		}
		
		private function updateProxiedCustomers(proxiedCustomers:ArrayCollection):void
		{
			var i:int = 0;
			for each (var obj:Object in proxiedCustomers)
			{
				var cp:CustomerPerson = obj.cp;
				updateBoothPosition(cp, i+1);
				cp.updateBoothFront(i);
				i++;				
			}
		}
		
		private function onFinalDestinationReached(evt:WorldEvent):void
		{
			if (evt.activeAsset is CustomerPerson)
			{
				var cp:CustomerPerson = evt.activeAsset as CustomerPerson;
				if (cp.state == CustomerPerson.ROUTE_STATE)
					cp.isCustomerAtQueue();
				else if (cp.state == CustomerPerson.QUEUED_STATE)
				{
					cp.checkIfFrontOfQueue();	
					cp.standFacingObject(cp.currentBooth);
				}
				else if (cp.state == CustomerPerson.HEADTOSTAGE_STATE)
					cp.advanceState(CustomerPerson.BITMAPPED_ENTHRALLED_STATE);
				else if (cp.state == CustomerPerson.ENTHRALLED_STATE)
				{
					
				}
				else if (cp.state == CustomerPerson.HEADTODOOR_STATE)
					cp.advanceState(CustomerPerson.HEADTOSTAGE_STATE);
				else if (cp.state == CustomerPerson.ROAM_STATE)
					cp.advanceState(CustomerPerson.ENTHRALLED_STATE);
				else
					throw new Error("This doesn't really make sense");
			}
		}
		
		public function update(deltaTime:Number):void
		{			
			for each (var person:CustomerPerson in this)
			{
				if (person.update(deltaTime))
				{		
					remove(person);							
				}
				else 
				{
				}
			}
		}
		
		public function removeCustomers():void
		{
			var cpLength:int = length;
			for (var i:int = (cpLength - 1); i >= 0; i--)				
			{
				var cp:CustomerPerson = this[i] as CustomerPerson;
				remove(cp);
			}
		}
		
		public function remove(cp:CustomerPerson):void
		{
			if(_myWorld)
			{
				_myWorld.removeAsset(cp);
				var personIndex:Number = getItemIndex(cp);
				removeItemAt(personIndex);
			}
			else 
			{
				throw new Error("how the hell did this happen?");
			}
		}
		
		public function redrawAllCustomers():void
		{
			var cpLength:int = length;
			for (var i:int = (cpLength - 1); i >= 0; i--)
			{
				var cp:CustomerPerson = this[i] as CustomerPerson;
				remove(cp);				
				addAfterInitializing(cp);				
			}
		}
		
		public function redrawStandAloneCustomers():void
		{
			var i:int = 0;
			var toRemove:ArrayCollection = new ArrayCollection();
			for each (var cp:CustomerPerson in this)
			{
				if (!cp.isBitmapped && !cp.isSuperFan)
				{
					toRemove.addItem(cp);
					i++;
				}
			}
			for each (cp in toRemove)
			{
				remove(cp);				
				addAfterInitializing(cp);	
			}
			trace(i.toString());
		}
		
		public function removeAllCustomers():void
		{
			for each (var cp:CustomerPerson in this)
			{
				remove(cp);
			}
		}		
		
		private function onDirectionChanged(evt:WorldEvent):void
		{
			for each (var asset:ActiveAsset in this)
			{
				if (evt.activeAsset == asset)
				{
					var nextPoint:Point3D = (asset as CustomerPerson).getNextPointAlongPath();
					(asset as CustomerPerson).setDirection(nextPoint);
				}
			}
		}		
		
		public function removeBoothFromAvailable(booth:Booth):void
		{
			for each (var cp:CustomerPerson in this)
			{
				if (cp.currentBooth == booth)
				{
					cp.advanceState(CustomerPerson.ROAM_STATE);
				}
			}
		}
						
		public function set myWorld(val:World):void
		{
			if(!_myWorld)
			{
				_myWorld = val;
				_myWorld.addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);				
				_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDestinationReached);
			}
			else
			{
				throw new Error("Don't change this!!");				
			}
		}		
		
		public function get myWorld():World
		{
			return _myWorld;
		}		
				
		public function set concertStage(val:ConcertStage):void
		{
			if(!_concertStage)
				_concertStage = val;
			else
				throw new Error("Don't change this!!");
		}
		
		public function get concertStage():ConcertStage
		{
			return _concertStage;
		}		
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}	
		
	}
}