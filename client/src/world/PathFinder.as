package world
{
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import rock_on.Person;
	
	import views.AssetBitmapData;

	public class PathFinder extends ArrayCollection
	{
		public var pathGrid:ArrayCollection;
		[Bindable] public var _world:World;
		
		public function PathFinder(world:World, source:Array=null)
		{
			super(source);
			_world = world;
			createPathGrid();
		}
		
		public function add(asset:ActiveAsset, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exemptStructures:ArrayCollection=null):ArrayCollection
		{
			addItem(asset);
			var assetPathFinder:ArrayCollection = calculatePathGrid(asset, asset.lastWorldPoint, asset.worldDestination, avoidStructures, avoidPeople, exemptStructures);
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
		
		private function initializePath(destination:Point3D):ArrayCollection
		{
			var assetPathFinder:ArrayCollection = new ArrayCollection();
			var tempArray:Array = new Array();
			tempArray[0] = pathGrid[destination.x][destination.y][destination.z];
			assetPathFinder.addItemAt(tempArray, 0);	
			return assetPathFinder;		
		}
		
		private function initializeUnorganizedPoints(destination:Point3D):ArrayCollection
		{
			var unorganizedPoints:ArrayCollection = new ArrayCollection();
			var tempArray:Array = new Array();
			tempArray[0] = pathGrid[destination.x][destination.y][destination.z];
			unorganizedPoints.addItem(tempArray[0]);
			return unorganizedPoints;			
		}
		
		public function validateDestination(asset:ActiveAsset, destination:Point3D, occupiedSpaces:ArrayCollection):void
		{
			if (!asset.worldDestination)
			{
//				throw new Error("No destination specified");
			}
			else if (occupiedSpaces.contains(pathGrid[asset.worldDestination.x][asset.worldDestination.y][asset.worldDestination.z]))
			{
				var tempPoint:Point3D = pathGrid[asset.worldDestination.x][asset.worldDestination.y][asset.worldDestination.z];
				throw new Error("Destination is currently occupied");
			}			
		}
		
		public function getNeighboringPoints(assetPathFinder:ArrayCollection, index:int, occupiedSpaces:ArrayCollection, unorganizedPoints:ArrayCollection):Array
		{	
			var coordsArray:Array = new Array();
			var pt:Point3D;
			var hasAvailableNextPoint:Boolean = false;
			for (var i:int = 0; i < assetPathFinder[index-1].length; i++)
			{
				var reference:Point3D = assetPathFinder[index-1][i];
				pt = getNeighbor('top', reference);
				if (pt != null && checkIfValid(pt, occupiedSpaces, unorganizedPoints))
				{
					coordsArray.push(pt);
					unorganizedPoints.addItem(pt);					
				}	
				pt = getNeighbor('bottom', reference);
				if (pt != null && checkIfValid(pt, occupiedSpaces, unorganizedPoints))
				{
					coordsArray.push(pt);
					unorganizedPoints.addItem(pt);					
				}	
				pt = getNeighbor('left', reference);
				if (pt != null && checkIfValid(pt, occupiedSpaces, unorganizedPoints))
				{
					coordsArray.push(pt);
					unorganizedPoints.addItem(pt);					
				}
				pt = getNeighbor('right', reference);
				if (pt != null && checkIfValid(pt, occupiedSpaces, unorganizedPoints))
				{
					coordsArray.push(pt);
					unorganizedPoints.addItem(pt);					
				}
				if (coordsArray)
				{
					hasAvailableNextPoint = true;
				}
				
			}
			if (!hasAvailableNextPoint)
			{
				// This needs decent handling
				
				throw new Error("No available next point");
			}
			return coordsArray;			
		}
		
		private function isStartPointReached(coordsArray:Array, startPoint:Point3D):Boolean
		{
			for each (var pt:Point3D in coordsArray)
			{
				if (pt == startPoint)
				{
					return true;
				}
				if (pt.x == startPoint.x && pt.y == startPoint.y && pt.z == startPoint.z)
				{
					trace ("Start point found, different instance");
					return true;
				}
			}
			return false;
		}
		
		public function calculatePathGrid(asset:ActiveAsset, currentPoint:Point3D, destination:Point3D, careAboutStructureOccupiedSpaces:Boolean=true, careAboutPeopleOccupiedSpaces:Boolean=false, exemptStructures:ArrayCollection=null):ArrayCollection
		{
			var pathGridComplete:Boolean = false;
			
			var assetPathFinder:ArrayCollection = initializePath(destination);
			var unorganizedPoints:ArrayCollection = initializeUnorganizedPoints(destination);
			
			var occupiedSpaces:ArrayCollection = updateOccupiedSpaces(careAboutPeopleOccupiedSpaces, careAboutStructureOccupiedSpaces, exemptStructures);
			validateDestination(asset, destination, occupiedSpaces);		
			
			var startPoint:Point3D = mapPointToPathGrid(currentPoint);
			var startPointReached:Boolean = false;
			var index:int = 1;
			
			// Until I add a point that's the same as my start point, keep adding points to the list
			
			if (currentPoint.x == destination.x && currentPoint.y == destination.y && currentPoint.z == destination.z)
			{
				
			}
			else
			{
				do
				{
					var coordsArray:Array = getNeighboringPoints(assetPathFinder, index, occupiedSpaces, unorganizedPoints);
					startPointReached = isStartPointReached(coordsArray, startPoint);
					if (startPointReached)
					{
						coordsArray = new Array();
						coordsArray.push(startPoint);
					}
					assetPathFinder.addItemAt(coordsArray, index);
					index++;			
					if (index > 100)
					{
						throw new Error("You're fucked");
						break;
					}
				}
				while (!startPointReached);
			}
			
			
			return assetPathFinder;		
		}	
		
		public function establishOwnedStructures():ArrayCollection
		{
			var occupiedStructures:ArrayCollection = new ArrayCollection();
			for each (var os:OwnedStructure in FlexGlobals.topLevelApplication.gdi.structureManager.owned_structures)
			{
				addToOccupiedSpaces(os);
			}
			return occupiedStructures;
		}
		
		public function establishPeopleOccupiedSpaces():ArrayCollection
		{
			var peopleOccupiedSpaces:ArrayCollection = getPeopleOccupiedSpacesForArray(_world.assetRenderer.unsortedAssets);
			if (_world.bitmapBlotter)
			{
				peopleOccupiedSpaces.addAll(getPeopleOccupiedSpacesForBitmap(_world.bitmapBlotter.bitmapReferences));			
			}
			return peopleOccupiedSpaces;
		}
		
		public function getPeopleOccupiedSpacesForArray(sourceArray:ArrayCollection):ArrayCollection
		{
			var peopleOccupiedSpaces:ArrayCollection = new ArrayCollection();
			for each (var asset:ActiveAsset in sourceArray)
			{
				if (asset is Person)
				{
					peopleOccupiedSpaces.addItem(getPoint3DForPerson(asset));
				}
			}
			return peopleOccupiedSpaces;
		}
		
		public function getPeopleOccupiedSpacesForBitmap(sourceArray:ArrayCollection):ArrayCollection
		{
			var peopleOccupiedSpaces:ArrayCollection = new ArrayCollection();
			for each (var abd:AssetBitmapData in sourceArray)
			{
				var asset:ActiveAsset = abd.activeAsset;
				if (asset is Person)
				{
					peopleOccupiedSpaces.addItem(getPoint3DForPerson(asset));
				}
			}
			return peopleOccupiedSpaces;
		}
		
		public function updateOccupiedSpaces(getPeopleOccupiedSpaces:Boolean, getStructureOccupiedSpaces:Boolean, exemptStructures:ArrayCollection=null):ArrayCollection
		{
			var allOccupiedSpaces:ArrayCollection = new ArrayCollection();
			var pt:Point3D;
			if (getStructureOccupiedSpaces)
			{
				var structureOccupiedSpaces:ArrayCollection = establishStructureOccupiedSpaces(exemptStructures);
//				Alert.show("sos: " + structureOccupiedSpaces.length.toString());
				for each (pt in structureOccupiedSpaces)
				{
					allOccupiedSpaces.addItem(pt);
				}			
			}
			if (getPeopleOccupiedSpaces)
			{
				var peopleOccupiedSpaces:ArrayCollection = establishPeopleOccupiedSpaces();	
//				Alert.show("pos: " + peopleOccupiedSpaces.length.toString());				
				for each (pt in peopleOccupiedSpaces)
				{
					allOccupiedSpaces.addItem(pt);
				}		
			}
			validateOccupiedSpaces(allOccupiedSpaces);
			return allOccupiedSpaces;
		}
		
		public function validateOccupiedSpaces(occupiedSpaces:ArrayCollection):void
		{
			if (occupiedSpaces.length >= _world.tilesDeep*_world.tilesWide)
			{
				throw new Error("No free spaces! That's crazy pills! total spaces: " + _world.tilesDeep.toString() + "::" + _world.tilesWide.toString());
			}			
		}
		
		public function establishStructureOccupiedSpaces(exemptStructures:ArrayCollection=null):ArrayCollection
		{
			var structureOccupiedSpaces:ArrayCollection = getStructureOccupiedSpacesForArray(_world.assetRenderer.unsortedAssets, exemptStructures);
			if (_world.bitmapBlotter)
			{
				structureOccupiedSpaces.addAll(getStructureOccupiedSpacesForBitmap(_world.bitmapBlotter.bitmapReferences, exemptStructures));			
			}
			return structureOccupiedSpaces;
		}
		
		private function getStructureOccupiedSpacesForBitmap(sourceArray:ArrayCollection, exemptStructures:ArrayCollection):ArrayCollection
		{
			var structureOccupiedSpaces:ArrayCollection = new ArrayCollection();
			var structureSpaces:ArrayCollection;	
			
			for each (var abd:AssetBitmapData in sourceArray)
			{				
				// Check if the owned structures in exemptStructures equal asset.thinger; if so, do not add them
				
				var asset:ActiveAsset = abd.activeAsset;
				if (asset.thinger is OwnedStructure)
				{
					if (!exemptStructures)
					{
						structureSpaces = addToOccupiedSpaces(asset.thinger as OwnedStructure);						
					}
					else
					{
						for each (var os:OwnedStructure in exemptStructures)
						{
							if (!(os.id == (asset.thinger as OwnedStructure).id && os.structure == (asset.thinger as OwnedStructure).structure))
							{
								structureSpaces = addToOccupiedSpaces(asset.thinger as OwnedStructure);							
							}
						}
					}		
					for each (var pt:Point3D in structureSpaces)
					{
						structureOccupiedSpaces.addItem(pt);
					}
				}
			}
			return structureOccupiedSpaces;			
		}
		
		private function getStructureOccupiedSpacesForArray(sourceArray:ArrayCollection, exemptStructures:ArrayCollection=null):ArrayCollection
		{	
			var structureOccupiedSpaces:ArrayCollection = new ArrayCollection();
			var structureSpaces:ArrayCollection;	
			
			for each (var asset:ActiveAsset in sourceArray)
			{				
				// Check if the owned structures in exemptStructures equal asset.thinger; if so, do not add them
				
				if (asset.thinger is OwnedStructure)
				{
					if (!exemptStructures)
					{
						structureSpaces = addToOccupiedSpaces(asset.thinger as OwnedStructure);						
					}
					else
					{
						for each (var os:OwnedStructure in exemptStructures)
						{
							if (!(os.id == (asset.thinger as OwnedStructure).id && os.structure == (asset.thinger as OwnedStructure).structure))
							{
								structureSpaces = addToOccupiedSpaces(asset.thinger as OwnedStructure);							
							}
						}
					}		
					for each (var pt:Point3D in structureSpaces)
					{
						structureOccupiedSpaces.addItem(pt);
					}
				}
			}
			return structureOccupiedSpaces;
		}
		
		private function addToOccupiedSpaces(os:OwnedStructure):ArrayCollection
		{
			var structureSpaces:ArrayCollection = new ArrayCollection();			
			structureSpaces = getPoint3DForStructure(os, structureSpaces);
			return structureSpaces;
		}
		
		public function getPoint3DForStructure(os:OwnedStructure, structureSpaces:ArrayCollection):ArrayCollection
		{
			// Does not count height			
			for (var xPt:int = 0; xPt < os.structure.width; xPt++)
			{
				for (var zPt:int = 0; zPt < os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = pathGrid[os.x + xPt][0][os.z + zPt];
					structureSpaces.addItem(osPt3D);										
				}
			}
			if (!os.structure.width || !os.structure.depth)
			{
				throw new Error("No dimensions specified for structure");
			} 
			
			return structureSpaces;
		}
		
		public function getPoint3DForMovingStructure(asset:ActiveAsset, os:OwnedStructure, structureSpaces:ArrayCollection):ArrayCollection
		{
			// Does not count height			
			for (var xPt:int = 0; xPt < os.structure.width; xPt++)
			{
				for (var zPt:int = 0; zPt < os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = pathGrid[asset.worldCoords.x + xPt][0][asset.worldCoords.z + zPt];
					structureSpaces.addItem(osPt3D);										
				}
			}
			if (!os.structure.width || !os.structure.depth)
			{
				throw new Error("No dimensions specified for structure");
			} 
			
			return structureSpaces;
		}
		
		private function getPoint3DForPerson(asset:ActiveAsset):Point3D
		{
			var osPt3D:Point3D;
			if (asset.worldDestination)
			{
				osPt3D = pathGrid[asset.worldDestination.x][0][asset.worldDestination.z];
				return osPt3D;
			}
			else if (asset.worldCoords)
			{
				osPt3D = pathGrid[asset.worldCoords.x][0][asset.worldCoords.z];
				return osPt3D;
			}
			return null;
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
		
		private function checkIfValid(pt:Point3D, occupiedSpaces:ArrayCollection, unorganizedPoints:ArrayCollection):Boolean
		{
//			// Checks to see whether the point has been added already
//			
//			for each (var coordsArray:Array in assetPathFinder)
//			{
//				for each (var pt2:Point3D in coordsArray)
//				{
//					if (pt2.x == pt.x && pt2.y == pt.y && pt2.z == pt.z)
//					{
//						return false;
//						trace("Already added this point");
//					}
//				}
//			}			
			if (unorganizedPoints.contains(pt))
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