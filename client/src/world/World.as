package world
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
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
		public var _bitmapBlotter:BitmapBlotter;
		
		[Bindable] public var assetRenderer:AssetRenderer;
		[Bindable] public var pathFinder:PathFinder;		
		
		public function World(worldWidth:int, worldDepth:int, blockSize:int, maxHeight:int=0)
		{
			super();
			_worldWidth = worldWidth;
			_worldDepth = worldDepth;
			_blockSize = blockSize;
			drawInitialGrid();
			assetRenderer = new AssetRenderer();
			assetRenderer.addEventListener(WorldEvent.DESTINATION_REACHED, onDestinationReached);
			addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);
			pathFinder = new PathFinder(this, maxHeight);
			addChild(assetRenderer);
			addEventListener(Event.ADDED, onAdded);			
		}
		
		public function drawInitialGrid():void
		{
			wg = new WorldGrid(_worldWidth, _worldDepth, _blockSize);
//			addChild(wg);
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
		
		public function getMatchingStaticAsset(thinger:Object):ActiveAsset
		{
			for each (var asset:ActiveAsset in this.assetRenderer.unsortedAssets)
			{
				if (asset.thinger)
				{
					if (asset.thinger.id == thinger.id)
					{
						return asset;
					}
				}
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
				assetRenderer.unsortedAssets.removeItemAt(index);
			}
			else if (bitmapBlotter.getMatchingBitmap(activeAsset) != null)
			{
				bitmapBlotter.removeRenderedBitmap(activeAsset);
			}
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
		
		public function moveAssetTo(activeAsset:ActiveAsset, destination:Point3D, fourDirectional:Boolean = false, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exemptStructures:ArrayCollection=null, heightBase:int=0):void
		{	
			validateDestination(destination);
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
					moveFourDirectional(activeAsset, avoidStructures, avoidPeople, exemptStructures);
				}
			}
			else
			{
				
			}
			activeAsset.realDestination = worldToActualCoords(activeAsset.worldDestination);
			activeAsset.isMoving = true;			
		}
		
		private function moveFourDirectional(asset:ActiveAsset, avoidStructures:Boolean, avoidPeople:Boolean, exemptStructures:ArrayCollection):void
		{
			var tilePath:ArrayCollection = pathFinder.add(asset, avoidStructures, avoidPeople, exemptStructures);		
			asset.currentPath = tilePath;
			asset.pathStep = 0;
			var nextPoint:Point3D = asset.currentPath[asset.pathStep];
			asset.worldDestination = nextPoint;
			asset.directionality = new Point3D(nextPoint.x - Math.round(asset.worldCoords.x), nextPoint.y - Math.round(asset.worldCoords.y), nextPoint.z - Math.round(asset.worldCoords.z));	
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
				throw new Error("Destination should be a whole number");
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
		
		public function findAssetByThinger(thinger:Object):ActiveAsset
		{
			for each (var asset:ActiveAsset in assetRenderer.unsortedAssets)
			{
				if (asset.thinger)
				{
					if (asset.thinger.id)
					{
						if (asset.thinger.id == thinger.id)
						{
							return asset;					
						}
					}
				}
			}
			for each (var abd:AssetBitmapData in this.bitmapBlotter.bitmapReferences)
			{
				if (abd.activeAsset.thinger)
				{
					if (abd.activeAsset.thinger.id == thinger.id)
					{
						return abd.activeAsset;
					}
				}
			}
			return null;
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
		
		public function set bitmapBlotter(val:BitmapBlotter):void
		{
			_bitmapBlotter = val;
		}
		
		public function get bitmapBlotter():BitmapBlotter
		{
			return _bitmapBlotter;
		}
	}
}