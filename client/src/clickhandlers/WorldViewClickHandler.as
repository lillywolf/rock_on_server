package clickhandlers
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import game.MoodBoss;
	
	import helpers.CollectibleDrop;
	
	import models.EssentialModelReference;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import rock_on.Hater;
	import rock_on.Person;
	import rock_on.Venue;
	
	import views.AssetBitmapData;
	import views.HoverTextBox;
	import views.StageView;
	import views.WorldView;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;
	
	public class WorldViewClickHandler extends EventDispatcher
	{
		public var _venue:Venue;
		public var _worldView:WorldView;
		public var _stageView:StageView;
		public var _mouseBoss:MouseBoss;
		
		public var isDragging:Boolean;
		public var hoverTimer:Timer;
		public var clickWaitTimer:Timer;
		public var mouseIncrementX:Number;
		public var mouseIncrementY:Number;
		public var lastMouseX:Number;
		public var lastMouseY:Number;
		public var objectOfInterest:Object;
		
		public static const CLICK_WAIT_TIME:int = 500;	
		
		public function WorldViewClickHandler(venue:Venue, worldView:WorldView, target:IEventDispatcher=null)
		{
			super(target);
			_venue = venue;
			_worldView = worldView;
			
			_worldView.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_worldView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		public function onEnterFrame(evt:Event):void
		{
			checkForMouseMovement();
			checkDrag();
			handleHover();
		}
		
		private function checkDrag():void
		{
			if (isDragging)
				doDrag();
		}	
		
		private function doDrag():void
		{	
			_worldView.x = _worldView.x + (_worldView.mouseX - mouseIncrementX);
			_worldView.y = _worldView.y + (_worldView.mouseY - mouseIncrementY);
			
			dragStageToo();
		}		
		
		private function dragStageToo():void
		{
			if (_stageView)
			{
				_stageView.x = _stageView.x + (_stageView.mouseX - mouseIncrementX);
				_stageView.y = _stageView.y + (_stageView.mouseY - mouseIncrementY);				
			}
		}
		
		private function onMouseDown(evt:MouseEvent):void
		{			
			if (!isDragging)
				waitForDrag();				
			listenForMouseUp();			
		}
		
		public function checkForMouseMovement():void
		{
			if (lastMouseX != _worldView.mouseX && lastMouseY != _worldView.mouseY)
				resetHoverTimer();
			this.lastMouseX = _worldView.mouseX;
			this.lastMouseY = _worldView.mouseY;
		}
		
		private function listenForMouseUp():void
		{
			_worldView.addEventListener(MouseEvent.MOUSE_UP, function onMouseUp(evt:MouseEvent):void
			{
				if (clickWaitTimer && clickWaitTimer.running)
					if (objectOfInterest)
						objectClicked(objectOfInterest);
					else
						moveMyAvatar(convertPointToWorldPoint(new Point(_worldView.mouseX, _worldView.mouseY)));
				_worldView.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				isDragging = false;
			});
		}
		
		private function objectClicked(obj:Object):void
		{
			if (obj is Person)
				personClicked(obj as Person);				
		}
		
		private function personClicked(person:Person):void
		{
			if (person.personType == Person.STATIC || person.personType == Person.SUPER)
				doStaticPersonMoodActivities(person);
			else if (person.personType == Person.MOVING)
				doMovingPersonMoodActivities(person);
			replacePersonInBottomBar(person);
		}
		
		private function doMovingPersonMoodActivities(person:Person):void
		{
			
		}
		
		private function doStaticPersonMoodActivities(person:Person):void
		{
			for each (var reward:Object in person.mood.rewards)
			{
				if (reward.mc)
				{	
					var klass:Class = getDefinitionByName(reward.mc) as Class;
					var mc:MovieClip = new klass() as MovieClip;
					addCollectible(mc, person);
				}
			}
			if ((person.mood.possible_rewards as Array).length > 0)
				addCollectible(MoodBoss.getRandomItemByMood(person.mood), person);			
		}
		
		private function addCollectible(mc:MovieClip, asset:ActiveAsset):void
		{
			var evt:UIEvent = new UIEvent(UIEvent.COLLECTIBLE_DROP);
			evt.asset = asset;
			evt.mc = mc;
			this.dispatchEvent(evt);
		}
		
		private function replacePersonInBottomBar(person:Person):void
		{
			var evt:UIEvent = new UIEvent(UIEvent.REPLACE_BOTTOMBAR);
			evt.asset = person;
			this.dispatchEvent(evt);
		}
		
		public function convertPointToWorldPoint(pt:Point):Point
		{
			var worldRect:Rectangle = _worldView.myWorld.getBounds(_worldView); 
			var wgRect:Rectangle = _worldView.myWorld.wg.getBounds(_worldView.myWorld);
			var newPoint:Point = new Point(pt.x - worldRect.left, pt.y + wgRect.y - (_worldView.height - worldRect.height)/2);
			return newPoint;			
		}		
		
		public function clearFilters():void
		{
			clearUIObjectFilters();
			clearMoveableObjectFilters();
			clearBitmappedObjectFilters();
		}
		
		private function waitForDrag():void
		{
			startClickWaitTimer();
			isDragging = true;
			mouseIncrementX = _worldView.mouseX.valueOf();
			mouseIncrementY = _worldView.mouseY.valueOf();			
		}		
		
		private function resetHoverTimer():void
		{
			if (hoverTimer)
				hoverTimer.removeEventListener(TimerEvent.TIMER, onHoverTimerComplete);
			hoverTimer = new Timer(WorldViewClickHandler.CLICK_WAIT_TIME);
			hoverTimer.addEventListener(TimerEvent.TIMER, onHoverTimerComplete);
			hoverTimer.start();
		}
		
		private function onHoverTimerComplete(evt:TimerEvent):void
		{
			if (objectOfInterest)
			{	
				if (objectOfInterest is Person)
				{
//					Handle hovered person
				}
			}	
		}
		
		private function onClickWaitComplete(evt:TimerEvent):void
		{
			clickWaitTimer.stop();
			clickWaitTimer.removeEventListener(TimerEvent.TIMER, onClickWaitComplete);
		}
		
		private function startClickWaitTimer():void
		{
			clickWaitTimer = new Timer(CLICK_WAIT_TIME);
			clickWaitTimer.addEventListener(TimerEvent.TIMER, onClickWaitComplete);
			clickWaitTimer.start();			
		}
		
		public function moveMyAvatar(pt:Point):void
		{
			var pt3D:Point3D = World.actualToWorldCoords(pt);
			if (_venue.isPointInVenueBounds(pt3D) && 
				!_venue.isPointInStageRect(pt3D) && 
				!_venue.isPointInRect(pt3D, _venue.mainCrowdRect))
			{
				moveAvatarToWorld(pt3D);
			}
		}
		
		private function moveAvatarToWorld(pt3D:Point3D):void
		{
			_venue.bandMemberManager.moveMyAvatar(new Point3D(Math.round(pt3D.x), Math.round(pt3D.y), Math.round(pt3D.z)), true, false);											
		}
		
		public function handleHover():Object
		{
			clearFilters();				
			var newObjectOfInterest:Object = handleObjectUnderHover();
			if (newObjectOfInterest != objectOfInterest)
			{	
				removeAllHoverBoxes();
				objectOfInterest = newObjectOfInterest;	
				handleTransitionalHoverEffects(objectOfInterest as ActiveAsset)
			}	
			return objectOfInterest;
		}
		
		private function handleTransitionalHoverEffects(asset:ActiveAsset):void
		{
			if (asset && asset is Person)
				showPersonHoverText(asset as Person);			
		}
		
		private function handleObjectUnderHover():Object
		{
			var obj:Object = uiObjectUnderHover();
			if (obj)
				return obj;
			obj = moveableObjectUnderHover();
			if (obj)
				return obj;
			obj = bitmappedObjectUnderHover();
			if (obj)
				return obj;
			return null;
		}
		
		private function uiObjectUnderHover():Object
		{
			var closestSprite:Sprite;
			for (var i:int; i < _worldView.myWorld.numChildren; i++)
			{	
				if (_worldView.myWorld.getChildAt(i) is CollectibleDrop)
				{
					var sprite:Sprite = _worldView.myWorld.getChildAt(i) as Sprite;
					var bounds:Rectangle = sprite.getBounds(_worldView.myWorld);
					if (bounds.contains(_worldView.myWorld.mouseX, _worldView.myWorld.mouseY))
						closestSprite = sprite;					
				}
			}	
			handleUIObjectUnderHover(closestSprite);			
			return closestSprite;			
		}
		
		private function handleUIObjectUnderHover(sprite:Sprite):void
		{
			if (sprite)
			{	
				var gf:GlowFilter = new GlowFilter(0xFFEE00, 1, 2, 2, 20, 20);	
				sprite.filters = [gf];
			}
		}
		
		private function moveableObjectUnderHover():Object
		{
			var closestSprite:Sprite;
			for each (var sprite:Sprite in sortAssets(_worldView.myWorld.assetRenderer.unsortedAssets))
			{
				var bounds:Rectangle = sprite.getBounds(_worldView);
				if (bounds.contains(_worldView.mouseX, _worldView.mouseY))
				{
					if (sprite is ActiveAsset)
						closestSprite = sprite;
				}
			}
			handleMoveableObjectUnderHover(closestSprite as ActiveAsset);
			return closestSprite;
		}
		
		private function handleHoverTransitions(asset:ActiveAsset):void
		{
			if (objectOfInterest != asset)
				removeAllHoverBoxes();
		}
		
		private function handleMoveableObjectUnderHover(asset:ActiveAsset):void
		{
			if (asset && asset is Person)
				handlePersonUnderHover(asset);
			else if (asset)
				handleStructureUnderHover(asset);
		}
		
		private function handlePersonUnderHover(asset:ActiveAsset):void
		{
			var gf:GlowFilter;
			if (asset is Hater)		
				gf = new GlowFilter(0xFF054C, 1, 2, 2, 20, 20);	
			else
				gf = new GlowFilter(0x00F2FF, 1, 2, 2, 20, 20);
			asset.filters = [gf];
		}
		
		private function handleStructureUnderHover(asset:ActiveAsset):void
		{
			var gf:GlowFilter = new GlowFilter(0x00F2FF, 1, 2, 2, 20, 20);
			asset.filters = [gf];
		}
		
		private function bitmappedObjectUnderHover():Object
		{
			var closestBitmap:AssetBitmapData;
			for each (var abd:AssetBitmapData in _worldView.bitmapBlotter.bitmapReferences)
			{
				if (_worldView.bitmapBlotter.isUnderMousePoint(abd))
					closestBitmap = abd;
			}
			handleBitmapUnderHover(closestBitmap);
			if (closestBitmap)
				return closestBitmap.activeAsset;
			else
				return null;
		}
		
		private function handleBitmapUnderHover(abd:AssetBitmapData):void
		{
			if (abd)
			{
				var gf:GlowFilter = new GlowFilter(0x00F2FF, 1, 2, 2, 20, 20);
				abd.bitmap.filters = [gf];
				abd.moodClip.filters = [gf];
			}
		}
		
		private function showPersonHoverText(person:Person):void
		{
			var hoverBox:HoverTextBox = person.generateMoodMessage();
			if (hoverBox)
			{	
				hoverBox.x = _worldView.mouseX;
				hoverBox.y = _worldView.mouseY;
				_worldView.addChild(hoverBox);	
			}	
		}
		
		private function removeAllHoverBoxes():void
		{
			for (var i:int = 0; i < _worldView.numChildren; i++)
			{
				var worldChild:DisplayObject = _worldView.getChildAt(i);
				if (worldChild is HoverTextBox)
					_worldView.removeChild(worldChild);
			}
		}
		
		private function clearUIObjectFilters():void
		{
			for (var i:int; i < _worldView.myWorld.numChildren; i++)
			{	
				if (_worldView.myWorld.getChildAt(i) is CollectibleDrop)
				{
					(_worldView.myWorld.getChildAt(i) as CollectibleDrop).filters = null;
				}	
			}	
		}
		
		private function clearMoveableObjectFilters():void
		{
			for each (var sprite:Sprite in _worldView.myWorld.assetRenderer.unsortedAssets)
				sprite.filters = null;
		}
		
		private function clearBitmappedObjectFilters():void
		{
			for each (var abd:AssetBitmapData in _worldView.bitmapBlotter.bitmapReferences)
			{
				abd.bitmap.filters = null;
				abd.moodClip.filters = null;
			}	
		}
		
		public function sortAssets(assets:ArrayCollection):ArrayCollection
		{
			var sort:Sort = _worldView.myWorld.assetRenderer.getYSort();
			var sorted:ArrayCollection = new ArrayCollection();
			for each (var asset:ActiveAsset in assets)
			{
				sorted.addItem(asset);
			}	
			sorted.sort = sort;
			sorted.refresh();	
			return sorted;
		}		
		
		public function set stageView(val:StageView):void
		{
			_stageView = val;
		}

		public function set mouseBoss(val:MouseBoss):void
		{
			_mouseBoss = val;
		}
	}
}