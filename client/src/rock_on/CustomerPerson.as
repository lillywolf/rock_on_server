package rock_on
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	import mx.events.DynamicEvent;
	
	import user.UserEvent;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.WorldEvent;

	public class CustomerPerson extends Person
	{
		public static const ENTER_STATE:int = 0;
		public static const ROAM_STATE:int = 1;
		public static const STOP_STATE:int = 3;
		public static const LEAVING_STATE:int = 2;
		public static const GONE_STATE:int = 5;		
		public static const QUEUED_STATE:int = 6;
		
		private static const ROAM_TIME:int = Math.random()*50000 + 3000;
		private static const STOP_TIME:int = 10000;
		private static const STAGE_ESCAPE_TIME:int = 5000;
		private static const IN_QUEUE:int = 5000;
		private static const STAGE_CATCH_TIME_INCREMENT:int = 3000;	
		private static const CATCH_PROBABILITY_THRESHOLD:Number = 0.4;
		
		public var betweenQueues:int;
		public var isQueued:Boolean;
		public var isEnRoute:Boolean;
		public var betweenQueueTime:Timer;
		public var queueTime:Timer;
		public var stageCatchTime:Timer;
		public var stageEscapeTime:Timer;
		public var currentBooth:Booth;
		public var currentBoothSlot:int;
		public var boothFront:Point3D;	
		public var adjustingForPathToQueue:Boolean;	
		
		public var _booths:ArrayCollection = new ArrayCollection();
		public var destinationLocation:Point3D;
	
//		[Bindable] public var _collisionManager:CollisionManager;		
		
		public function CustomerPerson(movieClipStack:MovieClip, layerableOrder:Array=null, creature:Creature=null, personScale:Number=1, source:Array=null)
		{
			super(movieClipStack, layerableOrder, creature, personScale, source);
			isQueued = false;
		}

		override public function doRoamState(deltaTime:Number):void
		{
						
		}	
		
		public function catchIfNearStage(evt:TimerEvent):void
		{
			var distanceFromBottom:Number = worldCoords.x - (concertStage.worldCoords.x + concertStage.width);
			var distanceFromRight:Number = worldCoords.z - (concertStage.worldCoords.z + concertStage.depth);
			var distanceFromTop:Number = worldCoords.x - concertStage.worldCoords.x;
			var distanceFromLeft:Number = worldCoords.z - concertStage.worldCoords.z;
			
			var shortestDistanceFromStage:Number = Math.min(Math.abs(distanceFromBottom), Math.abs(distanceFromTop), Math.abs(distanceFromLeft), Math.abs(distanceFromRight));
			
			var distanceFromWallBottom:Number = worldCoords.x - _world.tilesWide;
			var distanceFromWallTop:Number = worldCoords.x;
			var distanceFromWallRight:Number = worldCoords.z - _world.tilesDeep;
			var distanceFromWallLeft:Number = worldCoords.z;
			
			var shortestDistanceFromWall:Number = Math.min(Math.abs(distanceFromWallBottom), Math.abs(distanceFromWallTop), Math.abs(distanceFromWallRight), Math.abs(distanceFromWallLeft));
			
			var catchProbability:Number;
			if (shortestDistanceFromStage != 0)
			{
				catchProbability = shortestDistanceFromWall/shortestDistanceFromStage;			
			}
			else
			{
				catchProbability = 1;
			}
			
			if (catchProbability * Math.random() > CATCH_PROBABILITY_THRESHOLD)
			{
				advanceState(STOP_STATE);
			} 
		}
		
		public function showCustomerPopup(evt:MouseEvent):void
		{
			
		}	
		
		override public function startStopState():void
		{
			state = STOP_STATE;
			adjustForPathfinding();
			
			if (stageCatchTime)
			{
				stageCatchTime.stop();
				stageCatchTime.removeEventListener(TimerEvent.TIMER, catchIfNearStage);
			}
			
			stopTime = new Timer(STOP_TIME);
			stopTime.addEventListener(TimerEvent.TIMER, queueUp);
			stopTime.start();
			
//			roamTime = new Timer(ROAM_TIME);					
//			roamTime.addEventListener(TimerEvent.TIMER, roam);
//			roamTime.start();
		}
		
		override public function endStopState():void
		{
//			roamTime.stop();
//			roamTime.removeEventListener(TimerEvent.TIMER, roam);
			if (stopTime)
			{
				stopTime.stop();
				stopTime.removeEventListener(TimerEvent.TIMER, queueUp);
			}
		}		
							
		override public function startRoamState():void
		{
			// Clean and reset
			isQueued = false;
			isEnRoute = false;
			if (currentBooth)
			{
				currentBooth.hasCustomerEnRoute = false;			
			}
			currentBooth = null;
			currentBoothSlot = -99;
			
			state = ROAM_STATE;
			adjustForPathfinding();
			
			stageEscapeTime = new Timer(STAGE_ESCAPE_TIME);
			stageEscapeTime.addEventListener(TimerEvent.TIMER, startStageCatcher);
			stageEscapeTime.start();
		}	
		
		private function startStageCatcher(evt:TimerEvent):void
		{
			stageEscapeTime.stop();
			stageEscapeTime.removeEventListener(TimerEvent.TIMER, startStageCatcher);
			stageCatchTime = new Timer(STAGE_CATCH_TIME_INCREMENT);
			stageCatchTime.addEventListener(TimerEvent.TIMER, catchIfNearStage);
			stageCatchTime.start();
		}
		
		public function adjustForPathfinding():void
		{
			// Don't move out of bounds!
			// Don't move into structures
			
			if (worldCoords.x%1 != 0 || worldCoords.y%1 != 0 || worldCoords.z%1 != 0)
			{
				var nextPoint:Point3D;
				if (directionality.x > 0)
				{
					nextPoint = new Point3D(Math.ceil(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
					if (_world.pathFinder.occupiedSpaces.contains(_world.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
					{
						nextPoint = new Point3D(Math.floor(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
					}
					_myWorld.moveAssetTo(this, nextPoint);
				}
				else if (directionality.x < 0)
				{
					nextPoint = new Point3D(Math.floor(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
					if (_world.pathFinder.occupiedSpaces.contains(_world.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
					{
						nextPoint = new Point3D(Math.ceil(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
					}					
					_myWorld.moveAssetTo(this, nextPoint);
				}
				else if (directionality.z > 0)
				{
					nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.ceil(worldCoords.z));
					if (_world.pathFinder.occupiedSpaces.contains(_world.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
					{
						nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.floor(worldCoords.z));
					}					
					_myWorld.moveAssetTo(this, nextPoint);
				}
				else if (directionality.z < 0)
				{
					nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.floor(worldCoords.z));
					if (_world.pathFinder.occupiedSpaces.contains(_world.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
					{
						nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.ceil(worldCoords.z));
					}						
					_myWorld.moveAssetTo(this, nextPoint);					
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
				else if (state == QUEUED_STATE)
				{
					walkToQueue();
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
			movePerson(destination, true);
			
//			betweenQueues = Math.random()*15000;
//			betweenQueueTime = new Timer(betweenQueues);
//			betweenQueueTime.addEventListener(TimerEvent.TIMER, queueUp);
//			betweenQueueTime.start();				
		}
		
		public function setPathToCurrentCoords():void
		{
			var destination:Point3D = new Point3D(worldCoords.x, worldCoords.y, worldCoords.z);
			movePerson(destination, true);
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
				else if (state == QUEUED_STATE)
				{
					walkToQueue();
				}	
				else if (state == STOP_STATE)
				{
					standFacingStage();
				}		
			}
		}
		
		public function queueUp(evt:TimerEvent):void
		{
			advanceState(QUEUED_STATE);
		}
			
		public function startQueuedState():void
		{
			state = QUEUED_STATE;
//			betweenQueueTime.stop();
//			betweenQueueTime.removeEventListener(TimerEvent.TIMER, queueUp);
				
			// If there are no available booths			
			queueTime = null;
			if (!availableBooths())
			{
				advanceState(ROAM_STATE);
				return;
			}
			
			var boothIndex:int = Math.floor(Math.random()*_booths.length);
			while ((boothIndex == _booths.getItemIndex(currentBooth) || (_booths.getItemAt(boothIndex) as Booth).hasCustomerEnRoute))
			{
				boothIndex = Math.floor(Math.random()*_booths.length);				
			}
					
			var booth:Booth = _booths[boothIndex];
//			if (booth.rotation == 0)
//			{
//				fpFront = new Point3D(Math.floor(fp.collidable.right + (fp.currentQueue + 1)), Math.floor(fp.collidable.y), Math.floor(fp.collidable.z));			
//			}
//			else
//			{
				// This needs to change
				boothFront = new Point3D(Math.floor(booth.structure.width/2 + booth.x + (booth.currentQueue + 1)), 0, Math.floor(booth.structure.depth/4 + booth.z));							
//			}
			
//			var attempt:Collidable = new Collidable(fpFront.x, fpFront.y, fpFront.z, 1, 1, 1);
//			if (_collisionManager.doesCollide(attempt))
//			{
//				advanceState(ROAM_STATE);
//				return;
//			}
			
			if (!isQueued)
			{
				adjustingForPathToQueue = true;
				isQueued = true;
				booth.currentQueue++;	
				booth.hasCustomerEnRoute = true;
				currentBooth = booth;
				currentBoothSlot = currentBooth.currentQueue;				
				adjustForPathfinding();
			}
		}
		
		public function walkToQueue():void
		{
			// This got moved so be careful!
			
			if (boothFront.x%1 != 0 || boothFront.y%1 != 0 || boothFront.z%1 != 0)
			{
				throw new Error('boothFront must be a whole number');
			}
			
			if (adjustingForPathToQueue)
			{
				adjustingForPathToQueue = false;
				isEnRoute = true;
//				isQueued = true;
//				currentBooth.currentQueue++;	
//				currentBooth.hasCustomerEnRoute = true;				
			}
			
			// Don't let it go out of bounds!
			
			movePerson(boothFront, true);	
		}
		
		public function availableBooths():Boolean
		{
			var i:int;
			for (i = 0; i < _booths.length; i++)
			{
				if (!(_booths[i] as Booth).hasCustomerEnRoute)
				{
					return true;
				}
			}
			return false;
		}
		
		public function setQueueOrientation():void
		{
			// This really ought to be worldCoords, should fix
			
			var rightDiff:int = worldDestination.z - (currentBooth.z + currentBooth.structure.depth/2);
			var leftDiff:int = worldDestination.z - (currentBooth.z - currentBooth.structure.depth/2);
			var frontDiff:int = worldDestination.x - (currentBooth.x + currentBooth.structure.width/2);
			var backDiff:int = worldDestination.x - (currentBooth.x - currentBooth.structure.width/2);
			
			if (rightDiff >= 0 && frontDiff < 0 && backDiff >= 0)
			{
				movieClipStack.scaleX = orientation;
				doAnimation('stand_still_away');
			}
			else if (rightDiff < 0 && leftDiff >= 0 && frontDiff >= 0 && backDiff > 0)
			{
				movieClipStack.scaleX = -(orientation);
				doAnimation('stand_still_away');
			}
			else if (rightDiff < 0 && leftDiff > 0 && backDiff < 0)
			{
				movieClipStack.scaleX = orientation;
				doAnimation('stand_still_toward');
			}
			else if (leftDiff < 0 && frontDiff < 0 && backDiff > 0)
			{
				movieClipStack.scaleX = -(orientation);
				doAnimation('stand_still_toward');
			}
			else
			{
				throw new Error("something inconceivable just happened");
			}
		}
		
		public function standFacingStage():void
		{
			var frameNumber:int = 1;			
			var distanceFromLeft:Number = concertStage.worldCoords.z - worldCoords.z;
			var distanceFromBottom:Number = worldCoords.x - (concertStage.worldCoords.x + concertStage.width);
			if (distanceFromLeft > 0 && distanceFromBottom <= 0)
			{
				frameNumber = 37;
				_movieClipStack.scaleX = orientation;
			}
			else if (distanceFromBottom > 0 && distanceFromLeft <= 0)
			{
				frameNumber = 37;
				_movieClipStack.scaleX = -(orientation);
			}
			else if (distanceFromBottom > 0 && distanceFromLeft > 0)
			{
				frameNumber = 37;
				if (distanceFromBottom > distanceFromLeft)
				{
					_movieClipStack.scaleX = -(orientation);
				}
				else
				{
					_movieClipStack.scaleX = orientation;
				}
			}
			else if (distanceFromLeft < -(concertStage.depth) && distanceFromBottom <= 0)
			{
				frameNumber = 39;
				_movieClipStack.scaleX = orientation;
			}
			else if (distanceFromLeft < -(concertStage.depth) && distanceFromBottom > 0)
			{
				if (Math.abs(distanceFromLeft) - concertStage.depth > distanceFromBottom)
				{
					frameNumber = 39;
					_movieClipStack.scaleX = orientation;
				}
				else
				{
					frameNumber = 37;
					_movieClipStack.scaleX = orientation;
				}
			}
			
			// More cases to go here
			
			stand(frameNumber);			
		}
		
		public function standStill():void
		{
			var frameNumber:int = 1;
			if (directionality.x > 0)
			{
				frameNumber = 39;
				_movieClipStack.scaleX = -(orientation);
			}
			else if (directionality.x < 0)
			{
				frameNumber = 37;
				_movieClipStack.scaleX = -(orientation);
			}
			else if (directionality.z > 0)
			{
				frameNumber = 37;
				_movieClipStack.scaleX = orientation;
			}
			else if (directionality.z < 0)
			{
				frameNumber = 39;
				_movieClipStack.scaleX = orientation;
			}
			stand(frameNumber);
		}
		
		public function moveUpInQueue(booth:Booth):void
		{
			currentBoothSlot--;
//			if (booth.rotation == 0)
//			{
				// This isn't working quite right...
				boothFront = new Point3D(Math.floor(worldCoords.x - 1), Math.floor(worldCoords.y), Math.floor(worldCoords.z));			
//			}
			if (isEnRoute)
			{
				throw new Error("You are on route!");
			}
			if (worldCoords.x%1 != 0 || worldCoords.y%1 != 0 || worldCoords.z%1 != 0)
			{
				throw new Error('You should be standing on a whole number world coord');
			}
			
//			_myWorld.moveAssetTo(this, boothFront, true);		
//			setDirection(boothFront);	
			adjustingForPathToQueue = true;
			adjustForPathfinding();	
		}
		
		public function incrementQueueSlotWhileEnRoute():void
		{
			if (!isEnRoute)
			{
				throw new Error("You're not on route!");
			}
			currentBoothSlot++;
//			if (currentBooth.rotation == 0)
//			{
				boothFront = new Point3D(boothFront.x + 1, boothFront.y, boothFront.z);
//			}
			
			var moveDestination:Point3D = calculateMoveDestination();
//			var attempt:Collidable = new Collidable(moveDestination.x, moveDestination.y, moveDestination.z, 1, 1, 1);
//			if (_collisionManager.doesCollide(attempt))
//			{
//				// Write something better here
//				moveDestination.x = Math.ceil(worldX);
//				moveDestination.y = Math.ceil(worldY);
//				moveDestination.z = Math.ceil(worldZ);
//			}
			
//			_myWorld.moveAssetTo(this, boothFront, true);
//			setDirection(boothFront);
			adjustForPathfinding();
		}
		
		public function calculateMoveDestination():Point3D
		{
			var moveDestination:Point3D = new Point3D(Math.floor(worldCoords.x), Math.floor(worldCoords.y), Math.floor(worldCoords.z));
			if (worldCoords.x % 1 != 0)
			{
				if (worldCoords.x > currentDirection.x)
				{
					moveDestination.x = Math.floor(worldCoords.x);
				}
				else
				{
					moveDestination.x = Math.ceil(worldCoords.x);
				}
				moveDestination.y = Math.floor(worldCoords.z);
			}
			else
			{
				if (worldCoords.z > currentDirection.y)
				{
					moveDestination.y = Math.floor(worldCoords.z);
				}
				else
				{
					moveDestination.y = Math.ceil(worldCoords.z);
				}
				moveDestination.x = Math.floor(worldCoords.x);
			}
			return moveDestination;			
		}
		
		public function decrementQueueSlotWhileEnRoute():void
		{
			currentBoothSlot--;
//			if (currentBooth.rotation == 0)
//			{
				boothFront = new Point3D(boothFront.x - 1, boothFront.y, boothFront.z);
//			}
			
			var moveDestination:Point3D = calculateMoveDestination();
//			var attempt:Collidable = new Collidable(moveDestination.x, moveDestination.y, moveDestination.z, 1, 1, 1);
//			if (_collisionManager.doesCollide(attempt))
//			{
//				// Write something better here
//				moveDestination.x = Math.ceil(worldX);
//				moveDestination.y = Math.ceil(worldY);
//				moveDestination.z = Math.ceil(worldZ);
//			}			
			
//			_isoWorldCanvas.moveSkin(this, moveDestination.x, moveDestination.y, moveDestination.z);
//			setDirection(moveDestination);
//			_myWorld.moveAssetTo(this, boothFront, true);		
//			setDirection(boothFront);	
			adjustForPathfinding();
		}
		
		override public function endRoamState():void
		{
			
		}
		
		public function endQueuedState():void
		{
			if (currentBoothSlot != 1)
			{
				// Used to be an error
			}
			if (queueTime)
			{
				queueTime.stop();
				queueTime.removeEventListener(TimerEvent.TIMER, roam);
				queueTime.reset();
				isQueued = false;
				var evt:DynamicEvent = new DynamicEvent('queueDecremented', true, true);
				evt.booth = currentBooth;
				evt.person = this;
				dispatchEvent(evt);
				currentBooth.currentQueue--;
				currentBooth = null;
			}
		}
		
		public function doQueuedState(deltaTime:Number):void
		{
			
		}
		
		public function checkForEnRouteToQueue():void
		{
			var evt:DynamicEvent = new DynamicEvent('arrivedAtQueue', true, true);
			evt.person = this;
			dispatchEvent(evt);
		}
		
		public function standAtBooth():void
		{
			isEnRoute = false;	
			currentBooth.hasCustomerEnRoute = false;				
			checkForEnRouteToQueue();
			setQueueOrientation();
			
			if (currentBoothSlot == 1)
			{
				queueTime = new Timer(IN_QUEUE);	
				queueTime.addEventListener(TimerEvent.TIMER, roam);
				queueTime.start();			
			}
			
			var evt:UserEvent = new UserEvent(UserEvent.THINGER_PURCHASED, true, true);
			evt.creditsToAdd = 1;
			myWorld.dispatchEvent(evt);
		}
		
		override public function setNextAction():void
		{
			if (state == ENTER_STATE)
			{
				advanceState(ROAM_STATE);
			}
			else if (state == ROAM_STATE)
			{
				advanceState(STOP_STATE);
			}
			else if (state == QUEUED_STATE)
			{
				standAtBooth();
			}
			else if (state == LEAVING_STATE)
			{
				advanceState(GONE_STATE);
			}
		}
		
		public function attemptDestination():Point3D
		{
			var attempt:Point3D = setInitialDestination();
			return new Point3D(attempt.x, attempt.y, attempt.z);		
		}
		
		public function setInitialDestination():Point3D
		{
			destinationLocation = tryDestination();			
			
			if (_myWorld.pathFinder.occupiedSpaces.length >= _myWorld.tilesDeep*_myWorld.tilesWide)
			{
				throw new Error("No free spaces! That's crazy pills!");
			}
			while (_myWorld.pathFinder.occupiedSpaces.contains(_myWorld.pathFinder.pathGrid[destinationLocation.x][destinationLocation.y][destinationLocation.z])
			|| isAnyoneElseThere(destinationLocation))
			{
				destinationLocation = tryDestination();
			}			
			return destinationLocation;
		}	
		
		public function isAnyoneElseThere(destinationLocation:Point3D):Boolean
		{
			for each (var asset:ActiveAsset in _myWorld.assetRenderer.sortedAssets)
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
			if (Math.random() < 0.5)
			{
				destinationLocation = new Point3D(Math.floor(concertStage.width + (Math.random()*(_myWorld.tilesWide-concertStage.width))), 0, Math.floor(Math.random()*_myWorld.tilesDeep));
			}
			else
			{
				destinationLocation = new Point3D(Math.floor(Math.random()*_myWorld.tilesWide), 0, Math.floor(concertStage.height + (Math.random()*(_myWorld.tilesDeep-concertStage.height))));
			}		
			return destinationLocation;	
		}	
						
		override public function update(deltaTime:Number):Boolean
		{
//			if (collidedWith)
//			{
//			}
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
				case QUEUED_STATE:
					doQueuedState(deltaTime);
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
				case QUEUED_STATE:
					endQueuedState();
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
				case STOP_STATE:
					startStopState();
					break;
				case LEAVING_STATE:
					startLeavingState();
					break;
				case QUEUED_STATE:
					startQueuedState();
					break;	
				case GONE_STATE:
					startGoneState();
					break;	
				default: throw new Error('no state to advance to!');	
			}
		}
								
		public function get booths():ArrayCollection
		{
			return _booths;
		}
		
		public function set booths(val:ArrayCollection):void
		{
			_booths = val;
		}	
		
	}
}