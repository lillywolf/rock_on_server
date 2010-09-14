package clickhandlers
{
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
	
	import helpers.CollectibleDrop;
	
	import models.OwnedStructure;
	
	import rock_on.ConcertStage;
	import rock_on.Person;
	import rock_on.Venue;
	
	import views.HoverTextBox;
	import views.StageView;
	import views.WorldView;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;
	
	public class StageViewClickHandler extends EventDispatcher
	{
		public var _venue:Venue;
		public var _stageView:StageView;
		public var _worldView:WorldView;
		public var _mouseBoss:MouseBoss;
		
		public var isDragging:Boolean;
		public var clickWaitTimer:Timer;
		public var hoverTimer:Timer;
		public var lastMouseX:Number;
		public var lastMouseY:Number;
		public var objectOfInterest:Object;	
		
		public static const CLICK_WAIT_TIME:int = 500;			
		
		public function StageViewClickHandler(venue:Venue, worldView:WorldView, stageView:StageView, target:IEventDispatcher=null)
		{
			super(target);
			_venue = venue;
			_stageView = stageView;
			_worldView = worldView;
			
			_worldView.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_worldView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);			
		}
		
		private function onMouseDown(evt:MouseEvent):void
		{
			if (!isDragging)
				waitForDrag();				
			listenForMouseUp();			
		}		
		
		public function onEnterFrame(evt:Event):void
		{
			handleHover();
		}		
		
		private function waitForDrag():void
		{
			startClickWaitTimer();
			isDragging = true;		
		}			
		
		private function listenForMouseUp():void
		{
			_worldView.addEventListener(MouseEvent.MOUSE_UP, function onMouseUp(evt:MouseEvent):void
			{
				if (clickWaitTimer && clickWaitTimer.running)
					if (objectOfInterest)
						objectClicked(objectOfInterest);
					else
						moveMyAvatar(convertPointToWorldPoint(new Point(_stageView.mouseX, _stageView.mouseY)));
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
			if (person.personType == Person.MOVING)
				doMovingPersonMoodActivities(person);
			replacePersonInBottomBar(person);
		}
		
		private function doMovingPersonMoodActivities(person:Person):void
		{
			
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
			var newPoint:Point = new Point(pt.x - worldRect.left, pt.y + wgRect.y - (_worldView.height - wgRect.height)/2);
			return newPoint;		
		}		
		
		public function clearFilters():void
		{
			clearMoveableObjectFilters();
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
			hoverTimer.stop();
			hoverTimer.removeEventListener(TimerEvent.TIMER, onHoverTimerComplete);
			hoverTimer = null;
			
			if (objectOfInterest && objectOfInterest is Person)
			{	
				var uiEvt:UIEvent = new UIEvent(UIEvent.REPLACE_BOTTOMBAR);
				uiEvt.asset = objectOfInterest as Person;
				this.dispatchEvent(uiEvt);
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
		
		private function isDestinationInStage(pt3D:Point3D):Boolean
		{
			var rect:Rectangle = _venue.stageRect;
			if (pt3D.x <= rect.right && pt3D.z >= rect.top)
				return true;
			return false;
		}
		
		public function moveMyAvatar(pt:Point):void
		{
			var pt3D:Point3D = World.actualToWorldCoords(pt, _stageView.concertStage.structure.height);
			if (isDestinationInStage(pt3D))
				moveAvatarToStage(pt3D);
		}		
		
		private function moveAvatarToStage(pt3D:Point3D):void
		{
			_venue.bandMemberManager.moveMyAvatar(new Point3D(Math.round(pt3D.x), Math.round(pt3D.y), Math.round(pt3D.z)), false, true);											
		}
		
		public function handleHover():Object
		{
			clearFilters();
			var newObjectOfInterest:Object;
			if (_mouseBoss && !_mouseBoss.checkIfWorldViewHovering())
				newObjectOfInterest = handleObjectUnderHover();
//			Do not count concert stage as an object of interest
			if (newObjectOfInterest != objectOfInterest && !(newObjectOfInterest as ActiveAsset).thinger is ConcertStage)
			{	
				resetHoverTimer();
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
			return closestSprite;			
		}
		
		private function moveableObjectUnderHover():Object
		{
			var closestAsset:ActiveAsset;
			for each (var asset:ActiveAsset in _stageView.myStage.assetRenderer.unsortedAssets)
			{
				var bounds:Rectangle = asset.getBounds(_stageView);
				if (bounds.contains(_stageView.mouseX, _stageView.mouseY))
				{
					if (!(asset.thinger is OwnedStructure && (asset.thinger as OwnedStructure).structure.structure_type == "Tile"))
						closestAsset = asset;
				}
			}
			handleMoveableObjectUnderHover(closestAsset);
			return closestAsset;
		}
		
		private function handleMoveableObjectUnderHover(asset:ActiveAsset):void
		{
			if (asset && asset is Person)
				handlePersonUnderHover(asset);
			else if (asset)
				handleStructureUnderHover(asset);
		}
		
		public function set mouseBoss(val:MouseBoss):void
		{
			_mouseBoss = val;
		}
		private function handlePersonUnderHover(asset:ActiveAsset):void
		{
			var gf:GlowFilter = new GlowFilter(0x00F2FF, 1, 2, 2, 20, 20);
			asset.filters = [gf];
		}
		
		private function handleStructureUnderHover(asset:ActiveAsset):void
		{
			var gf:GlowFilter = new GlowFilter(0x00F2FF, 1, 2, 2, 20, 20);
			asset.filters = [gf];
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
		
		private function clearMoveableObjectFilters():void
		{
			for each (var sprite:Sprite in _stageView.myStage.assetRenderer.unsortedAssets)
			sprite.filters = null;
		}		
	}
}