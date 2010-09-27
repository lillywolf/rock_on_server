package world
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.getTimer;
	
	import flashx.textLayout.tlf_internal;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;

	public class AssetRenderer extends UIComponent
	{
		public var sortedAssets:ArrayCollection;
		public var unsortedAssets:ArrayCollection;
		public var renderFirst:ArrayCollection;
		public var initialDraw:Boolean;
		public var ySort:Sort;
		private static const DEFAULT_SPEED:Number = .02;

		[Bindable] public var myMemory:Number;
		[Bindable] public var fps:Number;
		[Bindable] public var aux:Number;	
		private var lastTime:Number;	
		private var frameCount:int = 0;
					
		public function AssetRenderer()
		{
			super();
			sortedAssets = new ArrayCollection();
			unsortedAssets = new ArrayCollection();
			renderFirst = new ArrayCollection();
			unsortedAssets.addEventListener(CollectionEvent.COLLECTION_CHANGE, updateUnsortedAssets);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			createYSort();
		}
		
		private function onEnterFrame(evt:Event):void
//		private function update():void
		{
			var time:Number = getTimer();
			var deltaTime:Number = time - lastTime;
			var lockedDelta:Number = Math.min(200, deltaTime);
			lastTime = time;
			
			if (frameCount%4 == 1)
			{
				removeExistingAssets();
				updateSortedAssets(lockedDelta);
//				drawAssets();
			}
			else
			{
				updateCoords(lockedDelta);
			}
			frameCount++;
		}
		
		private function drawAssets():void
		{			
			for (var i:int = 0; i<sortedAssets.length; i++)
			{
				var asset:ActiveAsset = sortedAssets[i];
				addChild(asset);
				asset.actualBounds = asset.getBounds(this).clone();
			}
			if (!initialDraw)
			{
				initialDraw = true;
				dispatchInitialDrawEvent();
				trace("initial draw dispatched");
			}
		}
		
		public function dispatchInitialDrawEvent():void
		{
			var evt:WorldEvent = new WorldEvent(WorldEvent.ASSETS_DRAWN, null, true, true);
			dispatchEvent(evt);
		}
		
		private function updateCoords(lockedDelta:Number):void
		{
			for (var i:int = 0; i<unsortedAssets.length; i++)
			{
				var speed:Number;
				var asset:ActiveAsset = unsortedAssets[i];
				if (asset.isMoving == true)
				{
					if (asset.speed != -1)
						speed = asset.speed;
					else
						speed = DEFAULT_SPEED;
					
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
							distanceToMoveX = -distanceToMoveX;
					}
					else if (xDiff != 0)
					{
						ratio = yDiff/xDiff;					
						distanceToMoveX = Math.sqrt((distanceToMove * distanceToMove) / (1 + ratio * ratio));
						if (xDiff < 0)
							distanceToMoveX = -distanceToMoveX;
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
//			var tempArray:ArrayCollection = new ArrayCollection();
//			for each (var a:ActiveAsset in unsortedAssets)
//			{
//				var index:Number = unsortedAssets.getItemIndex(a);
//				tempArray.addItemAt(a, index);
//			}
			updateCoords(lockedDelta);	
			unsortedAssets.sort = ySort;
			unsortedAssets.refresh();
			var tempArray:ArrayCollection = new ArrayCollection();
			tempArray.addAll(unsortedAssets);
//			sortedAssets = new ArrayCollection();
			for (var i:int = 0; i<renderFirst.length; i++)
			{
				var leadAsset:ActiveAsset = renderFirst.getItemAt(i) as ActiveAsset;
				var tempIndex:int = tempArray.getItemIndex(leadAsset);
				tempArray.removeItemAt(tempIndex);
				addChild(leadAsset);
//				sortedAssets.addItem(leadAsset);
			}
			for (var j:int = 0; j<tempArray.length; j++)
			{
				var asset:ActiveAsset = tempArray.getItemAt(j) as ActiveAsset;
				addChild(asset);
//				sortedAssets.addItem(asset);
			}
			
			if (!initialDraw)
			{
				initialDraw = true;
				dispatchInitialDrawEvent();
				trace("initial draw dispatched");
			}			
		}
		
		public function createYSort():Sort
		{
			ySort = new Sort();
			var sortField:SortField = new SortField("realCoordY");
			sortField.numeric = true;
			ySort.fields = [sortField];	
			return ySort;
		}
		
		public function swapEnterFrameHandler():void
		{
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.addEventListener(Event.ENTER_FRAME, onSpecialEnterFrame);
		}
		
		public function revertEnterFrameHandler():void
		{
			this.removeEventListener(Event.ENTER_FRAME, onSpecialEnterFrame);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onSpecialEnterFrame(evt:Event):void
		{
			var time:Number = getTimer();
			var deltaTime:Number = time - lastTime;
			var lockedDelta:Number = Math.min(200, deltaTime);
			lastTime = time;				
			
			if (frameCount%4 == 1)
			{
				removeExistingAssets();
				specialSort(lockedDelta);
				drawAssets();
			}
			else
				updateCoords(lockedDelta);
			frameCount++;							
		}

		public function specialSort(lockedDelta:Number):void
		{
			var ordered:ArrayCollection = new ArrayCollection();
			for each (var a:ActiveAsset in unsortedAssets)
			{
				if ((a.thinger as OwnedStructure).structure.structure_type != "StructureTopper" || isUnattachedAsTopper(a.thinger as OwnedStructure))
					ordered.addItem(a);	
			}
			updateCoords(lockedDelta);	
//			var sort:Sort = getYSort();
			ordered.sort = ySort;
			ordered.refresh();
			sortedAssets = new ArrayCollection();
			for (var i:int = 0; i<renderFirst.length; i++)
			{
				var leadAsset:ActiveAsset = renderFirst.getItemAt(i) as ActiveAsset;
				var tempIndex:int = ordered.getItemIndex(leadAsset);
				ordered.removeItemAt(tempIndex);
				sortedAssets.addItem(leadAsset);
			}			
			for (var j:int = 0; j < ordered.length; j++)
			{
				sortedAssets.addItem(ordered.getItemAt(j));
				var toppers:ArrayCollection = (ordered.getItemAt(j) as ActiveAsset).toppers;
				if (toppers && toppers.length > 0)
				{	
					var topperAssets:ArrayCollection = getAssociatedToppers(toppers);
					topperAssets.sort = ySort;
					topperAssets.refresh();
					for each (var t:ActiveAsset in topperAssets)
					{
						sortedAssets.addItem(t);
					}
				}
			}
		}
		
		private function getAssociatedToppers(toppers:ArrayCollection):ArrayCollection
		{
			var assets:ArrayCollection = new ArrayCollection();
			for each (var a:ActiveAsset in unsortedAssets)
			{
				for each (var t:OwnedStructure in toppers)
				{
					if (a.thinger && a.thinger.id == t.id)
						assets.addItem(a);
				}
			}
			return assets;
		}
		
		private function isUnattachedAsTopper(os:OwnedStructure):Boolean
		{
			for each (var asset:ActiveAsset in unsortedAssets)
			{
				if (asset.toppers && asset.toppers.contains(os))
					return false;
			}
			return true;
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
//			for (var i:int = 0; i<sortedAssets.length; i++)
//			{
//				var asset:ActiveAsset = sortedAssets[i];
//				if (sortedAssets.contains(asset))
//				{
//					if (this.contains(asset))
//					{
//						removeChild(asset);														
//					}
//				}
//			}			
			var kids:int = this.numChildren;
			for (var i:int = 0; i < kids; i++)
			{
				this.removeChildAt(0);
			}
		}
		
	}
}