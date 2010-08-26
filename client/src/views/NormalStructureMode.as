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
		public var structureRotating:Boolean;
		public var currentStructure:ActiveAsset;
		public var currentStructurePoints:ArrayCollection;
		public var structureSurfaces:Array;
		public var structureBases:Array;
		public var structureToppers:Array;
		public var allStructures:ArrayCollection;
		public var normalMode:Boolean;
		public var rotationToolEnabled:Boolean;
		
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
			createStructureBases();
			createStructureToppers();

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
			var toRemove:ArrayCollection = new ArrayCollection();
			var toAdd:ArrayCollection = new ArrayCollection();
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				if (asset.toppers && asset.toppers.length > 0)
				{
					var aas:ActiveAssetStack = new ActiveAssetStack(null, asset.movieClip);
					aas.copyFromActiveAsset(asset);
					aas.setMovieClipsForStructure(aas.toppers);
					aas.bitmapWithToppers();
					toRemove.addItem(asset);
					toAdd.addItem(aas);
				}
				if ((asset.thinger as OwnedStructure).structure.structure_type == "StructureTopper")
					toRemove.addItem(asset);
			}
			swapAssets(toRemove, toAdd);
			structureWorld.assetRenderer.revertEnterFrameHandler();
			normalMode = true;
		}

		private function redrawStructure(asset:ActiveAsset):ActiveAsset
		{
			var toRemove:ArrayCollection = new ArrayCollection();
			var toAdd:ArrayCollection = new ArrayCollection();			
			var aas:ActiveAssetStack = new ActiveAssetStack(null, asset.movieClip);
			aas.copyFromActiveAsset(asset);
			aas.setMovieClipsForStructure(aas.toppers);
			aas.bitmapWithToppers();
			toRemove.addItem(asset);
			toAdd.addItem(aas);
			normalMode = true;
			for each (var a:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				if ((a.thinger as OwnedStructure).structure.structure_type == "StructureTopper")
					toRemove.addItem(a);			
			}
			swapAssets(toRemove, toAdd);
			structureWorld.assetRenderer.revertEnterFrameHandler();
			return aas;
		}

		private function redrawForToppers():void
		{
			var toAdd:ArrayCollection = new ArrayCollection();
			var toRemove:ArrayCollection = new ArrayCollection();
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				if (asset.toppers && asset.toppers.length > 0)
				{
					var a:ActiveAsset = new ActiveAsset();
					a.movieClip = EssentialModelReference.getMovieClipCopy(asset.movieClip);
					a.copyFromActiveAsset(asset);
					a.reflected = asset.flipped;
					a.switchToBitmap();
					updateAllStructures(a);
					toRemove.addItem(asset);
					toAdd.addItem(a);
				}
			}	
			for each (var t:ActiveAsset in allStructures)
			{
				if ((t.thinger as OwnedStructure).structure.structure_type == "StructureTopper")
					toAdd.addItem(t);	
			}	
			swapAssets(toRemove, toAdd);
			structureWorld.assetRenderer.swapEnterFrameHandler();
			normalMode = false;
		}
		
		private function swapAssets(toRemove:ArrayCollection, toAdd:ArrayCollection):void
		{
			var aa:ActiveAsset;
			for each (aa in toRemove)
			{
				structureWorld.removeAsset(aa);
			}
			for each (aa in toAdd)
			{
				structureWorld.addAsset(aa, aa.worldCoords);
			}				
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
		
		public function selectStructureForRotation(asset:ActiveAsset):void
		{
			if ((asset.thinger as OwnedStructure).structure.structure_type != "Tile")
			{
				setCurrentStructure(asset);
				structureRotating = true;
				updateRotatedToppers(asset);							
				rotateAsset(asset, 1);
				currentStructure.speed = 1;
				currentStructure.alpha = 0.5;
				structureEditing = true;
				_editView.addEventListener(MouseEvent.MOUSE_MOVE, onStructureMouseMove);			}
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
				if (asset.toppers && asset.toppers.contains(topper))
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
		
		private function handleMoveClick(asset:ActiveAsset):void
		{			
			if (!structureEditing && asset)
				selectStructure(asset);
			else if (structureEditing && (currentStructure.thinger as OwnedStructure).structure.structure_type != "StructureTopper")
			{
				if (isStructureInBounds(currentStructure) && !(doesStructureCollide(currentStructure)))
					placeStructure();				
				else
					revertStructure();
			}
			else if (structureEditing && (currentStructure.thinger as OwnedStructure).structure.structure_type == "StructureTopper")
			{
				var parentAsset:ActiveAsset = checkStructureSurfaces();
				if (parentAsset && !doesTopperCollide(currentStructure))
					placeTopper(parentAsset);
				else
					revertStructure();
			}
		}
		
		private function handleRotationClick(asset:ActiveAsset):void
		{
			if (!structureRotating && asset)
				selectStructureForRotation(asset);
			else if (structureEditing && (currentStructure.thinger as OwnedStructure).structure.structure_type != "StructureTopper")
			{
				if (isStructureInBounds(asset) && !doesStructureCollide(currentStructure))
					placeStructureAfterRotating();
				else
					revertStructure();
			}
		}
		
		public function handleClick(evt:MouseEvent):void
		{
			var coords:Point3D = World.actualToWorldCoords(new Point(structureWorld.mouseX, structureWorld.mouseY));
			var asset:ActiveAsset = evt.target as ActiveAsset;
			
			if (rotationToolEnabled)
				handleRotationClick(asset);
			else
				handleMoveClick(asset);
		}
		
		public function placeStructure():void
		{
			currentStructure.alpha = 1;
			currentStructure.filters = null;
			saveStructureCoords(currentStructure);
			resetEditMode();
			redrawForToppers();			
		}
		
		
		public function placeStructureAfterRotating():void
		{
			currentStructure.alpha = 1;
			currentStructure.filters = null;
			saveStructureCoords(currentStructure);
			resetEditMode();
			redrawForToppers();	
		}		
		
		public function placeTopper(parentAsset:ActiveAsset):void
		{
			currentStructure.alpha = 1;
			currentStructure.filters = null;
			saveStructureCoords(currentStructure, parentAsset);
			updateStructureToppers(currentStructure);
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
				removeImposterStructure(currentStructure);
			if (!normalMode)
				reassignAndRedrawTopper(currentStructure);
			resetEditMode();
		}
		
		private function reassignAndRedrawTopper(topper:ActiveAsset):void
		{
			var asset:ActiveAsset = checkStructureSurfacesForSavedTopper();
			if (!asset.toppers.contains(topper))
				asset.toppers.addItem(topper.thinger);
			redrawForToppers();
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
			structureRotating = false;			
			currentStructure = null;
			updateStructureFilters();
		}
		
		public function saveStructureCoords(asset:ActiveAsset, parentAsset:ActiveAsset=null):void
		{
			if (isOwned(asset))
			{
				var evt:DynamicEvent = new DynamicEvent("structurePlaced", true, true);
				evt.asset = asset;
				if (parentAsset)
				{
					var parentOs:OwnedStructure = parentAsset.thinger as OwnedStructure;
					evt.currentPoint = new Point3D(asset.worldCoords.x + parentOs.structure.height, parentOs.structure.height, asset.worldCoords.z - parentOs.structure.height);
				}
				else
					evt.currentPoint = new Point3D(asset.worldCoords.x, asset.worldCoords.y, asset.worldCoords.z);
				dispatchEvent(evt);
			}
			else if (!isOwned(asset))
			{
				_structureController.saveNewOwnedStructure(asset.thinger as OwnedStructure, _venue, asset.worldCoords);
			}
			if (asset.toppers && asset.toppers.length > 0)
			{
				saveToppers(asset);
			}
			if ((asset.thinger as OwnedStructure).structure.structure_type != "StructureTopper")
			{	
				updateStructureSurfaces(asset);
				updateStructureBases(asset);
			}	
		}	
		
		private function saveToppers(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			var ptDiff:Point3D = new Point3D(asset.worldCoords.x - os.x, asset.worldCoords.y - os.y, asset.worldCoords.z - os.z);
			for each (var topper:OwnedStructure in asset.toppers)
			{
				var newPt:Point3D = new Point3D(topper.x + ptDiff.x, os.structure.height, topper.z + ptDiff.z);
				var evt:DynamicEvent = new DynamicEvent("structurePlaced", true, true);
				var topperAsset:ActiveAsset = getMatchingAssetForOwnedStructure(topper);
				topperAsset.worldCoords = new Point3D(newPt.x, os.structure.height, newPt.z);
				updateStructureToppers(topperAsset);
				evt.asset = topperAsset;
				evt.currentPoint = newPt;
				this.dispatchEvent(evt);
			}
		}
		
		private function getMatchingAssetForOwnedStructure(os:OwnedStructure):ActiveAsset
		{
			for each (var asset:ActiveAsset in allStructures)
			{
				if (asset.thinger && asset.thinger.id == os.id)
					return asset;
			}
			return null;
		}
		
		private function flip(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if (asset.flipped)
			{
				asset.flipped = false;
				os.flipped = false;
			}
			else
			{
				asset.flipped = true;
				os.flipped = true;
			}
		}
		
		private function rotate(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if (asset.rotated)
			{
				asset.rotated = false;
				os.rotated = false;
			}
			else
			{
				asset.rotated = true;
				os.rotated = true;
			}
		}
		
		private function rotateAsset(asset:ActiveAsset, degree:int):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;	
			asset.rotationDegree = (asset.rotationDegree + 1)%2;
			if (asset.rotationDegree == 1)
			{
				flip(asset);
				rotate(asset);
			}
			else if (asset.rotationDegree == 0)
				flip(asset);
			currentStructure = redrawStructure(asset);
		}
		
		private function updateRotatedToppers(asset:ActiveAsset):void
		{
			for each (var topper:OwnedStructure in asset.toppers)
			{
				var topperAsset:ActiveAsset = getMatchingAssetForOwnedStructure(topper);
				var xCoord:Number = topperAsset.worldCoords.x;
				var zCoord:Number = topperAsset.worldCoords.z;
				topperAsset.worldCoords.x = asset.worldCoords.z - zCoord + asset.worldCoords.x;
				topperAsset.worldCoords.z = xCoord - asset.worldCoords.x + asset.worldCoords.z;
				topper.x = topperAsset.worldCoords.x;
				topper.z = topperAsset.worldCoords.z;
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
				if (parentStructure && !doesTopperCollide(asset))
				{	
					addTopperToStructure(os, parentStructure);
//					updateDestination(destination, parentStructure.thinger as OwnedStructure);
					showValidStructureFilters();
				}	
				else if (parentStructure)
				{
					addTopperToStructure(os, parentStructure);
					showInvalidStructureFilters();					
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
			currentStructurePoints = getOccupiedOuterPoints(currentStructure);	
			var oldParent:ActiveAsset;
			var newParent:ActiveAsset;
			var numSpaces:int = currentStructurePoints.length;
			var spaceCount:int = 0;
			for each (var pt3D:Point3D in currentStructurePoints)
			{
				if (structureSurfaces[pt3D.x] && structureSurfaces[pt3D.x][pt3D.y] && structureSurfaces[pt3D.x][pt3D.y][pt3D.z])
				{	
					newParent = structureSurfaces[pt3D.x][pt3D.y][pt3D.z];
					if (!oldParent || oldParent == newParent)
					{	
						spaceCount++;
						oldParent = newParent;
					}
					else
						return null;
				}	
			}
			if (spaceCount == numSpaces)
				return newParent;
			return null;
		}
		
		private function checkStructureSurfacesForSavedTopper():ActiveAsset
		{
			currentStructurePoints = getSavedStructurePoints(currentStructure, false);		
			var os:OwnedStructure = currentStructure.thinger as OwnedStructure;
			for each (var pt3D:Point3D in currentStructurePoints)
			{
				var adjusted:Point3D = new Point3D(pt3D.x - os.structure.height, pt3D.y, pt3D.x + os.structure.height);
				if (structureSurfaces[adjusted.x] && structureSurfaces[adjusted.x][adjusted.y] && structureSurfaces[adjusted.x][adjusted.y][adjusted.z])
					return structureSurfaces[adjusted.x][adjusted.y][adjusted.z];
			}
			return null;
		}		
		
		private function updateStructureSurfaces(asset:ActiveAsset):void
		{
			var pt:Point3D;
			var old:ArrayCollection = getSavedStructurePoints(asset, false);
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			for each (pt in old)
			{
				removePointFrom3DArray(new Point3D(pt.x - os.structure.height, pt.y, pt.z + os.structure.height), structureSurfaces);
			}
			var newPts:ArrayCollection = getOccupiedOuterPoints(asset);
			for each (pt in newPts)
			{
				addPointTo3DArray(new Point3D(pt.x - os.structure.height, pt.y, pt.z + os.structure.height), asset, structureSurfaces);
			}
		}

		private function updateStructureBases(asset:ActiveAsset):void
		{
			var pt:Point3D;
			var old:ArrayCollection = getSavedStructurePoints(asset, true);
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			for each (pt in old)
			{
				removePointFrom3DArray(new Point3D(pt.x, pt.y, pt.z), structureBases);
			}
			var newPts:ArrayCollection = getOccupiedInnerPoints(asset);
			for each (pt in newPts)
			{
				addPointTo3DArray(new Point3D(pt.x, pt.y, pt.z), asset, structureBases);
			}
		}
		
		private function updateStructureToppers(asset:ActiveAsset):void
		{
			var pt:Point3D;
			var old:ArrayCollection = getSavedStructurePoints(asset, true);
			var os:OwnedStructure = asset.thinger as OwnedStructure;			
			for each (pt in old)
			{
				removePointFrom3DArray(new Point3D(pt.x - os.structure.height, pt.y, pt.z + os.structure.height), structureToppers);
			}
			var newPts:ArrayCollection = getOccupiedInnerPoints(asset);
			for each (pt in newPts)
			{
				addPointTo3DArray(new Point3D(pt.x - os.structure.height, pt.y, pt.z + os.structure.height), asset, structureToppers);
			}
		}
		
		private function createStructureSurfaces():void
		{
			structureSurfaces = new Array();
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				var os:OwnedStructure = asset.thinger as OwnedStructure;
				if (os.structure.structure_type != "StructureTopper" && os.structure.structure_type != "Tile")
				{
					var pts:ArrayCollection = getOccupiedOuterPoints(asset);
					for each (var pt:Point3D in pts)
					{
						addPointTo3DArray(new Point3D(pt.x - os.structure.height, pt.y, pt.z + os.structure.height), asset, structureSurfaces);
					}
				}
			}
		}
		
		private function createStructureBases():void
		{
			structureBases = new Array();
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				var os:OwnedStructure = asset.thinger as OwnedStructure;
				if (os.structure.structure_type != "StructureTopper" && os.structure.structure_type != "Tile")
				{
					var pts:ArrayCollection = getOccupiedInnerPoints(asset);
					for each (var pt:Point3D in pts)
					{
						addPointTo3DArray(new Point3D(pt.x, pt.y, pt.z), asset, structureBases);
					}
				}
			}
		}		

		private function createStructureToppers():void
		{
			structureToppers = new Array();
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				var os:OwnedStructure = asset.thinger as OwnedStructure;
				if (os.structure.structure_type == "StructureTopper")
				{
					var pts:ArrayCollection = getOccupiedInnerPoints(asset);
					for each (var pt:Point3D in pts)
					{
						addPointTo3DArray(new Point3D(pt.x - os.structure.height, pt.y, pt.z + os.structure.height), asset, structureToppers);
					}
				}
			}
		}		
		
		private function removePointFrom3DArray(pt:Point3D, removeFrom:Array):void
		{
			if (removeFrom[pt.x] && removeFrom[pt.x][pt.y] && removeFrom[pt.x][pt.y][pt.z])
				removeFrom[pt.x][pt.y][pt.z] = 0;
		}
		
		private function addPointTo3DArray(pt:Point3D, asset:ActiveAsset, addTo:Array):void
		{
			if (addTo[pt.x] && addTo[pt.x][pt.y])
			{	
				addTo[pt.x][pt.y][pt.z] = asset;
			}
			else if (addTo[pt.x])
			{
				addTo[pt.x][pt.y] = new Array();
				addTo[pt.x][pt.y][pt.z] = asset;
			}
			else
			{
				addTo[pt.x] = new Array();
				addTo[pt.x][pt.y] = new Array();
				addTo[pt.x][pt.y][pt.z] = asset;
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
			else
			{
				clearFilters();
			}
		}
		
		public function isStructureInBounds(asset:ActiveAsset):Boolean
		{
		var os:OwnedStructure = asset.thinger as OwnedStructure;

			if ((asset.worldCoords.x - os.structure.width/2 < _venue.venueRect.left || 
				asset.worldCoords.x + os.structure.width/2 > _venue.venueRect.right ||
				asset.worldCoords.z - os.structure.depth/2 < _venue.venueRect.top ||
				asset.worldCoords.z + os.structure.depth/2 > _venue.venueRect.bottom) || 
					(asset.worldCoords.x + os.structure.width/2 > _venue.audienceRect.left &&
					asset.worldCoords.x - os.structure.width/2 < _venue.audienceRect.right - _venue.crowdBufferRect.width &&
					asset.worldCoords.z + os.structure.depth/2 > _venue.audienceRect.top &&
					asset.worldCoords.z - os.structure.depth/2 < _venue.audienceRect.bottom))
			{			
				return false;
			}	
			return true;
		}
		
		public function doesStructureCollide(asset:ActiveAsset):Boolean
		{
			currentStructurePoints = getOccupiedOuterPoints(asset);
			for each (var pt3D:Point3D in currentStructurePoints)
			{
				if (structureBases[pt3D.x] && structureBases[pt3D.x][pt3D.y] && structureBases[pt3D.x][pt3D.y][pt3D.z] &&
					(structureBases[pt3D.x][pt3D.y][pt3D.z] as ActiveAsset).thinger.id != asset.thinger.id)
					return true;
			}	
			return false;
		}
		
		private function doesTopperCollide(asset:ActiveAsset):Boolean
		{
			currentStructurePoints = getOccupiedOuterPoints(asset);
			for each (var pt3D:Point3D in currentStructurePoints)
			{
				if (structureToppers[pt3D.x] && structureToppers[pt3D.x][pt3D.y] && structureToppers[pt3D.x][pt3D.y][pt3D.z] &&
					(structureToppers[pt3D.x][pt3D.y][pt3D.z] as ActiveAsset).thinger.id != asset.thinger.id)
					return true;
			}	
			return false;
		}
			
		private function getSavedStructurePoints(asset:ActiveAsset, inner:Boolean):ArrayCollection
		{
			var structurePoints:ArrayCollection;
			if (inner)
				structurePoints = getSavedInnerPoints(asset.thinger as OwnedStructure);
			else
				structurePoints = getSavedOuterPoints(asset.thinger as OwnedStructure);
			return structurePoints;
		}

		private function getOccupiedOuterPoints(asset:ActiveAsset):ArrayCollection
		{		
			var structurePoints:ArrayCollection = new ArrayCollection();
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			
			for (var xPt:int = 0; xPt <= os.structure.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(asset.worldCoords.x - os.structure.width/2 + xPt), 0, Math.round(asset.worldCoords.z - os.structure.depth/2 + zPt));
					structurePoints.addItem(osPt3D);										
				}
			}
			return structurePoints;
		}			
		
		private function getOccupiedInnerPoints(asset:ActiveAsset):ArrayCollection
		{		
			var structurePoints:ArrayCollection = new ArrayCollection();
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			
			for (var xPt:int = 1; xPt < os.structure.width; xPt++)
			{
				for (var zPt:int = 1; zPt < os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(asset.worldCoords.x - os.structure.width/2 + xPt), 0, Math.round(asset.worldCoords.z - os.structure.depth/2 + zPt));
					structurePoints.addItem(osPt3D);										
				}
			}
			return structurePoints;
		}
		
		private function getSavedOuterPoints(os:OwnedStructure):ArrayCollection
		{		
			var structurePoints:ArrayCollection = new ArrayCollection();
			
			for (var xPt:int = 0; xPt <= os.structure.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(os.x - os.structure.width/2 + xPt), 0, Math.round(os.z - os.structure.depth/2 + zPt));
					structurePoints.addItem(osPt3D);										
				}
			}
			return structurePoints;
		}		
		
		private function getSavedInnerPoints(os:OwnedStructure):ArrayCollection
		{		
			var structurePoints:ArrayCollection = new ArrayCollection();
			
			for (var xPt:int = 1; xPt < os.structure.width; xPt++)
			{
				for (var zPt:int = 1; zPt < os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(os.x - os.structure.width/2 + xPt), 0, Math.round(os.z - os.structure.depth/2 + zPt));
					structurePoints.addItem(osPt3D);										
				}
			}
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
		
		public function clearFilters():void
		{
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				asset.alpha = 1;
				asset.filters = null;
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