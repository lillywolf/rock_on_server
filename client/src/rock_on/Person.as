package rock_on
{
	import com.flashdynamix.motion.Tweensy;
	
	import fl.motion.easing.Bounce;
	
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import models.Creature;
	import models.EssentialModelReference;
	import models.OwnedLayerable;
	import models.OwnedStructure;
	import models.Usable;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	import views.BouncyBitmap;
	import views.ExpandingMovieclip;
	import views.HoverTextBox;
	
	import world.ActiveAssetStack;
	import world.MoodEvent;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;
	
	public class Person extends ActiveAssetStack
	{
		public var mood:Object;
		public var moodCursorID:int;
		public var moodClip:BouncyBitmap;		
		public var currentDirection:Point3D;
		public var proxiedDestination:Point3D;
		public var rectanglesToAvoid:ArrayCollection;
		
		public var _myWorld:World;
		public var _myStage:World;
		public var _stageManager:StageManager;
		
		public var personType:int;
		public static const STATIC:int = 0;
		public static const SUPER:int = 1;
		public static const MOVING:int = 2;		
		
		public function Person(creature:Creature, movieClip:MovieClip=null, layerableOrder:Array=null, scale:Number=1)
		{
			super(creature, movieClip, layerableOrder, scale);
		}
	
		public function generateMoodOverheadHover(mood:Object):MovieClip
		{
			if (mood.symbol_name)
			{
				var cursorClass:Class = getDefinitionByName(mood.symbol_name) as Class;
				var mc:MovieClip = new cursorClass() as MovieClip;
				mc.cacheAsBitmap = true;
				return mc;			
			}
			return null;
		}
		
		public function generateMoodCursor(mood:Object):MovieClip
		{
			if (mood.symbol_name)
			{
				var cursorClass:Class = getDefinitionByName(mood.symbol_name) as Class;			
				var mc:MovieClip = new cursorClass() as MovieClip;
				mc.cacheAsBitmap = true;
				return mc;
			}
			return null;
		}	
		
		public function generateMoodMessage():HoverTextBox
		{
			if (mood)
			{
				var hoverBox:HoverTextBox = new HoverTextBox(mood.message as String);
				return hoverBox;
			}
			return null;
		}
		
		public function startMood(mood:Object):void
		{
			var cursor:MovieClip = generateMoodOverheadHover(mood);
			moodClip = new BouncyBitmap(cursor, 0.75);
			moodClip.y = -(height + moodClip.height - 8);
			moodClip.x = -moodClip.width/4;
			handleMoodForStaticPeople(mood, moodClip);
			trace("mood started");
		}		
		
		public function handleMoodForStaticPeople(mood:Object, moodClip:BouncyBitmap):void
		{
			if (this.personType == Person.STATIC)
			{
				_myWorld.bitmapBlotter.addMoodToAssetBitmapData(this, mood, moodClip);
			}
			else
			{
				addChild(moodClip);
				var t:Timer = new Timer(Math.random() * 1000);
				t.addEventListener(TimerEvent.TIMER, onBounceWaitComplete);
				t.start();
			}
		}
		
		private function onBounceWaitComplete(evt:TimerEvent):void
		{
			moodClip.doBounce(20);
			var timer:Timer = evt.target as Timer;
			timer.removeEventListener(TimerEvent.TIMER, onBounceWaitComplete);
			timer = null;			
		}
		
		public function removeMoodClip():void
		{		
			if (contains(moodClip))
			{
				removeChild(moodClip);
			}
			else if (this.personType == Person.STATIC)
			{
				if (moodClip)
				{
					if (myWorld.contains(moodClip))
					{
						_myWorld.removeChild(moodClip);					
					}
				}
			}
		}
		
		public function endMood():void
		{
			mood = null;
			trace("mood ended");
		}		
		
		public function doMultipleAnimations(animations:Array):void
		{
			for each (var anim:String in animations)
			{
				doAnimation(anim, true);
			}
		}
		
		public function standFacingObject(os:OwnedStructure, frameNumber:int=0, strictFacing:Boolean=true):Object
		{
			var cornerMatrix:Dictionary = os.getCornerMatrix();
			var relationship:Array = getHorizontalAndVerticalRelationship(cornerMatrix);						
			_frameNumber = evaluateHorizontalAndVerticalRelationship(relationship, frameNumber, os, strictFacing);						
			var reflection:Boolean = getReflection(relationship);	
			var standAnimation:String = getStandAnimation(_frameNumber);
			stand(standAnimation, _frameNumber, relationship);
			return {frameNumber: _frameNumber, animation: standAnimation, reflection: reflection};			
		}
		
		public function getDirectionalRelationshipsArray():Array
		{
			var relationships:Array = new Array();
			relationships["horizontalRelationship"] = ["right", "left"];
			relationships["verticalRelationship"] = ["top", "bottom"];			
			return relationships;
		}		
		
		public function standFacingCurrentDirection():void
		{
			if (this.animation == "walk_away")
			{
				_frameNumber = 37;
				stand("stand_still_away", _frameNumber);
			}
			else
			{
				_frameNumber = 39;
				stand("stand_still_toward", _frameNumber);
			}
		}
		
		public function getStandAnimation(frameNumber:int):String
		{
			if (frameNumber == 37)
			{
				return "stand_still_away";
			}
			else if (frameNumber == 39)
			{
				return "stand_still_toward";
			}
			else
			{
				return null;
			}
		}
		
		public function getReflection(relationship:Array):Boolean
		{
			var reflection:Boolean = false;
			
			if (relationship["horizontalRelationship"] == "center" && relationship["verticalRelationship"] == "top")
			{
				reflection = true;
			}
			else if (relationship["horizontalRelationship"] != "center" && relationship["verticalRelationship"] == "top")
			{
				if (Math.random() < 0.5)
				{
					reflection = true;
				}
			}
			return reflection;
		}
		
		public function getHorizontalAndVerticalRelationship(cornerMatrix:Dictionary):Array
		{
			var relationship:Array = [];
			
			if (worldCoords.x < (cornerMatrix["topLeft"] as Point3D).x)
			{
				relationship["verticalRelationship"] = "bottom";
			}
			else if (worldCoords.x > (cornerMatrix["bottomLeft"] as Point3D).x)
			{
				relationship["verticalRelationship"] = "top";
			}
			else
			{
				relationship["verticalRelationship"] = "center";
			}
			
			if (worldCoords.z < (cornerMatrix["topLeft"] as Point3D).z)
			{
				relationship["horizontalRelationship"] = "left";
			}		
			else if (worldCoords.z > (cornerMatrix["topRight"] as Point3D).z)
			{
				relationship["horizontalRelationship"] = "right";
			}	
			else
			{
				relationship["horizontalRelationship"] = "center";
			}			
			return relationship;
		}
		
		public function evaluateHorizontalAndVerticalRelationship(relationship:Array, frameNumber:int=0, structure:*=null, strictFacing:Boolean=false):int
		{
			var rand:Number = Math.random();
			
			if (relationship["verticalRelationship"] == "bottom")
			{
				frameNumber = 39;
			}
			else if (relationship["horizontalRelationship"] == "left")
			{
				frameNumber = 37;
			}
			else if (relationship["verticalRelationship"] == "top")
			{
				frameNumber = 37;
			}
			else if (relationship["horizontalRelationship"] == "right")
			{
				frameNumber = 39;
			}
			else
			{
				throw new Error("You're in the middle of a structure");
			}
			return frameNumber;
		}	
		
		public function adjustScaleToSpatialRelationship(relationship:Array):void
		{
			if (relationship["verticalRelationship"] == "bottom")
			{
				changeScale(-(_scale), _scale);
			}
			else if (relationship["horizontalRelationship"] == "left")
			{
				changeScale(_scale, _scale);
			}
			else if (relationship["verticalRelationship"] == "top")
			{
				changeScale(-(_scale), _scale);
			}
			else if (relationship["horizontalRelationship"] == "right")
			{
				changeScale(_scale, _scale);
			}			
		}
		
		public function getClosestAvailableSpot(pt3D:Point3D):Point3D
		{
			var depthIndex:int = 1;
			var closestAvailableSpot:Point3D;
			do
			{
				var surroundingPoints:ArrayCollection = getSurroundingPointsLayer(depthIndex, pt3D);
				if (surroundingPoints.length > 0)
				{
					closestAvailableSpot = surroundingPoints.getItemAt(Math.floor(Math.random() * surroundingPoints.length)) as Point3D;
				}
				depthIndex++;
				if (depthIndex > 4)
				{
					break;
				}
			}
			while (!closestAvailableSpot);
			return closestAvailableSpot;
		}
		
		public function getSurroundingPointsLayer(depthIndex:int, pt3D:Point3D):ArrayCollection
		{
			var concentricArray:ArrayCollection = new ArrayCollection();
			var neighbor:Point3D;
			for (var i:int = 0; i < 2; i++)
			{
				for (var j:int = 0; j < (depthIndex * 2 + 1); j++)
				{
					neighbor = _myWorld.pathFinder.mapPointToPathGrid(new Point3D(pt3D.x - (depthIndex * (i * 2 - 1)), pt3D.y, pt3D.z - (depthIndex - j)));
					if (neighbor && !(_myWorld.pathFinder.establishStructureOccupiedSpaces() as ArrayCollection).contains(neighbor))
					{
						concentricArray.addItem(neighbor);					
					}
				}
			}
			for (i = 0; i < 2; i++)
			{
				for (j = 0; j < (depthIndex * 2 - 1); j++)
				{
					neighbor = _myWorld.pathFinder.mapPointToPathGrid(new Point3D(pt3D.x - (depthIndex - j), pt3D.y, pt3D.z - (depthIndex * (i * 2 - 1))));
					if (neighbor && !(_myWorld.pathFinder.establishStructureOccupiedSpaces() as ArrayCollection).contains(neighbor))
					{
						concentricArray.addItem(neighbor);					
					}					
				}
			}
			return concentricArray;
		}
		
		public function stand(animation:String, frameNumber:int, relationship:Array = null):void
		{
			doAnimation(animation, false, frameNumber);
			if (relationship)
			{
				adjustScaleToSpatialRelationship(relationship);						
			}
			switchToBitmap();
		}
		
		public function updateDestination(newDestination:Point3D):void
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
				if (occupiedSpaces.contains(_myWorld.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
				{
					nextPoint = new Point3D(Math.floor(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
				}
				_myWorld.moveAssetTo(this, nextPoint);
			}
			else if (directionality.x < 0)
			{
				nextPoint = new Point3D(Math.floor(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
				if (occupiedSpaces.contains(_myWorld.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
				{
					nextPoint = new Point3D(Math.ceil(worldCoords.x), Math.round(worldCoords.y), Math.round(worldCoords.z));
				}					
				_myWorld.moveAssetTo(this, nextPoint);
			}
			else if (directionality.z > 0)
			{
				nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.ceil(worldCoords.z));
				if (occupiedSpaces.contains(_myWorld.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
				{
					nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.floor(worldCoords.z));
				}					
				_myWorld.moveAssetTo(this, nextPoint);
			}
			else if (directionality.z < 0)
			{
				nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.floor(worldCoords.z));
				if (occupiedSpaces.contains(_myWorld.pathFinder.pathGrid[nextPoint.x][nextPoint.y][nextPoint.z]))
				{
					nextPoint = new Point3D(Math.round(worldCoords.x), Math.round(worldCoords.y), Math.ceil(worldCoords.z));
				}						
				_myWorld.moveAssetTo(this, nextPoint);					
//				_myWorld.assetRenderer.addEventListener(WorldEvent.DESTINATION_REACHED, onAdjustedForPathfinding);								
//				validatePoint(nextPoint);
			}
			else 
			{
				doNextActivityAfterAdjusting();				
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
			movePerson(proxiedDestination);
			proxiedDestination = null;
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
		
		public function onDirectionChanged(evt:WorldEvent):void
		{
			if (evt.activeAsset == this)
			{
				var nextPoint:Point3D = getNextPointAlongPath();
				setDirection(nextPoint);
			}
		}		
		
		public function movePerson(destination:Point3D, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exemptStructures:ArrayCollection=null, heightBase:int=0, extraStructures:ArrayCollection=null):void
		{
			if (worldCoords.x%1 == 0 && worldCoords.y%1 == 0 && worldCoords.z%1 == 0)
			{			
				_myWorld.moveAssetTo(this, destination, true, avoidStructures, avoidPeople, exemptStructures, heightBase, extraStructures);			
			}
			else
			{
//				throw new Error("Cannot move from non whole number coords");
			}
			
			if (currentPath)
			{
				var nextPoint:Point3D = getNextPointAlongPath();
				setDirection(nextPoint);			
			}			
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
						doAnimation("walk_toward", true);
					}
					else
					{
						doAnimation("walk_away", true);
					}
					changeScale(-(_scale), _scale);			
				}
					
				else if (Math.abs(xDiff) < Math.abs(yDiff))
				{
					if (yDiff > 0)
					{
						doAnimation("walk_away", true);
					}
					else
					{		
						doAnimation("walk_toward", true);	
					}
					changeScale(_scale, _scale);
				}
				else
				{				
				}
				currentDirection = destination;
			}
		}
		
		public function swapMovieClipsByOwnedLayerable(ol:OwnedLayerable, animation:String):void
		{
			
		}
		
		public function set myWorld(val:World):void
		{
			_myWorld = val;
		}
		
		public function get myWorld():World
		{
			return _myWorld;
		}
		
		public function set stageManager(val:StageManager):void
		{
			_stageManager = val;
		}
		
		public function get stageManager():StageManager
		{
			return _stageManager;
		}
		
	}
}