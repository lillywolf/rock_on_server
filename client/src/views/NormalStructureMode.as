package views
{
	import controllers.StructureController;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import game.ImposterOwnedStructure;
	
	import models.EssentialModelReference;
	import models.OwnedSong;
	import models.OwnedStructure;
	import models.OwnedThinger;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.UIComponent;
	import mx.events.DynamicEvent;
	
	import rock_on.Venue;
	
	import server.ServerDataEvent;
	
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
		public var structureBasesOuter:Array;
		public var structureToppers:Array;
		public var structureSingletons:Array;
		public var allStructures:ArrayCollection;
		public var normalMode:Boolean;
		public var rotationToolEnabled:Boolean;
		public var inventoryToolEnabled:Boolean;
		
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
			createStructureBasesOuter();
			createStructureToppers();
			createStructureSingletons()

			_structureController.addEventListener(ServerDataEvent.INSTANCE_CREATED, onNewInstanceCreated);
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
					aas.toppers = asset.toppers;
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
			var aas:ActiveAssetStack = new ActiveAssetStack(null, asset.movieClip);
			aas.copyFromActiveAsset(asset);
			aas.toppers = asset.toppers;
			aas.setMovieClipsForStructure(aas.toppers);
			aas.bitmapWithToppers();
			var a:ActiveAsset = getMatchingAssetFromAssetRenderer(asset.thinger as OwnedStructure);
			structureWorld.removeAsset(a);
			structureWorld.addAsset(aas, aas.worldCoords);
			normalMode = true;
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
					a.toppers = asset.toppers;
					a.switchToBitmap();
					updateAllStructures(a);
					toRemove.addItem(asset);
					toAdd.addItem(a);
				}
			}	
			if (normalMode)
			{
				for each (var t:ActiveAsset in allStructures)
				{
					if ((t.thinger as OwnedStructure).structure.structure_type == "StructureTopper")
						toAdd.addItem(t);	
				}	
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
//			Do I need this stupid fucking function?
			
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
					addStructureAsset(os, structureWorld);
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
			asset.copyFromOwnedStructure(os);
			asset.toppers = _structureController.getStructureToppers(os);
			asset.switchToBitmap();
			_world.addAsset(asset, new Point3D(os.x, os.y, os.z));
			allStructures.addItem(asset);
			if (os.structure.structure_type == "ConcertStage")
				_world.addToPrioritizedRenderList(asset);
			return asset;
		}

		public function addStructureAssetFromInventory(os:OwnedStructure, _world:World):ActiveAsset
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
			var asset:ActiveAsset = new ActiveAsset(mc);
			asset.copyFromOwnedStructure(os);
			asset.switchToBitmap();
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
				structureEditing = true;
				cutStructureFromCollisionArrays(asset);
				_editView.addEventListener(MouseEvent.MOUSE_MOVE, onStructureMouseMove);
				
				dispatchSelectEvent(asset);
			}
		}
		
		private function cutStructureFromCollisionArrays(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if (os.structure.structure_type != "StructureTopper")
			{
				if (os.depth == 1 && os.width == 1)
					removeSavedPointsFromSingletonsArray(asset.thinger as OwnedStructure);
				else
				{
					removeSavedPointsFromBasesArray(asset);
					removeSavedPointsFromOuterBasesArray(asset);
				}
				removeSavedPointsFromSurfacesArray(asset.thinger as OwnedStructure);
				for each (var topper:OwnedStructure in asset.toppers)
				{
					removeSavedPointsFromStructureToppers(topper);			
				}
			}
			else
				cutTopperFromCollisionArrays(asset);
		}
		
		private function addStructureToCollisionArrays(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if (os.structure.structure_type != "StructureTopper")
			{			
				if (os.depth == 1 && os.width == 1)
					addCurrentPointsToSingletonsArray(asset);
				else
				{
					addCurrentPointsToBasesArray(asset);
					addCurrentPointsToOuterBasesArray(asset);
				}
				addCurrentPointsToSurfacesArray(asset);
				for each (var topper:OwnedStructure in asset.toppers)
				{
					addCurrentPointsToStructureToppers(getMatchingAssetForOwnedStructure(topper));
				}
			}
			else
				addTopperToCollisionArrays(asset);
		}

		private function addSavedStructureToCollisionArrays(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if (os.structure.structure_type != "StructureTopper")
			{	
				if (os.depth == 1 && os.width == 1)
					addSavedPointsToSingletonsArray(asset);
				else
				{
					addSavedPointsToBasesArray(asset);
					addSavedPointsToOuterBasesArray(asset);
				}
				addSavedPointsToSurfacesArray(asset);
				for each (var topper:OwnedStructure in asset.toppers)
				{
					addSavedPointsToStructureToppers(getMatchingAssetForOwnedStructure(topper));
				}
			}	
			else
				addSavedPointsToStructureToppers(asset);
		}
		
		private function cutTopperFromCollisionArrays(topperAsset:ActiveAsset):void
		{
			removeSavedPointsFromStructureToppers(topperAsset.thinger as OwnedStructure);
		}
		
		private function addTopperToCollisionArrays(topperAsset:ActiveAsset):void
		{
			addCurrentPointsToStructureToppers(topperAsset);
		}
		
		public function selectStructureForRotation(asset:ActiveAsset):void
		{
			if ((asset.thinger as OwnedStructure).structure.structure_type != "Tile")
			{
				structureRotating = true;
				
//				Do this before rotation changes owned structure
				cutStructureFromCollisionArrays(asset);

//				Rotate and redraw
				updateRotatedToppers(asset);
				rotateAsset(asset);
				redrawForNormalStructures();
				currentStructure = redrawStructure(asset);	
				
				currentStructure.speed = 1;
				structureEditing = true;
				updateStructureFilters();				
				_editView.addEventListener(MouseEvent.MOUSE_MOVE, onStructureMouseMove);	
				
				dispatchSelectEvent(currentStructure);
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
			currentStructure.speed = 1;
			currentStructure.alpha = 0.5;			
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
			if (!asset.toppers)
				asset.toppers = new ArrayCollection();
			if (!asset.toppers.contains(topper))
				asset.toppers.addItem(topper);
		}
		
		private function handleMoveClick(asset:ActiveAsset):void
		{			
			if (!structureEditing && asset)
				selectStructure(asset);
			else if (structureEditing && (currentStructure.thinger as OwnedStructure).structure.structure_type != "StructureTopper")
			{
				if (isStructureInBounds(currentStructure) && !(doesStructureCollide(currentStructure)))
					placeNormalStructure();				
				else
					revertStructure();
			}
			else if (structureEditing && (currentStructure.thinger as OwnedStructure).structure.structure_type == "StructureTopper")
			{
				var parentAsset:ActiveAsset = checkStructureSurfaces(currentStructure);
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
			else if (structureRotating && (currentStructure.thinger as OwnedStructure).structure.structure_type != "StructureTopper")
			{
				if (isStructureInBounds(asset) && !doesStructureCollide(currentStructure))
					placeStructureAfterRotating();
				else
					revertStructureAfterRotating();
			}
		}
		
		public function handleClick(evt:MouseEvent):void
		{
			var coords:Point3D = World.actualToWorldCoords(new Point(structureWorld.mouseX, structureWorld.mouseY));
			var asset:ActiveAsset = evt.target as ActiveAsset;
			
			if (rotationToolEnabled)
				handleRotationClick(asset);
			else if (inventoryToolEnabled)
				placeInInventory(asset);
			else
				handleMoveClick(asset);
		}
		
		public function placeNormalStructure():void
		{
			currentStructure.alpha = 1;
			currentStructure.filters = null;
			saveStructureCoords(currentStructure);
			addStructureToCollisionArrays(currentStructure);
			resetEditMode();
			redrawForToppers();	
			dispatchPlaceEvent();
		}
		
		public function placeTopper(parentAsset:ActiveAsset):void
		{
			currentStructure.alpha = 1;
			currentStructure.filters = null;
			saveStructureCoords(currentStructure, parentAsset);
			addTopperToCollisionArrays(currentStructure);
			resetEditMode();
			redrawForToppers();
			dispatchPlaceEvent();
		}
		
		public function placeStructureAfterRotating():void
		{
			currentStructure.alpha = 1;
			currentStructure.filters = null;
			saveStructureCoordsAndRotation(currentStructure);
			addStructureToCollisionArrays(currentStructure);			
			resetEditMode();
			redrawForToppers();	
			dispatchPlaceEvent();
		}
		
		private function dispatchPlaceEvent():void
		{
			var evt:DynamicEvent = new DynamicEvent("objectPlaced", true, true);
			_editView.dispatchEvent(evt);
		}

		private function dispatchSelectEvent(asset:ActiveAsset):void
		{
			var evt:DynamicEvent = new DynamicEvent("objectSelected", true, true);
			evt.selectedObject = asset;
			_editView.dispatchEvent(evt);
		}
		
		public function revertStructure():void
		{
			moveStructureBack(currentStructure);
			addSavedStructureToCollisionArrays(currentStructure);
			resetEditMode();
		}
		
		private function revertStructureAfterRotating():void
		{
			revertRotatedToppers(currentStructure);
			revertRotation(currentStructure);
			
//			Redraws asset as it was pre-rotation
			currentStructure = redrawStructure(currentStructure);
			moveStructureBack(currentStructure);
			
			addSavedStructureToCollisionArrays(currentStructure);
			resetEditMode();
		}		

		private function moveStructureBack(asset:ActiveAsset):void
		{			
			if (isOwned(currentStructure) && (currentStructure.thinger as OwnedStructure).in_use)
			{
				var os:OwnedStructure = asset.thinger as OwnedStructure;
				structureWorld.moveAssetTo(asset, new Point3D(os.x, os.y, os.z));
			}
			else if (isOwned(currentStructure) && !(currentStructure.thinger as OwnedStructure).in_use)
				replaceInInventory(currentStructure.thinger as OwnedStructure);
			else
				removeImposterStructure(asset);
			if (!normalMode)
				reassignAndRedrawTopper(asset);
		}
		
		private function replaceInInventory(os:OwnedStructure):void
		{
			
		}
		
		private function revertRotation(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			os.rotation = 3-os.rotation+((os.rotation-2)%2)*(2*os.rotation-4);
			asset.setRotation(os);			
		}
		
		private function reassignAndRedrawTopper(topper:ActiveAsset):void
		{
			var asset:ActiveAsset = checkStructureSurfacesForSavedTopper();
			if (!asset.toppers)
				asset.toppers = new ArrayCollection();
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
					return true;
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
		
		public function saveStructureCoordsAndRotation(asset:ActiveAsset):void
		{
			if (isOwned(asset))
			{
				var evt:DynamicEvent = new DynamicEvent("structurePlacedAndRotated", true, true);
				evt.asset = asset;	
				evt.rotation = (asset.thinger as OwnedStructure).rotation;
				evt.currentPoint = new Point3D(asset.worldCoords.x, asset.worldCoords.y, asset.worldCoords.z);
				dispatchEvent(evt);
				
				if (asset.toppers && asset.toppers.length > 0)
					saveToppers(asset);	
				
//				_venue.doStructureRedraw(asset);
			}		
		}
		
		public function saveStructureCoords(asset:ActiveAsset, parentAsset:ActiveAsset=null):void
		{
			if (isOwned(asset))
				saveOwnedStructureCoords(asset, parentAsset);
			else if (!isOwned(asset))
			{
				saveNewOwnedStructureCoords(asset, parentAsset);				
				_structureController.saveNewOwnedStructure(asset.thinger as ImposterOwnedStructure, _venue, asset.worldCoords);
			}
		}
		
		private function onNewInstanceCreated(evt:ServerDataEvent):void
		{
			for each (var asset:ActiveAsset in allStructures)
			{
				if (asset.thinger is ImposterOwnedStructure && (asset.thinger as ImposterOwnedStructure).id == evt.params.id)
					asset.thinger = evt.params;
			}
		}
		
		private function saveNewOwnedStructureCoords(asset:ActiveAsset, parentAsset:ActiveAsset=null):void
		{	
//			Add to imposters array in structureController and assign a temporary id of -1 so it counts as owned, and give it a key
			_structureController.imposters.addItem(asset.thinger as OwnedStructure);
			(asset.thinger as ImposterOwnedStructure).key = Math.random();
			(asset.thinger as OwnedStructure).id = -1;
			
			if (parentAsset)
			{
				var parentOs:OwnedStructure = parentAsset.thinger as OwnedStructure;				
				(asset.thinger as OwnedStructure).x = asset.worldCoords.x + parentOs.structure.height;
				(asset.thinger as OwnedStructure).y = parentOs.structure.height;
				(asset.thinger as OwnedStructure).z = asset.worldCoords.z - parentOs.structure.height;				
				doTopperRedraw(asset.thinger as OwnedStructure, parentAsset);								
			}
//			else
//				_venue.doStructureRedraw(asset);
		}
		
		private function saveOwnedStructureCoords(asset:ActiveAsset, parentAsset:ActiveAsset=null):void
		{
			var evt:DynamicEvent = new DynamicEvent("structurePlaced", true, true);
			evt.asset = asset;
			
			if (parentAsset)
			{
//				Brings topper coords back up to parent structure height
				var parentOs:OwnedStructure = parentAsset.thinger as OwnedStructure;
				evt.currentPoint = new Point3D(asset.worldCoords.x + parentOs.structure.height, parentOs.structure.height, asset.worldCoords.z - parentOs.structure.height);
				(asset.thinger as OwnedStructure).x = asset.worldCoords.x + parentOs.structure.height;
				(asset.thinger as OwnedStructure).y = parentOs.structure.height;
				(asset.thinger as OwnedStructure).z = asset.worldCoords.z - parentOs.structure.height;
				doTopperRedraw(asset.thinger as OwnedStructure, parentAsset);				
			}
			else
			{		
				evt.currentPoint = new Point3D(asset.worldCoords.x, asset.worldCoords.y, asset.worldCoords.z);
//				If asset has toppers then save their coords
				if (asset.toppers && asset.toppers.length > 0)
					saveToppers(asset);
//				_venue.doStructureRedraw(asset);
			}
			
			dispatchEvent(evt);			
		}
		
		private function saveToppers(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			var ptDiff:Point3D = new Point3D(asset.worldCoords.x - os.x, asset.worldCoords.y - os.y, asset.worldCoords.z - os.z);
			for each (var topper:OwnedStructure in asset.toppers)
			{
//				Update topper coords based on parent structure move
				var newPt:Point3D = new Point3D(topper.x + ptDiff.x, os.structure.height, topper.z + ptDiff.z);
				var evt:DynamicEvent = new DynamicEvent("structurePlaced", true, true);
				var topperAsset:ActiveAsset = getMatchingAssetForOwnedStructure(topper);
				topperAsset.worldCoords = new Point3D(newPt.x, os.structure.height, newPt.z);
				
				evt.asset = topperAsset;
				evt.currentPoint = newPt;
				this.dispatchEvent(evt);
			}
		}
		
		private function doTopperRedraw(topper:OwnedStructure, parentAsset:ActiveAsset):void
		{
//			for each (var asset:ActiveAsset in _venue.myWorld.assetRenderer.unsortedAssets)
//			{
//				if (asset.toppers && asset.toppers.contains(topper) && 
//					asset.thinger.id != parentAsset.thinger.id)
//				{
//					var index:int = asset.toppers.getItemIndex(topper);
//					asset.toppers.removeItemAt(index);
//					_venue.doStructureRedraw(asset);					
//				}
//			}
			if (!parentAsset.toppers.contains(topper))
				parentAsset.toppers.addItem(topper);
//			_venue.doStructureRedraw(parentAsset);
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

		private function getMatchingAssetFromAssetRenderer(os:OwnedStructure):ActiveAsset
		{
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				if (asset.thinger && asset.thinger.id == os.id)
					return asset;
			}
			return null;
		}
		
		private function rotateAsset(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;	
			os.rotation = (os.rotation+1)%4;
			asset.setRotation(os);
		}
		
		private function updateRotatedToppers(asset:ActiveAsset):void
		{
			for each (var topper:OwnedStructure in asset.toppers)
			{
				var topperAsset:ActiveAsset = getMatchingAssetForOwnedStructure(topper);
				var xCoord:Number = topperAsset.worldCoords.x;
				var zCoord:Number = topperAsset.worldCoords.z;
				if ((asset.rotated && !asset.flipped) || (!asset.rotated && !asset.flipped))
				{
					topperAsset.worldCoords.x = xCoord;
					topperAsset.worldCoords.z = 2 * asset.worldCoords.z - zCoord;
				}	
				else
				{
					topperAsset.worldCoords.x = asset.worldCoords.z - zCoord + asset.worldCoords.x;
					topperAsset.worldCoords.z = xCoord - asset.worldCoords.x + asset.worldCoords.z;
				}
				topper.x = topperAsset.worldCoords.x;
				topper.z = topperAsset.worldCoords.z;
			}
		}

		private function revertRotatedToppers(asset:ActiveAsset):void
		{
			for each (var topper:OwnedStructure in asset.toppers)
			{
				var topperAsset:ActiveAsset = getMatchingAssetForOwnedStructure(topper);
				var os:OwnedStructure = asset.thinger as OwnedStructure;
				var xCoord:Number = topper.x;
				var zCoord:Number = topper.z;
				if ((asset.rotated && asset.flipped) || (!asset.rotated && asset.flipped))
				{
					topperAsset.worldCoords.x = xCoord;
					topperAsset.worldCoords.z = 2 * os.z - zCoord;
				}	
				else
				{
					topperAsset.worldCoords.x = os.x + zCoord - os.z;
					topperAsset.worldCoords.z = os.x - xCoord + os.z;
				}
				topper.x = topperAsset.worldCoords.x;
				topper.z = topperAsset.worldCoords.z;
			}
		}
				
		public function onStructureMouseMove(evt:MouseEvent):void
		{
			var os:OwnedStructure = currentStructure.thinger as OwnedStructure;
			
//			Get destination of structure; If it's a stage decoration, give it a height base
			var destination:Point3D;
			if (os.structure.structure_type == "StageDecoration")
				destination = World.actualToWorldCoords(new Point(structureWorld.mouseX, structureWorld.mouseY), os.y);
			else
				destination = World.actualToWorldCoords(new Point(structureWorld.mouseX, structureWorld.mouseY));
			
			destination.y = Math.round(destination.y);
			if (os.width%2 == 0)
				destination.x = Math.round(destination.x);
			else
				destination.x = snapToCenterPoint(currentStructure, destination.x);
			if (os.depth%2 == 0)
				destination.z = Math.round(destination.z);
			else
				destination.z = snapToCenterPoint(currentStructure, destination.z);
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
				var parentStructure:ActiveAsset = checkStructureSurfaces(currentStructure);
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
		
		private function bringPointsToYZero(points:ArrayCollection):void
		{
			for each (var pt:Point3D in points)
			{
				pt.x = pt.x + pt.y;
				pt.y = 0;
				pt.z = pt.x - pt.y;
			}
		}
		
		private function checkStructureSurfaces(asset:ActiveAsset):ActiveAsset
		{
			currentStructurePoints = getOccupiedOuterPoints(asset);	
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
		
		private function getExtraBasePointsByStructureType(asset:ActiveAsset):ArrayCollection
		{
			var extra:ArrayCollection = new ArrayCollection();
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if (os.structure.structure_type == "Booth")
				extra.addItem(getStructureFrontByRotation(asset, os));
			else if (os.structure.structure_type == "ListeningStation")
				extra.addItem(getStructureFrontByRotation(asset, os));
			return extra;		
		}
		
		private function getStructureFrontByRotation(asset:ActiveAsset, os:OwnedStructure):Point3D
		{
			if (os.rotation == 0)
				return new Point3D(Math.ceil(asset.worldCoords.x + os.width/2 + 1), asset.worldCoords.y, Math.round(asset.worldCoords.z));
			else if (os.rotation == 1)
				return new Point3D(Math.round(asset.worldCoords.x), asset.worldCoords.y, Math.ceil(asset.worldCoords.z + os.depth/2 + 1));
			else if (os.rotation == 2)
				return new Point3D(Math.floor(asset.worldCoords.x - os.width/2 - 1), asset.worldCoords.y, Math.round(asset.worldCoords.z));
			else
				return new Point3D(Math.round(asset.worldCoords.x), asset.worldCoords.y, Math.floor(asset.worldCoords.z - os.depth/2 - 1));			
		}
		
		private function checkStructureSurfacesForSavedTopper():ActiveAsset
		{
			var os:OwnedStructure = currentStructure.thinger as OwnedStructure;
			currentStructurePoints = getSavedStructurePoints(os, false);		
			for each (var pt3D:Point3D in currentStructurePoints)
			{
				var adjusted:Point3D = new Point3D(pt3D.x - os.structure.height, 0, pt3D.x + os.structure.height);
				if (structureSurfaces[adjusted.x] && structureSurfaces[adjusted.x][adjusted.y] && structureSurfaces[adjusted.x][adjusted.y][adjusted.z])
					return structureSurfaces[adjusted.x][adjusted.y][adjusted.z];
			}
			return null;
		}		
		
		private function removeSavedPointsFromSurfacesArray(os:OwnedStructure):void
		{
			var old:ArrayCollection = getSavedStructurePoints(os, false);
			for each (var pt:Point3D in old)
			{
				removePointFrom3DArray(new Point3D(pt.x - os.structure.height, 0, pt.z + os.structure.height), structureSurfaces);
			}
		}	

		private function addSavedPointsToSurfacesArray(asset:ActiveAsset):void
		{
			var newPts:ArrayCollection = getSavedStructurePoints(asset.thinger as OwnedStructure, false);
			var os:OwnedStructure = asset.thinger as OwnedStructure;						
			for each (var pt:Point3D in newPts)
			{
				addPointTo3DArray(new Point3D(pt.x - os.structure.height, 0, pt.z + os.structure.height), asset, structureSurfaces);
			}
		}	
			
		private function addCurrentPointsToSurfacesArray(asset:ActiveAsset):void
		{		
			var newPts:ArrayCollection = getOccupiedOuterPoints(asset);
			var os:OwnedStructure = asset.thinger as OwnedStructure;			
			for each (var pt:Point3D in newPts)
			{
				addPointTo3DArray(new Point3D(pt.x - os.structure.height, 0, pt.z + os.structure.height), asset, structureSurfaces);
			}
		}

		private function removeSavedPointsFromBasesArray(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			var old:ArrayCollection = getSavedStructurePoints(os, true);
			old.addAll(getExtraBasePointsByStructureType(asset));
			for each (var pt:Point3D in old)
			{
				removePointFrom3DArray(new Point3D(pt.x, pt.y, pt.z), structureBases);
			}
		}

		private function addSavedPointsToBasesArray(asset:ActiveAsset):void
		{
			var newPts:ArrayCollection = getSavedStructurePoints(asset.thinger as OwnedStructure, true);
			newPts.addAll(getExtraBasePointsByStructureType(asset));
			for each (var pt:Point3D in newPts)
			{
				addPointTo3DArray(new Point3D(pt.x, pt.y, pt.z), asset, structureBases);
			}
		}
		
		private function addCurrentPointsToBasesArray(asset:ActiveAsset):void
		{
			var newPts:ArrayCollection = getOccupiedInnerPoints(asset);
			newPts.addAll(getExtraBasePointsByStructureType(asset));
			for each (var pt:Point3D in newPts)
			{
				addPointTo3DArray(new Point3D(pt.x, pt.y, pt.z), asset, structureBases);
			}
		}

		private function removeSavedPointsFromOuterBasesArray(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			var old:ArrayCollection = getSavedStructurePoints(os, false);
			old.addAll(getExtraBasePointsByStructureType(asset));
			for each (var pt:Point3D in old)
			{
				removePointFrom3DArrayOfArrays(new Point3D(pt.x, pt.y, pt.z), asset, structureBasesOuter);
			}
		}

		private function addSavedPointsToOuterBasesArray(asset:ActiveAsset):void
		{
			var newPts:ArrayCollection = getSavedStructurePoints(asset.thinger as OwnedStructure, false);
			newPts.addAll(getExtraBasePointsByStructureType(asset));
			for each (var pt:Point3D in newPts)
			{
				addPointTo3DArrayOfArrays(new Point3D(pt.x, pt.y, pt.z), asset, structureBasesOuter);
			}
		}
		
		private function addCurrentPointsToOuterBasesArray(asset:ActiveAsset):void
		{
			var newPts:ArrayCollection = getOccupiedOuterPoints(asset);
			newPts.addAll(getExtraBasePointsByStructureType(asset));
			for each (var pt:Point3D in newPts)
			{
				addPointTo3DArrayOfArrays(new Point3D(pt.x, pt.y, pt.z), asset, structureBasesOuter);
			}
		}
		
		private function removeSavedPointsFromStructureToppers(os:OwnedStructure):void
		{
			var old:ArrayCollection = getSavedStructurePoints(os, true);
			for each (var pt:Point3D in old)
			{
				removePointFrom3DArray(new Point3D(pt.x - pt.y, 0, pt.z + pt.y), structureToppers);
			}			
		}
		
		private function addSavedPointsToStructureToppers(asset:ActiveAsset):void
		{
			var newPts:ArrayCollection = getSavedStructurePoints(asset.thinger as OwnedStructure, true);
			for each (var pt:Point3D in newPts)
			{
				addPointTo3DArray(new Point3D(pt.x - pt.y, 0, pt.z + pt.y), asset, structureToppers);
			}
		}
		
		private function addCurrentPointsToStructureToppers(asset:ActiveAsset):void
		{
			var newPts:ArrayCollection = getOccupiedInnerPoints(asset);
			for each (var pt:Point3D in newPts)
			{
				addPointTo3DArray(new Point3D(pt.x - pt.y, 0, pt.z + pt.y), asset, structureToppers);
			}
		}		

		private function removeSavedPointsFromSingletonsArray(os:OwnedStructure):void
		{
			var pt:Point3D = new Point3D(os.x - 0.5, os.y, os.z - 0.5);
			removePointFrom3DArray(pt, structureSingletons);
		}
		
		private function addCurrentPointsToSingletonsArray(asset:ActiveAsset):void
		{
			var pt:Point3D = new Point3D(asset.worldCoords.x - 0.5, asset.worldCoords.y, asset.worldCoords.z - 0.5);
			addPointTo3DArray(pt, asset, structureSingletons);
		}
		
		private function addSavedPointsToSingletonsArray(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			var pt:Point3D = new Point3D(os.x - 0.5, os.y, os.z - 0.5);
			addPointTo3DArray(pt, asset, structureSingletons);
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
				if (os.structure.structure_type != "StructureTopper" && os.structure.structure_type != "Tile" && os.structure.structure_type != "ConcertStage")
				{
					var pts:ArrayCollection = getOccupiedInnerPoints(asset);
					pts.addAll(getExtraBasePointsByStructureType(asset));
					for each (var pt:Point3D in pts)
					{
						addPointTo3DArray(new Point3D(pt.x, pt.y, pt.z), asset, structureBases);
					}
				}
			}
		}		

		private function createStructureBasesOuter():void
		{
			structureBasesOuter = new Array();
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				var os:OwnedStructure = asset.thinger as OwnedStructure;
				if (os.structure.structure_type != "StructureTopper" && os.structure.structure_type != "Tile" && os.structure.structure_type != "ConcertStage")
				{
					var pts:ArrayCollection = getOccupiedOuterPoints(asset);
					pts.addAll(getExtraBasePointsByStructureType(asset));
					for each (var pt:Point3D in pts)
					{
						addPointTo3DArrayOfArrays(new Point3D(pt.x, pt.y, pt.z), asset, structureBasesOuter);
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
						addPointTo3DArray(new Point3D(pt.x - pt.y, 0, pt.z + pt.y), asset, structureToppers);
					}
				}
			}
		}		

		private function createStructureSingletons():void
		{
			structureSingletons = new Array();
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				var os:OwnedStructure = asset.thinger as OwnedStructure;
				if (os.structure.depth == 1 && os.structure.width == 1)
				{
					var pt:Point3D = new Point3D(os.x - 0.5, os.y, os.z - 0.5);
					addPointTo3DArray(pt, asset, structureSingletons);
				}
			}
		}		
		
		private function removePointFrom3DArray(pt:Point3D, removeFrom:Array):void
		{
			if (removeFrom[pt.x] && removeFrom[pt.x][pt.y] && removeFrom[pt.x][pt.y][pt.z])
				removeFrom[pt.x][pt.y][pt.z] = 0;
		}

		private function removePointFrom3DArrayOfArrays(pt:Point3D, asset:ActiveAsset, removeFrom:Array):void
		{
			if (removeFrom[pt.x] && removeFrom[pt.x][pt.y] && removeFrom[pt.x][pt.y][pt.z])
			{
				if ((removeFrom[pt.x][pt.y][pt.z] as ArrayCollection).length == 1)
					removeFrom[pt.x][pt.y][pt.z] = 0;
				else
				{
					var index:int = (removeFrom[pt.x][pt.y][pt.z] as ArrayCollection).getItemIndex(asset);
					(removeFrom[pt.x][pt.y][pt.z] as ArrayCollection).removeItemAt(index);
				}
			}
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
		
		public function addPointTo3DArrayOfArrays(pt:Point3D, asset:ActiveAsset, addTo:Array):void
		{
			if (addTo[pt.x] && addTo[pt.x][pt.y] && addTo[pt.x][pt.y][pt.z])
			{
				(addTo[pt.x][pt.y][pt.z] as ArrayCollection).addItem(asset);
			}
			else if (addTo[pt.x] && addTo[pt.x][pt.y])
			{
				addTo[pt.x][pt.y][pt.z] = new ArrayCollection();
				(addTo[pt.x][pt.y][pt.z] as ArrayCollection).addItem(asset);				
			}
			else if (addTo[pt.x])
			{
				addTo[pt.x][pt.y] = new Array();
				addTo[pt.x][pt.y][pt.z] = new ArrayCollection();
				(addTo[pt.x][pt.y][pt.z] as ArrayCollection).addItem(asset);								
			}
			else
			{
				addTo[pt.x] = new Array();
				addTo[pt.x][pt.y] = new Array();
				addTo[pt.x][pt.y][pt.z] = new ArrayCollection();
				(addTo[pt.x][pt.y][pt.z] as ArrayCollection).addItem(asset);												
			}	
		}
		
		private function snapToCenterPoint(asset:ActiveAsset, dimension:Number):Number
		{
			var center:Number = Math.round(dimension);
			if (center > dimension)
				center = center - 0.5;
			else
				center = center + 0.5;
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
			if (os.structure.structure_type == "ListeningStation")
			{
				if (isSpecialStructureInBounds(asset, _venue.outsideRect))
					return true;				
			}
			else if (os.structure.structure_type == "StageDecoration")
			{
				if (isSpecialStructureInBounds(asset, _venue.stageRect))
					return true;				
			}
			else
			{
				if (isVenueStructureInBounds(asset))
					return true;
			}
			return false;
		}
		
		public function isVenueStructureInBounds(asset:ActiveAsset):Boolean
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if ((asset.worldCoords.x - os.width/2 < _venue.venueRect.left || 
				asset.worldCoords.x + os.width/2 > _venue.venueRect.right ||
				asset.worldCoords.z - os.depth/2 < _venue.venueRect.top ||
				asset.worldCoords.z + os.depth/2 > _venue.venueRect.bottom) || 
					(asset.worldCoords.x + os.width/2 > _venue.audienceRect.left &&
					asset.worldCoords.x - os.width/2 < _venue.audienceRect.right - _venue.crowdBufferRect.width &&
					asset.worldCoords.z + os.depth/2 > _venue.audienceRect.top &&
					asset.worldCoords.z - os.depth/2 < _venue.audienceRect.bottom))
			{			
				return false;
			}	
			return true;			
		}

		public function isSpecialStructureInBounds(asset:ActiveAsset, rect:Rectangle):Boolean
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if (asset.worldCoords.x + asset.worldCoords.y - os.width/2 < rect.left || 
				asset.worldCoords.x + asset.worldCoords.y + os.width/2 > rect.right ||
				asset.worldCoords.z - asset.worldCoords.y - os.depth/2 < rect.top ||
				asset.worldCoords.z - asset.worldCoords.y + os.depth/2 > rect.bottom)
			{			
				return false;
			}	
			return true;			
		}
		
		public function doesStructureCollide(asset:ActiveAsset):Boolean
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			currentStructurePoints = getOccupiedOuterPoints(asset);
			currentStructurePoints.addAll(getExtraBasePointsByStructureType(asset));
			
			for each (var pt3D:Point3D in currentStructurePoints)
			{
				if (structureBases[pt3D.x] && structureBases[pt3D.x][pt3D.y] && structureBases[pt3D.x][pt3D.y][pt3D.z] &&
					(structureBases[pt3D.x][pt3D.y][pt3D.z] as ActiveAsset).thinger.id != asset.thinger.id)
					return true;
			}	
			if (os.width == 1 || os.depth == 1)
			{
				if (doesSingleTileStructureCollide(asset, currentStructurePoints))
					return true;				
			}
			return false;
		}
		
		private function doesSingleTileStructureCollide(asset:ActiveAsset, currentStructurePoints:ArrayCollection):Boolean
		{
//			To collide, at least two points must overlap and have a different x and y
			var os:OwnedStructure = asset.thinger as OwnedStructure;			
			var overlaps:ArrayCollection = new ArrayCollection();
			
//			Does it collide with any other single tile structures?
			if (structureSingletons[asset.worldCoords.x - 0.5] && structureSingletons[asset.worldCoords.x - 0.5][asset.worldCoords.y] &&
				structureSingletons[asset.worldCoords.x - 0.5][asset.worldCoords.y][asset.worldCoords.z - 0.5] &&
				(structureSingletons[asset.worldCoords.x - 0.5][asset.worldCoords.y][asset.worldCoords.z - 0.5] as ActiveAsset).thinger.id != asset.thinger.id)
				return true;
			
//			Does it collide with any larger (non single tile) structures?
			for each (var pt3D:Point3D in currentStructurePoints)
			{			
				if (structureBasesOuter[pt3D.x] && structureBasesOuter[pt3D.x][pt3D.y] &&
					structureBasesOuter[pt3D.x][pt3D.y][pt3D.z])
				{
					var arr:ArrayCollection = structureBasesOuter[pt3D.x][pt3D.y][pt3D.z];
					for each (var entry:ActiveAsset in arr)
					{
						if (entry != asset)
							overlaps.addItem(entry);
					}
				}
			}	
			for (var i:int = 0; i < overlaps.length; i++)
			{
				var totalAssets:int = 1;
				var a1:ActiveAsset = overlaps.getItemAt(i) as ActiveAsset;
				for (var j:int = 0; j < overlaps.length; j++)
				{
					if (i != j && a1 == overlaps.getItemAt(j))
						totalAssets++;
					if (totalAssets > 2)
						return true;
				}
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
			
		private function getSavedStructurePoints(os:OwnedStructure, inner:Boolean):ArrayCollection
		{
			var structurePoints:ArrayCollection;
			if (inner)
				structurePoints = getSavedInnerPoints(os);
			else
				structurePoints = getSavedOuterPoints(os);
			return structurePoints;
		}

		private function getOccupiedOuterPoints(asset:ActiveAsset):ArrayCollection
		{		
			var structurePoints:ArrayCollection = new ArrayCollection();
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			
			for (var xPt:int = 0; xPt <= os.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(asset.worldCoords.x - os.width/2 + xPt), asset.worldCoords.y, Math.round(asset.worldCoords.z - os.depth/2 + zPt));
					structurePoints.addItem(osPt3D);										
				}
			}
			return structurePoints;
		}			
		
		private function getOccupiedInnerPoints(asset:ActiveAsset):ArrayCollection
		{		
			var structurePoints:ArrayCollection = new ArrayCollection();
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			
			for (var xPt:int = 1; xPt < os.width; xPt++)
			{
				for (var zPt:int = 1; zPt < os.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(asset.worldCoords.x - os.width/2 + xPt), asset.worldCoords.y, Math.round(asset.worldCoords.z - os.depth/2 + zPt));
					structurePoints.addItem(osPt3D);										
				}
			}
			return structurePoints;
		}
		
		private function getSavedOuterPoints(os:OwnedStructure):ArrayCollection
		{		
			var structurePoints:ArrayCollection = new ArrayCollection();
			
			for (var xPt:int = 0; xPt <= os.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(os.x - os.width/2 + xPt), os.y, Math.round(os.z - os.depth/2 + zPt));
					structurePoints.addItem(osPt3D);										
				}
			}
			return structurePoints;
		}		
		
		private function getSavedInnerPoints(os:OwnedStructure):ArrayCollection
		{		
			var structurePoints:ArrayCollection = new ArrayCollection();
			
			for (var xPt:int = 1; xPt < os.width; xPt++)
			{
				for (var zPt:int = 1; zPt < os.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(os.x - os.width/2 + xPt), os.y, Math.round(os.z - os.depth/2 + zPt));
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
		
		private function placeInInventory(asset:ActiveAsset):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			if (asset.toppers)
				removeToppersFromEditMode(asset.toppers);
			if (os.structure.structure_type == "StructureTopper")
				removeTopperFromParent(os);
			_structureController.takeOutOfUse(os);
			removeStructureFromEditMode(asset);
		}
		
		private function removeToppersFromEditMode(toppers:ArrayCollection):void
		{
			for each (var t:OwnedStructure in toppers)
			{
				var topperAsset:ActiveAsset = getMatchingAssetForOwnedStructure(t);
				removeStructureFromEditMode(topperAsset);
				_structureController.takeOutOfUse(t);
			}		
		}
		
		private function removeTopperFromParent(os:OwnedStructure):void
		{			
			var parentAsset:ActiveAsset = getContainingStructure(os);
			var index:int = parentAsset.toppers.getItemIndex(os);
			parentAsset.toppers.removeItemAt(index);
		}
		
		private function getContainingStructure(topper:OwnedStructure):ActiveAsset
		{
			for each (var asset:ActiveAsset in structureWorld.assetRenderer.unsortedAssets)
			{
				if (asset.toppers && asset.toppers.contains(topper))
					return asset;
			}
			return null;
		}
		
		private function removeStructureFromEditMode(asset:ActiveAsset):void
		{
			if (allStructures.contains(asset))
			{
				var index:int = allStructures.getItemIndex(asset);
				this.allStructures.removeItemAt(index);
			}
			structureWorld.removeAsset(asset);	
			if ((asset.thinger as OwnedStructure).structure.structure_type != "StructureTopper")
				cutStructureFromCollisionArrays(asset);
			else
				cutTopperFromCollisionArrays(asset);
		}
	}
}