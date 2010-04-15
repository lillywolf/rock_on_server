package rock_on
{
	import mx.collections.ArrayCollection;
	import mx.events.DynamicEvent;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class CustomerPersonManager extends ArrayCollection
	{
		public static const ENTER_STATE:int = 0;
		public static const ROAM_STATE:int = 1;
		public static const STOP_STATE:int = 3;
		public static const LEAVING_STATE:int = 2;
		public static const GONE_STATE:int = 5;		
		public static const QUEUED_STATE:int = 6;		
		private var _myWorld:World;
//		private var _collisionManager:CollisionManager;
		private var _concertStage:ConcertStage;
		public var spawnLocation:Point3D;		
		
		public function CustomerPersonManager(source:Array=null)
		{
			super(source);
		}
		
		public function add(person:CustomerPerson):void
		{
			if(_myWorld)
			{			
//				setSpawnLocation();
				person.myWorld = _myWorld;
				var initialLocation:Point3D = person.setInitialDestination();
				_myWorld.addAsset(person, initialLocation);				
				addItem(person);
				person.addEventListener('queueDecremented', decrementQueue);
				person.addEventListener('arrivedAtQueue', updateQueue);
//				person.collisionManager = _collisionManager;
			}
			else
			{
				throw new Error("you have to fill your pool before you dive");
			}
		}	
		
		private function decrementQueue(evt:DynamicEvent):void
		{
			var booth:Booth = evt.booth;
			var person:CustomerPerson = evt.person;
			for each (var cp:CustomerPerson in this)
			{
				if (cp.currentBooth == booth && cp.isQueued && !cp.isEnRoute)
				{
					cp.moveUpInQueue(booth);
				}
				else if (cp.currentBooth == booth && cp.isQueued && cp.isEnRoute)
				{
					cp.decrementQueueSlotWhileEnRoute();
				}
			}
		}
		
		private function updateQueue(evt:DynamicEvent):void
		{
			var person:CustomerPerson = evt.person;
			var i:int;
			for (i = 0; i < person.currentBoothSlot - 1; i++)
			{	
				for each (var cp:CustomerPerson in this)
				{
					if (cp.currentBooth == person.currentBooth && cp.currentBoothSlot == (person.currentBoothSlot - 1) && cp.isEnRoute)
					{
						person.moveUpInQueue(person.currentBooth);
						
						cp.incrementQueueSlotWhileEnRoute();
					}
				}
			}
		}
		
		private function onFinalDestinationReached(evt:WorldEvent):void
		{
			if (evt.activeAsset is CustomerPerson)
			{
				var cp:CustomerPerson = evt.activeAsset as CustomerPerson;
				if (cp.isEnRoute)
				{
					cp.standAtBooth();			
				}
				else if (cp.state == ROAM_STATE && Math.random())
				{
					cp.findNextPath();
				}
				else
				{
					cp.standFacingStage();
				}
			}
		}
		
		public function setSpawnLocation():void
		{
			if (Math.random() > 0.5)
			{
				spawnLocation = new Point3D(Math.floor(Math.random()*_myWorld.tilesWide), 0, _myWorld.tilesDeep - 1);		
			}
			else
			{
				spawnLocation = new Point3D(_myWorld.tilesWide - 1, 0, Math.floor(Math.random()*_myWorld.tilesDeep));
			}
		}
		
		public function update(deltaTime:Number):void
		{			
			for each (var person:CustomerPerson in this)
			{
				// var collidedWith:Collidable = _collisionManager.doesCollide(person.collidable);
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
				// _collisionManager.removeCollidable(audienceMember.collidable);
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
		
//		public function set collisionManager(val:CollisionManager):void
//		{
//			if(!_collisionManager)
//				_collisionManager = val;
//			else
//				throw new Error("Don't change this!!");
//		}
//		public function get collisionManager():CollisionManager
//		{
//			return _collisionManager;
//		}	
					
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