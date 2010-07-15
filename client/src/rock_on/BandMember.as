package rock_on
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	
	import org.osmf.events.TimeEvent;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.WorldEvent;

	public class BandMember extends Person
	{
		public static const ENTER_STATE:int = 0;
		public static const ROAM_STATE:int = 1;
		public static const STOP_STATE:int = 3;
		public static const LEAVING_STATE:int = 2;
		public static const WAIT_STATE:int = 4;
		public static const GONE_STATE:int = 5;
		public static const EXIT_STAGE_STATE:int = 6;
		public static const OFFSTAGE_STATE:int = 7;
		
		private static const ROAM_TIME:int = Math.random()*5000 + 500;
		private static const STOP_TIME:int = 10000;
		private static const ENTER_TIME:int = 1000;
		
		public var _venue:Venue;
		public var destinationLocation:Point3D;
		public var offStageDestination:Point3D;
		public var exemptStructures:ArrayCollection;
		public var state:int;
		public var stopTime:Timer;
		public var enterTime:Timer;
		
		public function BandMember(creature:Creature, movieClip:MovieClip=null, layerableOrder:Array=null, scale:Number=1)
		{
			super(creature, movieClip, layerableOrder, scale);			
			addEventListener(MouseEvent.CLICK, showBandMemberPopup);
		}
		
		public function addExemptStructures():void
		{
			exemptStructures = new ArrayCollection();
			exemptStructures.addItem(_stageManager.concertStage);
		}
		
		private function showBandMemberPopup(evt:MouseEvent):void
		{
			
		}
		
		public function startStopState():void
		{
			state = STOP_STATE;
			standFacingCrowd();
						
//			stopTime = new Timer(STOP_TIME);
//			stopTime.addEventListener(TimerEvent.TIMER, roam);
//			stopTime.start();
		}	
		
		public function endStopState():void
		{
			stopTime.stop();
			stopTime.removeEventListener(TimerEvent.TIMER, roam);
		}
		
		public function roam(evt:TimerEvent):void
		{
			advanceState(ROAM_STATE);
		}		
		
		public function stop(evt:TimerEvent):void
		{
			advanceState(STOP_STATE);
		}
		
		public function startRoamState():void
		{
			state = ROAM_STATE;
			adjustForPathfinding();
		}	
		
		public function adjustForPathfinding():void
		{
			// Don't move out of bounds!
			// Don't move into structures
			
			if (worldCoords.x%1 != 0 || worldCoords.y%1 != 0 || worldCoords.z%1 != 0)
			{
				if (directionality.x > 0)
				{
					_myWorld.moveAssetTo(this, new Point3D(Math.ceil(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z)));
				}
				else if (directionality.x < 0)
				{
					_myWorld.moveAssetTo(this, new Point3D(Math.floor(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z)));
				}
				else if (directionality.z > 0)
				{
					_myWorld.moveAssetTo(this, new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.ceil(worldCoords.z)));
				}
				else if (directionality.z < 0)
				{
					_myWorld.moveAssetTo(this, new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.floor(worldCoords.z)));					
				}
				else 
				{
					// Something?
				}
				_myWorld.assetRenderer.addEventListener(WorldEvent.DESTINATION_REACHED, onAdjustedForPathfinding);								
			}
			else
			{
				if (state == ROAM_STATE)
				{
					findNextPath();									
				}
				if (state == STOP_STATE)
				{
					setPathToCurrentCoords();
				}
			}
		}	
		
		public function findNextPath():void
		{
			var destination:Point3D = attemptDestination();
			_myWorld.moveAssetTo(this, destination, true, true, false, exemptStructures);			
			setDirection(worldDestination);			
		}
		
		public function setPathToCurrentCoords():void
		{
			var destination:Point3D = new Point3D(worldCoords.x, worldCoords.y, worldCoords.z);
			_myWorld.moveAssetTo(this, destination, true, true, false, exemptStructures);
			setDirection(worldDestination);
		}
		
		private function onAdjustedForPathfinding(evt:WorldEvent):void
		{
			if (evt.activeAsset == this)
			{
				_myWorld.assetRenderer.removeEventListener(WorldEvent.DESTINATION_REACHED, onAdjustedForPathfinding);
				if (state == ROAM_STATE)
				{			
					findNextPath();	
				}		
				else if (state == STOP_STATE)
				{
					standFacingCrowd();
				}		
			}
		}
		
		public function standFacingCrowd():void
		{
			var frameNumber:int = 1;			
			var distanceFromLeft:Number = worldCoords.z - _stageManager.concertStage.worldCoords.z;
			var distanceFromBottom:Number = _stageManager.concertStage.worldCoords.x - worldCoords.x;
			
			if (distanceFromLeft < distanceFromBottom)
			{
				frameNumber = 39;
				changeScale(_scale, _scale);
			}
			else
			{
				frameNumber = 39;
				changeScale(_scale, _scale);
			}
			
			var standAnimation:String = getStandAnimation(frameNumber);
			stand(standAnimation, frameNumber);			
		}	
		
		public function startWaitState():void
		{
			state = WAIT_STATE;
			standFacingCrowd();			
		}
		
		public function endWaitState():void
		{
			
		}
		
		public function doWaitState(deltaTime:Number):void
		{
			
		}
		
		public function attemptDestination():Point3D
		{
			var attempt:Point3D = setInitialDestination();
			return new Point3D(attempt.x, attempt.y, attempt.z);		
		}
		
		public function setInitialDestination():Point3D
		{
			trace("set initial dest");
			destinationLocation = tryDestination();			
			
			var occupiedSpaces:ArrayCollection = _myWorld.pathFinder.updateOccupiedSpaces(false, true);
			if (occupiedSpaces.length >= _world.tilesDeep*_world.tilesWide)
			{
				throw new Error("No free spaces for band member!");
			}
			
			// Adjust so that person avoids furniture on stage
			
			while (isAnyoneElseThere(destinationLocation))
			{
				destinationLocation = tryDestination();
			}	
			trace("destination set");
			return destinationLocation;
		}	
		
		public function isAnyoneElseThere(destinationLocation:Point3D):Boolean
		{
			for each (var asset:ActiveAsset in _world.assetRenderer.sortedAssets)
			{
				if (asset != this && asset.worldCoords)
				{
					if (asset.worldCoords.x == destinationLocation.x && asset.worldCoords.y == destinationLocation.y && asset.worldCoords.z == destinationLocation.z)
					{
						return true;
					}
					if (asset.worldDestination)
					{
						if (asset.worldDestination.x == destinationLocation.x && asset.worldDestination.y == destinationLocation.y && asset.worldDestination.z == destinationLocation.z)
						{
							return true;
						}
					}
				}
			}
			return false;
		}
		
		public function tryDestination():Point3D
		{
			destinationLocation = new Point3D(_stageManager.concertStage.worldCoords.x + Math.floor((_stageManager.concertStage.structure.width - 1) - (Math.random()*(_stageManager.concertStage.structure.width - 1))), 
				0, 
				_stageManager.concertStage.worldCoords.z + Math.floor((_stageManager.concertStage.structure.depth - 1) - Math.random()*(_stageManager.concertStage.structure.depth - 1)));	
			return destinationLocation;	
		}
				
		public function update(deltaTime:Number):Boolean
		{
			switch (state)
			{
				case ENTER_STATE:
					doEnterState(deltaTime);
					break;
				case ROAM_STATE:
					doRoamState(deltaTime);
					break;
				case STOP_STATE:
					doStopState(deltaTime);
					break;					
				case LEAVING_STATE:
					doLeavingState(deltaTime);
					break;
				case WAIT_STATE:
					doWaitState(deltaTime);
					break;
				case EXIT_STAGE_STATE:
					doExitStageState(deltaTime);
					break;
				case OFFSTAGE_STATE:
					doOffstageState(deltaTime);
					break;
				case GONE_STATE:
					doGoneState(deltaTime);	
					return true;
				default: throw new Error('oh noes!');
			}
			return false;
		}		
		
		public function advanceState(destinationState:int):void
		{
			switch (state)
			{	
				case ENTER_STATE:
					endEnterState();
					break;
				case ROAM_STATE:
					endRoamState();				
					break;	
				case STOP_STATE:
					endStopState();
					break;	
				case LEAVING_STATE:
					endLeavingState();
					break;	
				case WAIT_STATE:
					endWaitState();
					break;	
				case EXIT_STAGE_STATE:
					endExitStageState();
					break;
				case OFFSTAGE_STATE:
					endOffstageState();
					break;
				case GONE_STATE:
					break;					
				default: throw new Error('no state to advance from!');
			}
			switch (destinationState)
			{
				case ENTER_STATE:
					startEnterState();
					break;				
				case ROAM_STATE:
					startRoamState();
					break;
				case STOP_STATE:
					startStopState();
					break;
				case LEAVING_STATE:
					startLeavingState();
					break;
				case GONE_STATE:
					startGoneState();
					break;	
				case WAIT_STATE:
					startWaitState();
					break;
				case EXIT_STAGE_STATE:
					startExitStageState();
					break;
				case OFFSTAGE_STATE:
					startOffstageState();
					break;
				default: throw new Error('no state to advance to!');	
			}
		}	
		
		public function startEnterState():void
		{
			state = ENTER_STATE;
			enterTime = new Timer(ENTER_TIME);
			enterTime.addEventListener(TimerEvent.TIMER, roam);
			enterTime.start();
		}
		
		public function startLeavingState():void
		{
			state = LEAVING_STATE;
//			pickLeaveDirection();
		}
		
		public function startGoneState():void
		{
			state = GONE_STATE;
		}
		
		public function startExitStageState():void
		{
			state = EXIT_STAGE_STATE;
			movePerson(destinationLocation);
		}
		
		public function endExitStageState():void
		{
			removeFromView();
		}
		
		public function startOffstageState():void
		{
			state = OFFSTAGE_STATE;
			addToOffstageView();
			movePerson(offStageDestination);
		}
		
		public function endOffstageState():void
		{
			
		}
		
		public function doOffstageState(deltaTime:Number):void
		{
			
		}
		
		public function doExitStageState(deltaTime:Number):void
		{
			
		}
		
		private function addToOffstageView():void
		{
			_myWorld = _venue.myWorld;
			_myWorld.addAsset(this, _venue.mainEntrance);
		}
		
		private function removeFromView():void
		{
			_myWorld.removeAsset(this);
		}
		
		public function endDirectedState():void
		{
			
		}
		
		public function endEnterState():void
		{
//			enterTime.stop();
//			enterTime.removeEventListener(TimerEvent.TIMER, roam);
		}
		
		public function endRoamState():void
		{
			
		}
		
		public function endLeavingState():void
		{
			
		}
		
		public function doEnterState(deltaTime:Number):void
		{
			
		}
		
		public function doRoamState(deltaTime:Number):void
		{
			
		}
		
		public function doStopState(deltaTime:Number):void
		{
			
		}
		
		public function doLeavingState(deltaTime:Number):void
		{
			
		}
		
		public function doGoneState(deltaTime:Number):void
		{
			
		}	
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}
		
	}
}