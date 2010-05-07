package game
{
	import flash.events.Event;

	public class CounterEvent extends Event
	{
		public static const COUNTER_COMPLETE:String = "Server:ModelCollectionLoaded";		
		
		public function CounterEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}