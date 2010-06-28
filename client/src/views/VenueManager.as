package views
{
	import controllers.CreatureController;
	import controllers.DwellingController;
	import controllers.LayerableController;
	import controllers.LevelController;
	import controllers.StructureController;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import helpers.CreatureGenerator;
	
	import models.OwnedDwelling;
	
	import mx.collections.ArrayCollection;
	
	import rock_on.BoothBoss;
	import rock_on.ConcertStage;
	import rock_on.CustomerPerson;
	import rock_on.CustomerPersonManager;
	import rock_on.GroupieBoss;
	import rock_on.ListeningStationBoss;
	import rock_on.StageManager;
	import rock_on.Venue;
	import rock_on.VenueEvent;
	
	import world.BitmapBlotter;
	import world.World;

	public class VenueManager extends EventDispatcher
	{
		public static const PERSON_SCALE:Number = 0.4;	
		public static const STATIC_CUSTOMER_FRACTION:Number = 0.8;
		public static const SUPER_CUSTOMER_FRACTION:Number = 0.1;
		
		public var venue:Venue;
		public var concertGoers:ArrayCollection;
		public var _wbi:WorldBitmapInterface;
		public var _dwellingController:DwellingController;
		public var _levelController:LevelController;
		public var _structureController:StructureController;
		public var _creatureController:CreatureController;
		public var _layerableController:LayerableController;
		
		public var _bitmapBlotter:BitmapBlotter;
		public var _myWorld:World;
		public var _booths:ArrayCollection;
		
		public var bandBoss:BandBoss;
		
		public function VenueManager(wbi:WorldBitmapInterface, structureController:StructureController, layerableController:LayerableController, dwellingController:DwellingController, levelController:LevelController, creatureController:CreatureController, target:IEventDispatcher=null)
		{
			super(target);
			_wbi = wbi;
			_layerableController = layerableController;
			_dwellingController = dwellingController;
			_levelController = levelController;
			_structureController = structureController;
			_creatureController = creatureController;			
		}
		
		public function getVenue():void
		{
			var venues:ArrayCollection = _dwellingController.getDwellingsByType("Venue");
			venue = new Venue(_wbi, this, _dwellingController, _creatureController, _layerableController, _structureController, bandBoss, venues[0] as OwnedDwelling);				
		}
		
		public function update(deltaTime:Number):void
		{
			if (venue)
			{
				venue.update(deltaTime);			
			}
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
					bandBoss.setInMotion();				
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
		
		public function set myWorld(val:World):void
		{
			_myWorld = val;
			venue.myWorld = val;
		}
		
		public function updateWorld(myWorld:World, bitmapBlotter:BitmapBlotter):void
		{
			_myWorld = myWorld;
			venue.myWorld = myWorld;
			_bitmapBlotter = bitmapBlotter;
			venue.bitmapBlotter = bitmapBlotter;
			initializeBandBoss();
		}
		
		public function initializeBandBoss():void
		{			
			bandBoss = new BandBoss(this, _creatureController, _myWorld);									
		}
		
		public function set bitmapBlotter(val:BitmapBlotter):void
		{
			_bitmapBlotter = val;
			venue.bitmapBlotter = val;
		}
		
		public function get dwellingController():DwellingController
		{
			return _dwellingController;
		}
		
		public function get levelController():LevelController
		{
			return _levelController;
		}
		
	}
}