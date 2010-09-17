package rock_on
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import game.Leftover;
	
	import models.Creature;
	import models.EssentialModelReference;
	
	import mx.collections.ArrayCollection;
	
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
		public static const LEAVING_STATE:int = 6;
		public static const MAX_LEFTOVERS:int = 2;
		
		public var enthralledTimer:Timer;
		public var isStatic:Boolean;
				
		public function StationListener(listeningStationBoss:ListeningStationBoss, passerbyManager:PasserbyManager, myWorld:World, venue:Venue, creature:Creature, movieClip:MovieClip=null, layerableOrder:Array=null, scale:Number=1)
		{
			super(listeningStationBoss, passerbyManager, myWorld, venue, creature, movieClip, layerableOrder, scale);
		}	
		
		override public function startRouteState():void
		{
			state = ROUTE_STATE;
			
			var station:ListeningStation = _listeningStationBoss.getRandomStation(currentStation);
			if (station == null)
			{
				// advance state
			}
			else
			{
				currentStation = station;
				currentStation.currentQueue++;
				var destination:Point3D = setInitialDestination();
				if (destination)
					movePerson(destination, true);	
				else
					throw new Error("no valid station destination");
			}			
		}
		
		override public function setInitialDestination():Point3D
		{
			var occupiedSpaces:Array = _myWorld.pathFinder.updateOccupiedSpaces(true, true);
			var destination:Point3D = tryDestination();
			if ((occupiedSpaces[destination.x] && occupiedSpaces[destination.x][destination.y] && occupiedSpaces[destination.x][destination.y][destination.z]) || 
				isAnyoneElseThere(destination))
			{
				return null;
			}
			return destination;
		}			
		
		override public function tryDestination():Point3D
		{
			var stationFront:Point3D = _listeningStationBoss.getStationFront(_myWorld.getAssetFromOwnedStructure(currentStation));
			return stationFront;				
		} 
		
		override public function update(deltaTime:Number):Boolean
		{
			switch (state)
			{
				case ROAM_STATE:
					doRoamState(deltaTime);
					break;
				case ENTHRALLED_STATE:
					doEnthralledState(deltaTime);
					break;					
				case ROUTE_STATE:
					doRouteState(deltaTime);	
					break;
				case LEAVING_STATE:
					doLeavingState(deltaTime);	
					break;
				case GONE_STATE:
					doGoneState(deltaTime);
					return true;	
				default: throw new Error('oh noes!');
			}
			return false;
		}		 

		override public function advanceState(destinationState:int):void
		{
			switch (state)
			{	
				case ROAM_STATE:
					endRoamState();
					break;
				case ENTHRALLED_STATE:
					endEnthralledState();				
					break;	
				case ROUTE_STATE:
					endRouteState();
					break;		
				case LEAVING_STATE:
					endLeavingState();
					break;		
				case GONE_STATE:
					break;					
				default: throw new Error('no state to advance from!');
			}
			switch (destinationState)
			{
				case ROAM_STATE:
					startRoamState();
					break;
				case ENTHRALLED_STATE:
					startEnthralledState();
					break;
				case ROUTE_STATE:
					startRouteState();
					break;					
				case LEAVING_STATE:
					startLeavingState();
					break;					
				case GONE_STATE:
					startGoneState();
					break;	
				default: throw new Error('no state to advance to!');	
			}
		}	
		
		public function doLeavingState(deltaTime:Number):void
		{
			
		}
		
		public function endLeavingState():void
		{
			
		}
		
		override public function startEnthralledState():void
		{
			state = ENTHRALLED_STATE;
			currentStation.currentListeners.addItem(this);
			currentStation.hasCustomerEnRoute = false;
			standFacingObject(currentStation);
			
			if (currentStation.isPermanentSlotAvailable() || isStatic)
			{
//				addLeftovers();
			}
			else
			{
				var enthralledTime:int = 2000 + Math.random()*2000;
				enthralledTimer = new Timer(enthralledTime);
				enthralledTimer.addEventListener(TimerEvent.TIMER, leave);
				enthralledTimer.start();			
			}
		}
		
		override public function endEnthralledState():void
		{
			var index:int = currentStation.currentListeners.getItemIndex(this);
			currentStation.currentListeners.removeItemAt(index);
		}
		
		private function addLeftovers():void
		{
			var setLeftovers:ArrayCollection = EssentialModelReference.getSetLeftovers("Listening Station");
			var randomLeftovers:ArrayCollection = EssentialModelReference.getRandomLeftovers("Listening Station");
			var numExtras:int = Math.round(Math.random()*MAX_LEFTOVERS);
			
			for each (var leftover:Leftover in setLeftovers)
			{
				this.currentStation.addLeftoverToStation(leftover);
			}
			for (var i:int = 0; i < numExtras; i++)
			{
				this.currentStation.addLeftoverToStation(randomLeftovers[Math.floor(Math.random()*randomLeftovers.length)]);
			}
		}	
		
		public function selectStationActivity():void
		{
			if (currentStation.isPermanentSlotAvailable())
			{
				
			}
			else if (currentStation.isSlotAvailable())
			{
				
			}
			else
			{
				startRouteState();
			}
		}
		
		public function leave(evt:TimerEvent):void
		{
			advanceState(LEAVING_STATE);
			enthralledTimer.stop();
			enthralledTimer.removeEventListener(TimerEvent.TIMER, leave);
		}
		
		public function startLeavingState():void
		{
			state = LEAVING_STATE;
			var destination:Point3D = setLeaveDestination();
			movePerson(destination, true);			
		}
		
		public function setLeaveDestination():Point3D
		{
			var leaveDestination:Point3D;
			if (Math.random() < 0.5)
			{
				leaveDestination = new Point3D(_myWorld.tilesWide - Math.round(Math.random() * (_myWorld.tilesWide - _venue.venueRect.right)), 0, 0);
			}
			else
			{
				leaveDestination = new Point3D(_myWorld.tilesWide - Math.round(Math.random() * (_myWorld.tilesWide - _venue.venueRect.right)), 0, _myWorld.tilesDeep);
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