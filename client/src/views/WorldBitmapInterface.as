package views
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.containers.Canvas;
	
	import rock_on.BandMember;
	import rock_on.CustomerPerson;
	import rock_on.CustomerPersonManager;
	import rock_on.Person;
	
	import world.ActiveAsset;
	import world.AssetStack;
	import world.BitmapBlotter;
	
	public class WorldBitmapInterface extends EventDispatcher
	{
		[Bindable] public var _bandManager:BandManager;
		[Bindable] public var _customerPersonManager:CustomerPersonManager;
		[Bindable] public var _worldView:WorldView;
		[Bindable] public var _stageView:StageView;
		[Bindable] public var _bitmapBlotter:BitmapBlotter;
		[Bindable] public var _editView:EditView;
		[Bindable] public var _bottomBar:BottomBar;
		[Bindable] public var _backgroundCanvas:Canvas;
		public var cursorUIC:ContainerUIC;
		public var isDragging:Boolean;
		public var mouseIncrementX:Number;
		public var mouseIncrementY:Number;
		public function WorldBitmapInterface(worldView:WorldView, stageView:StageView, editView:EditView, bottomBar:BottomBar, target:IEventDispatcher=null)
		{
			super(target);
			_worldView = worldView;
			_stageView = stageView;
			_editView = editView;
			_bottomBar = bottomBar;
		}
		
		public function set backgroundCanvas(val:Canvas):void
		{
			_backgroundCanvas = val;
		}
		
		public function get backgrounsCanvas():Canvas
		{
			return _backgroundCanvas;
		}
		
		public function set bitmapBlotter(val:BitmapBlotter):void
		{
			_bitmapBlotter = val;
		}
		
		public function get bitmapBlotter():BitmapBlotter
		{
			return _bitmapBlotter;
		}
		
		public function handleEnterFrameEvents():void
		{
			if (_worldView)
			{
				if (_worldView.creaturesAdded && _stageView.bandManager)
				{
					if (_stageView.bandManager.bandMemberManager)
					{
						updateCursor();									
					}
				}
				checkDrag();			
			}
		}
		
		public function checkDrag():void
		{
			if (isDragging)
			{
				dragStage();
			}				
		}
		
		public function getPersonFromAsset(asset:ActiveAsset):Person
		{
			for each (var cp:CustomerPerson in _customerPersonManager)
			{
				if (cp.creature)
				{
					if (cp.creature == (asset as AssetStack).creature && cp.moods)
					{					
						return cp;
					}
				}
			}
			for each (var bm:BandMember in _bandManager.bandMemberManager)
			{
				if (bm == asset && bm.moods)
				{
					return bm;
				}
			}
			return null;
		}
		
		public function checkCreatureHover(asset:ActiveAsset):MovieClip
		{
			var person:Person = getPersonFromAsset(asset);
			if (person)
			{
				var cursorClip:MovieClip = person.generateMoodCursor(person.moods[0]);
				var gf:GlowFilter = new GlowFilter(0x0CEB7B);
				person.filters = [gf];						
				return cursorClip;
			}
			return null;
		}					
		
		public function onWorldViewClicked(evt:MouseEvent):void
		{
			var bitmapClicked:Boolean = bitmapClicked(evt);
			
			if (!bitmapClicked)
			{
				checkIfStageViewClicked(_worldView.mouseX - _worldView.myWorld.x, _worldView.mouseY, _stageView.height);				
			}
		}
		
		public function sortStageAssets():ArrayCollection
		{
			var sort:Sort = _stageView.myStage.assetRenderer.getYSort();
			var sortedArray:ArrayCollection = new ArrayCollection();
			for each (var asset:ActiveAsset in _stageView.myStage.assetRenderer.unsortedAssets)
			{
				sortedArray.addItem(asset);
			}
			sortedArray.sort = sort;
			sortedArray.refresh();	
			return sortedArray;
		}	
		
		public function sortWorldAssets():ArrayCollection
		{
			var sort:Sort = _worldView.myWorld.assetRenderer.getYSort();
			var sortedArray:ArrayCollection = new ArrayCollection();
			for each (var asset:ActiveAsset in _worldView.myWorld.assetRenderer.unsortedAssets)
			{
				sortedArray.addItem(asset);
			}
			sortedArray.sort = sort;
			sortedArray.refresh();	
			return sortedArray;		
		}
		
		public function stageClicked(currentMouseX:int, currentMouseY:int):void
		{
			var sortedArray:ArrayCollection = sortStageAssets();
			
			for each (var asset:ActiveAsset in sortedArray)				
			{
				if (asset is AssetStack)
				{
					var hitRect:Rectangle = new Rectangle(asset.x - asset.width/2, asset.y - asset.height, asset.width, asset.height);
					if (hitRect.contains(currentMouseX, currentMouseY))
					{
						_bottomBar.replaceCreature((asset as AssetStack).creature);
					}
				}
			}
		}
		
		public function worldHovered():MovieClip
		{
			var cursorClip:MovieClip;
			
			for each (var asset:ActiveAsset in _worldView.myWorld.assetRenderer.unsortedAssets)				
			{
				if (asset is AssetStack)
				{
					var bounds:Rectangle = (asset as AssetStack).movieClipStack.getBounds(_worldView);
					if (bounds.contains(_worldView.mouseX, _worldView.mouseY))
					{
						clearFilters();
						cursorClip = checkCreatureHover(asset);
					}
				}
			}	
			return cursorClip;
		}
		
		public function stageHovered(currentMouseX:int, currentMouseY:int):MovieClip
		{
			var sortedArray:ArrayCollection = sortStageAssets();
			var cursorClip:MovieClip;
			
			for each (var asset:ActiveAsset in sortedArray)				
			{
				if (asset is AssetStack)
				{
					var hitRect:Rectangle = new Rectangle(asset.x - asset.width/2, asset.y - asset.height, asset.width, asset.height);
					if (hitRect.contains(currentMouseX, currentMouseY))
					{
						clearFilters();
						cursorClip = checkCreatureHover(asset);
					}
				}
			}				
			return cursorClip;
		}		
		
		private function updateCursor():void
		{
			clearFilters();
			
			var bitmapHovered:Boolean = bitmapHovered();
			var cursorClip:MovieClip;
			if (!bitmapHovered)
			{
				cursorClip = checkIfStageViewHovered(_worldView.mouseX - _worldView.myWorld.x, _worldView.mouseY, _stageView.height);				
			}
			if (!cursorClip)
			{
				cursorClip = worldHovered();
			}
			handleCursorClip(cursorClip);
		}	
		
		public function handleCursorClip(cursorClip:MovieClip):void
		{
			if (!cursorUIC && !cursorClip)
			{
			}
			else if (!cursorUIC && cursorClip)
			{
				addCursorUIC(cursorClip);
			}
			else if (!cursorClip && cursorUIC)
			{
				removeCursorUIC();
			}
			else if (getQualifiedClassName(cursorUIC.mc) != getQualifiedClassName(cursorClip))
			{
				swapCursorClip(cursorClip);
			}
			else
			{
				updateCursorUIC();
			}
		}
		
		public function clearFilters():void
		{
			if (_customerPersonManager)
			{
				_customerPersonManager.clearFilters();			
			}
			if (_bandManager)
			{
				_bandManager.bandMemberManager.clearFilters();			
			}
		}
		
		public function removeCursorUIC():void
		{
			if (_worldView.contains(cursorUIC))
			{
				_worldView.removeChild(cursorUIC);				
			}
			cursorUIC = null;
		}
		
		public function addCursorUIC(cursorClip:MovieClip):void
		{
			createNewCursorUIC(cursorClip);
			_worldView.addChild(cursorUIC);
		}
		
		public function swapCursorClip(cursorClip:MovieClip):void
		{
			if (_worldView.contains(cursorUIC))
			{
				_worldView.removeChild(cursorUIC);				
			}
			createNewCursorUIC(cursorClip);
			_worldView.addChild(cursorUIC);
		}
		
		public function createNewCursorUIC(cursorClip:MovieClip):void
		{
			cursorUIC = new ContainerUIC();
			var bp:Bitmap = BitmapBlotter.getBitmapForMovieClip(cursorClip);
			cursorUIC.setStyles(_worldView.mouseX, _worldView.mouseY, cursorClip.width, cursorClip.height);
			cursorUIC.mc = cursorClip;
			cursorUIC.bitmap = bp;
			cursorUIC.addChild(bp);				
		}
		
		public function updateCursorUIC():void
		{
			cursorUIC.x = _worldView.mouseX;
			cursorUIC.y = _worldView.mouseY;
		}	
		
		public function onMouseDown(evt:MouseEvent):void
		{
			isDragging = true;
			mouseIncrementX = _worldView.mouseX.valueOf();
			mouseIncrementY = _worldView.mouseY.valueOf();
			_worldView.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}	
		
		public function isMouseInsideBitmapAsset():AssetBitmapData
		{
			var hitAbd:AssetBitmapData;
			for each (var abd:AssetBitmapData in _bitmapBlotter.bitmapReferences)
			{
				if (isMouseInsideAsset(abd))
				{
					hitAbd = abd;
				}
			}	
			return hitAbd;
		}
		
		public function isMouseInsideAsset(abd:AssetBitmapData):Boolean
		{
			var isInside:Boolean;
			if (abd.bitmap)
			{
				var hitRect:Rectangle = new Rectangle(abd.bitmap.x, abd.bitmap.y, abd.mc.width, abd.mc.height);
				if (hitRect.contains(_backgroundCanvas.mouseX, _backgroundCanvas.mouseY))
				{
					isInside = true;
				}
			}	
			return isInside;
		}
		
		private function bitmapClicked(evt:MouseEvent):Boolean
		{
			var abd:AssetBitmapData = isMouseInsideBitmapAsset();
			if (abd)
			{
				_bottomBar.replaceCreature((abd.activeAsset as AssetStack).creature);
				return true;
			}
			return false;
		}	
		
		private function bitmapHovered():Boolean
		{
			var abd:AssetBitmapData = isMouseInsideBitmapAsset();
			if (abd)
			{
				return true;
			}
			return false;
		}	
		
		private function checkIfStageViewClicked(currentMouseX:Number, currentMouseY:Number, viewHeight:Number):void
		{
			var adjustedY:Number = getAdjustedY(currentMouseX, currentMouseY, viewHeight);
			stageClicked(currentMouseX, adjustedY);				
		}
		
		private function checkIfStageViewHovered(currentMouseX:Number, currentMouseY:Number, viewHeight:Number):MovieClip
		{
			var cursorClip:MovieClip;
			var adjustedY:Number = getAdjustedY(currentMouseX, currentMouseY, viewHeight);
			cursorClip = stageHovered(currentMouseX, adjustedY);
			return cursorClip;
		}
		
		public function getAdjustedY(currentMouseX:Number, currentMouseY:Number, viewHeight:Number):Number
		{
			var adjustedY:Number;
			if (currentMouseY <= viewHeight/2)
			{
				adjustedY = currentMouseY - viewHeight/2;
			}
			else
			{
				adjustedY = -(viewHeight/2 - currentMouseY);
			}
			return adjustedY;
		}
		
		private function dragStage():void
		{		
			_stageView.x = _stageView.x + (_worldView.mouseX - mouseIncrementX);
			_stageView.y = _stageView.y + (_worldView.mouseY - mouseIncrementY);
			_worldView.x = _worldView.x + (_worldView.mouseX - mouseIncrementX);
			_worldView.y = _worldView.y + (_worldView.mouseY - mouseIncrementY);
		}		
		
		private function onMouseUp(evt:MouseEvent):void
		{
			_worldView.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			isDragging = false;
		}		
		
		public function set bandManager(val:BandManager):void
		{
			_bandManager = val;
		}
		
		public function get bandManager():BandManager
		{
			return _bandManager;
		}
		
		public function set customerPersonManager(val:CustomerPersonManager):void
		{
			_customerPersonManager = val;
		}
		
		public function get customerPersonManager():CustomerPersonManager
		{
			return _customerPersonManager;
		}
	}
}