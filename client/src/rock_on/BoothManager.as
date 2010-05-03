package rock_on
{
	import controllers.StructureManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.events.DynamicEvent;
	
	import world.ActiveAsset;
	import world.Point;
	import world.Point3D;
	import world.World;

	public class BoothManager extends EventDispatcher
	{
		public static const BOOTH_CREDITS_MULTIPLIER:int = 50;
		
		public var booths:ArrayCollection;
		public var _myWorld:World;
		public var _structureManager:StructureManager;
		
		public function BoothManager(structureManager:StructureManager, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_myWorld = myWorld;
			_structureManager = structureManager;
			addEventListener("queueDecremented", onQueueDecremented);
		}
				
		public function setInMotion():void
		{
			booths = new ArrayCollection();
			showBooths();
		}
		
		private function onQueueDecremented(evt:DynamicEvent):void
		{
			var booth:Booth = evt.booth as Booth;
			var id:int = booth.id;
			_structureManager.decrementInventoryCount(id);
			
			if (booth.inventory_count - 1 == 0)
			{
				booth.advanceState(Booth.UNSTOCKED_STATE);
			}
		}
		
		public function showBooths():void
		{
			var boothStructures:ArrayCollection = _structureManager.getStructuresByType("Booth");
			for each (var os:OwnedStructure in boothStructures)
			{
				var asset:ActiveAsset = new ActiveAsset(os.structure.mc);
				asset.thinger = os;
				var booth:Booth = new Booth(os);
				addBoothListeners(booth);
				booths.addItem(booth);
				var addTo:Point3D = new Point3D(os.x, os.y, os.z);
				_myWorld.addStaticAsset(asset, addTo);
			}
		}		
		
		public function addBoothListeners(booth:Booth):void
		{
			booth.addEventListener("unstockedState", onUnstockedState);
		}
		
		private function onUnstockedState(evt:DynamicEvent):void
		{
			var booth:Booth = evt.currentTarget as Booth;
			addBoothCollectionButton(booth);
		}
		
		public function addBoothCollectionButton(booth:Booth):void
		{	
			var btn:SpecialButton = new SpecialButton();
			btn.booth = booth;
			btn.addEventListener(MouseEvent.CLICK, onCollectionButtonClicked);
			var actualCoords:Point = World.worldToActualCoords(new Point3D(booth.x, booth.y, booth.z));
			btn.x = actualCoords.x;
			btn.y = actualCoords.y;
			Application.application.addChild(btn);		
		}
		
		private function onCollectionButtonClicked(evt:MouseEvent):void
		{
			var btn:SpecialButton = evt.currentTarget as SpecialButton;
			var booth:Booth = btn.booth;
			var creditsToAdd:int = booth.getTotalInventory() * BOOTH_CREDITS_MULTIPLIER;
			
			// Update credits on the server
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
				while (selectedBooth == booth && selectedBooth.state != Booth.STOCKED_STATE);
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