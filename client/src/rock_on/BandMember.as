package rock_on
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import game.MoodBoss;
	
	import helpers.CollectibleDrop;
	
	import models.Creature;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.events.DynamicEvent;
	
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
		public static const SING_STATE:int = 10;
		public static const SING_BOB_STATE:int = 11;
		public static const BOB_STATE:int = 12;
		public static const STRUM_STATE:int = 13;
		public static const BOB_AND_STRUM_STATE:int = 14;
		
		private static const ROAM_TIME:int = Math.random()*5000 + 500;
		private static const STOP_TIME:int = 10000;
		private static const ENTER_TIME:int = 1000;
		private static const BOB_MULTIPLIER:int = 10;
		private static const BOB_CONSTANT:int = 1;
		private static const BOB_WAIT_MULTIPLIER:int = 10000;
		private static const BOB_WAIT_CONSTANT:int = 1000;
		private static const SING_MULTIPLIER:int = 20000;
		private static const SING_CONSTANT:int = 2000;
		private static const SING_WAIT_MULTIPLIER:int = 20000;
		private static const SING_WAIT_CONSTANT:int = 2000;
		private static const BOB_SING_MULTIPLIER:int = 20000;
		private static const BOB_SING_CONSTANT:int = 2000;
		private static const BOB_SING_WAIT_MULTIPLIER:int = 20000;
		private static const BOB_SING_WAIT_CONSTANT:int = 2000;
		
		public var _venue:Venue;
		public var inWorld:Boolean;
		public var itemDropRecipient:Object;
		public var destinationLocation:Point3D;
		public var exitLocation:Point3D;
		public var exemptStructures:ArrayCollection;
		public var state:int;
		public var stopTime:Timer;
		public var enterTime:Timer;
		public var bobTime:Timer;
		public var bobWaitTime:Timer;
		public var singTime:Timer;
		public var singWaitTime:Timer;
		public var bobSingTime:Timer;
		public var bobSingWaitTime:Timer;
		
		private var bandAnimations:Object = {
			walk_toward: 						{"body": "walk_toward", "eyes": "walk_toward", "shoes": "walk_toward", "bottom": "walk_toward", "bottom custom": "walk_toward", "top": "walk_toward", "top custom": "walk_toward", "hair front": "walk_toward", "hair band": "walk_toward", "instrument": "walk_toward"},
			walk_toward_and_sing: 				{},
			walk_away: 							{},
			bob_head: 							{"body": "head_bob", "eyes": "head_bob", "mouth": "head_bob", "shoes": "stand_still_toward", "bottom": "stand_still_toward", "bottom custom": "stand_still_toward", "top": "stand_still_toward", "top custom": "stand_still_toward", "head": "head_bob", "hair front": "head_bob", "hair band": "head_bob", "instrument": "stand_still_toward"},
			bob_head_and_sing: 					{"body": "head_bob", "eyes": "head_bob", "mouth": "sing_head_bob", "shoes": "stand_still_toward", "bottom": "stand_still_toward", "bottom custom": "stand_still_toward", "top": "stand_still_toward", "top custom": "stand_still_toward", "hair front": "head_bob", "hair band": "head_bob", "instrument": "stand_still_toward"},
			bob_head_and_walk_toward:			{},
			bob_head_and_walk_away:				{},
			bob_head_and_strum_guitar:			{"body": "strum_guitar", "eyes": "stand_still_toward", "mouth": "stand_still_toward", "shoes": "stand_still_toward", "bottom": "stand_still_toward", "bottom custom": "stand_still_toward", "top": "stand_still_toward", "top custom": "stand_still_toward", "head": "head_bob", "hair front": "head_bob", "hair band": "head_bob", "instrument": "stand_still_toward", "left arm": "strum_guitar", "right arm": "strum_guitar"},
			bob_head_and_strum_guitar_and_sing:	{"body": "strum_guitar", "eyes": "stand_still_toward", "mouth": "sing", "shoes": "stand_still_toward", "bottom": "stand_still_toward", "bottom custom": "stand_still_toward", "top": "stand_still_toward", "top custom": "stand_still_toward", "head": "head_bob", "hair front": "head_bob", "hair band": "head_bob", "instrument": "stand_still_toward", "left arm": "strum_guitar", "right arm": "strum_guitar"},
			strum_guitar:						{"body": "strum_guitar", "eyes": "stand_still_toward", "mouth": "stand_still_toward", "shoes": "stand_still_toward", "bottom": "stand_still_toward", "bottom custom": "stand_still_toward", "top": "stand_still_toward", "top custom": "stand_still_toward", "head": "stand_still_toward", "hair front": "stand_still_toward", "hair band": "stand_still_toward", "instrument": "stand_still_toward", "left arm": "strum_guitar", "right arm": "strum_guitar"},
			strum_guitar_and_sing:				{"body": "strum_guitar", "eyes": "stand_still_toward", "mouth": "sing", "shoes": "stand_still_toward", "bottom": "stand_still_toward", "bottom custom": "stand_still_toward", "top": "stand_still_toward", "top custom": "stand_still_toward", "head": "stand_still_toward", "hair front": "stand_still_toward", "hair band": "stand_still_toward", "instrument": "stand_still_toward", "left arm": "strum_guitar", "right arm": "strum_guitar"},
			sing:								{"body": "stand_still_toward", "eyes": "stand_still_toward", "mouth": "sing", "shoes": "stand_still_toward", "bottom": "stand_still_toward", "bottom custom": "stand_still_toward", "top": "stand_still_toward", "top custom": "stand_still_toward", "hair front": "stand_still_toward", "hair band": "stand_still_toward", "instrument": "stand_still_toward"}
		}
		
		public function BandMember(creature:Creature, movieClip:MovieClip=null, layerableOrder:Array=null, scale:Number=1)
		{
			super(creature, movieClip, layerableOrder, scale);			
			addEventListener(MouseEvent.CLICK, showBandMemberPopup);
			updateLayerableOrder();
		}
		
		private function updateLayerableOrder():void
		{
			layerableOrder = new Array();
			layerableOrder['walk_toward'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "mouth", "hair front", "hair band", "instrument"];
			layerableOrder['walk_away'] = ["body", "shoes", "bottom", "top", "bottom custom", "top custom", "hair front", "hair band", "instrument"];
			layerableOrder['stand_still_toward'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "mouth", "hair front", "hair band", "instrument"];
			layerableOrder['stand_still_away'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band", "instrument"];			
			layerableOrder['sing'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "mouth", "hair front", "hair band", "instrument"];			
			layerableOrder['bob_head_and_sing'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "head", "mouth", "hair front", "hair band", "instrument"];			
			layerableOrder['bob_head'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "head", "mouth", "hair front", "hair band", "instrument"];			
			layerableOrder['bob_head_and_strum_guitar'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "instrument", "left arm", "right arm", "head", "mouth", "hair front", "hair band"];			
			layerableOrder['strum_guitar'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "head", "mouth", "hair front", "hair band", "instrument", "left arm", "right arm"];			
			layerableOrder['strum_guitar_and_sing'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "head", "mouth", "hair front", "hair band", "instrument", "left arm", "right arm"];			
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
		
		public function startSingState():void
		{
			state = SING_STATE;
			standAndSing();
		}
		
		public function startBobState():void
		{
			state = BOB_STATE;
			startBob();
		}
		
		public function startStrumState():void
		{
			state = STRUM_STATE;
			startStrum();
		}
		
		public function startBobAndStrumState():void
		{
			state = STRUM_STATE;
			startBobAndStrum();
		}
		
		public function endSingState():void
		{
			if (singTime)
			{
				this.singTime.stop();			
				this.singTime = null;
			}
			if (singWaitTime)
			{
				this.singWaitTime.stop();
				this.singWaitTime = null;
			}
		}
		
		public function endSingBobState():void
		{
			this.bobSingTime.stop();
			this.bobSingWaitTime.stop();
			this.bobSingTime = null;
			this.bobSingWaitTime = null;
		}
		
		public function endBobState():void
		{
			this.bobTime.stop();
			this.bobWaitTime.stop();
			this.bobTime = null;
			this.bobWaitTime = null;
			if (this.hasEventListener("loopComplete"))
			{
				this.removeEventListener("loopComplete", onBobLoopComplete);
			}
		}
		
		private function endStrumState():void
		{
			
		}

		private function endBobAndStrumState():void
		{
			
		}
		
		public function startSingBobState():void
		{
			state = SING_BOB_STATE;
			startBobSingTimer();
		}
		
		public function doSingBob():void
		{
			doComplexAnimation("bob_head_and_sing", this.bandAnimations["bob_head_and_sing"]);
		}
		
		public function stopSingBob():void
		{
			standFacingCrowd();
		}
		
		private function startStrum():void
		{
			doComplexAnimation("strum_guitar", this.bandAnimations["strum_guitar"]);
		}

		private function startBobAndStrum():void
		{
			doComplexAnimation("bob_head_and_strum_guitar", this.bandAnimations["bob_head_and_strum_guitar"]);
		}
		
		public function doBob(loops:int):void
		{
			doComplexAnimation("bob_head", loops);
		}
		
		public function stopBob():void
		{
			standFacingCrowd();
		}
		
		public function stopStrum():void
		{
			standFacingCrowd();
		}
		
		private function startBob():void
		{
			this.addEventListener("loopComplete", onBobLoopComplete);
			var loops:int = Math.ceil(BOB_CONSTANT + Math.random() * BOB_MULTIPLIER);
			doBob(loops);					
		}
		
		private function onBobLoopComplete(evt:DynamicEvent):void
		{
			startBobWaitTimer();
			this.removeEventListener("loopComplete", onBobLoopComplete);
		}
		
		private function startSingTimer():void
		{
			singTime = new Timer(Math.random() * SING_MULTIPLIER + SING_CONSTANT);
			singTime.addEventListener(TimerEvent.TIMER, onSingTimeComplete);
			singTime.start();
		}
		
		private function startBobSingTimer():void
		{
			doSingBob();
			bobSingTime = new Timer(Math.random() * BOB_SING_MULTIPLIER + BOB_SING_CONSTANT);
			bobSingTime.addEventListener(TimerEvent.TIMER, onBobSingComplete);
			bobSingTime.start();
		}
		
		private function onBobSingComplete(evt:TimerEvent):void
		{
			stopSingBob();
			bobSingTime.stop();
			bobSingTime.removeEventListener(TimerEvent.TIMER, onBobSingComplete);
			startBobSingWaitTimer();
		}
		
		private function startBobSingWaitTimer():void
		{
			bobSingWaitTime = new Timer(Math.random() * BOB_SING_WAIT_MULTIPLIER + BOB_SING_CONSTANT);
			bobSingWaitTime.addEventListener(TimerEvent.TIMER, onBobSingWaitComplete);
			bobSingWaitTime.start();
		}
		
		private function onBobSingWaitComplete(evt:TimerEvent):void
		{
			bobSingWaitTime.stop();
			bobSingWaitTime.removeEventListener(TimerEvent.TIMER, onBobSingWaitComplete);
			startBobSingTimer();
		}
		
		private function onBobTimeComplete(evt:TimerEvent):void
		{
			stopBob();
			bobTime.stop();
			bobTime.removeEventListener(TimerEvent.TIMER, onBobTimeComplete);
			startBobWaitTimer();
		}
		
		private function startBobWaitTimer():void
		{
			bobWaitTime = new Timer(Math.random() * BOB_WAIT_MULTIPLIER + BOB_WAIT_CONSTANT);
			bobWaitTime.addEventListener(TimerEvent.TIMER, onBobWaitComplete);
			bobWaitTime.start();			
		}
		
		private function onBobWaitComplete(evt:TimerEvent):void
		{
			bobWaitTime.stop();
			bobWaitTime.removeEventListener(TimerEvent.TIMER, onBobWaitComplete);
			startBob();
		}
		
		private function onSingTimeComplete(evt:TimerEvent):void
		{
			singTime.stop();
			singTime.removeEventListener(TimerEvent.TIMER, onSingTimeComplete);
			startSingWaitTimer();
		}
		
		private function startSingWaitTimer():void
		{
			singWaitTime = new Timer(Math.random() * SING_WAIT_MULTIPLIER + SING_WAIT_CONSTANT);
			singWaitTime.addEventListener(TimerEvent.TIMER, onSingWaitComplete);
			singWaitTime.start();			
		}	
		
		private function onSingWaitComplete(evt:TimerEvent):void
		{
			singWaitTime.stop();
			singWaitTime.removeEventListener(TimerEvent.TIMER, onSingWaitComplete);
			startSingTimer();
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
		
		public function findNextPath():void
		{
			var destination:Point3D = attemptDestination();
			_myWorld.moveAssetTo(this, destination, true, true, true, false, exemptStructures);			
			setDirection(worldDestination);			
		}
		
		public function setPathToCurrentCoords():void
		{
			var destination:Point3D = new Point3D(worldCoords.x, worldCoords.y, worldCoords.z);
			_myWorld.moveAssetTo(this, destination, true, true, true, false, exemptStructures);
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
		
		public function standAndSing():void
		{
			doAnimation("sing", true, 39);
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
			
			var occupiedSpaces:Array = _myWorld.pathFinder.occupiedByStructures;
			if (occupiedSpaces.length >= _world.tilesDeep*_world.tilesWide)
				throw new Error("No free spaces for band member!");
			
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
				case SING_STATE:
					break;
				case SING_BOB_STATE:
					break;
				case BOB_STATE:
					break;
				case STRUM_STATE:
					break;
				case BOB_AND_STRUM_STATE:
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
				case SING_STATE:
					endSingState();
					break;
				case SING_BOB_STATE:
					endSingBobState();
					break;
				case BOB_STATE:
					endBobState();
					break;
				case STRUM_STATE:
					endStrumState();
					break;
				case BOB_AND_STRUM_STATE:
					endBobAndStrumState();
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
				case SING_STATE:
					startSingState();
					break;
				case SING_BOB_STATE:
					startSingBobState();
					break;
				case BOB_STATE:
					startBobState();
					break;
				case STRUM_STATE:
					startStrumState();
					break;
				case BOB_AND_STRUM_STATE:
					startBobAndStrumState();
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