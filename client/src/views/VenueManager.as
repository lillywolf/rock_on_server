package views
{
	import controllers.DwellingManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import game.GameClock;
	
	import helpers.CreatureGenerator;
	
	import models.OwnedDwelling;
	
	import mx.collections.ArrayCollection;
	
	import rock_on.ConcertStage;
	import rock_on.CustomerPerson;
	import rock_on.CustomerPersonManager;
	import rock_on.Venue;
	
	import world.World;

	public class VenueManager extends EventDispatcher
	{
		public var venue:Venue;
		public var _dwellingManager:DwellingManager;
		public var _customerPersonManager:CustomerPersonManager;
		public var _myWorld:World;
		public var _creatureGenerator:CreatureGenerator;
		public var _booths:ArrayCollection;
		public var _concertStage:ConcertStage;
		
		public function VenueManager(creatureGenerator:CreatureGenerator, customerPersonManager:CustomerPersonManager, dwellingManager:DwellingManager, booths:ArrayCollection, concertStage:ConcertStage, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_creatureGenerator = creatureGenerator;
			_customerPersonManager = customerPersonManager;
			_dwellingManager = dwellingManager;
			_booths = booths;
			_concertStage = concertStage;
			_myWorld = myWorld;
		}
		
		public function setInMotion():void
		{
			getVenue();
			addCustomersToVenue();
		}
		
		private function getVenue():void
		{
			var venues:ArrayCollection = _dwellingManager.getDwellingsByType("Venue");
			venue = new Venue(venues[0] as OwnedDwelling);		
			venue.lastShowTime = GameClock.convertStringTimeToUnixTime((venues[0] as OwnedDwelling).last_showtime);
		}

		
		private function addCustomersToVenue():void
		{
			for (var i:int = 0; i < venue.fancount; i++)
			{
				var cp:CustomerPerson = _creatureGenerator.createCustomer("generic", "walk_toward");
				cp.speed = 0.07;
				_customerPersonManager.add(cp);
			}
		}
		
//		private function setCustomerVariables(cp:CustomerPerson):void
//		{
//			cp.roamLength = int(Math.floor(Math.random()*2000 + 1000));
//			cp.stopLength = int(Math.floor(Math.random()*40000)); 
//			cp.stopLengthConstant = 50000;
//		}
		
	}
}