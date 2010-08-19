package rock_on
{
	import flash.events.Event;
	
	public class VenueEvent extends Event
	{
		public static const BOOTH_UNSTOCKED:String = "VenueEvent:BoothUnstocked";
		public static const VENUE_INITIALIZED:String = "VenueEvent:VenueInitialized";
		public static const STAGE_INITIALIZED:String = "VenueEvent:StageInitialized";
		
		public var _booth:Booth;
		public var _venue:Venue;
		
		public function VenueEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set booth(val:Booth):void
		{
			_booth = val;
		}
		
		public function get booth():Booth
		{
			return _booth;
		}
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}
		
		public function get venue():Venue
		{
			return _venue;
		}
		
	}
}