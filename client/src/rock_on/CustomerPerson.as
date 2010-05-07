package rock_on
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	import mx.events.DynamicEvent;
	
	import world.Point3D;
	import world.WorldEvent;

	public class CustomerPerson extends Person
	{
		public static const ENTHRALLED_STATE:int = 1;
		public static const ROAM_STATE:int = 2;
		public static const ROUTE_STATE:int = 3;
		public static const QUEUED_STATE:int = 4;
		public static const GONE_STATE:int = 5;
		public static const HEADTOSTAGE_STATE:int = 6;
		public static const HEADTODOOR_STATE:int = 7;
		
		public static const ENTHRALLED_TIME:int = 30000;
		public static const QUEUED_TIME:int = 4000;
		public static const FAN_CONVERSION_DELAY:int = 2000;
				
		public var enthralledTimer:Timer;
		public var queuedTimer:Timer;
		
		public var numQueuedTimers:int = 0;
		public var numEnthralledTimers:int = 0;
		
		public var currentBooth:Booth;
		public var currentBoothPosition:int;
		public var activityTimer:Timer;
		public var _concertStage:ConcertStage;
		public var _boothManager:BoothManager;
		public var _venue:Venue;
		public var proxiedDestination:Point3D;
		
		public function CustomerPerson(movieClipStack:MovieClip, concertStage:ConcertStage, boothManager:BoothManager, layerableOrder:Array=null, creature:Creature=null, personScale:Number=1, source:Array=null)
		{
			super(movieClipStack, layerableOrder, creature, personScale, source);
			_concertStage = concertStage;
			_boothManager = boothManager;
			startRoamState();
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
				case QUEUED_STATE:
					doQueuedState(deltaTime);
					break;
				case ROUTE_STATE:
					doRouteState(deltaTime);	
					break;
				case HEADTOSTAGE_STATE:
					doHeadToStageState(deltaTime);	
					break;
				case HEADTODOOR_STATE:
					doHeadToDoorState(deltaTime);	
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
				case QUEUED_STATE:
					endQueuedState();
					break;	
				case HEADTOSTAGE_STATE:
					endHeadToStageState();
					break;	
				case HEADTODOOR_STATE:
					endHeadToStageState();
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
				case QUEUED_STATE:
					startQueuedState();
					break;
				case ROUTE_STATE:
					startRouteState();
					break;
				case HEADTOSTAGE_STATE:
					startHeadToStageState();
					break;					
				case HEADTODOOR_STATE:
					startHeadToDoorState();
					break;					
				case GONE_STATE:
					startGoneState();
					break;	
				default: throw new Error('no state to advance to!');	
			}
		}		
		
		override public function startRoamState():void
		{
			state = ROAM_STATE;
		}
		
		public function timedConverstion(fanIndex:int):void
		{
			var convertTimer:Timer = new Timer(fanIndex * FAN_CONVERSION_DELAY);
			convertTimer.addEventListener(TimerEvent.TIMER, onConversionComplete);
			convertTimer.start();
		}	
		
		private function onConversionComplete(evt:TimerEvent):void
		{
			var convertTimer:Timer = evt.currentTarget as Timer;
			convertTimer.removeEventListener(TimerEvent.TIMER, onConversionComplete);
			convertTimer.stop();
			
			advanceState(HEADTODOOR_STATE);
		}
		
		public function startHeadToDoorState():void
		{
			state = HEADTODOOR_STATE;
			var door:Point3D = _venue.mainEntrance;
			moveCustomer(door);
		}
		
		public function endHeadToDoorState():void
		{
			
		}
		
		public function doHeadToDoorState(deltaTime:Number):void
		{
			
		}
		
		override public function endRoamState():void
		{
			
		}
		
		override public function doRoamState(deltaTime:Number):void
		{
			
		}
		
		public function startEnthralledState():void
		{
			state = ENTHRALLED_STATE;
			
			var frameNumber:int = 1;
			standFacingObject(_concertStage, frameNumber);
			
			enthralledTimer = new Timer(CustomerPerson.ENTHRALLED_TIME);
			enthralledTimer.addEventListener(TimerEvent.TIMER, routeToQueue);
			enthralledTimer.start();
			numEnthralledTimers++;
		}
		
		private function routeToQueue(evt:TimerEvent):void
		{
			enthralledTimer.stop();
			enthralledTimer.removeEventListener(TimerEvent.TIMER, routeToQueue);
			numEnthralledTimers--;
			if (state == ENTHRALLED_STATE)
			{
				advanceState(ROUTE_STATE);			
			}
			else
			{
				throw new Error("State is not enthralled state");
			}
		}
		
		public function endEnthralledState():void
		{
			
		}
		
		public function doEnthralledState(deltaTime:Number):void
		{
			
		}
		
		public function startQueuedState():void
		{
			state = QUEUED_STATE;
			standFacingObject(currentBooth);
			currentBooth.actualQueue++;
			
			checkIfFrontOfQueue();
		}
		
		public function checkIfFrontOfQueue():void
		{
			if (!currentBooth)
			{
				throw new Error("Should have a current booth");
			}
			if (queuedTimer)
			{
				throw new Error("Queued timer already exists");
			}
			if (currentBoothPosition == 1 && !queuedTimer)
			{
				startQueuedTimer();
			}
			else if (currentBoothPosition == 0)
			{
				throw new Error("Booth position is 0");
			}
		}
		
		public function startQueuedTimer():void
		{
			if (state != QUEUED_STATE)
			{
				trace("Queued Timers: " + numQueuedTimers.toString());		
				trace("Enthralled Timers: " + numEnthralledTimers.toString());						
				throw new Error("State is not queued state");
			}
			
			queuedTimer = new Timer(CustomerPerson.QUEUED_TIME);
			queuedTimer.addEventListener(TimerEvent.TIMER, exitQueue);
			queuedTimer.start();	
			numQueuedTimers++;
			trace("Queued Timers: " + numQueuedTimers.toString());		
			trace("Enthralled Timers: " + numEnthralledTimers.toString());		
		}
		
		public function moveUpInQueue():void
		{
			// This assumes a particular orientation
			
			var destination:Point3D = new Point3D(Math.floor(worldCoords.x - 1), Math.floor(worldCoords.y), Math.floor(worldCoords.z));
			moveCustomer(destination);
		}
		
		private function exitQueue(evt:TimerEvent):void
		{
			if (state == QUEUED_STATE)
			{
				decrementQueue();
				worldDestination = null;
				
				queuedTimer.stop();
				queuedTimer.removeEventListener(TimerEvent.TIMER, exitQueue);
				queuedTimer = null;
				trace("Queued Timers: " + numQueuedTimers.toString());		
				trace("Enthralled Timers: " + numEnthralledTimers.toString());				
				
				advanceState(HEADTOSTAGE_STATE);
			}
			else
			{
				trace("Queued Timers: " + numQueuedTimers.toString());		
				trace("Enthralled Timers: " + numEnthralledTimers.toString());				
				throw new Error("State is not queued state");
				queuedTimer.stop();
				queuedTimer.removeEventListener(TimerEvent.TIMER, exitQueue);
				queuedTimer = null;				
			}
			
			numQueuedTimers--;
			trace(numQueuedTimers.toString());			
		}
		
		private function decrementQueue():void
		{
			currentBooth.boothManager.decreaseInventoryCount(currentBooth, 1);
			currentBooth.currentQueue--;
			currentBooth.actualQueue--;			
		}
		
		public function endQueuedState():void
		{
			dispatchExitQueueEvent();
			resetCurrentBooth();
		}
		
		private function resetCurrentBooth():void
		{
			currentBooth = null;			
		}
		
		private function dispatchExitQueueEvent():void
		{
			var evt:DynamicEvent = new DynamicEvent("queueDecremented", true, true);
			evt.person = this;
			evt.booth = currentBooth;
			dispatchEvent(evt);
		}
		
		public function doQueuedState(deltaTime:Number):void
		{
			
		}
		
		public function startHeadToStageState():void
		{
			state = HEADTOSTAGE_STATE;
			
			var destination:Point3D = pickPointNearStructure(_concertStage);
			moveCustomer(destination);
		}
		
		public function endHeadToStageState():void
		{
			
		}
		
		public function doHeadToStageState(deltaTime:Number):void
		{
			
		}
		
		public function startRouteState():void
		{
			state = ROUTE_STATE;
			
			var booth:Booth = _boothManager.getRandomBooth(currentBooth);
			if (booth == null)
			{
				advanceState(ROAM_STATE);
			}
			else
			{
				currentBooth = booth;
				currentBooth.currentQueue++;
							
				dispatchRouteEvent();
			}			
		}
		
		public function setQueuedPosition(index:int):void
		{
			currentBoothPosition = index;	
		}
		
		public function dispatchRouteEvent():void
		{
			var evt:DynamicEvent = new DynamicEvent("customerRouted", true, true);
			evt.cp = this;
			evt.booth = currentBooth;
			dispatchEvent(evt);
		}
		
		public function endRouteState():void
		{
			
		}
		
		public function doRouteState(deltaTime:Number):void
		{
			
		}	
		
		public function getBoothActivityTime():int
		{
			return QUEUED_TIME;
		}
		
		public function getEnthralledActivityTime():int
		{
			return ENTHRALLED_TIME;
		}
		
		public function pickPointNearStructure(structure:*):Point3D
		{
			var stagePoint:Point3D;
			var occupiedSpaces:ArrayCollection = _myWorld.pathFinder.updateOccupiedSpaces(true, true);
			
			if (availableSpaces(occupiedSpaces))
			{
				do 
				{
					stagePoint = new Point3D(Math.floor(Math.random()*_myWorld.tilesWide), 0, Math.floor(Math.random()*_myWorld.tilesDeep));				
				}
				while (occupiedSpaces.contains(_myWorld.pathFinder.mapPointToPathGrid(stagePoint)));
			}
			else
			{
				throw new Error("There are no available spaces in this world");
			}
			return stagePoint;
		}
		
		private function availableSpaces(occupiedSpaces:ArrayCollection):Boolean
		{
			if (occupiedSpaces.length > _myWorld.tilesDeep*_myWorld.tilesWide)
			{
				return false;
			}
			return true;
		}
		
		public function updateBoothFront(index:int):void
		{
			var boothFront:Point3D;
			if (state == ROUTE_STATE)
			{
				boothFront = _boothManager.getBoothFront(currentBooth, index, true);
				updateDestination(boothFront);
			}
			else if (state == QUEUED_STATE)
			{
				boothFront = _boothManager.getBoothFront(currentBooth, index, false, true);
				moveCustomer(boothFront);
			}
			else
			{
				throw new Error("Should not be updating booth front when not in route state");
			}
		}
		
		private function updateDestination(newDestination:Point3D):void
		{
			if (!proxiedDestination)
			{
				proxiedDestination = newDestination;
				adjustForPathfinding();
			}
			else
			{
				proxiedDestination = newDestination;
				adjustForPathfinding();
			}	
		}
		
		public function adjustForPathfinding():void
		{
			// Don't move out of bounds!
			// Don't move into structures
						
			var nextPoint:Point3D;
			var occupiedSpaces:ArrayCollection = _myWorld.pathFinder.updateOccupiedSpaces(false, true);
			
			if (directionality.x > 0)
			{
				nextPoint = new Point3D(Math.ceil(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
				if (occupiedSpaces.contains(_world.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
				{
					nextPoint = new Point3D(Math.floor(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
				}
				_myWorld.moveAssetTo(this, nextPoint);
			}
			else if (directionality.x < 0)
			{
				nextPoint = new Point3D(Math.floor(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
				if (occupiedSpaces.contains(_world.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
				{
					nextPoint = new Point3D(Math.ceil(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
				}					
				_myWorld.moveAssetTo(this, nextPoint);
			}
			else if (directionality.z > 0)
			{
				nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.ceil(worldCoords.z));
				if (occupiedSpaces.contains(_world.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
				{
					nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.floor(worldCoords.z));
				}					
				_myWorld.moveAssetTo(this, nextPoint);
			}
			else if (directionality.z < 0)
			{
				nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.floor(worldCoords.z));
				if (occupiedSpaces.contains(_world.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
				{
					nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.ceil(worldCoords.z));
				}						
				_myWorld.moveAssetTo(this, nextPoint);					
				_myWorld.assetRenderer.addEventListener(WorldEvent.DESTINATION_REACHED, onAdjustedForPathfinding);								
				validatePoint(nextPoint);
			}
			else 
			{
				doNextActivityAfterAdjusting();				
			}							
		}			
		
		private function validatePoint(nextPoint:Point3D):void
		{
			if (nextPoint.x > _myWorld.tilesWide || nextPoint.z > _myWorld.tilesDeep)
			{
				throw new Error("Outside of world");
			}
			if (nextPoint.y != 0)
			{
				throw new Error("Height not zero");
			}
			var occupiedSpaces:ArrayCollection = _myWorld.pathFinder.updateOccupiedSpaces(false, true);
			if (occupiedSpaces.contains(_myWorld.pathFinder.mapPointToPathGrid(nextPoint)))
			{
				throw new Error("Occupied space");
			}
		}
		
		private function onAdjustedForPathfinding(evt:WorldEvent):void
		{			
			if (evt.activeAsset == this)
			{
				_myWorld.assetRenderer.removeEventListener(WorldEvent.DESTINATION_REACHED, onAdjustedForPathfinding);
				doNextActivityAfterAdjusting();				
			}
		}				
		
		private function doNextActivityAfterAdjusting():void
		{
			moveCustomer(proxiedDestination);
			proxiedDestination = null;
		}
		
		public function getPathToBoothLength(routedCustomer:Boolean=false, queuedCustomer:Boolean=false):int
		{
			var boothFront:Point3D = _boothManager.getBoothFront(currentBooth, 0, routedCustomer, queuedCustomer);				
			var currentPoint:Point3D = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
			var path:ArrayCollection = _myWorld.pathFinder.calculatePathGrid(this, currentPoint, boothFront, false);

			return path.length;
		}
		
		public function isCustomerAtQueue():void
		{
			if (proxiedDestination)
			{
				if (worldCoords.x != proxiedDestination.x || worldCoords.y != proxiedDestination.y || worldCoords.z != proxiedDestination.z)
				{
					moveCustomer(proxiedDestination);
				}
				else
				{
					if (state == ROUTE_STATE)
					{
						advanceState(QUEUED_STATE);					
					}
					else
					{
						throw new Error("Must be in route state");
					}
				}
			}
			else
			{
				if (state == ROUTE_STATE)
				{
					advanceState(QUEUED_STATE);				
				}
				else
				{
					throw new Error("Must be in route state");
				}
			}
		}
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}
				
	}
}