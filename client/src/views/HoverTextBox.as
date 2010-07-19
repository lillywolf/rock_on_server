package views
{
	import com.google.analytics.debug.Label;
	
	import flash.text.AntiAliasType;
	
	import mx.containers.Canvas;
	import mx.controls.Text;
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
		
		[Embed(source="../libs/Museo_Slab_900.otf",
                    fontFamily="Museo_Slab_900",
                    mimeType="application/x-font",
                    embedAsCFF="true")]
		public const Museo_Slab_900_Font:Class;			
		
		public function HoverTextBox(hoverText:String, maximumWidth:Number = 250, _lineSpacing:Number = 4, _lineHeight:Number = 13, _topPadding:Number = 6, _sidePadding:Number = 6)
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
			this.setStyle("cornerRadius", 12);
			this.setStyle("backgroundColor", 0xffffff);
			this.setStyle("borderColor", 0x00223D);
			this.setStyle("borderStyle", "solid");
			this.verticalScrollPolicy = "off";
			this.horizontalScrollPolicy = "off";
			this.clipContent = false;
		}
		
		public function styleText():void
		{
			_textBox = new Text();
			_textBox.setStyle("paddingLeft", sidePadding);
			_textBox.setStyle("paddingRight", sidePadding);
			_textBox.setStyle("paddingTop", topPadding);
			_textBox.setStyle("paddingBottom", topPadding);
			_textBox.setStyle("fontFamily", "Museo-Slab-900");
			_textBox.setStyle("fontSize", 13);
			_textBox.maxWidth = _maxWidth;
			_textBox.text = _text;			
			addChild(_textBox);	
		}
		
		public function onCreationComplete(evt:FlexEvent):void
		{
			this.width = _textBox.width;
			this.height = _textBox.height;
//			var textWidth:Number = measureText(_textBox.text).width;
//			this.width = _textBox.measuredWidth + 2 * sidePadding;
//			var numLines:int = Math.floor(_maxWidth/textWidth);
//			this.height = (lineHeight * (numLines + 1)) + (topPadding * 2) + (lineSpacing * (numLines));
		}
	}
}