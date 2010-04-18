package world
{
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	import rock_on.Person;

	public class PathFinder extends ArrayCollection
	{
		public var pathGrid:ArrayCollection;
		[Bindable] public var _world:World;
		public var occupiedSpaces:ArrayCollection;
		
		public function PathFinder(world:World, source:Array=null)
		{
			super(source);
			_world = world;
			createPathGrid();
			
			occupiedSpaces = new ArrayCollection();
		}
		
		public function add(asset:ActiveAsset, exemptStructures:ArrayCollection=null):ArrayCollection
		{
			addItem(asset);
			var assetPathFinder:ArrayCollection = calculatePathGrid(asset, exemptStructures);
			var finalPath:ArrayCollection = determinePath(asset, assetPathFinder);
			return finalPath;
		}
		
		public function remove(asset:ActiveAsset):void
		{
			var index:Number = getItemIndex(asset);
			removeItemAt(index);
		}
		
		public function createPathGrid():void
		{
			pathGrid = new ArrayCollection();
			
			var depthRow:ArrayCollection = new ArrayCollection();
			var heightRow:ArrayCollection = new ArrayCollection();
		
			for (var i:int = 0; i<=_world.tilesWide; i++)
			{
				heightRow = new ArrayCollection();
				for (var j:int = 0; j<1; j++)
				{
					depthRow = new ArrayCollection();
					for (var k:int = 0; k<=_world.tilesDeep; k++)
					{
						var pt:Point3D = new Point3D(i, j, k);
						depthRow.addItem(pt);						
					}
					heightRow.addItem(depthRow);
				}
				pathGrid.addItem(heightRow);
			}
		}	
		
		public function calculatePathGrid(asset:ActiveAsset, exemptStructures:ArrayCollection=null):ArrayCollection
		{
			var pathGridComplete:Boolean = false;
			var assetPathFinder:ArrayCollection = new ArrayCollection();
			var unorganizedPoints:ArrayCollection = new ArrayCollection();
			var tileArray:Array = new Array();
			
			tileArray[0] = pathGrid[asset.worldDestination.x][asset.worldDestination.y][asset.worldDestination.z];
			assetPathFinder.addItemAt(tileArray, 0);
			unorganizedPoints.addItem(tileArray[0]);
			
			var currentlyOccupiedSpaces:ArrayCollection = new ArrayCollection();
			if (exemptStructures == null)
			{
				establishOccupiedSpaces(null);
				currentlyOccupiedSpaces = occupiedSpaces;
			}
			else
			{
				
			}
			
			if (currentlyOccupiedSpaces.contains(pathGrid[asset.worldDestination.x][asset.worldDestination.y][asset.worldDestination.z]))
			{
				throw new Error("Destination location is currently occupied");
			}
			
			var i:int = 1;
			while (true)
			{
				tileArray = new Array();
				var pt:Point3D;
				for (var j:int = 0; j<assetPathFinder[i-1].length; j++)
				{
					var reference:Point3D = assetPathFinder[i-1][j];
					pt = getNeighbor('top', reference);
					if (pt != null && checkIfValid(pt, unorganizedPoints, currentlyOccupiedSpaces, asset.world))
					{
						tileArray.push(pt);
						unorganizedPoints.addItem(pt);
					}	
					pt = getNeighbor('bottom', reference);
					if (pt != null && checkIfValid(pt, unorganizedPoints, currentlyOccupiedSpaces, asset.world))
					{
						tileArray.push(pt);
						unorganizedPoints.addItem(pt);					
					}	
					pt = getNeighbor('left', reference);
					if (pt != null && checkIfValid(pt, unorganizedPoints, currentlyOccupiedSpaces, asset.world))
					{
						tileArray.push(pt);
						unorganizedPoints.addItem(pt);					
					}
					pt = getNeighbor('right', reference);
					if (pt != null && checkIfValid(pt, unorganizedPoints, currentlyOccupiedSpaces, asset.world))
					{
						tileArray.push(pt);
						unorganizedPoints.addItem(pt);						
					}
				}
				for (var k:int = 0; k<tileArray.length; k++)
				{				
					if (tileArray[k].x == asset.lastWorldPoint.x && tileArray[k].y == asset.lastWorldPoint.y && tileArray[k].z == asset.lastWorldPoint.z)
					{
						tileArray = new Array();
						tileArray[0] = asset.lastWorldPoint;
						assetPathFinder.addItemAt(tileArray, i);
						pathGridComplete = true;
					}
				}
				if (asset.lastWorldPoint.x == asset.worldDestination.x && asset.lastWorldPoint.y == asset.worldDestination.y && asset.lastWorldPoint.z == asset.worldDestination.z)
				{
					throw new Error('Destination is the same as origin!');
				}
				if (pathGridComplete)
				{
					break;
				}
				assetPathFinder.addItemAt(tileArray, i);
				i++;
				if (i > 100)
				{
					throw new Error("You're fucked");
					return null;
				}
			}
			return assetPathFinder;			
		}	
		
		public function establishOwnedStructures():void
		{
			occupiedSpaces = new ArrayCollection();
			for each (var os:OwnedStructure in Application.application.gdi.structureManager.owned_structures)
			{
				addToOccupiedSpaces(os);
			}
		}
		
		public function establishPeopleOccupiedSpaces():ArrayCollection
		{
			var peopleOccupiedSpaces:ArrayCollection = new ArrayCollection();
			for each (var asset:ActiveAsset in _world.assetRenderer.sortedAssets)
			{
				if (asset is Person)
				{
					peopleOccupiedSpaces.addItem(getPoint3DForPerson(asset));
				}
			}
			return peopleOccupiedSpaces;
		}
		
		private function establishOccupiedSpaces(exemptStructures:ArrayCollection=null):void
		{
			occupiedSpaces = new ArrayCollection();
			for each (var asset:ActiveAsset in _world.assetRenderer.sortedAssets)
			{
				if (asset.thinger is OwnedStructure && exemptStructures == null)
				{
					addToOccupiedSpaces(asset.thinger as OwnedStructure);	
				}
				else if (asset.thinger is OwnedStructure && exemptStructures)
				{
					if (!exemptStructures.contains(asset.thinger))
					{
						addToOccupiedSpaces(asset.thinger as OwnedStructure);
					}
				}
			}	
		}
		
		private function addToOccupiedSpaces(os:OwnedStructure):void
		{
			getPoint3DForStructure(os);
		}
		
		private function getPoint3DForStructure(os:OwnedStructure):void
		{
			// Does not count height			
			for (var xPt:int = 0; xPt < os.structure.width; xPt++)
			{
				for (var zPt:int = 0; zPt < os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = pathGrid[os.x + xPt][0][os.z + zPt];
					occupiedSpaces.addItem(osPt3D);										
				}
			}
		}
		
		private function getPoint3DForPerson(asset:ActiveAsset):Point3D
		{
			var osPt3D:Point3D = pathGrid[asset.worldDestination.x][0][asset.worldDestination.z];
			return osPt3D;
//			occupiedSpaces.addItem(osPt3D);												
		}
				
		public function mapPointToPathGrid(point3D:Point3D):Point3D
		{
			return pathGrid[point3D.x][point3D.y][point3D.z];
		}
		
		private function determinePath(asset:ActiveAsset, pathGrid:ArrayCollection):ArrayCollection
		{
			var index:int = pathGrid.length - 1;
			var pt:Point3D = pathGrid[index][0];
			var tileArray:Array;
			var finalPath:ArrayCollection = new ArrayCollection();
			var foundValidPoint:Boolean = false;
			for (var i:int = (pathGrid.length-2); i>=0; i--)
			{
				foundValidPoint = false;
				tileArray = getSurroundingPoints(pt);
				for (var j:int = 0; j<tileArray.length; j++)
				{
					if (foundValidPoint == false)
					{
						for (var k:int = 0; k<(pathGrid[i] as Array).length; k++)
						{
							if ((tileArray[j] as Point3D).x == (pathGrid[i][k] as Point3D).x && (tileArray[j] as Point3D).y == (pathGrid[i][k] as Point3D).y && (tileArray[j] as Point3D).z == (pathGrid[i][k] as Point3D).z)
							{
								var validPoint:Point3D = tileArray[j];
								finalPath.addItem(validPoint);
							
								pt = validPoint;
								foundValidPoint = true;
							}
						}						
					}
					else
					{
						break;
					}
				}
			}
			return finalPath;
		}
		
		private function getNeighbor(direction:String, pt:Point3D):Point3D
		{
			var neighbor:Point3D;
			if (pt.x <= _world.tilesWide && pt.x >= 0 && pt.y >= 0 && pt.z <= _world.tilesDeep && pt.z >= 0)
			{			
				if (direction == 'top')
				{
					if (pt.z + 1 <= _world.tilesDeep)
					{
						neighbor = pathGrid[pt.x][pt.y][pt.z + 1];									
					}
				}
				else if (direction == 'bottom')
				{
					if (pt.z - 1 >= 0)
					{
						neighbor = pathGrid[pt.x][pt.y][pt.z - 1];					
					}
				}
				else if (direction == 'left')
				{
					if (pt.x + 1 <= _world.tilesWide)
					{					
						neighbor = pathGrid[pt.x + 1][pt.y][pt.z];
					}
				}
				else if (direction == 'right')
				{
					if (pt.x - 1 >= 0)
					{					
						neighbor = pathGrid[pt.x - 1][pt.y][pt.z];
					}
				}
			}	
			return neighbor;
		}
		
		private function checkIfValid(pt:Point3D, alreadyAdded:ArrayCollection, occupiedSpaces:ArrayCollection, assetWorld:World):Boolean
		{
//			if (pt.x > assetWorld.tilesWide || pt.z > assetWorld.tilesDeep || pt.x < 0 || pt.z < 0)
//			{
//				return false;
//			}
//			for each (var upt:Point3D in alreadyAdded)
//			{
//				if (upt.x == pt.x && upt.y == pt.y && upt.z == pt.z)
//				{
//					return false;
//				}
//			}
			if (alreadyAdded.contains(pt))
			{
				return false;
			}
			if (occupiedSpaces.contains(pt))
			{
				return false;
			}
			return true;
		}
		
		private function getSurroundingPoints(pt:Point3D):Array
		{
			var pointsArray:Array = new Array();
			var newPoint:Point3D;
			newPoint = new Point3D(pt.x + 1, pt.y, pt.z);
			pointsArray.push(newPoint);
			newPoint = new Point3D(pt.x - 1, pt.y, pt.z);
			pointsArray.push(newPoint);
			newPoint = new Point3D(pt.x, pt.y, pt.z + 1);
			pointsArray.push(newPoint);
			newPoint = new Point3D(pt.x, pt.y, pt.z - 1);
			pointsArray.push(newPoint);
			return pointsArray;
		}
		
		public function set world(val:World):void
		{
			_world = val;
		}
		
		public function get world():World
		{
			return _world;
		}
	}
}