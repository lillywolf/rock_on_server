package rock_on
{
	import mx.collections.ArrayCollection;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class PromoterManager extends ArrayCollection
	{
		public static const ENTER_STATE:int = 0;
		public static const ROAM_STATE:int = 1;
		public static const STOP_STATE:int = 3;
		public static const LEAVING_STATE:int = 2;
		public static const GONE_STATE:int = 5;	
			
		private var _myWorld:World;		
		public var spawnLocation:Point3D;			
		
		public function PromoterManager(source:Array=null)
		{
			super(source);
		}
		
		public function add(person:Promoter, addTo:Point3D):void
		{
			if(_myWorld)
			{			
				setSpawnLocation(addTo);
				_myWorld.addAsset(person, spawnLocation);				
				addItem(person);
				person.myWorld = _myWorld;
			}
			else
			{
				throw new Error("you have to fill your pool before you dive");
			}
		}
		
		private function onFinalDestinationReached(evt:WorldEvent):void
		{
			if (evt.activeAsset is Promoter)
			{	
				var pr:Promoter = evt.activeAsset as Promoter;
				if (pr.state == ROAM_STATE)
				{
				}
				else
				{
				}
			}
		}
		
		public function setSpawnLocation(addTo:Point3D):void
		{
			spawnLocation = addTo;
		}
		
		public function update(deltaTime:Number):void
		{			
			for each (var person:Promoter in this)
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
		
		public function remove(person:Promoter):void
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
					(asset as BandMember).setDirection(asset.worldDestination);
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
			
	}		
}