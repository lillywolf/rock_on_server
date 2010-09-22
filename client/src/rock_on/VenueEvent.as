package rock_on
{
	import flash.events.Event;
	
	import world.ActiveAsset;
	
	public class VenueEvent extends Event
	{
		public static const BOOTH_UNSTOCKED:String = "VenueEvent:BoothUnstocked";
		public static const VENUE_INITIALIZED:String = "VenueEvent:VenueInitialized";
		public static const STAGE_INITIALIZED:String = "VenueEvent:StageInitialized";
		
		public var _booth:ActiveAsset;
		public var _venue:Venue;
		
		public function VenueEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set booth(val:ActiveAsset):void
		{
			_booth = val;
		}
		
		public function get booth():ActiveAsset
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