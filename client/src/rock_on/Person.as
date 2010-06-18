package rock_on
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import models.Creature;
	import models.OwnedStructure;
	
	import world.AssetStack;
	import world.Point3D;
	import world.World;

	public class Person extends AssetStack
	{
		public static const ENTER_STATE:int = 0;
		public static const ROAM_STATE:int = 1;
		public static const STOP_STATE:int = 3;
		public static const LEAVING_STATE:int = 2;
		public static const GONE_STATE:int = 5;

		private static const ENTER_TIME:int = 1000;
		private static const ROAM_TIME:int = Math.random()*20000 + 3000;
		private static const STOP_TIME:int = 5000;
		
		public var stopTime:Timer;	
		public var enterTime:Timer;
		public var roamTime:Timer;
		
		public var _myWorld:World;
		private var _concertStage:ConcertStage;
		public var state:int;
		public var currentDirection:Point3D;	
		public var orientation:Number;			
		
		public function Person(movieClipStack:MovieClip, layerableOrder:Array=null, creature:Creature=null, personScale:Number=1, source:Array=null)
		{
			super(movieClipStack, source);
		
			orientation = personScale;
			movieClipStack.scaleX = orientation;
			movieClipStack.scaleY = orientation;		
			
			setOptionalProperties(layerableOrder, creature);
		}
		
		public function setOptionalProperties(layerableOrder:Array=null, creature:Creature=null):void
		{
			if (layerableOrder)
			{
				_layerableOrder = layerableOrder;
			}
			
			if (creature)
			{
				_creature = creature;
			}						
		}
		
		public function standFacingObject(structure:OwnedStructure, frameNumber:int=0, strictFacing:Boolean=true):Object
		{
			var horizontalRelationship:String;
			var verticalRelationship:String;
			
			var cornerMatrix:Dictionary = structure.getCornerMatrix();
			if (worldCoords.x < (cornerMatrix["topLeft"] as Point3D).x)
			{
				verticalRelationship = "bottom";
			}
			else if (worldCoords.x > (cornerMatrix["bottomLeft"] as Point3D).x)
			{
				verticalRelationship = "top";
			}
			else
			{
				verticalRelationship = "center";
			}
			if (worldCoords.z < (cornerMatrix["topLeft"] as Point3D).z)
			{
				horizontalRelationship = "left";
			}		
			else if (worldCoords.z > (cornerMatrix["topRight"] as Point3D).z)
			{
				horizontalRelationship = "right";
			}	
			else
			{
				horizontalRelationship = "center";
			}
			
			frameNumber = evaluateHorizontalAndVerticalRelationship(horizontalRelationship, verticalRelationship, frameNumber, structure, strictFacing);
	
			var animationType:String;
			if (frameNumber == 37)
			{
				animationType = "stand_still_away";
			}
			else if (frameNumber == 39)
			{
				animationType = "stand_still_toward";
			}
			
			var reflection:Boolean = false;

			if (horizontalRelationship == "center" && verticalRelationship == "top")
			{
				reflection = true;
			}
			else if (horizontalRelationship != "center" && verticalRelationship == "top")
			{
				if (Math.random() < 0.5)
				{
					reflection = true;
				}
			}
			
			stand(frameNumber, animationType);
			return {frameNumber: frameNumber, animation: animationType, reflection: reflection};
		}
		
		public function moveCustomer(destination:Point3D, avoidStructures:Boolean=true, avoidPeople:Boolean=false):void
		{
			if (this.worldCoords.x%1 == 0 && this.worldCoords.y%1 == 0 && this.worldCoords.z%1 == 0)
			{			
				_myWorld.moveAssetTo(this, destination, true, avoidStructures, avoidPeople);			
			}
			else
			{
				throw new Error("Cannot move from non whole number coords");
			}
			
			if (currentPath)
			{
				var nextPoint:Point3D = getNextPointAlongPath();
				setDirection(nextPoint);			
			}			
		}
		
//		public function moveCustomer(destination:Point3D, avoidStructures:Boolean=true, avoidPeople:Boolean=false):void
//		{	
//			if (this.worldCoords.x%1 == 0 && this.worldCoords.y%1 == 0 && this.worldCoords.z%1 == 0)
//			{			
////				if (!(_myWorld.assetRenderer.unsortedAssets.contains(this)))
////				{
////					_myWorld.addAsset(this, worldCoords);				
////					_myWorld.bitmapBlotter.removeBitmapFromBlotter(this);
////				}
//			}
//		}	
		
		public function getNextPointAlongPath():Point3D
		{
			if (currentPath.length > pathStep)
			{			
				var nextPoint:Point3D = currentPath.getItemAt(pathStep) as Point3D;
			}
			return nextPoint;
		}				
		
		public function evaluateHorizontalAndVerticalRelationship(horizontalRelationship:String, verticalRelationship:String, frameNumber:int=0, structure:*=null, strictFacing:Boolean=false):int
		{
			var rand:Number = Math.random();
			
			if (verticalRelationship == "bottom")
			{
				frameNumber = 39;
				this.movieClipStack.scaleX = -(orientation);
			}
			else if (horizontalRelationship == "left")
			{
				frameNumber = 37;
				this.movieClipStack.scaleX = orientation;
			}
			else if (verticalRelationship == "top")
			{
				frameNumber = 37;
				this.movieClipStack.scaleX = -(orientation);
			}
			else if (horizontalRelationship == "right")
			{
				frameNumber = 39;
				this.movieClipStack.scaleX = orientation;
			}
			else
			{
				throw new Error("You're in the middle of a structure");
			}
			return frameNumber;
		}				
		
		public function setDirection(destination:Point3D):void
		{
			if (destination)
			{	
				var xDiff:int = destination.x - Math.round(worldCoords.x);
				var yDiff:int = destination.z - Math.round(worldCoords.z);
				
				if (Math.abs(xDiff) > Math.abs(yDiff))
				{
					if (xDiff > 0)
					{
						doAnimation('walk_toward');
					}
					else
					{
						doAnimation('walk_away');
					}
					movieClipStack.scaleX = -(orientation);				
				}
				
				else if (Math.abs(xDiff) < Math.abs(yDiff))
				{
					if (yDiff > 0)
					{
						doAnimation('walk_away');
					}
					else
					{		
						doAnimation('walk_toward');	
					}
					movieClipStack.scaleX = orientation;
				}
				else
				{				
	//				throw new Error("this is pretty damn weird");
				}
				currentDirection = destination;
			}
		}	
		
		public function movePerson(destination:Point3D, fourDirectional:Boolean=false):void
		{
			_myWorld.moveAssetTo(this, destination, fourDirectional);
//			setDirection(destination);
			setDirection(worldDestination);
		}
		
		public function pickLeaveDirection():void
		{
			var leaveDirection:Point3D;
			if (Math.random() < 0.5)
			{
				leaveDirection = new Point3D(_myWorld.tilesWide - 1, worldCoords.x, 0);
			}
			else
			{
				leaveDirection = new Point3D(worldCoords.z, _myWorld.tilesDeep - 1, 0);
			}
			_myWorld.(this, leaveDirection);
		}
		
		public function setNextAction():void
		{
			if (state == ENTER_STATE)
			{
				advanceState(ROAM_STATE);
			}
			else if (state == ROAM_STATE)
			{
				advanceState(STOP_STATE);
			}
			else if (state == LEAVING_STATE)
			{
				advanceState(GONE_STATE);
			}
		}
		
		public function startEnterState():void
		{
			state = ENTER_STATE;
			enterTime = new Timer(ENTER_TIME);
			enterTime.addEventListener(TimerEvent.TIMER, roam);
			enterTime.start();
		}	
		
		public function startRoamState():void
		{
			state = ROAM_STATE;
			setDirection(worldDestination);
		}	
		
		public function startStopState():void
		{
			state = STOP_STATE;
			doAnimation("stand_still_away");
//			for each (movieClip in movieClipStack)
//			{
//				movieClip.gotoAndPlay('stand_still_away');						
//			}
			stopTime = new Timer(STOP_TIME);
			stopTime.addEventListener(TimerEvent.TIMER, leave);
			stopTime.start();
		}
		
		public function startLeavingState():void
		{
			state = LEAVING_STATE;
			pickLeaveDirection();
		}
		
		public function startGoneState():void
		{
			state = GONE_STATE;
		}
		
		public function endEnterState():void
		{
			enterTime.stop();
			enterTime.removeEventListener(TimerEvent.TIMER, roam);
		}
		
		public function endRoamState():void
		{
			
		}
		
		public function endStopState():void
		{
			stopTime.stop();
			stopTime.removeEventListener(TimerEvent.TIMER, leave);
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
		
		public function leave(evt:TimerEvent):void
		{
			advanceState(LEAVING_STATE);
		}
		
		public function roam(evt:TimerEvent):void
		{
			advanceState(ROAM_STATE);
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
				case GONE_STATE:
					startGoneState();
					break;	
				default: throw new Error('no state to advance to!');	
			}
		}	
		
		public function set myWorld(val:World):void
		{
			if(!_myWorld)
			{
				_myWorld = val;
			}
			else
			{	
//				throw new Error("Where's the world?");
			}	
		}
		
		public function get myWorld():World
		{
			return _myWorld;
		}	
		
		public function set concertStage(val:ConcertStage):void
		{
			if(!_concertStage)
				_concertStage = val;
			else
				throw new Error("Where's the world?");
		}
		
		public function get concertStage():ConcertStage
		{
			return _concertStage;
		}								
				
	}
}