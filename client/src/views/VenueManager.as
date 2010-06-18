package views
{
	import controllers.DwellingManager;
	import controllers.LevelManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import helpers.CreatureGenerator;
	
	import models.OwnedDwelling;
	
	import mx.collections.ArrayCollection;
	
	import rock_on.BoothManager;
	import rock_on.ConcertStage;
	import rock_on.CustomerPerson;
	import rock_on.CustomerPersonManager;
	import rock_on.StageManager;
	import rock_on.Venue;
	import rock_on.VenueEvent;
	
	import world.World;

	public class VenueManager extends EventDispatcher
	{
		public static const PERSON_SCALE:Number = 0.4;	
		public static const STATIC_CUSTOMER_FRACTION:Number = 0.8;
		public static const SUPER_CUSTOMER_FRACTION:Number = 0.1;
		
		public var venue:Venue;
		public var concertGoers:ArrayCollection;
		public var _dwellingManager:DwellingManager;
		public var _customerPersonManager:CustomerPersonManager;
		public var _stageManager:StageManager;
		public var _myWorld:World;
		public var _creatureGenerator:CreatureGenerator;
		public var _booths:ArrayCollection;
		public var _concertStage:ConcertStage;
		public var _bandManager:BandManager;
		public var _boothManager:BoothManager;
		public var _levelManager:LevelManager;
		
		public var numSuperCustomers:int;
		public var numStaticCustomers:int;
		public var numMovingCustomers:int;
		
		public function VenueManager(creatureGenerator:CreatureGenerator, customerPersonManager:CustomerPersonManager, dwellingManager:DwellingManager, levelManager:LevelManager, bandManager:BandManager, boothManager:BoothManager, stageManager:StageManager, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_creatureGenerator = creatureGenerator;
			_customerPersonManager = customerPersonManager;
			_dwellingManager = dwellingManager;
			_levelManager = levelManager;
			_bandManager = bandManager;
			_boothManager = boothManager;
			_booths = _boothManager.booths;
			_stageManager = stageManager;
			_concertStage = stageManager.concertStage;
			_myWorld = myWorld;
			
			concertGoers = new ArrayCollection();		
		}
		
		public function getVenue():void
		{
			var venues:ArrayCollection = _dwellingManager.getDwellingsByType("Venue");
			venue = new Venue(this, _myWorld, venues[0] as OwnedDwelling);	
			venue.addEventListener(VenueEvent.BOOTH_UNSTOCKED, onBoothUnstocked);
			
			numStaticCustomers = Math.floor(venue.fancount * VenueManager.STATIC_CUSTOMER_FRACTION);
			numSuperCustomers = Math.floor(venue.fancount * VenueManager.SUPER_CUSTOMER_FRACTION);
			numMovingCustomers = venue.fancount - numStaticCustomers - numSuperCustomers;			
		}
		
		public function onBoothUnstocked(evt:VenueEvent):void
		{
			_customerPersonManager.removeBoothFromAvailable(evt.booth);
		}
		
		public function addStaticCustomersToVenue():void
		{
			if (!_customerPersonManager.concertStage)
			{
				_customerPersonManager.concertStage = _concertStage;
			}
			for (var i:int = 0; i < numStaticCustomers; i++)
			{
				var cp:CustomerPerson = _creatureGenerator.createCustomer("Concert Goer", "walk_toward", _concertStage, _boothManager);
				cp.speed = 0.06;
				_customerPersonManager.add(cp, false, i);
				concertGoers.addItem(cp);
			}
		}
		
		public function addSuperCustomersToVenue(worldToUpdate:World):void
		{
			if (!_customerPersonManager.concertStage)
			{
				_customerPersonManager.concertStage = _concertStage;
			}
			for (var i:int = 0; i < numSuperCustomers; i++)
			{
				var cp:CustomerPerson = _creatureGenerator.createCustomer("Concert Goer", "walk_toward", _concertStage, _boothManager);
				cp.speed = 0.06;
				_customerPersonManager.add(cp, true, -1, this.venue.stageBufferRect, this.venue.stageRect, worldToUpdate);
				concertGoers.addItem(cp);
			}					
		}
		
		public function addMovingCustomersToVenue():void
		{
			if (!_customerPersonManager.concertStage)
			{
				_customerPersonManager.concertStage = _concertStage;
			}
			for (var i:int = 0; i < numMovingCustomers; i++)
			{
				var cp:CustomerPerson = _creatureGenerator.createCustomer("Concert Goer", "walk_toward", _concertStage, _boothManager);
				cp.speed = 0.06;
				_customerPersonManager.add(cp, true, -1, this.venue.boothsRect);
				concertGoers.addItem(cp);
			}			
		}
		
		public function removeCustomersFromVenue():void
		{
			for each (var cp:CustomerPerson in concertGoers)
			{
				_customerPersonManager.remove(cp);
			}
			concertGoers.removeAll();
		}
				
		public function onVenueUpdated(method:String, newInstance:OwnedDwelling):void
		{
			venue.updateProperties(newInstance);
			var destinationState:int;
			
			if (method == "update_state")
			{
				destinationState = venue.stateTranslateString();
				if (venue.state == 0)
				{
					venue.advanceState(destinationState);
					_bandManager.setInMotion();				
				}
				else if (venue.state != destinationState)
				{
					venue.advanceState(destinationState);
				}
			}
			else if (method == "update_fancount")
			{
				destinationState = venue.stateTranslateString();
				if (venue.state != destinationState)
				{
					venue.advanceState(destinationState);				
				}
			}				
		}		
		
		public function get bandManager():BandManager
		{
			return _bandManager;
		}
		
		public function get dwellingManager():DwellingManager
		{
			return _dwellingManager;
		}
		
		public function get levelManager():LevelManager
		{
			return _levelManager;
		}
		
		public function get concertStage():ConcertStage
		{
			return _concertStage
		}
		
	}
}