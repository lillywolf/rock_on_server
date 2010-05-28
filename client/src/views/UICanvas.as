package views
{
	import mx.containers.Canvas;

	public class UICanvas extends Canvas
	{
		public var MAX_WIDTH:int = 760;
		public var MAX_HEIGHT:int = 500;
		
		public function UICanvas()
		{
			super();
		}
		
		public function setStyles(color:Object, backgroundColor:Object, cornerRadius:int, width:int=0, height:int=0):void
		{
			clipContent = false;
			setStyle("backgroundColor", backgroundColor);
			setStyle("cornedRadius", cornerRadius);
			setStyle("color", color);
			setStyle("borderColor", backgroundColor);
			setStyle("borderStyle", "solid");
			width = width;
			height = height;
			x = MAX_WIDTH/2 - width/2;
			y = MAX_HEIGHT/2 - height/2;
		}
		
	}
}