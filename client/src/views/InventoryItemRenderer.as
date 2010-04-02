package views
{
	import mx.containers.Canvas;
	import mx.core.UIComponent;

	public class InventoryItemRenderer extends Canvas
	{
		public static const DIMENSION:int = 70;
		public static const PADDING:int = 6;
		
		public var _thingerIndex:int;
		public var _uic:UIComponent;
				
		public function InventoryItemRenderer()
		{
			super();			
			this.width = DIMENSION;
			this.height = DIMENSION;
			this.setStyle('backgroundColor', 'black');
			this.setStyle('cornerRadius', '14');
			this.setStyle('borderStyle', 'solid');
			this.setStyle('borderColor', 'black');
			this.clipContent = false;			
		}
		
		public function set thingerIndex(val:int):void
		{
			_thingerIndex = val;
			if (_uic)
			{
				setX();
			}
		}
		
		public function set uic(val:UIComponent):void
		{
			_uic = val;			
			addChild(_uic);
			if (_thingerIndex)
			{
				setX();
			}
			addFrame();
		}
		
		public function addFrame():void
		{
			var frame:ColorFrameBlue = new ColorFrameBlue();
			frame.x = (DIMENSION - frame.width)/2;
			frame.y = (DIMENSION - frame.height)/2;			
			_uic.addChild(frame);
		}
		
		public function setX():void
		{
			x = _thingerIndex * PADDING + _thingerIndex * _uic.width;			
		}
		
	}
}