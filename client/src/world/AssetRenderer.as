package world
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;

	public class AssetRenderer extends UIComponent
	{
		public var sortedAssets:ArrayCollection;
		public var unsortedAssets:ArrayCollection;
		private static const DEFAULT_SPEED:Number = .02;

		[Bindable] public var myMemory:Number;
		[Bindable] public var fps:Number;
		[Bindable] public var aux:Number;	
		private var lastTime:Number;		
					
		public function AssetRenderer()
		{
			super();
			sortedAssets = new ArrayCollection();
			unsortedAssets = new ArrayCollection();
			unsortedAssets.addEventListener(CollectionEvent.COLLECTION_CHANGE, updateUnsortedAssets);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.addEventListener(MouseEvent.CLICK, onMouseClicked);
		}
		
		private function onMouseClicked(evt:MouseEvent):void
		{
			
		}
		
		private function onEnterFrame(evt:Event):void
		{
			var time:Number = getTimer();
			var deltaTime:Number = time - lastTime;
			var lockedDelta:Number = Math.min(100, deltaTime);
			fps = 1000/deltaTime;
			myMemory = System.totalMemory;
			aux = sortedAssets.length;
			lastTime = time;
			
			removeExistingAssets();
			updateSortedAssets(lockedDelta);
			drawAssets();
		}
		
		private function drawAssets():void
		{			
			for (var i:int = 0; i<sortedAssets.length; i++)
			{
				var asset:ActiveAsset = sortedAssets[i];
				addChild(asset);
			}
		}
		
		private function updateCoords(lockedDelta:Number):void
		{
			for (var i:int = 0; i<sortedAssets.length; i++)
			{
				var speed:Number;
				var asset:ActiveAsset = sortedAssets[i];
				if (asset.isMoving == true)
				{
					if (asset.speed != -1)
					{
						speed = asset.speed;
					}
					else
					{
						speed = DEFAULT_SPEED;
					}
					
					var totalXDiff:Number = asset.realDestination.x - asset.lastRealPoint.x;
					var totalYDiff:Number = asset.realDestination.y - asset.lastRealPoint.y;
					var totalDistanceToMove:Number = Math.sqrt(totalXDiff * totalXDiff + totalYDiff * totalYDiff);
					
					var distanceToMove:Number = lockedDelta * speed;
					asset.walkProgress += distanceToMove;
					var xDiff:Number = asset.realDestination.x - asset.realCoords.x;
					var yDiff:Number = asset.realDestination.y - asset.realCoords.y;
					
					var ratio:Number;
					var distanceToMoveX:Number;
					var distanceToMoveY:Number;
					
					if (xDiff == 0 && yDiff != 0)
					{
						distanceToMoveX = 0;
						distanceToMoveY = distanceToMove;	
						if (yDiff < 0)
						{
							distanceToMoveY = -distanceToMoveY;
						}				
					}
					else if (yDiff == 0 && xDiff != 0)
					{
						distanceToMoveY = 0;
						distanceToMoveX = distanceToMove;
						if (xDiff < 0)
						{
							distanceToMoveX = -distanceToMoveX;
						}
					}
					else if (xDiff != 0)
					{
						ratio = yDiff/xDiff;					
						distanceToMoveX = Math.sqrt((distanceToMove * distanceToMove) / (1 + ratio * ratio));
						if (xDiff < 0)
						{
							distanceToMoveX = -distanceToMoveX;
						}
						distanceToMoveY = distanceToMoveX * ratio;
					}					
					else
					{
						distanceToMoveX = 0;
						distanceToMoveY = 0;
					}
							
					if (asset.walkProgress > totalDistanceToMove)				
					{
						asset.isMoving = false;
						asset.walkProgress = 0;
						asset.x = asset.realDestination.x;
						asset.y = asset.realDestination.y;
						asset.realCoords.x = asset.realDestination.x.valueOf();
						asset.realCoords.y = asset.realDestination.y.valueOf();
						asset.realCoordX = asset.realDestination.x;
						asset.realCoordY = asset.realDestination.y;
						asset.worldCoords.x = (asset.worldDestination.x.valueOf());
						asset.worldCoords.y = (asset.worldDestination.y.valueOf());
						asset.worldCoords.z = (asset.worldDestination.z.valueOf());
						
						if (asset.worldDestination.x%1 != 0 || asset.worldDestination.y%1 != 0 || asset.worldDestination.z%1 != 0)
						{
							throw new Error('destination world coords need to be whole numbers');
						}
						
						var evt:WorldEvent = new WorldEvent(WorldEvent.DESTINATION_REACHED, asset);
						dispatchEvent(evt);
					}
					else
					{
						asset.x += distanceToMoveX;
						asset.y += distanceToMoveY;
						asset.realCoords.x += distanceToMoveX;
						asset.realCoords.y += distanceToMoveY;
						asset.realCoordX += distanceToMoveX;
						asset.realCoordY += distanceToMoveY;
						// Update world coordinates as well
						asset.worldCoords = World.actualToWorldCoords(asset.realCoords);
					}
				}
			}				
		}	
		
		private function updateSortedAssets(lockedDelta:Number):void
		{
			var tempArray:ArrayCollection = new ArrayCollection();
			for each (var a:ActiveAsset in unsortedAssets)
			{
				var index:Number = unsortedAssets.getItemIndex(a);
				tempArray.addItemAt(a, index);
			}
			updateCoords(lockedDelta);	
			var dataSortField:SortField = new SortField("realCoordY");
			dataSortField.numeric = true;
			var numericDataSort:Sort = new Sort();
			numericDataSort.fields = [dataSortField];
			tempArray.sort = numericDataSort;
			tempArray.refresh();
			sortedAssets = new ArrayCollection();
			for (var i:int = 0; i<tempArray.length; i++)
			{
				var asset:ActiveAsset = tempArray.getItemAt(i) as ActiveAsset;
				sortedAssets.addItemAt(asset, i);
			}
		}
		
		private function updateUnsortedAssets(evt:CollectionEvent):void
		{

		}
		
		public function removeOwnedThinger(thinger:Object):void
		{
			for each (var asset:ActiveAsset in unsortedAssets)
			{
				if (asset.thinger == thinger)
				{
					var index:int = unsortedAssets.getItemIndex(asset);
					unsortedAssets.removeItemAt(index);
				}
			}
		}
		
		public function removeAsset(asset:ActiveAsset):void
		{
			var index:int = unsortedAssets.getItemIndex(asset);
			unsortedAssets.removeItemAt(index);
		}
		
		private function removeExistingAssets():void
		{
			for (var i:int = 0; i<sortedAssets.length; i++)
			{
				var asset:ActiveAsset = sortedAssets[i];
				if (sortedAssets.contains(asset))
				{
					removeChild(asset);									
				}
			}			
		}
		
	}
}