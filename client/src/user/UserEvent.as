package user
{
	import flash.events.Event;

	public class UserEvent extends Event
	{
		public static const THINGER_PURCHASED:String = 'UserEvent:ThingerPurchased';
		
		public var _creditsToAdd:int;
		
		public function UserEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set creditsToAdd(val:int):void
		{
			_creditsToAdd = val;
		}
		
		public function get creditsToAdd():int
		{
			return _creditsToAdd;
		}
		
	}
}