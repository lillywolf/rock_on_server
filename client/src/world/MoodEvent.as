package world
{
	import flash.events.TimerEvent;
	
	import views.ExpandingMovieclip;
	
	public class MoodEvent extends TimerEvent
	{
		public static const BOUNCE_WAIT_COMPLETE:String = "MoodEvent:BounceWaitComplete";
		public var _moodClip:ExpandingMovieclip;
		
		public function MoodEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set moodClip(val:ExpandingMovieclip):void
		{
			_moodClip = val;
		}
		
		public function get moodClip():ExpandingMovieclip
		{
			return _moodClip;
		}
	}
}