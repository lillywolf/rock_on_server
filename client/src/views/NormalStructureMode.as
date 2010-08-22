package views
{
	import controllers.StructureController;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.UIComponent;
	import mx.events.DynamicEvent;
	
	import rock_on.Venue;
	
	import world.ActiveAsset;
	import world.ActiveAssetStack;
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
		public var structureSurfaces:Array;
		public var allStructures:ArrayCollection;
		public var normalMode:Boolean;
		
		public function NormalStructureMode(editView:EditView, worldWidth:int, worldDepth:int, tileSize:int)
		{
			super();
			_editView = editView;
			_structureController = _editView.structureController;
			_venue = _editView.venueManager.venue;
			allStructures = new ArrayCollection();
			createStructureWorld(worldWidth, worldDepth, tileSize);
			currentStructurePoints = new ArrayCollection();
			createStructureSurfaces();

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
			structureWorld.assetRenderer.swapEnterFrameHandler();
			normalMode = false;
		}
		
		private function updateRenderingMode(asset:ActiveAsset):void
		{
			if ((asset.thinger as OwnedStructure).structure.structure_type == "StructureTopper" && normalMode)
				redrawForToppers();
			else if ((asset.thinger as OwnedStructure).structure.structure_type != "StructureTopper" && !normalMode)
				redrawForNormalStructures();
		}
		
		private function redrawForNormalStructures():void
		{
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				if (asset.toppers && asset.toppers.length > 0)
				{
					var aas:ActiveAssetStack = new ActiveAssetStack(null, asset.movieClip);
					aas.toppers = asset.toppers;
					aas.thinger = asset.thinger;
					structureWorld.removeAsset(asset);
					aas.setMovieClipsForStructure(aas.toppers);
					aas.reflected = false;
					aas.movieClip.gotoAndStop(0);
					aas.bitmapWithToppers();
					structureWorld.addAsset(aas, asset.worldCoords);
				}
				if ((asset.thinger as OwnedStructure).structure.structure_type == "StructureTopper")
					structureWorld.removeAsset(asset);
			}
			structureWorld.assetRenderer.revertEnterFrameHandler();
			normalMode = true;
		}

		private function redrawForToppers():void
		{
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				if (asset.toppers && asset.toppers.length > 0)
				{
					var a:ActiveAsset = new ActiveAsset(EssentialModelReference.getMovieClipCopy(asset.movieClip));
					a.toppers = asset.toppers;
					a.thinger = asset.thinger;
					updateAllStructures(a);
					structureWorld.removeAsset(asset);
					structureWorld.addAsset(a, asset.worldCoords);
				}
			}	
			for each (var t:ActiveAsset in allStructures)
			{
				if ((t.thinger as OwnedStructure).structure.structure_type == "StructureTopper")
					structureWorld.addAsset(t, t.worldCoords);	
			}	
			structureWorld.assetRenderer.swapEnterFrameHandler();
			normalMode = false;
		}
		
		private function updateAllStructures(a:ActiveAsset):void
		{
			for each (var asset:ActiveAsset in allStructures)
			{
				if (asset.thinger == a.thinger)
				{
					var index:int = allStructures.getItemIndex(asset);
					allStructures.removeItemAt(index);
					allStructures.addItem(a);
					return;
				}
			}
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
					addTileAsset(os, tileLayer);
				}
			}
		}
		
		public function addTileAsset(os:OwnedStructure, _world:World):ActiveAsset
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
			var asset:ActiveAsset = new ActiveAsset(mc);
			asset.thinger = os;		
			_world.addAsset(asset, new Point3D(os.x, os.y, os.z));	
			return asset;			
		}
		
		public function addStructureAsset(os:OwnedStructure, _world:World):ActiveAsset
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
			var asset:ActiveAsset = new ActiveAsset(mc);
			asset.thinger = os;
			asset.toppers = _structureController.getStructureToppers(os);
//			asset.setMovieClipsForStructure(_structureController.getStructureToppers(os));
//			asset.bitmapWithToppers();			
			_world.addAsset(asset, new Point3D(os.x, os.y, os.z));
			allStructures.addItem(asset);
			return asset;
		}
		
		public function selectStructure(asset:ActiveAsset):void
		{
			if ((asset.thinger as OwnedStructure).structure.structure_type != "Tile")
			{
				updateRenderingMode(asset);
				setCurrentStructure(asset);
				currentStructure.speed = 1;
				currentStructure.alpha = 0.5;
				structureEditing = true;
				_editView.addEventListener(MouseEvent.MOUSE_MOVE, onStructureMouseMove);				
			}
		}
		
		private function setCurrentStructure(asset:ActiveAsset):void
		{
			if (!asset.toppers)
				currentStructure = asset;
			else
			{
				for each (var a:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
				{
					if (a.thinger == asset.thinger)
						currentStructure = a;
				}
			}
		}
		
		private function removeTopperFromStructures(topper:OwnedStructure):void
		{
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				if (asset.toppers.contains(topper))
				{
					var index:int = asset.toppers.getItemIndex(topper);
					asset.toppers.removeItemAt(index);
				}	
			}
		}
		
		private function addTopperToStructure(topper:OwnedStructure, asset:ActiveAsset):void
		{
			if (!asset.toppers.contains(topper))
			{
				asset.toppers.addItem(topper);
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
			redrawForToppers();			
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
			updateStructureSurfaces(asset);
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
			updateFilterLogic(currentStructure, destination);
			doMoveLogic(destination);
		}
		
		private function doMoveLogic(destination:Point3D):void
		{
			structureWorld.moveAssetTo(currentStructure, destination);				
		}
		
		private function updateDestination(destination:Point3D, os:OwnedStructure):void
		{
			destination.y = os.structure.height;
		}
		
		private function updateFilterLogic(asset:ActiveAsset, destination:Point3D):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if ((asset.thinger as OwnedStructure).structure.structure_type == "StructureTopper")
			{	
				var parentStructure:ActiveAsset = checkStructureSurfaces();
				if (parentStructure)
				{	
					addTopperToStructure(os, parentStructure);
//					updateDestination(destination, parentStructure.thinger as OwnedStructure);
					showValidStructureFilters();
				}	
				else
				{	
					removeTopperFromStructures(os);	
					showInvalidStructureFilters();
				}	
			}	
			else
				updateStructureFilters();				
		}
		
		private function checkStructureSurfaces():ActiveAsset
		{
			currentStructurePoints = getCurrentStructurePoints(currentStructure);			
			for each (var pt3D:Point3D in currentStructurePoints)
			{
				if (structureSurfaces[pt3D.x] && structureSurfaces[pt3D.x][pt3D.y] && structureSurfaces[pt3D.x][pt3D.y][pt3D.z])
					return structureSurfaces[pt3D.x][pt3D.y][pt3D.z];
			}
			return null;
		}
		
		private function updateStructureSurfaces(asset:ActiveAsset):void
		{
			var pt:Point3D;
			var old:ArrayCollection = getSavedStructurePoints(asset);
			for each (pt in old)
			{
				removePointFromStructureSurfaces(pt);
			}
			var newPts:ArrayCollection = getCurrentStructurePoints(asset);
			for each (pt in newPts)
			{
				addPointToStructureSurfaces(pt, asset);
			}
		}
		
		private function createStructureSurfaces():void
		{
			structureSurfaces = new Array();
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				if ((asset.thinger as OwnedStructure).structure.structure_type != "StructureTopper" && (asset.thinger as OwnedStructure).structure.structure_type != "Tile")
				{
					var pts:ArrayCollection = _venue.myWorld.pathFinder.getStructurePoints(asset.thinger as OwnedStructure);
					for each (var pt:Point3D in pts)
					{
						addPointToStructureSurfaces(new Point3D(pt.x, pt.y, pt.z), asset);
					}
				}
			}
		}
		
		private function removePointFromStructureSurfaces(pt:Point3D):void
		{
			if (structureSurfaces[pt.x] && structureSurfaces[pt.x][pt.y] && structureSurfaces[pt.x][pt.y][pt.z])
				structureSurfaces[pt.x][pt.y][pt.z] = 0;
		}
		
		private function addPointToStructureSurfaces(pt:Point3D, asset:ActiveAsset):void
		{
			var xPt:Array;
			var yPt:Array;
			var zPt:Array;
			if (structureSurfaces[pt.x] && structureSurfaces[pt.x][pt.y])
			{
				structureSurfaces[pt.x][pt.y][pt.z] = asset;
			}
			else if (structureSurfaces[pt.x])
			{
				structureSurfaces[pt.x][pt.y] = new Array();
				structureSurfaces[pt.x][pt.y][pt.z] = asset;
			}
			else
			{
				structureSurfaces[pt.x] = new Array();
				structureSurfaces[pt.x][pt.y] = new Array();
				structureSurfaces[pt.x][pt.y][pt.z] = asset;
			}
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