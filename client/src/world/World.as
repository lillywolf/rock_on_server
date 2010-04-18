package world
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.UIComponent;

	public class World extends UIComponent
	{
		public var _worldWidth:int;
		public var _worldDepth:int;
		public var _blockSize:int;
		
		public var tilesWide:int;
		public var tilesDeep:int;
		public var wg:WorldGrid;
		
		[Bindable] public var assetRenderer:AssetRenderer;
		[Bindable] public var pathFinder:PathFinder;		
		
		public function World(worldWidth:int, worldDepth:int, blockSize:int)
		{
			super();
			_worldWidth = worldWidth;
			_worldDepth = worldDepth;
			_blockSize = blockSize;
			drawInitialGrid();
			assetRenderer = new AssetRenderer();
			assetRenderer.addEventListener(WorldEvent.DESTINATION_REACHED, onDestinationReached);
			addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);
			pathFinder = new PathFinder(this);
			addChild(assetRenderer);
			addEventListener(Event.ADDED, onAdded);			
		}
		
		public function drawInitialGrid():void
		{
			wg = new WorldGrid(_worldWidth, _worldDepth, _blockSize);
			addChild(wg);
			tilesWide = _worldWidth/_blockSize;
			tilesDeep = _worldDepth/_blockSize;
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
		
		public function removeAsset(activeAsset:ActiveAsset):void
		{
			var index:int = assetRenderer.unsortedAssets.getItemIndex(activeAsset);
			assetRenderer.unsortedAssets.removeItemAt(index);
		}
		
		public static function worldToActualCoords(worldCoords:Point3D):Point
		{
			var x:Number = worldCoords.x;
			var y:Number = worldCoords.y;
			var z:Number = worldCoords.z;
			var actualX:Number = (x + z) * Application.application.xGridCoord;
			var actualY:Number = (-2*y + x - z) * Application.application.yGridCoord;
			var actualCoords:Point = new Point(actualX, actualY);
			return actualCoords;
		}
		
		public static function actualToWorldCoords(actualCoords:Point):Point3D
		{
			var ratio:Number = Application.application.xGridCoord / Application.application.yGridCoord;			
			var starter:Number = actualCoords.x / (Application.application.xGridCoord * 2);
			var worldX:Number = starter + (actualCoords.y / (Application.application.yGridCoord * ratio));
			var worldZ:Number = starter - (actualCoords.y / (Application.application.yGridCoord * ratio));
			var worldY:Number = 0;
			return new Point3D(worldX, worldY, worldZ);
		}
		
		public function setLastWorldPoint(activeAsset:ActiveAsset):void
		{
			activeAsset.lastWorldPoint = new Point3D(0, 0, 0);
			activeAsset.lastWorldPoint.x = (activeAsset.worldCoords.x.valueOf());
			activeAsset.lastWorldPoint.y = (activeAsset.worldCoords.y.valueOf());
			activeAsset.lastWorldPoint.z = (activeAsset.worldCoords.z.valueOf());
		}
		
		public function moveAssetTo(activeAsset:ActiveAsset, destination:Point3D, fourDirectional:Boolean = false, exemptStructures:ArrayCollection=null):void
		{	
			if (destination.x%1 != 0 || destination.y%1 != 0 || destination.z%1 != 0)
			{
				throw new Error('why are you not a whole number?');
			}
			
			activeAsset.worldDestination = destination;
			activeAsset.lastRealPoint = new Point(activeAsset.realCoords.x, activeAsset.realCoords.y);
			activeAsset.lastWorldPoint = new Point3D(activeAsset.worldCoords.x, activeAsset.worldCoords.y, activeAsset.worldCoords.z);
			setLastWorldPoint(activeAsset);
			activeAsset.walkProgress = 0;
			activeAsset.isMoving = true;
			if (fourDirectional)
			{
				activeAsset.fourDirectional = true;
				if (activeAsset.worldDestination.x%1 != 0 || activeAsset.worldDestination.y%1 != 0 || activeAsset.worldDestination.z%1 != 0)
				{
					throw new Error('destination must be a whole number');
				}
				if (destination.x == activeAsset.lastWorldPoint.x && destination.y == activeAsset.lastWorldPoint.y && destination.z == activeAsset.lastWorldPoint.z)
				{
					var evt:WorldEvent = new WorldEvent(WorldEvent.FINAL_DESTINATION_REACHED, activeAsset, true, true);
					dispatchEvent(evt);
				}
				else
				{
					var tilePath:ArrayCollection = pathFinder.add(activeAsset, exemptStructures);		
					activeAsset.currentPath = tilePath;
					activeAsset.pathStep = 0;
					var nextPoint:Point3D = activeAsset.currentPath[activeAsset.pathStep];
					activeAsset.worldDestination = nextPoint;
					activeAsset.realDestination = worldToActualCoords(nextPoint);
					activeAsset.directionality = new Point3D(nextPoint.x - Math.round(activeAsset.worldCoords.x), nextPoint.y - Math.round(activeAsset.worldCoords.y), nextPoint.z - Math.round(activeAsset.worldCoords.z));
				}
			}
			else
			{
				activeAsset.fourDirectional = false;
				activeAsset.currentPath = null;
				var realDestination:Point = worldToActualCoords(destination);
				activeAsset.realDestination = realDestination;
			}
		}
		
		private function onDestinationReached(evt:WorldEvent):void
		{
			var asset:ActiveAsset = evt.activeAsset;
			if (asset.currentPath != null && asset.pathStep < (asset.currentPath.length-1))
			{
				asset.isMoving = true;
				asset.pathStep++;
				
				var currentPoint:Point3D = asset.currentPath[asset.pathStep-1];
				var nextPoint:Point3D = asset.currentPath[asset.pathStep];
				var newDirectionality:Point3D = new Point3D(nextPoint.x - currentPoint.x, nextPoint.y - currentPoint.y, nextPoint.z - currentPoint.z);
				
				asset.worldDestination = nextPoint;
				asset.realDestination = worldToActualCoords(nextPoint);
				
				if (asset.worldDestination.x%1 != 0 || asset.worldDestination.y%1 != 0 || asset.worldDestination.z%1 != 0)
				{
					throw new Error('destination must be a whole number');
				}
				
				if (newDirectionality.x != asset.directionality.x || newDirectionality.y != asset.directionality.y || newDirectionality.z != asset.directionality.z)
				{
					asset.directionality = newDirectionality;
					var evt:WorldEvent = new WorldEvent(WorldEvent.DIRECTION_CHANGED, asset);
					dispatchEvent(evt);
				}
				
				asset.lastRealPoint = new Point(asset.realCoords.x, asset.realCoords.y);
			}
//			else if (asset.pathStep == asset.currentPath.length)
			else
			{
				// Have reached final destination
				var finalDestinationEvent:WorldEvent = new WorldEvent(WorldEvent.FINAL_DESTINATION_REACHED, asset);
				dispatchEvent(finalDestinationEvent);
				if (asset.fourDirectional)
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
	}
}