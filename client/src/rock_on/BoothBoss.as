package rock_on
{
	import controllers.StructureController;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import models.BoothStructure;
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
				
		public function initialize():void
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
					_structureController.validateBoothCountZero(booth.id);				
			}			
		}
		
		public function updateBoothOnServerResponse(os:OwnedStructure, method:String):void
		{
//			var os:OwnedStructure = _structureController.getOwnedStructureById(os.id);
			var booth:BoothAsset;
			var boothStructure:Booth;
			
			if (method == "update_inventory_count")
			{
				booth = getBoothById(os.id);
				booth.updateState();		
			}			
			if (method == "add_booth_credits")
			{
				booth = getBoothById(os.id);
				boothStructure = booth.thinger as Booth;
				boothStructure.updateProperties(os);
				booth.advanceState(BoothAsset.STOCKED_STATE);
			}			
			if (method == "save_placement")
			{
				booth = getBoothById(os.id);
				boothStructure = booth.thinger as Booth;
				boothStructure.updateProperties(os);
				moveBoothUIComponents(booth);
			}						
			if (method == "sell")
			{
				booth = getBoothById(os.id);
				removeBooth(booth);
			}				
			if (method == "create_new")
			{
//				boothStructure = createBooth(os);
//				booth = createBoothAsset(boothStructure);
//				booth.updateState();
			}		
		}
		
		public function removeBooth(booth:BoothAsset):void
		{
			var index:int;
			var boothStructure:Booth = booth.thinger as Booth;
			index = boothAssets.getItemIndex(booth);
			boothAssets.removeItemAt(index);
			index = booths.getItemIndex(boothStructure);
			booths.removeItemAt(index);				
		}
		
		public function createBooth(os:OwnedStructure):Booth
		{
			var booth:Booth = new Booth(this, _venue, os);
//			booth.friendMirror = friendMirror;
//			booth.editMirror = editMirror;
			booths.addItem(booth);							
			return booth;
		}
		
		public function getBoothById(id:int):BoothAsset
		{
			for each (var booth:BoothAsset in boothAssets)
			{
				if ((booth.thinger as OwnedStructure).id == id)
					return booth;									
			}	
			return null;		
		}
		
		private function moveBoothUIComponents(booth:BoothAsset):void
		{
//			if (booth.state == Booth.UNSTOCKED_STATE)
//				moveBoothCollectionButton(booth.collectionButton, booth);
		}
		
		public function reInitializeBooths(bitmapped:Boolean):void
		{
			for each (var booth:BoothAsset in boothAssets)
			{
				booth.currentQueue = 0;
				booth.actualQueue = 0;
				booth.proxiedQueue.removeAll();
				booth.hasCustomerEnRoute = false;
			}
			if (bitmapped)
				removeRenderedBooths();
		}
		
		public function updateRenderedBooths(os:OwnedStructure, method:String):void
		{
			var asset:BoothAsset;
			if (method == "save_placement")
			{
				_structureController.savePlacement(os, new Point3D(os.x, os.y, os.z));
				_myWorld.saveStructurePlacement(os, false, null, _venue.stageRects);
				reInitializeBooths(false);
				_venue.redrawAllMovers();
			}
			else if (method == "save_placement_and_rotation")
			{
				_structureController.savePlacementAndRotation(os, new Point3D(os.x, os.y, os.z));
				_myWorld.saveStructurePlacement(os, true, null, _venue.stageRects);
				asset = _myWorld.getAssetFromOwnedStructure(os) as BoothAsset;
				asset.currentFrameNumber = asset.getCurrentFrameNumber();
				
				reInitializeBooths(false);
				_venue.redrawAllMovers();
				_venue.redrawAllStructures();
			}
			else if (method == "create_new")
			{
				_myWorld.updateUnwalkables(os, null, _venue.stageRects);
				asset = createEntireBooth(os);
				_myWorld.addStandardStructureToWorld(os, asset);
			}
		}
		
		public function showBooths():void
		{
			boothAssets = new ArrayCollection();
			var boothStructures:ArrayCollection = _structureController.getStructuresByType("Booth");
			for each (var os:OwnedStructure in boothStructures)
			{
				var asset:BoothAsset = createEntireBooth(os);
				if (asset)
				{	
					var addTo:Point3D = new Point3D(os.x, os.y, os.z);
					addBoothsToWorld(asset, addTo);
				}
			}
		}
		
		public function createEntireBooth(os:OwnedStructure):BoothAsset
		{
			var booth:Booth = createBooth(os);
			if (os.in_use)
			{
				var asset:BoothAsset = createBoothAsset(booth);
				asset.toppers = _structureController.getStructureToppers(os);
				asset.setMovieClipsForStructure(asset.toppers);
				asset.bitmapWithToppers();
				boothAssets.addItem(asset);				
				asset.updateState();
			}
			return asset;
		}
		
		public function addBoothsToWorld(asset:BoothAsset, addTo:Point3D):void
		{
			_myWorld.addStaticAsset(asset, addTo);
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

		public function createBoothAsset(booth:Booth):BoothAsset
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(booth.structure.mc);
			mc.cacheAsBitmap = true;
			var asset:BoothAsset = new BoothAsset(this, _venue, null, mc, null, StructureController.STRUCTURE_SCALE);
			asset.copyFromOwnedStructure(booth);
			asset.currentFrameNumber = asset.getCurrentFrameNumber();
			return asset;		
		}	
		
		public function addBoothCollectionButton(booth:Booth):void
		{	
			var btn:SpecialButton = new SpecialButton();
			btn.booth = booth;
//			booth.collectionButton = btn;
//			btn.addEventListener(MouseEvent.CLICK, onCollectionButtonClicked);
			addBoothCollectionButtonToUILayer(booth);
		}
		
		public function addBoothCollectionButtonToUILayer(booth:Booth):void
		{
			var actualCoords:flash.geom.Point = World.worldToActualCoords(new Point3D(booth.x, booth.y, booth.z));
//			booth.collectionButton.x = actualCoords.x + _myWorld.x;
//			booth.collectionButton.y = actualCoords.y + _myWorld.y;
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
		
		public function getRandomBooth(booth:BoothAsset=null):BoothAsset
		{
			var selectedBooth:BoothAsset = null;			
			
			if (stockedBoothExists(booth))
			{
				do 
				{
					selectedBooth = boothAssets.getItemAt(Math.floor(Math.random()*boothAssets.length)) as BoothAsset;			
				}
				while (selectedBooth == booth || selectedBooth.state != Booth.STOCKED_STATE);
			}
			trace("booth selected");
			return selectedBooth;	
		}
		
		private function stockedBoothExists(booth:BoothAsset):Boolean
		{
			if (boothAssets.length &&
				!(boothAssets.length == 1 && booth) &&
				hasStockedBooth(getBoothsInUse(), booth))
			{
				return true;
			}
			return false;
		}
		
		private function hasStockedBooth(inUse:ArrayCollection, discount:BoothAsset=null):Boolean
		{
			for each (var b:BoothAsset in inUse)
			{
				if (b != discount && b.state == Booth.STOCKED_STATE)
					return true;
			}
			return false;
		}
		
		private function getBoothsInUse():ArrayCollection
		{
			var inUse:ArrayCollection = new ArrayCollection();
			for each (var booth:BoothAsset in boothAssets)
			{
				if ((booth.thinger as OwnedStructure).in_use)
					inUse.addItem(booth);
			}
			return inUse;
		}
		
		public function getAnyExistingBooth(type:String=null):BoothAsset
		{
			var selectedBooth:BoothAsset = null;
			do
			{
				selectedBooth = boothAssets.getItemAt(Math.floor(Math.random()*boothAssets.length)) as BoothAsset;			
			}
			while ((selectedBooth.thinger as Booth).structure.booth_structure);
			return selectedBooth;
		}
		
		public function getUnstockedBooths():ArrayCollection
		{
			var unstockedBooths:ArrayCollection = new ArrayCollection();
			for each (var booth:BoothAsset in boothAssets)
			{
				if (!booth.state)
					unstockedBooths.addItem(booth);
				else if (booth.state && booth.state == Booth.UNSTOCKED_STATE)
					unstockedBooths.addItem(booth);
			}	
			return unstockedBooths;		
		}
				
		public function getBoothFront(booth:BoothAsset, index:int=0, routedCustomer:Boolean=false, queuedCustomer:Boolean=false, customerless:Boolean=false):Point3D
		{			
			// Do not allow out of bound points, etc.
			
			var boothFront:Point3D = booth.getStructureFrontByRotation();
			var boothStructure:Booth = booth.thinger as Booth;
			if (customerless)
				boothStructure.addPointsByRotation(boothFront, 0);
			else if (queuedCustomer)
				boothStructure.addPointsByRotation(boothFront, index);			
			else if (routedCustomer)
				boothStructure.addPointsByRotation(boothFront, booth.actualQueue + index);															
			else
				boothStructure.addPointsByRotation(boothFront, booth.currentQueue);	
			
			if ((_myWorld.pathFinder.occupiedByStructures[boothFront.x] &&
				_myWorld.pathFinder.occupiedByStructures[boothFront.x][boothFront.y] &&
				_myWorld.pathFinder.occupiedByStructures[boothFront.x][boothFront.y][boothFront.z] &&
				(_myWorld.pathFinder.occupiedByStructures[boothFront.x][boothFront.y][boothFront.z] as ActiveAsset).thinger.id != boothStructure.id) ||
				!_myWorld.pathFinder.isInBounds(boothFront))
			{
				trace ("booth front is null");
				return null;
			}
			trace ("booth front: " + boothFront.x.toString() + "," + boothFront.y.toString() + "," + boothFront.z.toString());
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