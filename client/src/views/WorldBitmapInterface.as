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
	
	import models.Usable;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.containers.Canvas;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	import rock_on.BandMember;
	import rock_on.CustomerPerson;
	import rock_on.CustomerPersonManager;
	import rock_on.Person;
	import rock_on.Venue;
	
	import world.ActiveAsset;
	import world.ActiveAssetStack;
	import world.AssetStack;
	import world.BitmapBlotter;
	import world.World;
	
	public class WorldBitmapInterface extends EventDispatcher
	{
		[Bindable] public var _venueManager:VenueManager;
		[Bindable] public var _bandBoss:BandBoss;
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
		public function WorldBitmapInterface(worldView:WorldView, stageView:StageView, editView:views.EditView=null, bottomBar:BottomBar=null, target:IEventDispatcher=null)
		{
			super(target);
			_worldView = worldView;
			_stageView = stageView;
			_editView = editView;
			_bottomBar = bottomBar;
			
			_venueManager = _worldView.venueManager;
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
		
		public function handleEnterFrameEvents(view:WorldView, concertStageView:StageView=null):void
		{
			if (view && concertStageView)
			{
				if (view.creaturesAdded && concertStageView.venueManager.bandBoss)
				{
					if (view.venueManager.venue.bandMemberManager)
					{
						updateCursor(view, concertStageView);									
					}
				}
			}
			if (view)
			{
				checkDrag(view, concertStageView);							
			}
		}
		
		public function checkDrag(view:WorldView, concertStageView:StageView=null):void
		{
			if (isDragging)
			{
				dragStage(view, concertStageView);
			}				
		}
		
		public function getPersonFromAsset(asset:ActiveAsset, view:WorldView, concertStageView:StageView):Person
		{
			for each (var cp:CustomerPerson in view.venueManager.venue.customerPersonManager)
			{
				if (cp.creature)
				{
					if (cp.creature == (asset as ActiveAssetStack).creature && cp.mood)
					{					
						return cp;
					}
				}
			}
			for each (var bm:BandMember in concertStageView.venueManager.venue.bandMemberManager)
			{
				if (bm == asset && bm.mood)
				{
					return bm;
				}
			}
			return null;
		}
		
		public function checkCreatureHover(asset:ActiveAsset, view:WorldView, concertStageView:StageView):Object
		{
			var person:Person = getPersonFromAsset(asset, view, concertStageView);
			
			if (person)
			{
				var cursorClip:MovieClip = person.generateMoodCursor(person.mood);
				var gf:GlowFilter = new GlowFilter(0x00F2FF, 1, 2, 2, 20, 20);
				person.filters = [gf];	
				var cursorMessage:UIComponent = person.generateMoodMessage(person.mood);
				return {cursorClip: cursorClip, cursorMessage: cursorMessage};
			}
			return null;
		}
		
		public static function getTypicalTextFilter():GlowFilter
		{
			var filter:GlowFilter = new GlowFilter(0x333333, 1, 1.4, 1.4, 30, 5); 
			return filter;
		}		
		
		public static function setStylesForNurtureText(usableText:Text, usable:Usable, numberOfOwnedUsables:int):void
		{
			usableText.setStyle("paddingLeft", 5);
			usableText.setStyle("paddingRight", 5);
			usableText.setStyle("paddingTop", 2);
			usableText.setStyle("paddingBottom", 2);
			usableText.setStyle("fontFamily", "Museo-Slab-900");
			usableText.setStyle("fontSize", 13);
			usableText.setStyle("color", 0xffffff);
			usableText.filters = [WorldBitmapInterface.getTypicalTextFilter()];
		}
		
		public static function setStylesForGenericBackContainer(container:Canvas):void
		{
			container.clipContent;
		}
		
		public static function setStylesForNurtureContainer(container:UIComponent, numberOfOwnedUsables:int):void
		{
//			container.y = 22;
//			container.x = 20;
			container.setStyle("cornerRadius", 6);
			container.setStyle("borderStyle", "solid");
			if (numberOfOwnedUsables > 0)
			{
				container.setStyle("borderColor", 0x008C52);
				container.setStyle("backgroundColor", 0x35DE49);
			}
			else
			{
				container.setStyle("borderColor", 0x910000);
				container.setStyle("backgroundColor", 0xFF3333);				
			}
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
		
		public function worldHovered(view:WorldView, concertStageView:StageView):Object
		{
			var cursorObject:Object;
			
			for each (var asset:ActiveAsset in view.myWorld.assetRenderer.unsortedAssets)				
			{
				if (asset is Person)
				{
					var bounds:Rectangle = (asset as Person).getBounds(view);
					if (bounds.contains(view.mouseX, view.mouseY))
					{
						clearFilters();
						cursorObject = checkCreatureHover(asset, view, concertStageView);
					}
				}
			}	
			return cursorObject;
		}
		
		public function stageHovered(currentMouseX:int, currentMouseY:int, view:WorldView, concertStageView:StageView):Object
		{
			var sortedArray:ArrayCollection = sortStageAssets();
			var cursorObject:Object;
			
			for each (var asset:ActiveAsset in sortedArray)				
			{
				if (asset is ActiveAssetStack)
				{
					var hitRect:Rectangle = new Rectangle(asset.x - asset.width/2, asset.y - asset.height, asset.width, asset.height);
					if (hitRect.contains(currentMouseX, currentMouseY))
					{
						clearFilters();
						cursorObject = checkCreatureHover(asset, view, concertStageView);
					}
				}
			}				
			return cursorObject;
		}		
		
		private function updateCursor(view:WorldView, concertStageView:StageView):void
		{
			clearFilters();
			
			var bitmapHovered:Boolean = bitmapHovered();
			var cursorObject:Object;

			if (!bitmapHovered)
			{
				cursorObject = checkIfStageViewHovered(view.mouseX - view.myWorld.x, concertStageView.mouseY, concertStageView.height, view, concertStageView);				
			}
			if (!cursorObject)
			{
				cursorObject = worldHovered(view, concertStageView);
			}
			handleCursorObject(cursorObject);
		}	
		
		public function handleCursorObject(cursorObject:Object):void
		{
//			var cursorClip:MovieClip = cursorObject.cursorClip;
			if (!cursorUIC && !cursorObject)
			{
			}
			else if (!cursorUIC && cursorObject)
			{
				addCursorUIC(cursorObject.cursorClip, cursorObject.cursorMessage);
			}
			else if (!cursorObject && cursorUIC)
			{
				removeCursorUIC();
			}
			else if (getQualifiedClassName(cursorUIC.mc) != getQualifiedClassName(cursorObject.cursorClip))
			{
				swapCursorClip(cursorObject.cursorClip, cursorObject.cursorMessage);
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
			if (_bandBoss)
			{
				_venueManager.venue.bandMemberManager.clearFilters();			
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
		
		public function addCursorUIC(cursorClip:MovieClip, cursorMessage:UIComponent=null):void
		{
			createNewCursorUIC(cursorClip, cursorMessage);
			_worldView.addChild(cursorUIC);
		}
		
		public function swapCursorClip(cursorClip:MovieClip, cursorMessage:UIComponent=null):void
		{
			if (_worldView.contains(cursorUIC))
			{
				_worldView.removeChild(cursorUIC);				
			}
			createNewCursorUIC(cursorClip, cursorMessage);
			_worldView.addChild(cursorUIC);
		}
		
		public function createNewCursorUIC(cursorClip:MovieClip, cursorMessage:UIComponent=null):void
		{
			cursorUIC = new ContainerUIC();
			var bp:Bitmap = BitmapBlotter.getBitmapForMovieClip(cursorClip);
			cursorUIC.setStyles(_worldView.mouseX, _worldView.mouseY, cursorClip.width, cursorClip.height);
			cursorUIC.mc = cursorClip;
			cursorUIC.bitmap = bp;
			cursorUIC.addChild(bp);	
			if (cursorMessage)
			{
				cursorMessage.y = bp.height + bp.y;
				cursorMessage.x = bp.x - 3;
				cursorUIC.addChild(cursorMessage);
			}
		}
		
		public function updateCursorUIC():void
		{
			cursorUIC.x = _worldView.mouseX;
			cursorUIC.y = _worldView.mouseY;
		}	
		
		public function handleMouseDown(view:WorldView):void
		{
			isDragging = true;
			mouseIncrementX = view.mouseX.valueOf();
			mouseIncrementY = view.mouseY.valueOf();
			view.addEventListener(MouseEvent.MOUSE_UP, function onMouseUp():void
			{
				view.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				isDragging = false;				
			});
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
				_bottomBar.replaceCreature((abd.activeAsset as ActiveAssetStack).creature);
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
		
		private function checkIfStageViewHovered(currentMouseX:Number, currentMouseY:Number, viewHeight:Number, view:WorldView, concertStageView:StageView):Object
		{
			var cursorObject:Object;
			var adjustedY:Number = getAdjustedY(currentMouseX, currentMouseY, viewHeight);
			cursorObject = stageHovered(currentMouseX, adjustedY, view, concertStageView);
			return cursorObject;
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
		
		private function dragStage(view:WorldView, concertStageView:StageView=null):void
		{		
			if (concertStageView)
			{
				concertStageView.x = concertStageView.x + (view.mouseX - mouseIncrementX);
				concertStageView.y = concertStageView.y + (view.mouseY - mouseIncrementY);
			}
			view.x = view.x + (view.mouseX - mouseIncrementX);
			view.y = view.y + (view.mouseY - mouseIncrementY);
		}
		
		public function createBackgroundLayer(currentWorld:World, currentWidth:int, currentHeight:int):Canvas
		{
			var relWidth:Number = currentWorld.wg.getRect(currentWorld).width;
			var relHeight:Number = currentWorld.wg.getRect(currentWorld).height;
			
			var bitmapBlotter:BitmapBlotter = new BitmapBlotter();
			currentWorld.bitmapBlotter = bitmapBlotter;
			bitmapBlotter.myWorld = currentWorld;
			bitmapBlotter.incrementX = (currentWidth - relWidth)/2;
			bitmapBlotter.incrementY = (currentHeight - relHeight)/2;
			bitmapBlotter.relWidth = relWidth;
			bitmapBlotter.relHeight = relHeight;
			currentWorld.bitmapBlotter = bitmapBlotter;
			
			var backgroundCanvas:Canvas = new Canvas();
			backgroundCanvas.width = relWidth;
			backgroundCanvas.height = relHeight;
			backgroundCanvas.clipContent = false;
			_backgroundCanvas = backgroundCanvas;
			backgroundCanvas.x = (currentWidth - relWidth)/2;
			backgroundCanvas.y = (currentHeight - relHeight)/2;
			backgroundCanvas.setStyle("backgroundAlpha", 0);
			
			bitmapBlotter.backgroundCanvas = backgroundCanvas;
			return backgroundCanvas;
//			addChild(backgroundCanvas);
//			backgroundCanvas.nestLevel = 2;				
		}
		
		public function set bandBoss(val:BandBoss):void
		{
			_bandBoss = val;
		}
		
		public function get bandBoss():BandBoss
		{
			return _bandBoss;
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