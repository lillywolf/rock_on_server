package views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	
	public class DraggableCanvas extends Canvas
	{
		public var isDragging:Boolean;
		public var mouseIncrementX:Number;
		public var mouseIncrementY:Number;
		
		public function DraggableCanvas()
		{
			super();
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);				
		}
		
		private function onMouseDown(evt:MouseEvent):void
		{
			isDragging = true;
			mouseIncrementX = mouseX.valueOf();
			mouseIncrementY = mouseY.valueOf();
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}	
		
	}
}