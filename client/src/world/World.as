package world
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	import models.Structure;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	
	import views.AssetBitmapData;
	import views.WorldView;

	public class World extends UIComponent
	{
		public var _worldWidth:int;
		public var _worldDepth:int;
		public var _blockSize:int;
		
		public var tilesWide:int;
		public var tilesDeep:int;
		public var wg:WorldGrid;
		public var _tile:Structure;
		public var _floorStyle:String;
		public var _bitmapBlotter:BitmapBlotter;
		
		[Bindable] public var assetRenderer:AssetRenderer;
		[Bindable] public var pathFinder:PathFinder;		
		
		public function World(worldWidth:int, worldDepth:int, blockSize:int, maxHeight:int=0, tile:Structure=null, floorStyle:String=null)
		{
			super();
			_worldWidth = worldWidth;
			_worldDepth = worldDepth;
			_blockSize = blockSize;
			_tile = tile;
			_floorStyle = floorStyle;
			drawInitialGrid();
			pathFinder = new PathFinder(this, maxHeight);
			assetRenderer = new AssetRenderer();
			assetRenderer.addEventListener(WorldEvent.DESTINATION_REACHED, onDestinationReached);
			pathFinder.addEventListener(WorldEvent.PATHFINDING_FAILED, onPathfindingFailed);
			addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);
			addChild(assetRenderer);
			addEventListener(Event.ADDED, onAdded);						
		}
		
		public function setOccupiedSpaces():void
		{
			this.pathFinder.populateOccupiedSpaces();
		}
		
		public function drawInitialGrid():void
		{
			wg = new WorldGrid(_worldWidth, _worldDepth, _blockSize, _tile, _floorStyle);
			addChild(wg);
			tilesWide = _worldWidth/_blockSize;
			tilesDeep = _worldDepth/_blockSize;
		}
		
		public function getActualHeight():Number
		{
			return wg.mc.height;
		}
		
		private function onAdded(evt:Event):void
		{
			removeEventListener(Event.ADDED, onAdded);
			x = (parent.width)/2 - (wg.mc.width/2);
			y = (parent.height)/2;
		}
		
		public function addAsset(activeAsset:ActiveAsset, worldCoords:Point3D):void
		{
			activeAsset.world = this;
			activeAsset.worldCoords = worldCoords;
			setLastWorldPoint(activeAsset);
			
			var addTo:Point = worldToActualCoords(worldCoords);
			activeAsset.realCoords = addTo;
			activeAsset.x = 0;
			activeAsset.y = 0;
			activeAsset.x += addTo.x;
			activeAsset.y += addTo.y;
			assetRenderer.unsortedAssets.addItem(activeAsset);
		}		
		
		public function addStaticBitmap(activeAsset:ActiveAsset, worldCoords:Point3D, animation:String=null, frameNumber:int=0, reflection:Boolean=false):void
		{
			activeAsset.world = this;
			activeAsset.worldCoords = worldCoords;
			setLastWorldPoint(activeAsset);
			
			var addTo:Point = worldToActualCoords(worldCoords);
			activeAsset.realCoords = addTo;
			activeAsset.x = 0;
			activeAsset.y = 0;
			activeAsset.x += addTo.x;
			activeAsset.y += addTo.y;
			_bitmapBlotter.addBitmap(activeAsset, animation, frameNumber, reflection);		
		}
		
		public function addStaticRenderedBitmap(activeAsset:ActiveAsset, worldCoords:Point3D, animation:String=null, frameNumber:int=0, reflection:Boolean=false):void
		{
			activeAsset.world = this;
			activeAsset.worldCoords = worldCoords;			
			var addTo:Point = worldToActualCoords(worldCoords);
			activeAsset.realCoords = addTo;
			activeAsset.x = addTo.x;
			activeAsset.y = addTo.y;	
			this.bitmapBlotter.addRenderedBitmap(activeAsset, animation, frameNumber, reflection);
		}

			
		public function getRectForStaticAsset(mc:MovieClip, realCoordX:int, realCoordY:int):Rectangle
		{
			mc.y = realCoordY;
			mc.x = realCoordX;
			var rect:Rectangle = mc.getBounds(this.assetRenderer);
			return rect;
		}	
		
		public function getWorldBoundsForAsset(asset:ActiveAsset):Point3D
		{
			var bottomLeft:Point = new Point(asset.actualBounds.left, asset.actualBounds.bottom);
			var worldBound:Point3D = World.actualToWorldCoords(bottomLeft, asset.worldCoords.y);
			worldBound = new Point3D(Math.round(worldBound.x), Math.round(worldBound.y), Math.round(worldBound.z));
			return worldBound;
		}
		
		public function getOccupiedSpaces(avoidStructures:Boolean = true, avoidPeople:Boolean = true, exempt:ArrayCollection = null):Array
		{
//			var structureOccupiedSpaces:ArrayCollection = new ArrayCollection();
//			var peopleOccupiedSpaces:ArrayCollection = new ArrayCollection();
			var spaces:Array = new Array();
			if (avoidStructures)
				spaces.concat(this.pathFinder.getStructureOccupiedSpaces(exempt));			
			if (avoidPeople)
				spaces.concat(this.pathFinder.getPeopleOccupiedSpacesForArray(this.assetRenderer.unsortedAssets));
//			structureOccupiedSpaces.addAll(peopleOccupiedSpaces);
			return spaces;
		}
		
		public function isPointAvailable(pt3D:Point3D, avoidStructures:Boolean = true, avoidPeople:Boolean = true, exemptStructures:ArrayCollection = null):Boolean
		{
			var occupiedSpaces:Array = getOccupiedSpaces(avoidStructures, avoidPeople, exemptStructures);
			if (occupiedSpaces[pt3D.x] && occupiedSpaces[pt3D.x][pt3D.y] && occupiedSpaces[pt3D.x][pt3D.y][pt3D.z])
				return false;
			return true;
		}
		
		public function pickRandomAvailableWorldPoint(avoidStructures:Boolean=true, avoidPeople:Boolean=true, exemptStructures:ArrayCollection=null):Point3D
		{
			var occupiedSpaces:Array = getOccupiedSpaces(avoidStructures, avoidPeople, exemptStructures);
			
			var pt3D:Point3D;
			return pt3D;
		}
		
		public function doesWorldContain(asset:ActiveAsset):Boolean
		{
			if (assetRenderer.unsortedAssets.contains(asset))
			{
				return true;
			}
			return false;
		}
		
		public function getMatchingStaticAsset(thinger:Object):ActiveAsset
		{
			for each (var asset:ActiveAsset in this.assetRenderer.unsortedAssets)
			{
				if (asset.thinger && asset.thinger.id == thinger.id)
					return asset;
			}
			return null;
		}
		
		public function removeAssetFromWorld(asset:ActiveAsset):void
		{
			if (assetRenderer.unsortedAssets.contains(asset))
			{
				var index:int = assetRenderer.unsortedAssets.getItemIndex(asset);
				assetRenderer.unsortedAssets.removeItemAt(index);
			}			
		}
		
		public function removeAsset(activeAsset:ActiveAsset):void
		{
			if (assetRenderer.unsortedAssets.contains(activeAsset))
			{
				var index:int = assetRenderer.unsortedAssets.getItemIndex(activeAsset);
				pathFinder.remove(activeAsset);
				assetRenderer.unsortedAssets.removeItemAt(index);
			}
//			else if (bitmapBlotter.getMatchingBitmap(activeAsset) != null)
//			{
//				bitmapBlotter.removeRenderedBitmap(activeAsset);
//			}
		}
		
		public static function worldToActualCoords(worldCoords:Point3D):Point
		{
			var x:Number = worldCoords.x;
			var y:Number = worldCoords.y;
			var z:Number = worldCoords.z;
			var actualX:Number = (x + z) * FlexGlobals.topLevelApplication.xGridCoord;
			var actualY:Number = (-2*y + x - z) * FlexGlobals.topLevelApplication.yGridCoord;
			var actualCoords:Point = new Point(actualX, actualY);
			return actualCoords;
		}
		
		public static function actualToWorldCoords(actualCoords:Point, heightBase:int=0):Point3D
		{
			var ratio:Number = FlexGlobals.topLevelApplication.xGridCoord / FlexGlobals.topLevelApplication.yGridCoord;			
			var starter:Number = actualCoords.x / (FlexGlobals.topLevelApplication.xGridCoord * 2);
			var worldX:Number = starter + (actualCoords.y / (FlexGlobals.topLevelApplication.yGridCoord * ratio)) + heightBase;
			var worldZ:Number = starter - (actualCoords.y / (FlexGlobals.topLevelApplication.yGridCoord * ratio)) - heightBase;
			var worldY:Number = heightBase;
			return new Point3D(worldX, worldY, worldZ);
		}
		
		public function setLastWorldPoint(activeAsset:ActiveAsset):void
		{
			activeAsset.lastWorldPoint = new Point3D(0, 0, 0);
			activeAsset.lastWorldPoint.x = (activeAsset.worldCoords.x.valueOf());
			activeAsset.lastWorldPoint.y = (activeAsset.worldCoords.y.valueOf());
			activeAsset.lastWorldPoint.z = (activeAsset.worldCoords.z.valueOf());
		}
		
		public function updatePlacement(asset:ActiveAsset, newCoords:Point3D):void
		{
			asset.worldCoords.x = newCoords.x;
			asset.worldCoords.y = newCoords.y;
			asset.worldCoords.z = newCoords.z;
			this.removeAsset(asset);
			this.addAsset(asset, asset.worldCoords);
		}
		
		public function updateUnwalkables(os:OwnedStructure):void
		{
			this.pathFinder.updateStructureOccupiedSpaces();
		}
		
		public function createNewStructure(os:OwnedStructure):void
		{
			var asset:ActiveAsset = World.createStandardAssetFromStructure(os);
			addAsset(asset, new Point3D(os.x, os.y, os.z));			
		}
		
		public function saveStructurePlacement(os:OwnedStructure, saveRotation:Boolean=false):void
		{
			var asset:ActiveAsset = getAssetFromOwnedStructure(os);
			updateUnwalkables(os);
			updatePlacement(asset, new Point3D(os.x, os.y, os.z));
			if (saveRotation)
				saveStructureRotation(asset, os);
		}
		
		public function saveStructureRotation(asset:ActiveAsset, os:OwnedStructure):void
		{
			asset.setRotation(os);
		}
		
		public function getAssetFromOwnedStructure(os:OwnedStructure):ActiveAsset
		{
			for each (var asset:ActiveAsset in assetRenderer.unsortedAssets)
			{
				if (asset.thinger && asset.thinger.id == os.id)
					return asset;
			}			
			return null;
		}

		public function getParentAssetFromTopper(os:OwnedStructure):ActiveAsset
		{
			for each (var asset:ActiveAsset in this.assetRenderer.unsortedAssets)
			{
				if (asset.thinger is OwnedStructure && (asset.thinger as OwnedStructure).structure.height > 0)
				{
					if (asset.toppers && asset.toppers.contains(os))
						return asset;
				}
			}
			return null;
		}
		
		public function doAssetRedraw(asset:ActiveAsset):void
		{
			this.removeAsset(asset);
			var temp:ActiveAssetStack = new ActiveAssetStack(null, asset.movieClip);
			temp.copyFromActiveAsset(asset);
			temp.setMovieClipsForStructure(temp.toppers);
			temp.bitmapWithToppers();
			this.addAsset(temp, temp.worldCoords);			
		}		
		
		public static function createStandardAssetFromStructure(os:OwnedStructure):ActiveAsset
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
			var asset:ActiveAsset = new ActiveAsset(mc);
			asset.thinger = os;
			return asset;
		}	
		
		public function validateWorldCoords(asset:ActiveAsset):void
		{
			if (!asset.worldCoords.x || !asset.worldCoords.y || !asset.worldCoords.z)
			{
//				throw new Error("Missing world coords");
			}
		}
		
		public function moveAssetTo(activeAsset:ActiveAsset, destination:Point3D, fourDirectional:Boolean = false, fallBack:Boolean=false, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exemptStructures:ArrayCollection=null, heightBase:int=0, extraStructures:ArrayCollection=null):void
		{	
			validateDestination(destination);
			validateWorldCoords(activeAsset);
			updatePointReferences(activeAsset, destination);
			activeAsset.currentPath = null;
			
			if (fourDirectional)
			{
//				activeAsset.fourDirectional = true;
				var arrived:Boolean = checkIfAtDestination(activeAsset);
				
				if (arrived)
				{
					
				}
				else
				{
					moveFourDirectional(activeAsset, fallBack, avoidStructures, avoidPeople, exemptStructures, heightBase, extraStructures);
				}
			}
			else
			{
				
			}
			activeAsset.realDestination = worldToActualCoords(activeAsset.worldDestination);
			activeAsset.isMoving = true;			
		}
		
		private function moveFourDirectional(asset:ActiveAsset, fallBack:Boolean, avoidStructures:Boolean, avoidPeople:Boolean, exemptStructures:ArrayCollection, heightBase:int=0, extraStructures:ArrayCollection=null):void
		{
			var tilePath:ArrayCollection = pathFinder.add(asset, fallBack, avoidStructures, avoidPeople, exemptStructures, heightBase, extraStructures);		
			if (tilePath && tilePath.length != 0)
			{	
				asset.currentPath = tilePath;
				asset.pathStep = 0;
				var nextPoint:Point3D = asset.currentPath[asset.pathStep];
				asset.worldDestination = nextPoint;
				asset.directionality = new Point3D(nextPoint.x - Math.round(asset.worldCoords.x), nextPoint.y - Math.round(asset.worldCoords.y), nextPoint.z - Math.round(asset.worldCoords.z));	
			}
		}
		
		private function checkIfAtDestination(asset:ActiveAsset):Boolean
		{
			if (asset.worldDestination.x == asset.lastWorldPoint.x && asset.worldDestination.y == asset.lastWorldPoint.y && asset.worldDestination.z == asset.lastWorldPoint.z)
			{
				var evt:WorldEvent = new WorldEvent(WorldEvent.FINAL_DESTINATION_REACHED, asset, true, true);
				dispatchEvent(evt);
				return true;
			}			
			return false;
		}
		
		private function updatePointReferences(asset:ActiveAsset, destination:Point3D):void
		{
			asset.worldDestination = destination;
			asset.lastRealPoint = new Point(asset.realCoords.x, asset.realCoords.y);
			asset.lastWorldPoint = new Point3D(asset.worldCoords.x, asset.worldCoords.y, asset.worldCoords.z);		
			setLastWorldPoint(asset);
			
			asset.walkProgress = 0;				
		}
		
		private function validateDestination(destination:Point3D):void
		{
			if (destination.x%1 != 0 || destination.y%1 != 0 || destination.z%1 != 0)
			{
//				throw new Error("Destination should be a whole number");
			}	
		}
		
		private function moveToNextPathStep(asset:ActiveAsset):void
		{
			asset.isMoving = true;
			asset.pathStep++;
			asset.lastRealPoint = new Point(asset.realCoords.x, asset.realCoords.y);
			asset.worldDestination = asset.currentPath[asset.pathStep];	
			asset.realDestination = worldToActualCoords(asset.worldDestination);	
			updateDirectionality(asset);				
		}		
		
		private function updateDirectionality(asset:ActiveAsset):void
		{
			var currentPoint:Point3D = asset.currentPath[asset.pathStep-1];			
			var newDirectionality:Point3D = new Point3D(asset.worldDestination.x - currentPoint.x, asset.worldDestination.y - currentPoint.y, asset.worldDestination.z - currentPoint.z);
			if (newDirectionality.x != asset.directionality.x || newDirectionality.y != asset.directionality.y || newDirectionality.z != asset.directionality.z)
			{
				asset.directionality = newDirectionality;
				var evt:WorldEvent = new WorldEvent(WorldEvent.DIRECTION_CHANGED, asset);
				dispatchEvent(evt);
			}			
		}
		
		private function onPathfindingFailed(evt:WorldEvent):void
		{
			var asset:ActiveAsset = evt.activeAsset;
			asset.isMoving = false;
			var newEvt:WorldEvent = new WorldEvent(WorldEvent.PATHFINDING_FAILED, asset);
			asset.dispatchEvent(newEvt);
		}
		
		private function onDestinationReached(evt:WorldEvent):void
		{
			var asset:ActiveAsset = evt.activeAsset;
			
			if (asset.currentPath != null && asset.pathStep < (asset.currentPath.length-1))
			{	
				moveToNextPathStep(asset);		
				validateDestination(asset.worldDestination);
			}
			else
			{
				// Have reached final destination
				
				var finalDestinationEvent:WorldEvent = new WorldEvent(WorldEvent.FINAL_DESTINATION_REACHED, asset);
				dispatchEvent(finalDestinationEvent);

				if (asset.fourDirectional && pathFinder.contains(asset))
				{
					pathFinder.remove(asset);				
				}
			}
		}
		
		public function addStaticAsset(asset:ActiveAsset, addTo:Point3D):void
		{
			addAsset(asset, addTo);
			asset.movieClip.gotoAndPlay(1);
			asset.movieClip.stop();
		}		
		
		public function updateAssetCoords(asset:ActiveAsset, newCoords:Point3D, bitmapped:Boolean):void
		{
			asset.worldCoords.x = newCoords.x;
			asset.worldCoords.y = newCoords.y;
			asset.worldCoords.z = newCoords.z;
			if (bitmapped)
			{
				this.removeAsset(asset);
				this.addStaticBitmap(asset, asset.worldCoords);
			}
			else
			{
				removeAsset(asset);
				addAsset(asset, asset.worldCoords);
			}
//			var evt:WorldEvent = new WorldEvent(WorldEvent.STRUCTURE_PLACED, asset, true, true);
//			dispatchEvent(evt);			
		}
		
		private function onDirectionChanged(evt:WorldEvent):void
		{
			var asset:ActiveAsset = evt.activeAsset;
		}
		
		public function set worldWidth(val:int):void
		{
			_worldWidth = val;
		}
		
		public function get worldWidth():int
		{
			return _worldWidth;
		}
		
		public function set worldDepth(val:int):void
		{
			_worldDepth = val;
		}
		
		public function get worldDepth():int
		{
			return _worldDepth;
		}
		
		public function get blockSize():int
		{
			return _blockSize;
		}
		
		public function set bitmapBlotter(val:BitmapBlotter):void
		{
			_bitmapBlotter = val;
		}
		
		public function get bitmapBlotter():BitmapBlotter
		{
			return _bitmapBlotter;
		}
		
		public function set tile(val:Structure):void
		{
			_tile = val;
		}
		
		public function get tile():Structure
		{
			return _tile;
		}
		
		public function set floorStyle(val:String):void
		{
			_floorStyle = val;
		}
		
		public function get floorStyle():String
		{
			return _floorStyle;
		}
	}
}