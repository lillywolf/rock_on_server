package rock_on
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.DynamicEvent;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class CustomerPersonManager extends ArrayCollection
	{	
		private var _myWorld:World;
		private var _concertStage:ConcertStage;
		
		public function CustomerPersonManager(source:Array=null)
		{
			super(source);
		}
		
		public function add(cp:CustomerPerson):void
		{
			if(_myWorld)
			{			
				cp.myWorld = _myWorld;
				addWithEventListeners(cp);
				cp.advanceState(CustomerPerson.ENTHRALLED_STATE);
			}
			else
			{
				throw new Error("you have to fill your pool before you dive");
			}
		}
		
		private function addWithEventListeners(cp:CustomerPerson):void
		{
			var destination:Point3D = cp.pickPointNearStructure(_concertStage);
			_myWorld.addAsset(cp, destination);
			this.addItem(cp);
			cp.addEventListener("customerRouted", onCustomerRouted);
			cp.addEventListener("queueDecremented", decrementQueue);
		}	
		
		private function decrementQueue(evt:DynamicEvent):void
		{
			var booth:Booth = evt.booth;
//			for each (var cp:CustomerPerson in this)
//			{
//				if (cp.currentBooth == booth && cp.state == CustomerPerson.QUEUED_STATE && cp != evt.person)
//				{
//					updateBoothPosition(cp, cp.currentBoothPosition-1);					
//					cp.moveUpInQueue();
//				}
//			}
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
					proxiedCustomers.addItem({cp: cp, pathLength: pathLength});
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
		
//		private function updateQueue(evt:DynamicEvent):void
//		{
//			var person:CustomerPerson = evt.person;
//			var i:int;
//			for (i = 0; i < person.currentBoothSlot - 1; i++)
//			{	
//				for each (var cp:CustomerPerson in this)
//				{
//					if (cp.currentBooth == person.currentBooth && cp.currentBoothSlot == (person.currentBoothSlot - 1) && cp.isEnRoute)
//					{
//						person.moveUpInQueue(person.currentBooth);
//						
//						cp.incrementQueueSlotWhileEnRoute();
//					}
//				}
//			}
//		}
		
		private function onFinalDestinationReached(evt:WorldEvent):void
		{
			if (evt.activeAsset is CustomerPerson)
			{
				var cp:CustomerPerson = evt.activeAsset as CustomerPerson;
				if (cp.state == CustomerPerson.ROUTE_STATE)
				{
					cp.isCustomerAtQueue();
				}
				else if (cp.state == CustomerPerson.QUEUED_STATE)
				{
					cp.checkIfFrontOfQueue();	
				}
				else if (cp.state == CustomerPerson.HEADTOSTAGE_STATE)
				{
					cp.advanceState(CustomerPerson.ENTHRALLED_STATE);
				}
				else
				{
					throw new Error("This doesn't really make sense");
				}
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
		
		public function remove(person:CustomerPerson):void
		{
			if(_myWorld)
			{
				_myWorld.removeChild(person);
				var movingSkinIndex:Number = _myWorld.assetRenderer.sortedAssets.getItemIndex(person);
				_myWorld.assetRenderer.sortedAssets.removeItemAt(movingSkinIndex);
				var personIndex:Number = getItemIndex(person);
				removeItemAt(personIndex);
			}
			else 
			{
				throw new Error("how the hell did this happen?");
			}
		}		
		
		private function onDirectionChanged(evt:WorldEvent):void
		{
			for each (var asset:ActiveAsset in this)
			{
				if (evt.activeAsset == asset)
				{
					(asset as CustomerPerson).setDirection(asset.worldDestination);
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
		
	}
}