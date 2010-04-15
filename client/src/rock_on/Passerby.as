package rock_on
{
	import flash.display.MovieClip;
	
	import models.Creature;
	
	import world.ActiveAsset;
	import world.Point3D;

	public class Passerby extends Person
	{
		public function Passerby(movieClipStack:MovieClip, layerableOrder:Array=null, creature:Creature=null, personScale:Number=1, source:Array=null)
		{
			super(movieClipStack, layerableOrder, creature, personScale, source);
		}
		
		override public function startEnterState():void
		{
			var destination:Point3D = setInitialDestination();
			movePerson(destination, true);				
		}
		
		override public function endEnterState():void
		{
			
		}
		
		public function setInitialDestination():Point3D
		{
			_myWorld.pathFinder.establishOwnedStructures();
			
			var destinationLocation:Point3D = tryDestination();			
			
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
			var destinationLocation:Point3D;
			if (worldCoords.z == 0)
			{
				destinationLocation = new Point3D(Math.floor(PasserbyManager.VENUE_BOUND_X + Math.random()*(_myWorld.tilesWide - PasserbyManager.VENUE_BOUND_X)), 0, _myWorld.tilesDeep);			
			}
			else
			{
				destinationLocation = new Point3D(Math.floor(PasserbyManager.VENUE_BOUND_X + Math.random()*(_myWorld.tilesWide - PasserbyManager.VENUE_BOUND_X)), 0, 0)
			}
			return destinationLocation;	
		}			
	}
}