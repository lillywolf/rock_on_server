package clickhandlers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Button;
	
	import rock_on.Venue;
	
	import views.EditView;
	import views.NormalStructureMode;
	import views.TileMode;
	
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
		
		public static const CLICK_WAIT_TIME:int = 500;			
		
		public function EditViewClickHandler(venue:Venue, editView:EditView, target:IEventDispatcher=null)
		{
			super(target);
			_venue = venue;
			_editView = editView;
			
			_editView.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_editView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
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
					objectClicked(objectOfInterest, evt);
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