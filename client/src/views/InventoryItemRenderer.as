package views
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import models.Level;
	import models.OwnedStructure;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.DynamicEvent;

	public class InventoryItemRenderer extends Canvas
	{
		public var DIMENSION:int = 58;
		public var PADDING:int = 22;
		public var DIMENSIONX:int = 58;
		public var DIMENSIONY:int = 58;
		public var INNER_PADDING:int = 2;
		
		public var _thingerIndex:int;
		public var _uic:UIComponent;
		public var _thinger:*;
		public var _level:Level;
		public var frameUIC:UIComponent;
		public var rankCanvas:Canvas;
		public var renderRightToLeft:Boolean;
				
		public function InventoryItemRenderer(backgroundColor:Object, borderColor:Object, level:Level, dimension:int=58)
		{
			super();
			DIMENSION = dimension;
			
			_level = level;		
			_thingerIndex = -1;
			this.width = DIMENSION;
			this.height = DIMENSION + 30;
			this.setStyle('backgroundColor', backgroundColor);
			this.setStyle('cornerRadius', "8");
			this.setStyle('borderStyle', 'solid');
			this.setStyle('borderColor', borderColor);
			this.clipContent = false;
			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		public function updateDefaultStyle(bgColor:Object=null, cornerRadius:int=0, alpha:Number=0):void
		{
			this.clearStyle("backgroundColor");
			this.clearStyle("borderStyle");
			this.clearStyle("borderColor");
			this.clearStyle("cornerRadius");
			
			if (bgColor || cornerRadius || alpha)
			{
				var backing:Canvas = new Canvas();
				backing.width = DIMENSION;
				backing.height = DIMENSION;
				if (bgColor)
					backing.setStyle("backgroundColor", bgColor);
				if (cornerRadius)
				{
					backing.setStyle("cornerRadius", cornerRadius);
					backing.setStyle("borderStyle", "solid");
					backing.setStyle("borderColor", bgColor);
				}
				if (alpha)
					backing.alpha = alpha;
				this.addChild(backing);
			}
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
			resizeUIC(_uic);
			if (_thingerIndex != -1)
			{
				setX();
			}
		}
				
		public function resizeUIC(uic:UIComponent):void
		{
			uic.width = DIMENSION - 8;
		}
		
		public function get uic():UIComponent
		{
			return _uic;
		}
		
		public function addFrame(frame:*, resize:int=0):void
		{
			var tempUIC:UIComponent = new UIComponent();
			if (resize)
			{
				(frame as DisplayObject).width = resize;
				(frame as DisplayObject).height = resize;			
			}
//			tempUIC = fitMovieClipToContainer(frame, tempUIC);

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
			levelBox.x = 0 - INNER_PADDING;
			levelBox.y = -2 - INNER_PADDING;
			var levelText:Label = new Label();
			levelText.text = (_level.rank).toString();
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
			var textFilter:GlowFilter = createTextFilter();
			friendName.filters = [textFilter];
			friendName.text = name;
			friendName.setStyle("fontFamily", "Museo-Slab-900");
			friendName.setStyle("fontSize", "11");
			friendName.setStyle("color", 0xffffff);
			friendName.width = width - INNER_PADDING;
			friendName.y = 63;
			friendName.setStyle("textAlign", "center");
			this.addChild(friendName);
		}		
		
		public function setX():void
		{
			if (!renderRightToLeft)
			{
				x = _thingerIndex * PADDING + _thingerIndex * DIMENSION;						
			}
			else
			{
				this.setStyle("right", _thingerIndex * PADDING + _thingerIndex * DIMENSION);
			}
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
		
		public function addInventoryButtons():void
		{
			var useBtn:Button = new Button();
			useBtn.width = 20;
			useBtn.height = 20;
			useBtn.y = DIMENSION + 10;
			useBtn.x = DIMENSION/2 - useBtn.width - 5;
			useBtn.addEventListener(MouseEvent.CLICK, onUseBtnClicked);
			this.addChild(useBtn);
			
			var sellBtn:Button = new Button();
			sellBtn.width = 20;
			sellBtn.height = 20;
			sellBtn.y = DIMENSION + 10;
			sellBtn.x = DIMENSION/2 + 5;
			sellBtn.addEventListener(MouseEvent.CLICK, onSellBtnClicked);
			this.addChild(sellBtn);
		}
		
		private function onUseBtnClicked(evt:MouseEvent):void
		{
			var btn:Button = evt.target as Button;
			btn.removeEventListener(MouseEvent.CLICK, onUseBtnClicked);
			if (_thinger is OwnedStructure)
				FlexGlobals.topLevelApplication.addFromInventory(_thinger);
		}
		
		private function onSellBtnClicked(evt:MouseEvent):void
		{
			var btn:Button = evt.target as Button;
			btn.removeEventListener(MouseEvent.CLICK, onSellBtnClicked);
			FlexGlobals.topLevelApplication.sellItem(_thinger);
		}
		
		public function fitMovieClipToContainer(mc:MovieClip, container:UIComponent):UIComponent
		{
			var toScale:Number;
			var ratio:Number = mc.width / mc.height;
			if (ratio > 1)
			{
				toScale = DIMENSION / mc.width;
			}
			else
			{
				toScale = DIMENSION / mc.height;
			}
			mc.scaleX = toScale;
			mc.scaleY = toScale;
			
			container.height = DIMENSION;
			container.width = DIMENSION;
			mc.x = container.width/2;
			mc.y = container.height - 10;
			container.addChild(mc);
			return container;
//			uic.x = CONTAINER_PADDING_X;
//			uic.y = CONTAINER_PADDING_Y;
//			container.addChild(uic);
		}		
		
	}
}