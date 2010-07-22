package world
{
	import flash.events.TimerEvent;
	
	import views.BouncyBitmap;
	import views.ExpandingMovieclip;
	
	public class MoodEvent extends TimerEvent
	{
		public static const BOUNCE_WAIT_COMPLETE:String = "MoodEvent:BounceWaitComplete";
		public var _moodClip:BouncyBitmap;
		
		public function MoodEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set moodClip(val:BouncyBitmap):void
		{
			_moodClip = val;
		}
		
		public function get moodClip():BouncyBitmap
		{
			return _moodClip;
		}
	}
}