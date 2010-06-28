package rock_on
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;

	public class Passerby extends Person
	{
		public static const ROAM_STATE:int = 1;
		public static const ROUTE_STATE:int = 2;
		public static const GONE_STATE:int = 3;
		public static const ENTHRALLED_STATE:int = 4;
		public static const REMOVE_STATE:int = 5;
		
		public var _listeningStationBoss:ListeningStationBoss;
		public var _passerbyManager:PasserbyManager;
		public var _venue:Venue;
		
		public var testTimer:Timer;
		public var testTime:int = 500;
		public var slatedForRemoval:Boolean;
				
		public function Passerby(movieClipStack:MovieClip, listeningStationBoss:ListeningStationBoss, passerbyManager:PasserbyManager, myWorld:World, venue:Venue, layerableOrder:Array=null, creature:Creature=null, personScale:Number=1, source:Array=null)
		{
			super(movieClipStack, layerableOrder, creature, personScale, source);
			_listeningStationBoss = listeningStationBoss;
			_passerbyManager = passerbyManager;
			_venue = venue;
			_myWorld = myWorld;
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
				case GONE_STATE:
					doGoneState(deltaTime);
					return true;	
				case REMOVE_STATE:
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
				case GONE_STATE:
					break;					
				case REMOVE_STATE:
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
				case GONE_STATE:
					startGoneState();
					break;	
				case REMOVE_STATE:
					startRemoveState();
					break;	
				default: throw new Error('no state to advance to!');	
			}
		}				
		
		public function startRouteState():void
		{
			state = ROUTE_STATE;
			
			var destination:Point3D = setInitialDestination();
			moveCustomer(destination);		
			
//			testTimer = new Timer(testTime);
//			testTimer.start();
//			testTimer.addEventListener(TimerEvent.TIMER, onTestComplete);
		}
		
		public function onTestComplete(evt:TimerEvent):void
		{
			advanceState(REMOVE_STATE);
		}
		
		public function startRemoveState():void
		{
			state = REMOVE_STATE;
		}
		
		public function endRouteState():void
		{
			
		}
		
		public function doRouteState(deltaTime:Number):void
		{
			
		}
		
		public function startEnthralledState():void
		{
			
		}
		
		public function endEnthralledState():void
		{
			
		}
		
		public function doEnthralledState(deltaTime:Number):void
		{
			
		}
		
		public function setInitialDestination():Point3D
		{
			var occupiedSpaces:ArrayCollection = _myWorld.pathFinder.updateOccupiedSpaces(true, true);
			var destination:Point3D;
			
			do
			{
				destination = tryDestination();
			}	
			while (occupiedSpaces.contains(_myWorld.pathFinder.mapPointToPathGrid(destination)) || isAnyoneElseThere(destination));		
				
			return destination;
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
			var destinationLocation:Point3D;
			if (worldCoords.z == 0)
			{
				destinationLocation = new Point3D(_myWorld.tilesWide - Math.round(Math.random() * (_myWorld.tilesWide - _venue.venueRect.right)), 0, _myWorld.tilesDeep);			
			}
			else
			{
				destinationLocation = new Point3D(_myWorld.tilesWide - Math.round(Math.random() * (_myWorld.tilesWide - _venue.venueRect.right)), 0, 0)
			}
			return destinationLocation;	
		}			
	}
}