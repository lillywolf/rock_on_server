package rock_on
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import game.MoodBoss;
	
	import helpers.CollectibleDrop;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	
	import org.osmf.events.TimeEvent;
	
	import views.WorldView;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class BandMember extends Person
	{
		public static const STAGE_ENTER_STATE:int = 0;
		public static const ROAM_STATE:int = 1;
		public static const STOP_STATE:int = 3;
		public static const LEAVING_STATE:int = 2;
		public static const WAIT_STATE:int = 4;
		public static const GONE_STATE:int = 5;
		public static const EXIT_STAGE_STATE:int = 6;
		public static const DIRECTED_MOVE_STATE:int = 7;
		public static const DIRECTED_STOP_STATE:int = 8;
		public static const EXIT_OFFSTAGE_STATE:int = 9;
		
		private static const ROAM_TIME:int = Math.random()*5000 + 500;
		private static const STOP_TIME:int = 10000;
		private static const ENTER_TIME:int = 1000;
		
		public var _venue:Venue;
		public var inWorld:Boolean;
		public var itemDropRecipient:Object;
		public var destinationLocation:Point3D;
		public var exitLocation:Point3D;
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
//			stopTime.stop();
//			stopTime.removeEventListener(TimerEvent.TIMER, roam);
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
		
//		public function adjustForPathfinding():void
//		{
//			// Don't move out of bounds!
//			// Don't move into structures
//			
//			if (worldCoords.x%1 != 0 || worldCoords.y%1 != 0 || worldCoords.z%1 != 0)
//			{
//				if (directionality.x > 0)
//				{
//					_myWorld.moveAssetTo(this, new Point3D(Math.ceil(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z)));
//				}
//				else if (directionality.x < 0)
//				{
//					_myWorld.moveAssetTo(this, new Point3D(Math.floor(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z)));
//				}
//				else if (directionality.z > 0)
//				{
//					_myWorld.moveAssetTo(this, new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.ceil(worldCoords.z)));
//				}
//				else if (directionality.z < 0)
//				{
//					_myWorld.moveAssetTo(this, new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.floor(worldCoords.z)));					
//				}
//				else 
//				{
//					// Something?
//				}
//				_myWorld.assetRenderer.addEventListener(WorldEvent.DESTINATION_REACHED, onAdjustedForPathfinding);								
//			}
//			else
//			{
//				if (state == ROAM_STATE)
//				{
//					findNextPath();									
//				}
//				if (state == STOP_STATE)
//				{
//					setPathToCurrentCoords();
//				}
//			}
//		}	
		
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
				case STAGE_ENTER_STATE:
					doStageEnterState(deltaTime);
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
				case DIRECTED_MOVE_STATE:
					doDirectedMoveState(deltaTime);
					break;
				case DIRECTED_STOP_STATE:
					doDirectedStopState(deltaTime);
					break;
				case EXIT_OFFSTAGE_STATE:
					doExitOffstageState(deltaTime);
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
				case STAGE_ENTER_STATE:
					endStageEnterState();
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
				case DIRECTED_MOVE_STATE:
					endDirectedMoveState();
					break;
				case DIRECTED_STOP_STATE:
					endDirectedStopState();
					break;
				case EXIT_OFFSTAGE_STATE:
					endExitOffstageState();
					break;
				case GONE_STATE:
					break;					
				default: throw new Error('no state to advance from!');
			}
			switch (destinationState)
			{
				case STAGE_ENTER_STATE:
					startStageEnterState();
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
				case DIRECTED_MOVE_STATE:
					startDirectedMoveState();
					break;
				case DIRECTED_STOP_STATE:
					startDirectedStopState();
					break;
				case EXIT_OFFSTAGE_STATE:
					startExitOffstageState();
					break;
				default: throw new Error('no state to advance to!');	
			}
		}	
		
		public function goToStage():Boolean
		{
			if (!(_myWorld == _venue.stageManager.myStage))
			{
				var exemptStructures:ArrayCollection = new ArrayCollection();
				exemptStructures.addItem(_venue.stageManager.concertStage);
				exitLocation = _venue.mainEntrance;
				destinationLocation = _venue.pickRandomAvailablePointWithinRect(_venue.stageRect, _venue.stageManager.myStage, _venue.stageManager.concertStage.structure.height, null, true, true, exemptStructures);
				advanceState(EXIT_OFFSTAGE_STATE);
				return false;
			}
			return true;
		}
		
		public function getYellowGlowfilter():GlowFilter
		{
			var gf:GlowFilter = new GlowFilter(0xFFDD00, 1, 2, 2, 20, 20);	
			return gf;
		}
		
		public function getMovieClipForRecipient(recipient:Person):MovieClip
		{
			if (recipient.mood)
			{
				var itemMc:MovieClip = MoodBoss.getMovieClipForMood(recipient.mood);							
			}
			return itemMc;
		}
		
		public function tossItem(recipient:Person, view:WorldView):void
		{
			if (recipient.mood)
			{
				var itemDestination:Point = World.worldToActualCoords(recipient.worldCoords);
				itemDestination.y -= (this.height - 70);
				var itemMc:MovieClip = getMovieClipForRecipient(recipient as Person);
				itemMc.scaleX = 0.5;
				itemMc.scaleY = 0.5;
				var gf:GlowFilter = getYellowGlowfilter();
				itemMc.filters = [gf];
				var item:CollectibleDrop = new CollectibleDrop(this, itemMc, new Point(10, 10), _venue.myWorld, view, 0, 600, .0008, itemDestination);
				item.addEventListener(WorldEvent.ITEM_DROPPED, function onItemDropped(evt:WorldEvent):void
				{
					item.removeEventListener(WorldEvent.ITEM_DROPPED, onItemDropped);
					_venue.myWorld.removeChild(item);
					dispatchEvent(evt);
				});
				_venue.myWorld.addChild(item);
				itemDropRecipient = null;
			}
//			else
//			{
//				throw new Error("attempted to toss item to a non-mood person");
//			}
		}
		
		public function validateDestinationLocation():Boolean
		{
			var exemptStructures:ArrayCollection = new ArrayCollection();
			exemptStructures.addItem(_venue.stageManager.concertStage);
			if (!_myWorld.isPointAvailable(destinationLocation, true, true, exemptStructures))
			{
				var newPoint:Point3D = getClosestAvailableSpot(destinationLocation);
				if (newPoint)
				{
					destinationLocation = newPoint;
					return true;
				}
				else
				{
					return false;
				}
			}
			return true;
		}
		
		public function startStageEnterState():void
		{
			state = STAGE_ENTER_STATE;
			addToOnstageView();	
			if (validateDestinationLocation())
			{
				movePerson(destinationLocation);			
			}
				
//			enterTime = new Timer(ENTER_TIME);
//			enterTime.addEventListener(TimerEvent.TIMER, roam);
//			enterTime.start();
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
			movePerson(exitLocation);
		}
		
		public function endExitStageState():void
		{
			inWorld = true;
			removeFromView();
		}
		
		public function startDirectedMoveState():void
		{		
			addToOffstageView();			
			if (!adjustInCaseAlreadyMoving(destinationLocation))
			{
				movePerson(destinationLocation);				
			}
			state = DIRECTED_MOVE_STATE;
		}
		
		public function checkIfProxiedMove(newState:int):void
		{
			if (proxiedDestination)
			{
				if (worldCoords.x != proxiedDestination.x || worldCoords.y != proxiedDestination.y || worldCoords.z != proxiedDestination.z)
				{
					var newDestination:Point3D = new Point3D(proxiedDestination.x, proxiedDestination.y, proxiedDestination.z);
					proxiedDestination = null;
					movePerson(newDestination);
				}		
			}
			else
			{
				advanceState(newState);				
			}
		}	
		
		public function endDirectedMoveState():void
		{
			
		}
		
		public function doDirectedMoveState(deltaTime:Number):void
		{
			
		}
		
		public function startDirectedStopState():void
		{
			state = DIRECTED_STOP_STATE;
			standFacingCurrentDirection();
		}
		
		public function endDirectedStopState():void
		{
			
		}
		
		public function doDirectedStopState(deltaTime:Number):void
		{
			
		}
		
		public function adjustInCaseAlreadyMoving(currentDestination:Point3D):Boolean
		{		
			if (state == DIRECTED_MOVE_STATE || state == EXIT_OFFSTAGE_STATE)
			{
				updateDestination(currentDestination);	
				return true;
			}
			return false;
		}
		
		public function startExitOffstageState():void
		{
			if (!adjustInCaseAlreadyMoving(exitLocation))
			{
				movePerson(exitLocation);			
			}
			state = EXIT_OFFSTAGE_STATE;
		}
		
		public function endExitOffstageState():void
		{
			inWorld = false;
			removeFromView();
		}
		
		public function doExitOffstageState(deltaTime:Number):void
		{
			
		}
		
		public function doExitStageState(deltaTime:Number):void
		{
			
		}
		
		private function addToOnstageView():void
		{
			if (!_venue.stageManager.myStage.doesWorldContain(this))
			{			
				_myWorld = _venue.stageManager.myStage;
				_myWorld.addAsset(this, _venue.stageManager.concertStage.stageEntryPoint);
			}	
		}
		
		private function addToOffstageView():void
		{
			if (!_venue.myWorld.doesWorldContain(this))
			{
				_myWorld = _venue.myWorld;
				_myWorld.addAsset(this, _venue.mainEntrance);
			}
		}
		
		private function removeFromView():void
		{
			_myWorld.removeAsset(this);
		}
		
		public function endDirectedState():void
		{
			
		}
		
		public function endStageEnterState():void
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
		
		public function doStageEnterState(deltaTime:Number):void
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