package world
{
	import flash.events.TimerEvent;
	
	import rock_on.Person;
	
	import views.BouncyBitmap;
	import views.ExpandingMovieclip;
	
	public class MoodEvent extends TimerEvent
	{
		public static const BOUNCE_WAIT_COMPLETE:String = "MoodEvent:BounceWaitComplete";
		public static const QUEST_INFO_REQUESTED:String = "MoodEvent:QuestInfoRequested";
		public var _moodClip:BouncyBitmap;
		public var _person:Person;
		
		public function MoodEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set moodClip(val:BouncyBitmap):void
		{
			_moodClip = val;
		}
		
		public function set person(val:Person):void
		{
			_person = val;
		}
		
		public function get person():Person
		{
			return _person;
		}
		
		public function get moodClip():BouncyBitmap
		{
			return _moodClip;
		}
	}
}