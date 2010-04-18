package views
{
	import controllers.DwellingManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import game.GameClock;
	
	import models.OwnedDwelling;
	
	import mx.collections.ArrayCollection;
	
	import rock_on.Venue;
	
	import world.World;

	public class VenueManager extends EventDispatcher
	{
		public var venue:Venue;
		public var _dwellingManager:DwellingManager;
		public var _myWorld:World;
		
		public function VenueManager(dwellingManager:DwellingManager, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_dwellingManager = dwellingManager;
			_myWorld = myWorld;
		}
		
		public function setInMotion():void
		{
			getVenue();
		}
		
		private function getVenue():void
		{
			var venues:ArrayCollection = _dwellingManager.getDwellingsByType("Venue");
			venue = new Venue(venues[0] as OwnedDwelling);		
			venue.lastShowTime = GameClock.convertStringTimeToUnixTime((venues[0] as OwnedDwelling).last_showtime);
		}
		
	}
}