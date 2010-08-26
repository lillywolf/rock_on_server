package rock_on
{
	import controllers.StructureController;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	
	import views.UILayer;
	
	import world.ActiveAsset;
	import world.ActiveAssetStack;
	import world.Point3D;
	import world.World;

	public class BoothBoss extends EventDispatcher
	{
		public static const BOOTH_CREDITS_MULTIPLIER:int = 50;
		
		public var booths:ArrayCollection;
		public var boothAssets:ArrayCollection;
		public var _uiLayer:UILayer;
		public var _myWorld:World;
		public var friendMirror:Boolean;
		public var editMirror:Boolean;
		[Bindable] public var _venue:Venue;
		public var _structureController:StructureController;
		
		public function BoothBoss(structureController:StructureController, myWorld:World, venue:Venue, target:IEventDispatcher=null)
		{
			super(target);
			_myWorld = myWorld;
			_structureController = structureController;
			_venue = venue;
		}
				
		public function setInMotion():void
		{
			booths = new ArrayCollection();
			showBooths();
		}
		
		public function tearDown():void
		{
			removeBooths();
		}
		
		public function decreaseInventoryCount(booth:Booth, toDecrease:int):void
		{
			booth.inventory_count = booth.inventory_count - toDecrease;
			
			if (booth.inventory_count - toDecrease <= 0)
			{
				booth.inventory_count = 0;
				
				if (!friendMirror)
				{
					_structureController.validateBoothCountZero(booth.id);				
				}
			}			
		}
		
		public function updateBoothOnServerResponse(os:OwnedStructure, method:String):void
		{
			var booth:Booth = getBoothById(os.id);
						
			if (method == "update_inventory_count")
			{
				booth.updateState();		
			}			
			if (method == "add_booth_credits")
			{
				booth.updateProperties(os);
				booth.advanceState(Booth.STOCKED_STATE);
			}			
			if (method == "save_placement")
			{
				booth.updateProperties(os);
				moveBoothUIComponents(booth);
			}						
			if (method == "sell")
			{
				removeBooth(booth);
			}				
			if (method == "create_new")
			{
				booth = createBooth(os);
				booth.updateState();
			}		
		}
		
		public function removeBooth(booth:Booth):void
		{
			var index:int = booths.getItemIndex(booth);
			booths.removeItemAt(index);				
		}
		
		public function createBooth(os:OwnedStructure):Booth
		{
			var booth:Booth = new Booth(this, _venue, os);
			booth.friendMirror = friendMirror;
			booth.editMirror = editMirror;
			booths.addItem(booth);
			return booth;
		}
		
		public function getBoothById(id:int):Booth
		{
			for each (var booth:Booth in booths)
			{
				if (booth.id == id)
				{
					return booth;									
				}
			}	
			return null;		
		}
		
		private function moveBoothUIComponents(booth:Booth):void
		{
			if (booth.state == Booth.UNSTOCKED_STATE && booth.collectionButton)
			{
				moveBoothCollectionButton(booth.collectionButton, booth);
			}
		}
		
		public function reInitializeBooths(bitmapped:Boolean):void
		{
			for each (var booth:Booth in booths)
			{
				booth.currentQueue = 0;
				booth.actualQueue = 0;
				booth.proxiedQueue.removeAll();
				booth.hasCustomerEnRoute = false;
			}
			if (bitmapped)
			{
				removeRenderedBooths();
			}
		}
		
		public function updateRenderedBooths(os:OwnedStructure, method:String):void
		{
			if (method == "save_placement")
			{
				_structureController.savePlacement(os, new Point3D(os.x, os.y, os.z));
				_myWorld.saveStructurePlacement(os);
				reInitializeBooths(false);
				_venue.redrawAllMovers();
//				_venue.customerPersonManager.redrawStandAloneCustomers();
			}
			else if (method == "create_new")
			{
				_myWorld.createNewStructure(os);
			}
		}
		
		public function showBooths():void
		{
			boothAssets = new ArrayCollection();
			var boothStructures:ArrayCollection = _structureController.getStructuresByType("Booth");
			for each (var os:OwnedStructure in boothStructures)
			{
				var booth:Booth = createBooth(os);
				var asset:ActiveAssetStack = createBoothAsset(booth);
				asset.toppers = _structureController.getStructureToppers(os);
				asset.setMovieClipsForStructure(asset.toppers);
				asset.bitmapWithToppers();
				var addTo:Point3D = new Point3D(booth.x, booth.y, booth.z);
				addBoothsToWorld(asset, addTo);
				boothAssets.addItem(asset);
				booth.updateState();
			}
		}
		
		public function addBoothsToWorld(asset:ActiveAsset, addTo:Point3D):void
		{
			if (editMirror)
			{
				_myWorld.addStaticAsset(asset, addTo);
			}
			else
			{
				_myWorld.addStaticAsset(asset, addTo);
			}
		}
		
		public function removeRenderedBooths():void
		{
			for each (var asset:ActiveAsset in boothAssets)
			{
				_myWorld.removeAsset(asset);
			}			
		}
		
		public function removeBooths():void
		{
			for each (var asset:ActiveAsset in boothAssets)
			{
				_myWorld.removeAsset(asset);
			}
			boothAssets.removeAll();
			booths.removeAll();
		}

		public function createBoothAsset(booth:Booth):ActiveAssetStack
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(booth.structure.mc);
			mc.cacheAsBitmap = true;
			var asset:ActiveAssetStack = new ActiveAssetStack(null, mc, null, StructureController.STRUCTURE_SCALE);	
			asset.copyFromOwnedStructure(booth);
			return asset;		
		}	
		
		public function addBoothCollectionButton(booth:Booth):void
		{	
			var btn:SpecialButton = new SpecialButton();
			btn.booth = booth;
			booth.collectionButton = btn;
			btn.addEventListener(MouseEvent.CLICK, onCollectionButtonClicked);
			addBoothCollectionButtonToUILayer(booth);
		}
		
		public function addBoothCollectionButtonToUILayer(booth:Booth):void
		{
			var actualCoords:flash.geom.Point = World.worldToActualCoords(new Point3D(booth.x, booth.y, booth.z));
			booth.collectionButton.x = actualCoords.x + _myWorld.x;
			booth.collectionButton.y = actualCoords.y + _myWorld.y;
			if (!friendMirror && !editMirror)
			{
//				_uiLayer.addChild(booth.collectionButton);
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
			
			_structureController.serverController.sendRequest({id: booth.id}, "owned_structure", "add_booth_credits");
			_uiLayer.removeChild(btn);
		}
		
		public function getRandomBooth(booth:Booth=null):Booth
		{
			trace("select booth");
			var selectedBooth:Booth = null;			
			var unstockedBooths:int = getUnstockedBooths().length;
			
			if (booths.length && !(booths.length == 1 && booth) && booths.length != unstockedBooths)
			{
				do 
				{
					selectedBooth = booths.getItemAt(Math.floor(Math.random()*booths.length)) as Booth;			
				}
				while (selectedBooth == booth || selectedBooth.state != Booth.STOCKED_STATE);
			}
			trace("booth selected");
			return selectedBooth;	
		}
		
		public function getAnyExistingBooth(type:String=null):Booth
		{
			var selectedBooth:Booth = null;
			do
			{
				selectedBooth = booths.getItemAt(Math.floor(Math.random()*booths.length)) as Booth;			
			}
			while (selectedBooth.structure.booth_structure);
			return selectedBooth;
		}
		
		public function getUnstockedBooths():ArrayCollection
		{
			var unstockedBooths:ArrayCollection = new ArrayCollection();
			for each (var booth:Booth in booths)
			{
				if (booth.state == Booth.UNSTOCKED_STATE)
				{
					unstockedBooths.addItem(booth);
				}
			}	
			return unstockedBooths;		
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
		
		public function get uiLayer():UILayer
		{
			return _uiLayer;
		}
		
	}
}