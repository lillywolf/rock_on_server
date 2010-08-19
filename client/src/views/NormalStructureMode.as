package views
{
	import controllers.StructureController;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.DynamicEvent;
	
	import rock_on.Venue;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;
	
	public class NormalStructureMode extends UIComponent
	{
		public var _structureController:StructureController;
		public var _editView:EditView;
		public var _venue:Venue;
		
		public var structureWorld:World;
		public var tileLayer:World;
		public var structureEditing:Boolean;
		public var currentStructure:ActiveAsset;
		public var currentStructurePoints:ArrayCollection;
		
		public function NormalStructureMode(editView:EditView, worldWidth:int, worldDepth:int, tileSize:int)
		{
			super();
			_editView = editView;
			_structureController = _editView.structureController;
			_venue = _editView.venueManager.venue;
			createStructureWorld(worldWidth, worldDepth, tileSize);
			currentStructurePoints = new ArrayCollection();

			this.addEventListener(Event.ADDED, onAdded);
		}
		
		private function onAdded(evt:Event):void
		{
			width = parent.width;
			height = parent.height;	
			tileLayer.x = _editView.worldOriginX;
			tileLayer.y = _editView.worldOriginY;
			structureWorld.x = _editView.worldOriginX;
			structureWorld.y = _editView.worldOriginY;
		}
		
		public function createStructureWorld(worldWidth:int, worldDepth:int, tileSize:int):void
		{
			addTileLayer(worldWidth, worldDepth, tileSize);
			structureWorld = new World(worldWidth, worldDepth, tileSize);
			addChild(structureWorld);
			showStructures();
		}		
		
		public function addTileLayer(worldWidth:int, worldDepth:int, tileSize:int):void
		{
			tileLayer = new World(worldWidth, worldDepth, tileSize);
			addChild(tileLayer);
			showTiles();
		}
		
		public function showStructures():void
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if (os.in_use && os.structure.structure_type != "Tile")
				{
					addStructureAsset(os, structureWorld);
				}
			}
		}
		
		public function showTiles():void
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if (os.in_use && os.structure.structure_type == "Tile")
				{
					addStructureAsset(os, tileLayer);
				}
			}
		}
		
		public function addStructureAsset(os:OwnedStructure, _world:World):ActiveAsset
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
			var asset:ActiveAsset = new ActiveAsset(mc);
			asset.thinger = os;
			_world.addAsset(asset, new Point3D(os.x, os.y, os.z));	
			return asset;
		}
		
		public function selectStructure(asset:ActiveAsset):void
		{
			if ((asset.thinger as OwnedStructure).structure.structure_type != "Tile")
			{
				currentStructure = asset;
				currentStructure.speed = 1;
				currentStructure.alpha = 0.5;
				structureEditing = true;
				_editView.addEventListener(MouseEvent.MOUSE_MOVE, onStructureMouseMove);				
			}	
		}
		
		public function handleClick(evt:MouseEvent):void
		{
			var coords:Point3D = World.actualToWorldCoords(new Point(structureWorld.mouseX, structureWorld.mouseY));
			var asset:ActiveAsset = evt.target as ActiveAsset;
//			var asset:ActiveAsset = getAccurateClickedStructure(coords);
			
			if (!structureEditing && asset)
			{
				selectStructure(asset);
			}
			else if (structureEditing && asset)
			{
				if (isStructureInBounds(asset) && !(doesStructureCollide(asset)))
				{
					placeStructure();				
				}
				else
				{
					revertStructure();
				}
			}
		}
		
		public function placeStructure():void
		{
			currentStructure.alpha = 1;
			currentStructure.filters = null;
			saveStructureCoords(currentStructure);
			resetEditMode();
		}
		
		public function revertStructure():void
		{
			if (isOwned(currentStructure))
			{
				var os:OwnedStructure = currentStructure.thinger as OwnedStructure;
				structureWorld.moveAssetTo(currentStructure, new Point3D(os.x, os.y, os.z));
			}
			else
			{
				removeImposterStructure(currentStructure);
			}
			resetEditMode();
		}
		
		public function removeImposterStructure(asset:ActiveAsset):void
		{
			structureWorld.removeAsset(asset);
		}
		
		public function isOwned(asset:ActiveAsset):Boolean
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if ((asset.thinger as OwnedStructure).id && (asset.thinger as OwnedStructure).id == os.id)
				{
					return true;
				}
			}
			return false;
		}
		
		public function resetEditMode():void
		{
			_editView.removeEventListener(MouseEvent.MOUSE_MOVE, onStructureMouseMove);
			structureEditing = false;
			currentStructure = null;
		}
		
		public function saveStructureCoords(asset:ActiveAsset):void
		{
			if (isOwned(asset))
			{
				var evt:DynamicEvent = new DynamicEvent("structurePlaced", true, true);
				evt.asset = asset;
				evt.currentPoint = asset.worldCoords;
				dispatchEvent(evt);
			}
			else
			{
				_structureController.saveNewOwnedStructure(asset.thinger as OwnedStructure, _venue, asset.worldCoords);
			}
		}	
		
		public function onStructureMouseMove(evt:MouseEvent):void
		{
			var destination:Point3D = World.actualToWorldCoords(new Point(structureWorld.mouseX, structureWorld.mouseY));
			var os:OwnedStructure = currentStructure.thinger as OwnedStructure;
			destination.y = Math.round(destination.y);
			if (os.structure.width%2 == 0)
			{
				destination.x = Math.round(destination.x);
			}
			else
			{
				destination.x = snapToCenterPoint(currentStructure, destination.x);
			}
			if (os.structure.depth%2 == 0)
			{
				destination.z = Math.round(destination.z);
			}
			else
			{
				destination.z = snapToCenterPoint(currentStructure, destination.z);
			}
			structureWorld.moveAssetTo(currentStructure, destination);
			updateStructureFilters();
		}
		
		private function snapToCenterPoint(asset:ActiveAsset, dimension:Number):Number
		{
			var center:Number = Math.round(dimension);
			if (center > dimension)
			{
				center = center - 0.5;
			}
			else
			{
				center = center + 0.5;
			}
			return center;
		}
		
		public function updateStructureFilters():void
		{
			if (currentStructure)
			{
				if (isStructureInBounds(currentStructure) && !doesStructureCollide(currentStructure))
					showValidStructureFilters();
				else
					showInvalidStructureFilters();
			}
		}
		
		public function isStructureInBounds(asset:ActiveAsset):Boolean
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			
			if ((asset.worldCoords.x - os.structure.width/2 < _venue.venueRect.left || 
				asset.worldCoords.x + os.structure.width/2 > _venue.venueRect.right ||
				asset.worldCoords.z - os.structure.depth/2 < _venue.venueRect.top ||
				asset.worldCoords.z + os.structure.depth/2 > _venue.venueRect.bottom) || 
				(asset.worldCoords.x - os.structure.width/2 >= _venue.audienceRect.left &&
				asset.worldCoords.x + os.structure.width/2 <= _venue.audienceRect.right - _venue.crowdBufferRect.width &&
				asset.worldCoords.z - os.structure.depth/2 >= _venue.audienceRect.top &&
				asset.worldCoords.z + os.structure.depth/2 <= _venue.audienceRect.bottom))
			{			
				return false;
			}
			return true;
		}
		
		public function doesStructureCollide(asset:ActiveAsset):Boolean
		{
			var structurePoints:ArrayCollection = _venue.myWorld.pathFinder.occupiedByStructures;
			var savedStructurePoints:ArrayCollection = getSavedStructurePoints(asset);
			currentStructurePoints = getCurrentStructurePoints(asset);
			for each (var pt3D:Point3D in currentStructurePoints)
			{
				if (structurePoints.contains(_venue.myWorld.pathFinder.mapPointToPathGrid(pt3D)) && 
					!(savedStructurePoints.contains(_venue.myWorld.pathFinder.mapPointToPathGrid(pt3D))))
					return true;
			}			
			return false;
		}
		
		private function getSavedStructurePoints(asset:ActiveAsset):ArrayCollection
		{
			var structurePoints:ArrayCollection = _venue.myWorld.pathFinder.getStructurePoints(asset.thinger as OwnedStructure);
			return structurePoints;
		}
		
		private function getCurrentStructurePoints(asset:ActiveAsset):ArrayCollection
		{
			var structurePoints:ArrayCollection = _venue.myWorld.pathFinder.getPoint3DForMovingStructure(asset);
			return structurePoints;
		}
		
		public function showValidStructureFilters():void
		{
			if (currentStructure)
			{
				currentStructure.alpha = 0.5;
				currentStructure.filters = null;
			}
		}
		
		public function showInvalidStructureFilters():void
		{
			if (currentStructure)
			{
				currentStructure.alpha = 1;
				var gf:GlowFilter = new GlowFilter(0xFF2655, 1, 2, 2, 20, 20);
				currentStructure.filters = [gf];			
			}
		}
		
		public function replaceStructure(os:OwnedStructure):void
		{
			
		}
		
		public function isStructureOccupied(asset:ActiveAsset):OwnedStructure
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if (asset.worldCoords.x == os.x &&
					asset.worldCoords.y == os.y &&
					asset.worldCoords.z == os.z &&
					(asset.thinger as OwnedStructure).id != os.id)
				{
					return os;
				}
			}
			return null;
		}		
	}
}