package stores
{
	import flash.display.MovieClip;
	
	import models.StoreOwnedThinger;
	
	import mx.core.UIComponent;

	public class StoreOwnedThingerUIComponent extends UIComponent
	{
		public var _storeOwnedThinger:StoreOwnedThinger;
		public var _mc:MovieClip;
		
		public function StoreOwnedThingerUIComponent(sot:StoreOwnedThinger)
		{
			super();
			_storeOwnedThinger = sot;
			_mc = sot.getMovieClip();
			if (_mc)
			{
				_mc.stop();
				addChild(_mc);		
			}
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