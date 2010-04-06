package views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.Application;
	import mx.core.UIComponent;

	public class FlexibleUIComponent extends UIComponent
	{
		public function FlexibleUIComponent()
		{
			super();
			this.graphics.beginFill(0, 0);
			this.graphics.drawRect(0, 0, Application.application.width, Application.application.height);
			this.graphics.endFill();
			
			addEventListener(Event.ADDED, onAdded);			
		}
		
		private function onAdded(evt:Event):void
		{
	
		}		
		
		private function onMouseMove(evt:MouseEvent):void
		{
			
		}
		
	}
}