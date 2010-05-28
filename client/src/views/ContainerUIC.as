package views
{
	import flash.display.MovieClip;
	
	import mx.core.UIComponent;

	public class ContainerUIC extends UIComponent
	{
		public var _mc:MovieClip;
		public var _thinger:Object;
		
		public function ContainerUIC(params:Object=null)
		{
			super();
		}
		
		public function setStyles(x:int=0, y:int=0, width:int=0, height:int=0):void
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public function set thinger(val:Object):void
		{
			_thinger = val;
		}
		
		public function get thinger():Object
		{
			return _thinger;
		}
		
		public function set mc(val:MovieClip):void
		{
			_mc = val;
		}
		
		public function get mc():MovieClip
		{
			return _mc;
		}
		
	}
}