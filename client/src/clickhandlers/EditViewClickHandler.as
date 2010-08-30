package clickhandlers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	
	import models.OwnedSong;
	import models.OwnedStructure;
	
	import mx.controls.Button;
	import mx.core.UIComponent;
	import mx.events.DynamicEvent;
	
	import rock_on.Venue;
	
	import views.EditView;
	import views.NormalStructureMode;
	import views.TileMode;
	
	import world.ActiveAsset;
	
	public class EditViewClickHandler extends EventDispatcher
	{
		public var _venue:Venue;
		public var _editView:EditView;
		
		public var isDragging:Boolean;
		public var clickWaitTimer:Timer;
		public var mouseIncrementX:Number;
		public var mouseIncrementY:Number;
		public var lastMouseX:Number;
		public var lastMouseY:Number;
		public var objectOfInterest:Object;
		public var selectedObject:Object;
		
		public static const CLICK_WAIT_TIME:int = 500;			
		
		public function EditViewClickHandler(venue:Venue, editView:EditView, target:IEventDispatcher=null)
		{
			super(target);
			_venue = venue;
			_editView = editView;
			
			_editView.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_editView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_editView.addEventListener(MouseEvent.MOUSE_MOVE, showHoverGlow);
			_editView.addEventListener("objectPlaced", onObjectPlaced);
			_editView.addEventListener("objectSelected", onObjectSelected);
		}
		
		private function showHoverGlow(evt:MouseEvent):void
		{
			var hitObject:Object = evt.target;
			
//			Remove filters for previous object
			if (hitObject != objectOfInterest && objectOfInterest)
				objectOfInterest.filters = null;
			
//			Add filter if valid hit object
			if (hitObject is ActiveAsset && !selectedObject)
			{	
				addHoverFilter(hitObject as ActiveAsset);
				objectOfInterest = hitObject;
			}
		}
		
		private function addHoverFilter(asset:ActiveAsset):void
		{
			if (!(_editView.currentMode is TileMode) && 
				(asset.thinger as OwnedStructure).structure.structure_type != "Tile")
			{
				var gf:GlowFilter = new GlowFilter(0xFFEE00, 1, 2, 2, 20, 20);
				asset.filters = [gf];			
			}
		}
		
		private function onEnterFrame(evt:Event):void
		{
			checkForMouseMovement();	
			checkDrag();
		}
		
		private function checkDrag():void
		{
			if (isDragging)
				doDrag();
		}
		
		private function onMouseDown(evt:MouseEvent):void
		{
			if (!(evt.target is Button))
				if (!isDragging)
					waitForDrag();				
				listenForMouseUp();			
		}
		
		private function checkForMouseMovement():void
		{
			this.lastMouseX = _editView.mouseX;
			this.lastMouseY = _editView.mouseY;
		}	
		
		private function listenForMouseUp():void
		{
			_editView.addEventListener(MouseEvent.MOUSE_UP, function onMouseUp(evt:MouseEvent):void
			{
				if (clickWaitTimer && clickWaitTimer.running)
				{	
					objectClicked(objectOfInterest, evt);
				}	
				_editView.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				isDragging = false;
			});
		}
		
		private function doDrag():void
		{	
			_editView.x = _editView.x + (_editView.mouseX - mouseIncrementX);
			_editView.y = _editView.y + (_editView.mouseY - mouseIncrementY);
		}
		
		private function objectClicked(objectOfInterest:Object, evt:MouseEvent):void
		{
			if (_editView.currentMode && _editView.currentMode is TileMode)
				(_editView.currentMode as TileMode).handleClick(evt);
			else if (_editView.currentMode && _editView.currentMode is NormalStructureMode)
				(_editView.currentMode as NormalStructureMode).handleClick(evt);
		}
		
		private function onObjectPlaced(evt:DynamicEvent):void
		{
			selectedObject = null;
		}

		private function onObjectSelected(evt:DynamicEvent):void
		{
			selectedObject = evt.selectedObject;
		}
		
		public function waitForDrag():void
		{
			startClickWaitTimer();
			isDragging = true;
			mouseIncrementX = _editView.mouseX.valueOf();
			mouseIncrementY = _editView.mouseY.valueOf();			
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
		
	}
}