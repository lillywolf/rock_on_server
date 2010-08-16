package clickhandlers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import helpers.CollectibleDrop;
	
	import rock_on.Person;
	import rock_on.Venue;
	
	import views.StageView;
	import views.WorldView;
	
	import world.Point3D;
	import world.World;
	
	public class WorldViewClickHandler extends EventDispatcher
	{
		public var _venue:Venue;
		public var _worldView:WorldView;
		public var _stageView:StageView;
		
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
		
		private function onEnterFrame(evt:Event):void
		{
			checkForMouseMovement();
			checkDrag();
			clearFilters();	
		}
		
		private function checkDrag():void
		{
			if (isDragging)
			{
				doDrag();
			}							
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
		
		private function checkForMouseMovement():void
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
				if (this.clickWaitTimer && this.clickWaitTimer.running)
					if (objectOfInterest)
						objectClicked(objectOfInterest);
					else
						moveMyAvatar(convertPointToWorldPoint(new Point(evt.localX, evt.localY)));
				_worldView.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				isDragging = false;
			});
		}
		
		private function objectClicked(obj:Object):void
		{
			
		}
		
		public function convertPointToWorldPoint(pt:Point):Point
		{
			var worldRect:Rectangle = _worldView.myWorld.getBounds(_worldView); 
			var wgRect:Rectangle = _worldView.myWorld.wg.getBounds(_worldView.myWorld);
			var newPoint:Point = new Point(pt.x + wgRect.left, pt.y + wgRect.y);
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
				_venue.bandMemberManager.moveMyAvatar(new Point3D(Math.round(pt3D.x), Math.round(pt3D.y), Math.round(pt3D.z)), true, false);								
			}
		}
		
		public function handleHover():Object
		{
			objectOfInterest = handleObjectUnderHover();
			if (objectOfInterest)
			{
				
			}	
			return objectOfInterest;
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
				if (_worldView.myWorld.getChildAt(i) is CollectibleDrop)
				{
					var sprite:Sprite = _worldView.myWorld.getChildAt(i) as Sprite;
					var bounds:Rectangle = sprite.getBounds(_worldView.myWorld);
					if (bounds.contains(_worldView.myWorld.mouseX, _worldView.myWorld.mouseY))
						closestSprite = sprite;					
				}
			handleUIObjectUnderHover(closestSprite);			
			return closestSprite;			
		}
		
		private function handleUIObjectUnderHover(sprite:Sprite):void
		{
			
		}
		
		private function moveableObjectUnderHover():Object
		{
			return null;
		}
		
		private function bitmappedObjectUnderHover():Object
		{
			return null;
		}
		
		private function clearUIObjectFilters():void
		{
			
		}
		
		private function clearMoveableObjectFilters():void
		{
			
		}
		
		private function clearBitmappedObjectFilters():void
		{
			
		}
		
		public function set stageView(val:StageView):void
		{
			_stageView = val;
		}
	}
}