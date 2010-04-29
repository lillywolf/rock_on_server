package rock_on
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.Creature;
	
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class StationListener extends Passerby
	{
		public var isEnRoute:Boolean;
		public var currentStation:ListeningStation;

		public static const ENTHRALLED_STATE:int = 1;
		public static const ROAM_STATE:int = 2;
		public static const ROUTE_STATE:int = 3;
		public static const QUEUED_STATE:int = 4;
		public static const GONE_STATE:int = 5;
		
		public var enthralledTimer:Timer;
		public var isStatic:Boolean;
				
		public function StationListener(movieClipStack:MovieClip, listeningStationManager:ListeningStationManager, passerbyManager:PasserbyManager, myWorld:World, layerableOrder:Array=null, creature:Creature=null, personScale:Number=1, source:Array=null)
		{
			super(movieClipStack, listeningStationManager, passerbyManager, myWorld, layerableOrder, creature, personScale, source);
		}	
		
		override public function startRouteState():void
		{
			var station:ListeningStation = _listeningStationManager.getRandomStation(currentStation);
			if (station == null)
			{
				// advance state
			}
			else
			{
				currentStation = station;
				currentStation.currentQueue++;
				var destination:Point3D = setInitialDestination();
				moveCustomer(destination);
			}			
		}
		
		override public function tryDestination():Point3D
		{
			var stationFront:Point3D = _listeningStationManager.getStationFront(currentStation);
			return stationFront;				
		}  
		
		override public function startEnthralledState():void
		{
			state = ENTHRALLED_STATE;
			currentStation.hasCustomerEnRoute = false;
			standFacingObject(currentStation);
			
			if (Math.random() > .95 || isStatic)
			{
				
			}
			else
			{
				var enthralledTime:int = 2000 + Math.random()*2000;
				enthralledTimer = new Timer(enthralledTime);
				enthralledTimer.addEventListener(TimerEvent.TIMER, leave);
				enthralledTimer.start();			
			}
		}
		
		override public function startLeavingState():void
		{
			state = Person.LEAVING_STATE;
			var destination:Point3D = setLeaveDestination();
			moveCustomer(destination);			
		}
		
		public function setLeaveDestination():Point3D
		{
			var leaveDestination:Point3D;
			if (Math.random() < 0.5)
			{
				leaveDestination = new Point3D(Math.round(PasserbyManager.VENUE_BOUND_X + Math.random()*(_myWorld.tilesWide - PasserbyManager.VENUE_BOUND_X)), 0, 0);
			}
			else
			{
				leaveDestination = new Point3D(Math.round(PasserbyManager.VENUE_BOUND_X + Math.random()*(_myWorld.tilesWide - PasserbyManager.VENUE_BOUND_X)), 0, _myWorld.tilesDeep);
			}
			return leaveDestination;
		}
		
		public function onFinalDestinationReached(evt:WorldEvent):void
		{
			
		}	
		
		override public function set myWorld(val:World):void
		{
			if(!_myWorld)
			{
				_myWorld = val;
				_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDestinationReached);				
			}
			else
				throw new Error("Where's the world?");			
		}	
		
		public function get passerbyManager():PasserbyManager
		{
			return _passerbyManager;
		}
		
		public function set passerbyManager(val:PasserbyManager):void
		{
			_passerbyManager = val;
		}
		
	}
}