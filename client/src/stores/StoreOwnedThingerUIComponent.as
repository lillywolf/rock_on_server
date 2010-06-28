package stores
{
	import controllers.LayerableController;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import models.StoreOwnedThinger;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;

	public class StoreOwnedThingerUIComponent extends UIComponent
	{
		public var _storeOwnedThinger:StoreOwnedThinger;
		public var _mc:MovieClip;
		public var frameUIC:UIComponent;
		public static const CONTAINER_WIDTH:int = 80;
		public static const CONTAINER_HEIGHT:int = 80;
		public static const CONTAINER_PADDING_X:int = 4;
		public static const CONTAINER_PADDING_Y:int = 4;
		
		public function StoreOwnedThingerUIComponent(sot:StoreOwnedThinger)
		{
			super();
			_storeOwnedThinger = sot;
			_mc = sot.getMovieClip();
			width = CONTAINER_WIDTH;
			height = CONTAINER_HEIGHT;
			
			var container:Canvas = createContainer();
			
			if (_mc)
			{
				_mc.gotoAndPlay(1);
				_mc.stop();
				var uic:UIComponent = LayerableController.formatMovieClipByDimensions(_mc, CONTAINER_WIDTH, CONTAINER_HEIGHT, CONTAINER_PADDING_X, CONTAINER_PADDING_Y);
				container.addChild(uic);
				addChild(container);
			}
			
			addFrame(new ColorFrameBlue());
			addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);			
		}
		
		public function addFrame(frame:*):void
		{
			(frame as MovieClip).scaleX = CONTAINER_WIDTH / frame.width;
			(frame as MovieClip).scaleY = CONTAINER_HEIGHT / frame.height;
			frame.x = CONTAINER_PADDING_X;
			frame.y = CONTAINER_PADDING_Y;
			var tempUIC:UIComponent = new UIComponent();
			tempUIC.x = (CONTAINER_WIDTH - frame.width)/2;
			tempUIC.y = (CONTAINER_HEIGHT - frame.height)/2;	
			tempUIC.width = frame.width;
			tempUIC.height = frame.height;		
			tempUIC.addChild(frame);
			this.addChild(tempUIC);
			frameUIC = tempUIC;			
		}

		public function onMouseOver(evt:MouseEvent):void
		{
			addFrame(new ColorFrameGreen());		
		}
		
		public function onMouseOut(evt:MouseEvent):void
		{
			if (frameUIC.getChildAt(0) is ColorFrameGreen)
			{
				removeChild(frameUIC);
			}			
		}
		
		public function fitMovieClipToContainer(container:Canvas):void
		{
			var toScale:Number;
			var ratio:Number = _mc.width / _mc.height;
			if (ratio > 1)
			{
				toScale = CONTAINER_WIDTH / _mc.width;
			}
			else
			{
				toScale = CONTAINER_HEIGHT / _mc.height;
			}
			_mc.scaleX = toScale;
			_mc.scaleY = toScale;
			
			var uic:UIComponent = new UIComponent();
			uic.addChild(_mc);
			uic.height = CONTAINER_HEIGHT;
			uic.width = CONTAINER_WIDTH;
			uic.x = CONTAINER_PADDING_X;
			uic.y = CONTAINER_PADDING_Y;
			container.addChild(uic);
		}
		
		public static function createContainer():Canvas
		{
			var backCanvas:Canvas = new Canvas();
			backCanvas.clipContent = false;
			backCanvas.setStyle("backgroundColor", 0x000000);
			backCanvas.setStyle("cornerRadius", "14");
			backCanvas.setStyle("borderStyle", "solid");
			backCanvas.setStyle("borderColor", 0x000000);
			backCanvas.width = CONTAINER_WIDTH + (2 * CONTAINER_PADDING_X);
			backCanvas.height = CONTAINER_HEIGHT + (2 * CONTAINER_PADDING_Y);
			return backCanvas;
		}
		
		public function set storeOwnedThinger(val:StoreOwnedThinger):void
		{
			_storeOwnedThinger = val;
		}
		
		public function get storeOwnedThinger():StoreOwnedThinger
		{
			return _storeOwnedThinger;
		}
		
		public function get mc():MovieClip
		{
			return _mc;
		}
		
	}
}