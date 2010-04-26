package rock_on
{
	import controllers.StructureManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;

	public class BoothManager extends EventDispatcher
	{
		public var booths:ArrayCollection;
		public var _myWorld:World;
		public var _structureManager:StructureManager;
		
		public function BoothManager(structureManager:StructureManager, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_myWorld = myWorld;
			_structureManager = structureManager;
		}
		
		public function setInMotion():void
		{
			booths = new ArrayCollection();
			showBooths();
		}
		
		public function showBooths():void
		{
			var boothStructures:ArrayCollection = _structureManager.getStructuresByType("Booth");
			for each (var os:OwnedStructure in boothStructures)
			{
				var asset:ActiveAsset = new ActiveAsset(os.structure.mc);
				asset.thinger = os;
				var booth:Booth = new Booth(os);
				booths.addItem(booth);
				var addTo:Point3D = new Point3D(os.x, os.y, os.z);
				_myWorld.addStaticAsset(asset, addTo);
			}
		}		
		
		public function getRandomBooth(booth:Booth=null):Booth
		{
			var selectedBooth:Booth = null;
			if (booths.length && !(booths.length == 1 && booth))
			{
				do 
				{
					selectedBooth = booths.getItemAt(Math.floor(Math.random()*booths.length)) as Booth;			
				}
				while (selectedBooth == booth);
			}
			return selectedBooth;	
		}
		
		public function getBoothFront(booth:Booth, index:int=0, routedCustomer:Boolean=false, queuedCustomer:Boolean=false, customerless:Boolean=false):Point3D
		{
			// Assumes a particular rotation
			
			var boothFront:Point3D;
			if (customerless)
			{
				boothFront = new Point3D(Math.floor(booth.structure.width/2 + booth.x + 1), 0, Math.floor(booth.structure.depth/4 + booth.z));
			}
			else if (queuedCustomer)
			{
				boothFront = new Point3D(Math.floor(booth.structure.width/2 + booth.x + index + 1), 0, Math.floor(booth.structure.depth/4 + booth.z));				
			}
			else if (routedCustomer)
			{
				boothFront = new Point3D(Math.floor(booth.structure.width/2 + booth.x + (booth.actualQueue + index + 1)), 0, Math.floor(booth.structure.depth/4 + booth.z));																	
			}
			else
			{
				boothFront = new Point3D(Math.floor(booth.structure.width/2 + booth.x + (booth.currentQueue + 1)), 0, Math.floor(booth.structure.depth/4 + booth.z));													
			}
			return boothFront;
		}
		
	}
}