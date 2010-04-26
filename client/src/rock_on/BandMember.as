package rock_on
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.WorldEvent;

	public class BandMember extends Person
	{
		public static const ENTER_STATE:int = 0;
		public static const ROAM_STATE:int = 1;
		public static const STOP_STATE:int = 3;
		public static const LEAVING_STATE:int = 2;
		public static const GONE_STATE:int = 5;		
		
		private static const ROAM_TIME:int = Math.random()*5000 + 500;
		private static const STOP_TIME:int = 10000;
		
		public var destinationLocation:Point3D;
		public var exemptStructures:ArrayCollection;
		
		public function BandMember(movieClipStack:MovieClip, layerableOrder:Array=null, creature:Creature=null, personScale:Number=1, source:Array=null)
		{
			super(movieClipStack, layerableOrder, creature, personScale, source);			
			addEventListener(MouseEvent.CLICK, showBandMemberPopup);
			startEnterState();				
		}
		
		public function addExemptStructures():void
		{
			exemptStructures = new ArrayCollection();
			exemptStructures.addItem(concertStage);
		}
		
		private function showBandMemberPopup(evt:MouseEvent):void
		{
			
		}
		
		override public function startStopState():void
		{
			state = STOP_STATE;
//			adjustForPathfinding();

			standFacingCrowd();
			
//			roamTime.stop();
//			roamTime.removeEventListener(TimerEvent.TIMER, stop);
						
			stopTime = new Timer(STOP_TIME);
			stopTime.addEventListener(TimerEvent.TIMER, roam);
			stopTime.start();
		}	
		
		override public function endStopState():void
		{
			stopTime.stop();
			stopTime.removeEventListener(TimerEvent.TIMER, roam);
		}
		
		public function stop(evt:TimerEvent):void
		{
			advanceState(STOP_STATE);
		}
		
		override public function startRoamState():void
		{
			state = ROAM_STATE;
			adjustForPathfinding();
			
//			roamTime = new Timer(ROAM_TIME);
//			roamTime.addEventListener(TimerEvent.TIMER, stop);
//			roamTime.start();
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
			_myWorld.moveAssetTo(this, destination, true, exemptStructures);			
			setDirection(worldDestination);			
		}
		
		public function setPathToCurrentCoords():void
		{
			var destination:Point3D = new Point3D(worldCoords.x, worldCoords.y, worldCoords.z);
			_myWorld.moveAssetTo(this, destination, true, exemptStructures);
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
			var distanceFromLeft:Number = worldCoords.z - concertStage.worldCoords.z;
			var distanceFromBottom:Number = concertStage.worldCoords.x - worldCoords.x;
			
			if (distanceFromLeft < distanceFromBottom)
			{
				frameNumber = 39;
				_movieClipStack.scaleX = orientation;
			}
			else
			{
				frameNumber = 39;
				_movieClipStack.scaleX = -(orientation);
			}
			
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
		
		public function attemptDestination():Point3D
		{
			var attempt:Point3D = setInitialDestination();
			return new Point3D(attempt.x, attempt.y, attempt.z);		
		}
		
		public function setInitialDestination():Point3D
		{
			destinationLocation = tryDestination();			
			
			var occupiedSpaces:ArrayCollection = _myWorld.pathFinder.updateOccupiedSpaces(false, true);
			if (occupiedSpaces.length >= _world.tilesDeep*_world.tilesWide)
			{
				throw new Error("No free spaces! That's crazy pills!");
			}
			
			// Adjust so that person avoids furniture on stage
			
			while (isAnyoneElseThere(destinationLocation))
			{
				destinationLocation = tryDestination();
			}			
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
			destinationLocation = new Point3D(concertStage.worldCoords.x + Math.floor((concertStage.structure.width - 1) - (Math.random()*(concertStage.structure.width - 1))), 0, concertStage.worldCoords.z + Math.floor((concertStage.structure.depth - 1) - Math.random()*(concertStage.structure.depth - 1)));	
			return destinationLocation;	
		}												
		
	}
}