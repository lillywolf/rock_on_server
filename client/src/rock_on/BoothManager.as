package rock_on
{
	import controllers.StructureManager;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	
	import views.UILayer;
	
	import world.ActiveAsset;
	import world.Point;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class BoothManager extends EventDispatcher
	{
		public static const BOOTH_CREDITS_MULTIPLIER:int = 50;
		
		public var booths:ArrayCollection;
		public var _uiLayer:UILayer;
		public var _myWorld:World;
		public var friendMirror:Boolean;
		public var editMirror:Boolean;
		[Bindable] public var _venue:Venue;
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
		
		public function decreaseInventoryCount(booth:Booth, toDecrease:int):void
		{
			booth.inventory_count = booth.inventory_count - toDecrease;
			
			if (booth.inventory_count - toDecrease <= 0)
			{
				booth.inventory_count = 0;
				
				if (!friendMirror)
				{
					_structureManager.validateBoothCountZero(booth.id);				
				}
			}			
		}
		
		public function updateBoothOnServerResponse(os:OwnedStructure, method:String):void
		{
			var selectedBooth:Booth;
			
			for each (var booth:Booth in booths)
			{
				if (booth.id == os.id)
				{
					selectedBooth = booth;									
				}
			}
						
			if (method == "update_inventory_count")
			{
				if (os.inventory_count <= 0)
				{
					if (selectedBooth.state != Booth.UNSTOCKED_STATE)
					{
						selectedBooth.advanceState(Booth.UNSTOCKED_STATE);										
					}
				}				
			}
			
			if (method == "add_booth_credits")
			{
				selectedBooth.updateProperties(os);
				selectedBooth.advanceState(Booth.STOCKED_STATE);
			}
			
			if (method == "save_placement")
			{
				selectedBooth.updateProperties(os);
				updateBoothPlacementPostServerResponse(selectedBooth);
			}			
		}
		
		public function updateBoothPlacementPostServerResponse(booth:Booth):void
		{
			for each (var asset:ActiveAsset in _myWorld.assetRenderer.unsortedAssets)
			{
				if (asset.thinger)
				{
					if (asset.thinger is OwnedStructure && asset.thinger.id == (booth as OwnedStructure).id)
					{
						asset.worldCoords.x = booth.x;
						asset.worldCoords.y = booth.y;
						asset.worldCoords.z = booth.z;
						_myWorld.removeAsset(asset);
						_myWorld.addStaticAsset(asset, asset.worldCoords);
						moveBoothUIComponents(booth);
						var evt:WorldEvent = new WorldEvent(WorldEvent.STRUCTURE_PLACED, asset, true, true);
						dispatchEvent(evt);
						break;
					}
				}
			}
		}
		
		private function moveBoothUIComponents(booth:Booth):void
		{
			if (booth.state == Booth.UNSTOCKED_STATE && booth.collectionButton)
			{
				moveBoothCollectionButton(booth.collectionButton, booth);
			}
		}
		
		public function reInitializeBooths():void
		{
			for each (var booth:Booth in booths)
			{
				booth.currentQueue = 0;
				booth.actualQueue = 0;
				booth.proxiedQueue.removeAll();
				booth.hasCustomerEnRoute = false;
			}
		}
		
		public function showBooths():void
		{
			var boothStructures:ArrayCollection = _structureManager.getStructuresByType("Booth");
			for each (var os:OwnedStructure in boothStructures)
			{
				var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
				var asset:ActiveAsset = new ActiveAsset(mc);
				asset.thinger = os;
				var booth:Booth = new Booth(this, _venue, os);
				booth.friendMirror = friendMirror;
				booths.addItem(booth);
				var addTo:Point3D = new Point3D(os.x, os.y, os.z);
				_myWorld.addStaticAsset(asset, addTo);
				booth.updateState();
			}
		}		
		
		public function addBoothCollectionButton(booth:Booth):void
		{	
			var btn:SpecialButton = new SpecialButton();
			btn.booth = booth;
			booth.collectionButton = btn;
			btn.addEventListener(MouseEvent.CLICK, onCollectionButtonClicked);
			addBoothCollectionButtonToUILayer(btn, booth);
		}
		
		public function addBoothCollectionButtonToUILayer(btn:SpecialButton, booth:Booth):void
		{
			var actualCoords:Point = World.worldToActualCoords(new Point3D(booth.x, booth.y, booth.z));
			btn.x = actualCoords.x + _myWorld.x;
			btn.y = actualCoords.y + _myWorld.y;
			if (!friendMirror && !editMirror)
			{
				_uiLayer.addChild(btn);
			}			
		}
		
		private function moveBoothCollectionButton(btn:SpecialButton, booth:Booth):void
		{
			var actualCoords:Point = World.worldToActualCoords(new Point3D(booth.x, booth.y, booth.z));
			btn.x = actualCoords.x + _myWorld.x;
			btn.y = actualCoords.y + _myWorld.y;			
		}
		
		private function onCollectionButtonClicked(evt:MouseEvent):void
		{
			var btn:SpecialButton = evt.currentTarget as SpecialButton;
			var booth:Booth = btn.booth;
//			var creditsToAdd:int = booth.getTotalInventory() * BOOTH_CREDITS_MULTIPLIER;
			
			_structureManager.serverController.sendRequest({id: booth.id}, "owned_structure", "add_booth_credits");
			_uiLayer.removeChild(btn);
		}
		
		public function getRandomBooth(booth:Booth=null):Booth
		{
			var selectedBooth:Booth = null;
			
			var unstockedBooths:int = 0;
			for each (var booth:Booth in booths)
			{
				if (booth.state == Booth.UNSTOCKED_STATE)
				{
					unstockedBooths++;
				}
			}
			
			if (booths.length && !(booths.length == 1 && booth) && booths.length != unstockedBooths)
			{
				do 
				{
					selectedBooth = booths.getItemAt(Math.floor(Math.random()*booths.length)) as Booth;			
				}
				while (selectedBooth == booth || selectedBooth.state != Booth.STOCKED_STATE);
			}
			return selectedBooth;	
		}
				
		public function getBoothFront(booth:Booth, index:int=0, routedCustomer:Boolean=false, queuedCustomer:Boolean=false, customerless:Boolean=false):Point3D
		{
			// Assumes a particular rotation
			
			// Do not allow out of bound points, etc.
			
			var boothFront:Point3D;
			if (customerless)
			{
				boothFront = new Point3D(Math.ceil(booth.structure.width/2 + booth.x + 1), 0, Math.floor(booth.structure.depth/4 + booth.z));
			}
			else if (queuedCustomer)
			{
				boothFront = new Point3D(Math.ceil(booth.structure.width/2 + booth.x + index + 1), 0, Math.floor(booth.structure.depth/4 + booth.z));				
			}
			else if (routedCustomer)
			{
				boothFront = new Point3D(Math.ceil(booth.structure.width/2 + booth.x + (booth.actualQueue + index + 1)), 0, Math.floor(booth.structure.depth/4 + booth.z));																	
			}
			else
			{
				boothFront = new Point3D(Math.ceil(booth.structure.width/2 + booth.x + (booth.currentQueue + 1)), 0, Math.floor(booth.structure.depth/4 + booth.z));													
			}
			return boothFront;
		}
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}
		
		public function set uiLayer(val:UILayer):void
		{
			_uiLayer = val;
		}
		
	}
}