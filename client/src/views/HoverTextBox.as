package views
{
	import com.google.analytics.debug.Label;
	
	import flash.display.GradientType;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	
	import mx.containers.Canvas;
	import mx.controls.Text;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class HoverTextBox extends Canvas
	{
		public var _text:String;
		public var _textBox:Text;
		public var _maxWidth:Number;
		public var lineSpacing:Number;
		public var lineHeight:Number;
		public var topPadding:Number;
		public var sidePadding:Number;
			
		[Embed(source="../libs/Otari-Bold-Limited.otf",
                    fontFamily="Otari-Bold",
                    mimeType="application/x-font",
                    embedAsCFF="true")]
		public const Otari_Bold:Class;			
		[Embed(source="../libs/Museo_Slab_900.otf",
                    fontFamily="Museo-Slab-900",
                    mimeType="application/x-font",
                    embedAsCFF="true")]
		public const Museo_Slab_900:Class;			
		
		public function HoverTextBox(hoverText:String, maximumWidth:Number = 250, _lineSpacing:Number = 4, _lineHeight:Number = 13, _topPadding:Number = 4, _sidePadding:Number = 6)
		{
			super();
			
			_text = hoverText;
			_maxWidth = maximumWidth;
			sidePadding = _sidePadding;
			topPadding = _topPadding;
			lineHeight = _lineHeight;
			lineSpacing = _lineSpacing;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			styleBox();
			styleText();
		}
		
		public function styleBox():void
		{
			this.maxWidth = _maxWidth;	
			this.minHeight = 30;
			this.setStyle("cornerRadius", 6);
			this.setStyle("borderColor", 0x020F6E);
			this.setStyle("borderStyle", "solid");
			this.verticalScrollPolicy = "off";
			this.horizontalScrollPolicy = "off";
			this.clipContent = false;
			this.visible = false;
		}
		
		public function getGlowFilter():GlowFilter
		{
			var gf:GlowFilter = new GlowFilter(0xffffff, 1, 1.6, 1.6, 50, 20);
			return gf;
		}
		
		public function getInnerGlowFilter():GlowFilter
		{
			var gf:GlowFilter = new GlowFilter(0xffffff, 1, 1.3, 1.3, 20, 20, true, true);
			return gf;
		}
		
		public function styleText():void
		{
			_textBox = new Text();
			_textBox.setStyle("paddingLeft", sidePadding);
			_textBox.setStyle("paddingRight", sidePadding);
			_textBox.setStyle("paddingTop", topPadding);
			_textBox.setStyle("paddingBottom", topPadding);
			_textBox.setStyle("fontFamily", "Otari-Bold");
			_textBox.setStyle("color", 0x182900);
			_textBox.setStyle("fontSize", 14);
			_textBox.maxWidth = _maxWidth;
			_textBox.text = _text;			
			var gf:GlowFilter = getGlowFilter();
			_textBox.filters = [gf];
			addChild(_textBox);	
		}
		
		public function onCreationComplete(evt:FlexEvent):void
		{
			this.width = _textBox.width;
			this.height = _textBox.height;
			this.drawRoundRect(0, 0, this.width, this.height, 8, [0xffffff, 0xB0FF5C], [1, 1], verticalGradientMatrix(0, 0, this.width, this.height), GradientType.LINEAR);
			this.visible = true;			
//			var bg:GreenGradientBox = new GreenGradientBox();
//			bg.width = this.width;
//			bg.height = this.height;
//			var uic:UIComponent = new UIComponent();
//			uic.width = this.width + 2;
//			uic.height = this.height;
//			uic.x = this.x + this.width/2;
//			uic.y = this.y + this.height/2;
//			uic.addChild(bg);
//			removeChild(_textBox);
//			addChild(uic);
//			addChild(_textBox);
//			var gf:GlowFilter = getInnerGlowFilter();
//			this.filters = [gf];
//			var textWidth:Number = measureText(_textBox.text).width;
//			this.width = _textBox.measuredWidth + 2 * sidePadding;
//			var numLines:int = Math.floor(_maxWidth/textWidth);
//			this.height = (lineHeight * (numLines + 1)) + (topPadding * 2) + (lineSpacing * (numLines));
		}
	}
}