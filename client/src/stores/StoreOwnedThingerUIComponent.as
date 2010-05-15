package stores
{
	import controllers.LayerableManager;
	
	import flash.display.MovieClip;
	
	import models.StoreOwnedThinger;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;

	public class StoreOwnedThingerUIComponent extends UIComponent
	{
		public var _storeOwnedThinger:StoreOwnedThinger;
		public var _mc:MovieClip;
		public static const CONTAINER_WIDTH:int = 80;
		public static const CONTAINER_HEIGHT:int = 80;
		
		public function StoreOwnedThingerUIComponent(sot:StoreOwnedThinger)
		{
			super();
			_storeOwnedThinger = sot;
			_mc = sot.getMovieClip();
			this.width = CONTAINER_WIDTH;
			this.height = CONTAINER_HEIGHT;
			
			var container:Canvas = createContainer();
			
			if (_mc)
			{
				_mc.gotoAndPlay(1);
				_mc.stop();
				var uic:UIComponent = LayerableManager.formatMovieClipByDimensions(_mc, CONTAINER_WIDTH, CONTAINER_HEIGHT);
				container.addChild(uic);
				addChild(container);
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
			container.addChild(uic);
		}
		
		public function createContainer():Canvas
		{
			var backCanvas:Canvas = new Canvas();
			backCanvas.clipContent = false;
			backCanvas.setStyle("backgroundColor", 0x000000);
			backCanvas.setStyle("cornerRadius", "14");
			backCanvas.setStyle("borderStyle", "solid");
			backCanvas.setStyle("borderColor", 0x666666);
			backCanvas.width = CONTAINER_WIDTH;
			backCanvas.height = CONTAINER_HEIGHT;
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