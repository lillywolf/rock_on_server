package stores
{
	import flash.events.Event;

	public class StoreEvent extends Event
	{
		public static const THINGER_PURCHASED:String = "StoreEvent:ThingerPurchased";
		public static const THINGER_SOLD:String = "StoreEvent:ThingerSold";
		public var _thinger:Object;
		
		public function StoreEvent(type:String, thinger:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			if (thinger)
			{
				_thinger = thinger;
			}
		}
		
		public function set thinger(val:Object):void
		{
			_thinger = val;
		}
		
		public function get thinger():Object
		{
			return _thinger;
		}
		
	}
}