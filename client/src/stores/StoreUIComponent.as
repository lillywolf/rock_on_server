package stores
{
	import flash.events.MouseEvent;
	
	import models.Store;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.core.UIComponent;

	public class StoreUIComponent extends UIComponent
	{
		public var _store:Store;
		public var canvas:Canvas;
		public static const STORE_WIDTH:int = 500;
		public static const STORE_HEIGHT:int = 400;
		public static const PADDING_X:int = 10;
		
		public function StoreUIComponent(store:Store)
		{
			super();
			_store = store;
		}
		
		public function addDefaultStyle():void
		{
			width = STORE_WIDTH;
			height = STORE_HEIGHT;
			canvas = new Canvas();
			canvas.setStyle("backgroundColor", 0x333333);
			canvas.setStyle("cornerRadius", "14");
			canvas.setStyle("borderColor", 0x333333);
			canvas.setStyle("borderStyle", "solid");
			canvas.width = STORE_WIDTH;
			canvas.height = STORE_HEIGHT;
			addCloseButton();
			addChild(canvas);
		}
		
		public function addCloseButton():void
		{
			var btn:Button = new Button();
			btn.width = 30;
			btn.height = 20;
			btn.setStyle("right", 0);
			btn.setStyle("top", 0);
			btn.addEventListener(MouseEvent.CLICK, onCloseButtonClicked);
			canvas.addChild(btn);
		}
		
		private function onCloseButtonClicked(evt:MouseEvent):void
		{
			parent.removeChild(this);
		}
		
		public function set store(val:Store):void
		{
			_store = val;
		}
		
		public function get store():Store
		{
			return _store;
		}
		
	}
}