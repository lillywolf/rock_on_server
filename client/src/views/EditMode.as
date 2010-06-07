package views
{
	import controllers.StructureManager;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import game.ImposterOwnedStructure;
	
	import models.OwnedStructure;
	import models.Structure;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import stores.StoreEvent;
	
	import world.ActiveAsset;
	import world.Point;
	import world.Point3D;
	import world.World;

	public class EditMode extends UIComponent
	{
		public var _myWorld:World;
		public var _editView:EditView;
		public var currentAsset:ActiveAsset;
		public var locked:Boolean = false;
		public var _structureManager:StructureManager;
		public var flexiUIC:FlexibleUIComponent;
		
		public static const INVALID_COLOR:ColorTransform = new ColorTransform(1, 0.25, 0.25);
		public static const NORMAL_COLOR:ColorTransform = new ColorTransform(1, 1, 1);
		
		public function EditMode(world:World, editView:EditView)
		{
			super();
			_myWorld = world;
			_editView = editView;
			_myWorld.addEventListener(MouseEvent.CLICK, onWorldClicked);

			enableMouseDetection();

			addEventListener(Event.ADDED, onAdded);
		}
		
		private function onAdded(evt:Event):void
		{
			width = parent.width;
			height = parent.height;	
			x = parent.x;
			y = parent.y;
		}
		
		private function enableMouseDetection():void
		{
			_myWorld.graphics.beginFill(0x000000, 0);
			_myWorld.graphics.drawRect(_myWorld.x, -(_myWorld.y), FlexGlobals.topLevelApplication.width, FlexGlobals.topLevelApplication.height);
			_myWorld.graphics.endFill();			
		}
		
		private function addFlexibleUIC():void
		{
			flexiUIC = new FlexibleUIComponent();
			addChild(flexiUIC);			
		}
		
		private function updateFlexibleUIC():void
		{
			flexiUIC.x = x;
			flexiUIC.y = y;
			flexiUIC.width = width;
			flexiUIC.height = height;
		}
		
		public function onOwnedStructureCollectionChange(evt:CollectionEvent):void
		{
			if (evt.kind == "add")
			{
				var newOwnedStructure:OwnedStructure = evt.items[0] as OwnedStructure;
				for each (var asset:ActiveAsset in _myWorld.assetRenderer.unsortedAssets)
				{
					if (asset.thinger is ImposterOwnedStructure && asset.thinger.structure_id == newOwnedStructure.structure_id)
					{
						var structure:Structure = asset.thinger.structure;
						newOwnedStructure.structure = asset.thinger.structure;
						asset.thinger = new OwnedStructure(newOwnedStructure);
					}
				}
			}
		}
		
		public function createPurchaseCopy(thinger:Object):ActiveAsset
		{
			var asset:ActiveAsset;
			if (thinger is ImposterOwnedStructure)
			{
				asset = _structureManager.generateAssetFromOwnedStructure(thinger as ImposterOwnedStructure);
			}
			if (thinger is OwnedStructure)
			{
				asset = _structureManager.generateAssetFromOwnedStructure(thinger as OwnedStructure);
				var currentPoint:Point = new Point(_myWorld.mouseX, _myWorld.mouseY);
				_myWorld.addStaticAsset(asset, World.actualToWorldCoords(currentPoint));
				return asset;
			}
			return null;
		}
		
		private function onThingerSold(evt:StoreEvent):void
		{
			_myWorld.assetRenderer.removeOwnedThinger(evt.thinger);
		}
		
		public function evaluateClickedAsset(asset:Object):void
		{			
			if (asset is ActiveAsset)
			{
				var assetParent:ActiveAsset = asset as ActiveAsset;
				if (assetParent.thinger is OwnedStructure && (assetParent.thinger as OwnedStructure).editing == false)
				{
					resetEditMode();			
					activateMoveableStructure(assetParent);
					locked = true;
					(assetParent.thinger as OwnedStructure).editing = true;
				}
				else if (assetParent.thinger is OwnedStructure)
				{
					deactivateMoveableStructure();
					locked = false;
					(assetParent.thinger as OwnedStructure).editing = false;
					if (assetParent.thinger is ImposterOwnedStructure)
					{
						saveNewOwnedStructure(assetParent.thinger as OwnedStructure, assetParent);
					}
				}
			}			
		}
		
		public function resetEditMode():void
		{
			if (locked)
			{
				removeListenersFromWorld();
				resetAssetColor();
				updateCurrentAssetCoordinates();
				updateCurrentAssetMode(false);
				removeAllOwnedStructureEditOptions();
			}
		}
		
		public function removeListenersFromWorld():void
		{
			if (_myWorld.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				_myWorld.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
		public function resetAssetColor():void
		{
			if (currentAsset)
			{
				currentAsset.transform.colorTransform = NORMAL_COLOR;							
			}
		}
		
		public function updateCurrentAssetCoordinates():void
		{
			if (currentAsset)
			{
				var os:OwnedStructure = currentAsset.thinger as OwnedStructure;
				_myWorld.removeAsset(currentAsset);			
				var addTo:Point3D = new Point3D(os.x, os.y, os.z);
				_myWorld.addStaticAsset(currentAsset, addTo);								
			}
		}
		
		public function updateCurrentAssetMode(mode:Boolean):void
		{
			if (currentAsset)
			{
				(currentAsset.thinger as OwnedStructure).editing = mode;
			}
		}
				
		public function deactivateStructureWithoutSaving():void
		{
			if (currentAsset)
			{
				var os:OwnedStructure = currentAsset.thinger as OwnedStructure;
				os.editing = false;
//				_myWorld.removeAsset(currentAsset);			
			}
			removeListenersFromWorld();		
		}
		
		public function saveNewOwnedStructure(os:OwnedStructure, asset:ActiveAsset):void
		{
			_structureManager.serverController.sendRequest({user_id: _editView.userManager.user.id, owned_dwelling_id: _editView.venueManager.venue.id, structure_id: os.structure.id, x: asset.worldCoords.x, y: asset.worldCoords.y, z: asset.worldCoords.z}, "owned_structure", "create_new");
		}
		
		public function onWorldClicked(evt:MouseEvent):void
		{
			evaluateClickedAsset(evt.target.parent);
		}		
		
		public function showOwnedStructureEditOptions():void
		{
			var osEditOptions:OwnedStructureEditOptions = new OwnedStructureEditOptions(currentAsset, _myWorld, this);
			_editView.uiLayer.addChild(osEditOptions);
		}
		
		public function removeAllOwnedStructureEditOptions():void
		{
			_editView.uiLayer.removeAllChildren();
		}
		
		public function sellButtonClicked():void
		{
			var os:OwnedStructure = currentAsset.thinger as OwnedStructure;
			_structureManager.serverController.sendRequest({id: os.id}, "owned_structure", "sell");
			deactivateStructureWithoutSaving();
			locked = false;			
		}
		
		public function moveButtonClicked():void
		{
			_myWorld.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			currentAsset.speed = 1;			
		}
		
		public function startMoveWithoutEditOptions(asset:ActiveAsset):void
		{
			locked = true;
			(asset.thinger as OwnedStructure).editing = true;				
			currentAsset = asset;
			moveButtonClicked();		
		}
		
		public function activateMoveableStructure(asset:ActiveAsset):void
		{						
			currentAsset = asset;
			showOwnedStructureEditOptions();
		}
		
		public function deactivateMoveableStructure():void
		{
			if (!(currentAsset.thinger is ImposterOwnedStructure))
			{
				saveCurrentPlacement();			
			}
			if (_myWorld.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				_myWorld.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);			
			}
		}
		
		public function saveCurrentPlacement():void
		{
			var pointToSave:Point3D = new Point3D(Math.round(currentAsset.worldDestination.x), Math.round(currentAsset.worldDestination.y), Math.round(currentAsset.worldDestination.z));
			pointToSave = keepPointInBounds(pointToSave);
			var evt:DynamicEvent = new DynamicEvent('structurePlaced', true, true);
			evt.asset = currentAsset;
			evt.currentPoint = pointToSave;
			dispatchEvent(evt);
		}
		
		private function onMouseMove(evt:Event):void
		{
			var currentPoint:Point = new Point(_myWorld.mouseX, _myWorld.mouseY);
			var worldDestination:Point3D = World.actualToWorldCoords(currentPoint);
			worldDestination.x = Math.round(worldDestination.x);
			worldDestination.z = Math.round(worldDestination.z);
			
//			worldDestination = keepPointInBounds(worldDestination);
			_myWorld.moveAssetTo(currentAsset, worldDestination, false);
			
			if (isFurnitureOutOfBounds() || isFurnitureOnInvalidPoint())
			{
				currentAsset.transform.colorTransform = INVALID_COLOR;
			}
			else
			{
				currentAsset.transform.colorTransform = NORMAL_COLOR;
			}
		}
		
		public function isFurnitureOutOfBounds():Boolean
		{
			if (currentAsset.worldCoords.x + (currentAsset.thinger as OwnedStructure).structure.width / 2 > _myWorld.tilesWide || 
			currentAsset.worldCoords.x - (currentAsset.thinger as OwnedStructure).structure.width / 2 < 0 || 
			currentAsset.worldCoords.z + (currentAsset.thinger as OwnedStructure).structure.depth / 2 > _myWorld.tilesDeep || 
			currentAsset.worldCoords.z - (currentAsset.thinger as OwnedStructure).structure.depth / 2 < 0)
			{
				return true;
			}
			return false;
		}
		
		public function isFurnitureOnInvalidPoint():Boolean
		{			
			var exemptStructures:ArrayCollection = new ArrayCollection();
			exemptStructures.addItem(currentAsset.thinger as OwnedStructure);
			var occupiedSpaces:ArrayCollection = _myWorld.pathFinder.establishStructureOccupiedSpaces(exemptStructures);
			var structureSpaces:ArrayCollection = new ArrayCollection();
			structureSpaces = _myWorld.pathFinder.getPoint3DForMovingStructure(currentAsset, currentAsset.thinger as OwnedStructure, structureSpaces);
			for each (var pt3D:Point3D in structureSpaces)
			{
				if (occupiedSpaces.contains(_myWorld.pathFinder.mapPointToPathGrid(pt3D)))
				{
					return true;
				}
			}
			return false;
		}
		
		public function keepPointInBounds(destination:Point3D):Point3D
		{
			if (destination.x < 0)
			{
				destination.x = 0;
			}
			else if (destination.x > _myWorld.tilesWide)
			{
				destination.x = _myWorld.tilesWide;
			}
			if (destination.z < 0)
			{
				destination.z = 0;
			}
			else if (destination.z > _myWorld.tilesDeep)
			{
				destination.z = _myWorld.tilesDeep;
			}
			return destination;			
		}
		
		public function cancelEditActivities():void
		{
			if (locked)
			{
				deactivateStructureWithoutSaving();
				locked = false;
			}
		}
		
		public function set structureManager(val:StructureManager):void
		{
			_structureManager = val;
			_structureManager.addEventListener(StoreEvent.THINGER_SOLD, onThingerSold);	
			_structureManager.owned_structures.addEventListener(CollectionEvent.COLLECTION_CHANGE, onOwnedStructureCollectionChange);					
		}
		
		public function get structureManager():StructureManager
		{
			return _structureManager;
		}
		
	}
}