package views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	
	public class DraggableCanvas extends Canvas
	{
		private var orgX:Number;
		private var orgY:Number;
		private var orgHScrollPosition:Number;
		private var orgVScrollPosition:Number;
		private var _childrenDoDrag:Boolean = true;

		public function DraggableCanvas()
		{
			super();
		}
		
		public function get childrenDoDrag():Boolean 
		{
			return _childrenDoDrag;
		}
		
		public function set childrenDoDrag(val:Boolean):void 
		{
			_childrenDoDrag = val;
		}
		
		override protected function createChildren():void 
		{
			super.createChildren();
			addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
		}
		
		protected function startDragging(evt:MouseEvent):void
		{		
			if (evt.target.parent == verticalScrollBar || evt.target.parent == horizontalScrollBar) 
			{
				return;
			}
			
			if (_childrenDoDrag || evt.target == this) 
			{
//				orgX = evt.stageX;
//				orgY = evt.stageY;
//				
//				orgHScrollPosition = this.horizontalScrollPosition;
//				orgVScrollPosition = this.verticalScrollPosition;
				
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseMove, true);
				
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
				
				stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			}
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{	
			evt.stopImmediatePropagation();
			
//			verticalScrollPosition = orgVScrollPosition - (evt.stageY - orgY);
//			horizontalScrollPosition = orgHScrollPosition - (evt.stageX - orgX);
			this.y = mouseY;
			this.x = mouseX;
		}
		
		private function onMouseUp(evt:MouseEvent):void
		{
			if (!isNaN(orgX))
				stopDragging();
		}
		
		private function onMouseLeave(evt:Event):void
		{
			if (!isNaN(orgX))
				stopDragging();
		}
		
		protected function stopDragging():void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
			
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
			
			stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			
			orgX = NaN;
			orgY = NaN;
		}
	}
}