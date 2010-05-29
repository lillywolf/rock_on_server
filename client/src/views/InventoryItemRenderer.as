package views
{
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.core.UIComponent;

	public class InventoryItemRenderer extends Canvas
	{
		public static const DIMENSION:int = 66;
		public static const PADDING:int = 6;
		
		public var _thingerIndex:int;
		public var _uic:UIComponent;
		public var _thinger:*;
		public var frameUIC:UIComponent;
		public var rankCanvas:Canvas;
				
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
			addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			
		}
		
		public function createTextFilter():GlowFilter
		{
			var filter:GlowFilter = new GlowFilter(0x333333, 1, 1.4, 1.4, 30, 4); 
			return filter;
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
			addFrame(new ColorFrameBlue());
		}
		
		public function get uic():UIComponent
		{
			return _uic;
		}
		
		public function addFrame(frame:*):void
		{
			var tempUIC:UIComponent = new UIComponent();
			tempUIC.x = (DIMENSION - frame.width)/2;
			tempUIC.y = (DIMENSION - frame.height)/2;	
			tempUIC.width = frame.width;
			tempUIC.height = frame.height;		
			tempUIC.addChild(frame);
			this.addChild(tempUIC);
			frameUIC = tempUIC;
		}
		
		private function onMouseOver(evt:MouseEvent):void
		{
			addFrame(new ColorFrameGreen());
			if (rankCanvas)
			{
				addLevelBox(_thingerIndex);
				rankCanvas.setStyle("backgroundColor", 0x1ea55e);			
			}
		}
		
		private function onMouseOut(evt:MouseEvent):void
		{
			if (frameUIC.getChildAt(0) is ColorFrameGreen)
			{
				removeChild(frameUIC);
			}
			if (rankCanvas)
			{
				if (rankCanvas.getStyle("backgroundColor") == 0x1ea55e)
				{
					removeChild(rankCanvas);
				}
			}
		}

		public function addLevelBox(index:int):void
		{
			var levelBox:Canvas = new Canvas();
			levelBox.width = 24;
			levelBox.height = 24;
			levelBox.setStyle("backgroundColor", 0x2DA2FC);
			levelBox.setStyle("borderStyle", "solid");
			levelBox.setStyle("borderColor", 0x091063);
			levelBox.setStyle("cornerRadius", 8);
			levelBox.x = 2;
			levelBox.y = 0;
			var levelText:Label = new Label();
			levelText.text = (index+1).toString();
			levelText.setStyle("color", 0xffffff);
			levelText.setStyle("textAlign", "center");
			levelText.y = 1;
			levelText.x = -1;
			levelText.width = levelBox.width;
			levelText.setStyle("fontFamily", "Museo-Slab-900");
			levelText.setStyle("fontSize", "14");
			rankCanvas = levelBox;
			levelBox.addChild(levelText);
			this.addChild(rankCanvas);
		}
		
		public function addName(name:String):void
		{
			var friendName:Label = new Label();
			friendName.text = name;
			friendName.setStyle("fontFamily", "Museo-Slab-900");
			friendName.setStyle("fontSize", "11");
			friendName.setStyle("color", 0xffffff);
			friendName.width = width;
			friendName.y = 63;
			friendName.setStyle("textAlign", "center");
			this.addChild(friendName);
		}		
		
		public function setX():void
		{
			x = _thingerIndex * PADDING + _thingerIndex * DIMENSION;			
		}
		
		public function getDimension():int
		{
			return DIMENSION;
		}
		
		public function set thinger(val:*):void
		{
			_thinger = val;
		}
		
		public function get thinger():*
		{
			return _thinger;
		}
		
	}
}