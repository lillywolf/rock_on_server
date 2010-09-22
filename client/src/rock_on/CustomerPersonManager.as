package rock_on
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import models.Creature;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.FlexGlobals;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import views.BouncyBitmap;
	import views.VenueManager;
	
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
		public var toExit:ArrayCollection;
		public var toMove:ArrayCollection;
		public var exitWaitTimer:Timer;
		public var replaceWaitTimer:Timer;
		
		public static const EXIT_WAIT_TIME_CONSTANT:int = 1000;
		public static const EXIT_WAIT_TIME_MULTIPLIER:int = 0;
		public static const REPLACE_WAIT_TIME_CONSTANT:int = 1100;
		
		public function CustomerPersonManager(myWorld:World, venue:Venue, source:Array=null)
		{
			super(source);
			_venue = venue;
			_myWorld = myWorld;
			_myWorld.addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);				
			_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDestinationReached);	
			addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);			
		}
		
		private function onCollectionChange(evt:CollectionEvent):void
		{
			setEnthralledTime(this.length);
		}
		
		public function setEnthralledTime(fancount:int):void
		{
			CustomerPerson.ENTHRALLED_TIME = 200000 + fancount * 3000;
		}
		
		public function startQueueTimersForCustomers():void
		{
			for each (var cp:CustomerPerson in this)
			{
				cp.initializeForQueueing();
			}
		}
		
		public function addConvertedCustomer(c:Creature, startPoint:Point3D, fanIndex:int):void
		{
			if (_myWorld)
			{
				var cp:CustomerPerson = createConvertedCustomer(c);
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
				if (isMoving)
					addMovingCustomerToWorld(cp, bounds, avoid, worldToUpdate);
				else
					addSeatedCustomerToWorld(cp, seatNumber);				
				
				addEventListeners(cp);
				addItem(cp);
			}
			else
				throw new Error("you have to fill your pool before you dive");
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
			}
		}
		
		private function addMovingCustomerToWorld(cp:CustomerPerson, bounds:Rectangle, avoid:Rectangle=null, worldToUpdate:World=null):void
		{
			var destination:Point3D = cp.pickPointNearStructure(bounds, avoid, worldToUpdate);
			if (worldToUpdate)
				worldToUpdate.addAsset(cp, destination);
			else
				_myWorld.addAsset(cp, destination);			
		}
				
		private function addSeatedCustomerToWorld(cp:CustomerPerson, seatNumber:int = -1):void
		{
			var destination:Point3D;
			if (seatNumber != -1)
			{
				destination = _venue.assignedSeats[seatNumber];
				_venue.numAssignedSeats++;
				cp.seatNumber = seatNumber;
			}
			else
				destination = cp.pickPointNearStructure(_venue.mainCrowdRect);			
//			var standAnimation:Object = cp.standFacingObject(_concertStage, 0, true);
			_myWorld.addAsset(cp, destination);
		}	
		
		private function addEventListeners(cp:CustomerPerson):void
		{
			if (!cp.hasEventListener("customerRouted"))
				cp.addEventListener("customerRouted", onCustomerRouted);			
			if (!cp.hasEventListener("queueDecremented"))
				cp.addEventListener("queueDecremented", decrementQueue);	
		}
		
		private function decrementQueue(evt:DynamicEvent):void
		{
			var booth:BoothAsset = evt.booth;
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
				customer.setQueuedPosition(customer.currentBooth.actualQueue + index);			
			else if (customer.state == CustomerPerson.QUEUED_STATE)
				customer.setQueuedPosition(index);
		}
		
		private function validateBoothPositions(booth:BoothAsset):void
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
		
		private function updateQueuedCustomers(booth:BoothAsset, excludePerson:CustomerPerson):void
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
		
		private function updateRoutedCustomers(booth:BoothAsset):void
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
		
		public function setEssentialVariables(cp:CustomerPerson):void
		{
			cp.stageManager = _venue.stageManager;
			cp.venue = _venue;
			cp.myWorld = _myWorld;
		}
		
		public function createSuperCustomer(c:Creature, addToWorld:World):CustomerPerson
		{
			var cp:CustomerPerson = createCustomer(c, Person.SUPER, 0.11, 0.5);
			add(cp, true, -1, _venue.stageBufferRect, _venue.stageRect, addToWorld);
			cp.advanceState(CustomerPerson.HEAD_BOB_STATE);	
			return cp;
		}
		
		public function createStaticCustomer(c:Creature, seatNumber:int=-1):CustomerPerson
		{
			var cp:CustomerPerson = createCustomer(c, Person.STATIC, 0.11, 0.5);
			add(cp, false, seatNumber);
			return cp;
		}
		
		public function createMovingCustomer(c:Creature):CustomerPerson
		{
			var cp:CustomerPerson = createCustomer(c, Person.MOVING, 0.11, 0.5);
			add(cp, true, -1, _venue.boothsRect);
			return cp;
		}

		public function createConvertedCustomer(c:Creature):CustomerPerson
		{
			var cp:CustomerPerson;
			if (Math.random() < VenueManager.STATIC_CUSTOMER_FRACTION)
				cp = createCustomer(c, Person.STATIC, 0.11, 0.5);
			else
				cp = createCustomer(c, Person.MOVING, 0.11, 0.5);
			return cp;
		}
		
		public function createCustomer(c:Creature, moveType:int, speed:Number, scale:Number):CustomerPerson
		{
			var cp:CustomerPerson = new CustomerPerson(_venue.boothBoss, c, null, c.layerableOrder, scale);
			cp.personType = moveType;
			cp.speed = speed;
			cp.thinger = c;
			setEssentialVariables(cp);
			return cp;
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
		
		public function assignNextState(cp:CustomerPerson):void
		{
			if (cp.state == CustomerPerson.QUEUED_STATE || cp.state== CustomerPerson.ROUTE_STATE)
			{
				if (Math.random() < VenueManager.STATIC_CUSTOMER_FRACTION)
				{
					cp.personType = Person.STATIC;
					cp.advanceState(CustomerPerson.HEADTOSTAGE_STATE);
				}
				else
				{
					cp.personType = Person.MOVING;
					cp.advanceState(CustomerPerson.ROAM_STATE);
				}
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
					cp.standFacingObject(cp.currentBooth.thinger as OwnedStructure);
				}
				else if (cp.state == CustomerPerson.HEADTOSTAGE_STATE)
					cp.advanceState(CustomerPerson.ENTHRALLED_STATE);
				else if (cp.state == CustomerPerson.DIRECTED_STATE)
					cp.advanceState(CustomerPerson.ENTHRALLED_STATE);
				else if (cp.state == CustomerPerson.ENTHRALLED_STATE)
				{
					
				}
				else if (cp.state == CustomerPerson.TEMPORARY_ENTHRALLED_STATE)
				{
					
				}
				else if (cp.state == CustomerPerson.HEADTODOOR_STATE)
					cp.advanceState(CustomerPerson.HEADTOSTAGE_STATE);
				else if (cp.state == CustomerPerson.ROAM_STATE)
					cp.advanceState(CustomerPerson.TEMPORARY_ENTHRALLED_STATE);
				else if (cp.state == CustomerPerson.EXIT_STATE)
				{
					cp.advanceState(CustomerPerson.GONE_STATE);					
					this.remove(cp);
				}
				else
					throw new Error("This doesn't really make sense");
			}
		}
		
		public function update(deltaTime:Number):void
		{			
			for each (var person:CustomerPerson in this)
			{
				if (person.update(deltaTime))
					remove(person);							
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
		
		public function removeMovingCustomers():void
		{
			var cpLength:int = length;
			for (var i:int = (cpLength - 1); i >= 0; i--)
			{
				var cp:CustomerPerson = this[i] as CustomerPerson;
				if (cp.personType == Person.MOVING)
				{
					remove(cp);				
				}
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
				throw new Error("how the hell did this happen?");
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
				if (cp.personType != Person.STATIC)
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
		
		public function removeBoothFromAvailable(booth:ActiveAsset):void
		{
			for each (var cp:CustomerPerson in this)
			{
				if (cp.currentBooth == booth)
					cp.advanceState(CustomerPerson.ROAM_STATE);
			}
		}
		
		public function initializeStaggeredExit(numExits:int):void
		{
			toExit = new ArrayCollection();
			toMove = new ArrayCollection();
			for each (var cp:CustomerPerson in this)
			{
				if (cp.seatNumber < numExits && cp.personType == Person.STATIC)
					toExit.addItem(cp);
			}
		}
		
		public function startStaggeredExit():void
		{
			exitWaitTimer = new Timer(EXIT_WAIT_TIME_CONSTANT + Math.random() * EXIT_WAIT_TIME_MULTIPLIER);
			exitWaitTimer.addEventListener(TimerEvent.TIMER, onExitWaitTimer);
			exitWaitTimer.start();
		}
		
		private function onExitWaitTimer(evt:TimerEvent):void
		{
			if (toExit.length > 0)
			{
				var cp:CustomerPerson = toExit.getItemAt(0) as CustomerPerson;
				toExit.removeItemAt(0);
//				_venue.removeMoodClipFromBitmappedAsset(cp);
//				cp.addVisibleMoodClip(cp.moodClip);
				cp.advanceState(CustomerPerson.EXIT_STATE);
			}
			else
			{
				exitWaitTimer.stop();
				exitWaitTimer.removeEventListener(TimerEvent.TIMER, onExitWaitTimer);
				exitWaitTimer = null;
				
				_venue.replaceExitedCustomers();
			}
		}
		
		public function initializeExitReplacements(numStaticCustomers:int, numExits:int):void
		{
			toMove = new ArrayCollection();
			var cp:CustomerPerson;
			if (numStaticCustomers > numExits)
			{
				while (toMove.length < numExits)
				{
					cp = this.getItemAt(Math.floor(Math.random() * this.length)) as CustomerPerson;
					if (cp.personType == Person.STATIC && !toMove.contains(cp) && !cp.isMoving)
					{
						toMove.addItem(cp);
						var index:int = toMove.getItemIndex(cp);
						cp.seatNumber = index;
						cp.worldDestination = new Point3D((_venue.assignedSeats.getItemAt(index) as Point3D).x, (_venue.assignedSeats.getItemAt(index) as Point3D).y, (_venue.assignedSeats.getItemAt(index) as Point3D).z);
					}
				}
			}
			else
			{
				for each (cp in this)
				{
					if (cp.personType == Person.STATIC)
						toMove.addItem(cp);
				}
			}
		}
		
		public function replaceExitedCustomers():void
		{
			replaceWaitTimer = new Timer(REPLACE_WAIT_TIME_CONSTANT);
			replaceWaitTimer.addEventListener(TimerEvent.TIMER, onReplaceWaitTime);
			replaceWaitTimer.start();
			
//			Adds an event listener for when replacement movers reach final destination; when the last one arrives, redraw the bitmap
			var totalMovers:int = toMove.length;
			if (totalMovers > 0)
			{
				var movers:int = 0;
				_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, function onFinalDest(evt:WorldEvent):void
				{
					var asset:ActiveAsset = evt.activeAsset;
					if (asset is CustomerPerson && (asset as CustomerPerson).personType == Person.STATIC && 
						(asset as CustomerPerson).state != CustomerPerson.GONE_STATE &&
						(asset as CustomerPerson).state != CustomerPerson.EXIT_STATE)
					{
						movers++;
						if (movers == totalMovers)
						{
							_myWorld.removeEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDest);
//							redrawBitmap();
						}
					}
				});
			}
		}
		
		private function onReplaceWaitTime(evt:TimerEvent):void
		{
			if (toMove.length > 0)
			{
				var cp:CustomerPerson = toMove.getItemAt(0) as CustomerPerson;
				toMove.removeItemAt(0);
				cp.advanceState(CustomerPerson.DIRECTED_STATE);
			}
			else
			{
				replaceWaitTimer.stop();
				replaceWaitTimer.removeEventListener(TimerEvent.TIMER, onReplaceWaitTime);
				replaceWaitTimer = null;				
			}
		}
		
		public function redrawBitmap():void
		{
//			Bitmap blotter should contain updated bitmap references at this point
			
			_venue.reRenderBitmap();
			
			for each (var cp:CustomerPerson in this)
			{
				if (cp.personType == Person.STATIC)
					_myWorld.removeAsset(cp);
			}
		}
		
//		public function convertStaticToMovingCustomers():void
//		{
//			for each (var cp:CustomerPerson in this)
//			{
//				if (cp.personType == Person.STATIC)
//				{
//					cp.advanceState(CustomerPerson.ENTHRALLED_STATE);
//					_myWorld.addAsset(cp, cp.worldCoords);
//				}
//			}
//		}		
						
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