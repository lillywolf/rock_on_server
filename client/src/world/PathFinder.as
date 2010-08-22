package world
{
	import flash.geom.Rectangle;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import rock_on.Person;
	
	import views.AssetBitmapData;

	public class PathFinder extends ArrayCollection
	{
		public var pathGrid:ArrayCollection;
		public var occupiedByStructures:ArrayCollection;
		public var occupiedByPeople:ArrayCollection;
		public var _world:World;
				
		public function PathFinder(world:World, worldHeight:int=0, source:Array=null)
		{
			super(source);
			_world = world;
			createPathGrid(worldHeight);
		}
		
		public function add(asset:ActiveAsset, fallBack:Boolean=false, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exemptStructures:ArrayCollection=null, heightBase:int=0, extraStructures:ArrayCollection=null):ArrayCollection
		{
			addItem(asset);
//			var assetPathFinder:ArrayCollection = calculatePathGrid(asset, asset.lastWorldPoint, asset.worldDestination, avoidStructures, avoidPeople, exemptStructures, extraStructures);
			var finalPath:ArrayCollection = calculateNaivePath(asset.lastWorldPoint, asset.worldDestination, avoidStructures, avoidPeople, exemptStructures, extraStructures);
			if (fallBack && (finalPath.length == 0 || !equivalent3DPoints(finalPath[finalPath.length-1], asset.worldDestination)))
				finalPath = calculateAStarPath(asset.lastWorldPoint, asset.worldDestination, avoidStructures, avoidPeople, exemptStructures, extraStructures);	
			else if (!fallBack && finalPath.length == 0)
				pathfindingFailed(asset);
			else if (!fallBack && isStandingOnPerson(asset, finalPath[finalPath.length-1]))
				tackOnAdditionalPath(asset, finalPath, avoidStructures, avoidPeople, exemptStructures, extraStructures, heightBase);
			else if (!fallBack && !equivalent3DPoints(finalPath[finalPath.length-1], asset.worldDestination))
				adjustAssetDestination(asset, finalPath);
			return finalPath;
		}
		
		private function tackOnAdditionalPath(asset:ActiveAsset, finalPath:ArrayCollection, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exempt:ArrayCollection=null, extra:ArrayCollection=null, heightBase:int=0):void
		{
//			var orientation:Object = getStartToEndOrientation(asset.lastWorldPoint, asset.worldDestination);						
			var destination:Point3D = pickNewDestination(finalPath[finalPath.length-1] as Point3D, avoidStructures, avoidPeople, exempt, extra, heightBase);
//			var additionalPath:ArrayCollection = calculateNaivePath(finalPath[finalPath.length-1] as Point3D, destination, avoidStructures, avoidPeople, exempt, extra);
			var additionalPath:ArrayCollection = calculateAStarPath(finalPath[finalPath.length-1] as Point3D, destination, avoidStructures, avoidPeople, exempt, extra);
			finalPath.addAll(additionalPath);
		}
		
		private function pickNewDestination(currentPoint:Point3D, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exempt:ArrayCollection=null, extra:ArrayCollection=null, heightBase:int=0):Point3D
		{
			var unwalkables:ArrayCollection = updateOccupiedSpaces(avoidPeople, avoidStructures, exempt, extra);
			var destination:Point3D = new Point3D(Math.round(Math.random()*_world.tilesWide), currentPoint.y, Math.round(Math.random()*_world.tilesDeep));		
			while (unwalkables.contains(mapPointToPathGrid(destination)))
			{
				destination = new Point3D(Math.round(Math.random()*_world.tilesWide), currentPoint.y, Math.round(Math.random()*_world.tilesDeep));		
			}
			return destination;
		}

		private function pickNewDestinationBasedOnOrientation(currentPoint:Point3D, orientation:Object, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exempt:ArrayCollection=null, extra:ArrayCollection=null, heightBase:int=0):Point3D
		{
			var unwalkables:ArrayCollection = updateOccupiedSpaces(avoidPeople, avoidStructures, exempt, extra);
			var destination:Point3D = getDestinationBasedOnOrientation(orientation, currentPoint); 
			while (unwalkables.contains(mapPointToPathGrid(destination)))
			{
				destination = getDestinationBasedOnOrientation(orientation, currentPoint);			
			}
			return destination;
		}
		
		private function getDestinationBasedOnOrientation(orientation:Object, currentPoint:Point3D):Point3D
		{
			var destination:Point3D = new Point3D(currentPoint.x, currentPoint.y, currentPoint.z);
			if (orientation.xSign > 0)
				destination.x = Math.round(Math.random()*currentPoint.x);
			else if (orientation.xSign < 0)
				destination.x = Math.round(currentPoint.x + Math.random()*(_world.tilesWide - currentPoint.x));
			else
				destination.x = Math.round(Math.random()*_world.tilesWide);
			if (orientation.zSign > 0)
				destination.z = Math.round(Math.random()*currentPoint.z);
			else if (orientation.zSign < 0)
				destination.z = Math.round(currentPoint.z + Math.random()*(_world.tilesDeep - currentPoint.z));
			else
				destination.z = Math.round(Math.random()*_world.tilesDeep);
			return destination;
		}
		
		private function isStandingOnPerson(asset:ActiveAsset, pt3D:Point3D):Boolean
		{
			for each (var a:ActiveAsset in this)
			{
				if (a != asset && equivalent3DPoints(a.worldCoords, pt3D))
					return true;
				if (a != asset && equivalent3DPoints(a.worldDestination, pt3D))
					return true;
			}
			return false;
		}
		
		private function pathfindingFailed(asset:ActiveAsset):void
		{
			var evt:WorldEvent = new WorldEvent(WorldEvent.PATHFINDING_FAILED, asset);
			asset.worldDestination = asset.worldCoords;
			this.dispatchEvent(evt);
		}
		
		private function adjustAssetDestination(asset:ActiveAsset, finalPath:ArrayCollection):void
		{
			asset.worldDestination = finalPath[finalPath.length-1];
		}
		
		
		public function remove(asset:ActiveAsset):void
		{
			if (this.contains(asset))
			{
				var index:Number = getItemIndex(asset);
				removeItemAt(index);
			}
		}
		
		public function createPathGrid(worldHeight:int=0):void
		{
			pathGrid = new ArrayCollection();
			addPlanesToPathGrid(worldHeight);
		}
		
		public function populateOccupiedSpaces():void
		{
			this.occupiedByStructures = establishStructureOccupiedSpaces();
		}
		
		private function addPlanesToPathGrid(worldHeight:int=0):void
		{
			var depthRow:ArrayCollection = new ArrayCollection();
			var widthRow:ArrayCollection = new ArrayCollection();
			var heightRow:ArrayCollection = new ArrayCollection();
			
			for (var i:int = 0; i<=_world.tilesWide; i++)
			{			
				widthRow = new ArrayCollection();
				for (var j:int = 0; j <= worldHeight; j++)
				{
					depthRow = new ArrayCollection();
					for (var k:int = 0; k<=_world.tilesDeep; k++)
					{
						var pt:Point3D = new Point3D(i, j, k);
						depthRow.addItem(pt);						
					}
					widthRow.addItem(depthRow);
				}
				pathGrid.addItem(widthRow);			
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
		
		private function getHScore(currentPoint:Point3D, destination:Point3D):Number
		{
			var hScore:Number = Math.abs(currentPoint.x - destination.x) + Math.abs(currentPoint.z - destination.z);
			return hScore;
		}
		
		private function getGScore(parentInfo:Object):Number
		{
			var gScore:Number = parentInfo.gScore + 1;
			return gScore;
		}
		
		private function addAStarNeighbor(neighbors:ArrayCollection, startingPoint:Point3D, destination:Point3D, currentPoint:Point3D, parentInfo:Object):void
		{
			var hScore:Number = getHScore(currentPoint, destination);
			var gScore:Number = getGScore(parentInfo);			
			neighbors.addItem({parentInfo: parentInfo, node: currentPoint, hScore: hScore, gScore: gScore});			
		}
		
		public function getAStarNeighbors(currentObject:Object, startingPt:Point3D, destination:Point3D, unwalkables:Array, closedList:ArrayCollection):ArrayCollection
		{
			var neighbors:ArrayCollection = new ArrayCollection();
			var pt:Point3D;
			pt = getNeighbor("top", currentObject.node);
			if (pt && pt.x < 14 && pt.z > 12)
				var blah:int = 0;
			if (pt && (!unwalkables[pt.x] || !unwalkables[pt.x][pt.y][pt.z]) && !closedList.contains(pt))
			{
				addAStarNeighbor(neighbors, startingPt, destination, pt, currentObject);
			}
			pt = getNeighbor("bottom", currentObject.node);
			if (pt && (!unwalkables[pt.x] || !unwalkables[pt.x][pt.y][pt.z]) && !closedList.contains(pt))
			{
				addAStarNeighbor(neighbors, startingPt, destination, pt, currentObject);			
			}
			pt = getNeighbor("right", currentObject.node);
			if (pt && (!unwalkables[pt.x] || !unwalkables[pt.x][pt.y][pt.z]) && !closedList.contains(pt))
			{
				addAStarNeighbor(neighbors, startingPt, destination, pt, currentObject);		
			}
			pt = getNeighbor("left", currentObject.node);
			if (pt && (!unwalkables[pt.x] || !unwalkables[pt.x][pt.y][pt.z]) && !closedList.contains(pt))
			{
				addAStarNeighbor(neighbors, startingPt, destination, pt, currentObject);
			}
			return neighbors;
		}
		
//		private function inClosedList(pt3D:Point3D, closedList:ArrayCollection):Boolean
//		{
//			for (var i:int = (closedList.length - 1); i >= 0; i--)
//			{
//				var obj:Object = closedList[i];
//				if (mapPointToPathGrid(pt3D) == mapPointToPathGrid(obj.node))
//					return true;
//			}
//			return false;
//		}
		
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
		
		public function createSeatingArrangement(bounds:Rectangle, stageBounds:Rectangle, totalSeats:int):ArrayCollection
		{
			trace("create seating arrangement");
			var seats:ArrayCollection = new ArrayCollection();
			var totalPoints:int = bounds.height * bounds.width;
			if (totalSeats < totalPoints)
			{
				// Subtract 2 to prevent overlap
				var dimension:int = stageBounds.top - bounds.top - 2;
				var seatsPerRow:int = Math.ceil(totalSeats / dimension);
				for (var i:int = 0; i < dimension; i++)
				{
					var rowSeats:ArrayCollection = new ArrayCollection();
					var orderedRowSeats:ArrayCollection = new ArrayCollection();
					var dist:int;
					for (var j:int = 0; j < seatsPerRow; j++)
					{
						var seatX:int;
						var seatY:int;
						do
						{
							if (Math.random() < 0.5)
							{
								seatX = stageBounds.right + 1 + i;
								seatY = bounds.bottom - Math.round(Math.random() * (stageBounds.height + i + 1));
								dist = seatY;
							}
							else
							{
								seatY = stageBounds.top - 1 - i;
								seatX = bounds.left + Math.round(Math.random() * (stageBounds.width + i + 1));
								dist = seatX;
							}	
							var reference:Point3D = this.pathGrid[seatX][0][seatY];
						}
						while (rowSeats.contains(reference));
								
						rowSeats.addItem(reference);
						orderedRowSeats.addItem({reference: reference, distance: dist});
//						seats.addItem(reference);
					}
					var sortField:SortField = new SortField("distance");
					sortField.numeric = true;
					var sort:Sort = new Sort();
					sort.fields = [sortField];
					orderedRowSeats.sort = sort;
					orderedRowSeats.refresh();
					for each (var obj:Object in orderedRowSeats)
					{
						seats.addItem(obj.reference);
					}
//					seats.addItem(rowSeats);
				}
			}
			else
			{
				throw new Error("Exceeds max capacity");
			}
			trace("seating created");
			return seats;		
		}
		
		public function getOuterPoints(selectedPoint:Point3D, bounds:Rectangle):int
		{
			var outsidePoints:int = 0;
			outsidePoints = ((bounds.right - selectedPoint.x) * bounds.height) + ((selectedPoint.z - bounds.top) * bounds.width);
			if (Math.abs(bounds.right - selectedPoint.x) > Math.abs(bounds.top - selectedPoint.z))
			{
				outsidePoints += bounds.right - selectedPoint.x;
			}
			else if (Math.abs(bounds.right - selectedPoint.x) < Math.abs(bounds.top - selectedPoint.z))
			{
				outsidePoints += bounds.top - selectedPoint.z;
			}
			return outsidePoints;
		}
		
		public function equivalent3DPoints(a:Point3D, b:Point3D):Boolean
		{
			return ((a.x == b.x) && (a.y == b.y) && (a.z == b.z)); 
		}
		
		public function calculateNaivePath(startingPoint:Point3D, destination:Point3D, avoidStructures:Boolean, avoidPeople:Boolean, exempt:ArrayCollection, extra:ArrayCollection):ArrayCollection
		{
			var newPoint:Point3D = new Point3D(startingPoint.x, startingPoint.y, startingPoint.z);
			var path:ArrayCollection = new ArrayCollection();
			var currentPoint:Point3D = new Point3D(startingPoint.x, startingPoint.y, startingPoint.z);
			var unwalkables:Array = getUnwalkables(avoidPeople, avoidStructures, exempt, extra);
			var orientation:Object = getStartToEndOrientation(startingPoint, destination);
			while (true)
			{
				newPoint.x = getXNeighbor(currentPoint, destination, orientation, unwalkables);
				
				if (newPoint.x == currentPoint.x)					
					newPoint.z = getZNeighbor(currentPoint, destination, orientation, unwalkables);
				
				if (newPoint.x == currentPoint.x && newPoint.z == currentPoint.z)
					return path;
				else
					path.addItem(new Point3D(newPoint.x, newPoint.y, newPoint.z));
				
				currentPoint.x = newPoint.x;
				currentPoint.y = newPoint.y;
				currentPoint.z = newPoint.z;
			}
			return null;
		}
		
		private function getXNeighbor(currentPoint:Point3D, destination:Point3D, orientation:Object, unwalkables:Object):int
		{
			var neighbor:Point3D;
			if (orientation.xSign > 0 && (destination.x - currentPoint.x > 0))
			{	
				neighbor = getNeighbor("left", currentPoint);
				if (!unwalkables[neighbor.x] || !unwalkables[neighbor.x][neighbor.y][neighbor.z])
					return neighbor.x;
				else
					return currentPoint.x;
			}	
			else if (orientation.xSign < 0 && (destination.x - currentPoint.x < 0))
			{	
				neighbor = getNeighbor("right", currentPoint);
				if (!unwalkables[neighbor.x] || !unwalkables[neighbor.x][neighbor.y][neighbor.z])
					return neighbor.x;
				else
					return currentPoint.x;
			}	
			return currentPoint.x;
		}

		private function getZNeighbor(currentPoint:Point3D, destination:Point3D, orientation:Object, unwalkables:Object):int
		{
			var neighbor:Point3D;
			if (orientation.zSign > 0 && (destination.z - currentPoint.z > 0))
			{	
				neighbor = getNeighbor("top", currentPoint);
				if (!unwalkables[neighbor.x] || !unwalkables[neighbor.x][neighbor.y][neighbor.z])
					return neighbor.z;
				else
					return currentPoint.z;
			}
			else if (orientation.zSign < 0 && (destination.z - currentPoint.z < 0))
			{	
				neighbor = getNeighbor("bottom", currentPoint);
				if (!unwalkables[neighbor.x] || !unwalkables[neighbor.x][neighbor.y][neighbor.z])
					return neighbor.z;
				else
					return currentPoint.z;
			}
			return currentPoint.z;
		}
		
		public function getStartToEndOrientation(startingPoint:Point3D, destination:Point3D):Object
		{
			var orientation:Object = new Object();
			if (destination.x - startingPoint.x > 0)
				orientation.xSign = 1;
			else if (destination.x - startingPoint.x < 0)
				orientation.xSign = -1;
			else
				orientation.xSign = 0;
			if (destination.z - startingPoint.z > 0)
				orientation.zSign = 1;
			else if (destination.z - startingPoint.z < 0)
				orientation.zSign = -1;
			else
				orientation.zSign = 0;
			return orientation;
		}
		
		public function calculateAStarPath(startingPoint:Point3D, destination:Point3D, avoidStructures:Boolean, avoidPeople:Boolean, exempt:ArrayCollection, extra:ArrayCollection):ArrayCollection
		{
			var closedList:ArrayCollection = new ArrayCollection();
			var openList:ArrayCollection = new ArrayCollection();
			var fauxOpenList:ArrayCollection = new ArrayCollection();
			var unwalkables:Array = getUnwalkables(avoidPeople, avoidStructures, exempt, extra);
			var lowestFScoreObject:Object;
			openList.addItem({parentInfo: null, node: startingPoint, hScore: getHScore(startingPoint, destination), gScore: 0}); //add starting point to open list
			fauxOpenList.addItem(startingPoint);
			while(openList.length != 0)  // quit if open list is emptied, ie. no path
			{
				lowestFScoreObject = getLowestFScore(openList);	//get the last/lowest FscoreObject from the open list
				var index:int = openList.getItemIndex(lowestFScoreObject);	
				openList.removeItemAt(index);
				fauxOpenList.removeItemAt(index); //remove the last object with the lowest Fscore from open list
				closedList.addItem(lowestFScoreObject);     //add that lowest FScoreObject to the closed List							
				if (equivalent3DPoints(closedList[closedList.length - 1].node, destination)) return determinePath(closedList); // exit while loop if we've hit the end
				var neighbors:ArrayCollection = updateAStarNeighbors(startingPoint, destination, unwalkables, openList, closedList, fauxOpenList);
			}
			return null;
		}
		
		private function updateAStarNeighbors(startingPt:Point3D, destination:Point3D, unwalkables:Array, openList:ArrayCollection, closedList:ArrayCollection, fauxOpenList:ArrayCollection):ArrayCollection
		{
			var neighbors:ArrayCollection = getAStarNeighbors(closedList[closedList.length-1], startingPt, destination, unwalkables, closedList);
			for each (var obj:Object in neighbors)    
			{
				if (!inOpenList(obj, fauxOpenList))   //for each neighbor that isn't yet on the open list
				{	
					openList.addItem(obj);
					fauxOpenList.addItem(obj.node);
				}
			}
			return neighbors;
		}
		
		private function inOpenList(obj:Object, fauxOpenList:ArrayCollection):Boolean
		{
			for (var i:int = (fauxOpenList.length - 1); i >= 0; i--)
			{
				var pt3D:Point3D = fauxOpenList[i];
				if (obj.node.x == pt3D.x &&
					obj.node.y == pt3D.y &&
					obj.node.z == pt3D.z)
					return true;
			}
			return false;
		}
		
		private function hasLowerFScore(obj:Object, closedList:ArrayCollection):Boolean
		{
			for each (var object:Object in closedList)
			{
				if (object.gScore + object.hScore < obj.gScore + obj.hScore)
					return false;
			}
			return true;
		}
		
		private function getLowestFScore(openList:ArrayCollection):Object
		{
			// This function finds the last node with the lowest F score in the open list
			// returns an object corresponding to that lowest node
			var lowest:Object = openList[openList.length-1];
			
			for (var i:int = 0; i < openList.length; i++)
			{
				if (openList[i].hScore + openList[i].gScore <= lowest.hScore + lowest.gScore)
					lowest = openList[i];
			}
			return lowest;
		}	
		
		public function calculateDepthFirstAStarPath(startingPoint:Point3D, destination:Point3D, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exemptStructures:ArrayCollection=null, extraStructures:ArrayCollection=null):ArrayCollection
		{
			var openList:ArrayCollection = new ArrayCollection();
			var closedList:ArrayCollection = new ArrayCollection();
			var unwalkables:Array = getUnwalkables(avoidPeople, avoidStructures, exemptStructures, extraStructures);
			var aStarInfo:ArrayCollection = new ArrayCollection();
			
			closedList.addItem(startingPoint);
			var startObject:Object = {parentInfo: null, node: startingPoint, hScore: null, gScore: 0};
			var nextObject:Object = calculateAStarNeighbors(startObject, startingPoint, destination, unwalkables, openList, closedList, aStarInfo);
			aStarInfo.addItem(startObject);
			aStarInfo.addItem(nextObject);
			
			while (!closedList.contains(mapPointToPathGrid(destination)))
			{	
				var newObject:Object = calculateAStarNeighbors(nextObject, startingPoint, destination, unwalkables, openList, closedList, aStarInfo);
				if (newObject)
				{
					nextObject = newObject;
					aStarInfo.addItem(newObject);
				}
				else
				{
					return aStarInfo;
				}
				if (closedList.length > 1000 || openList.length > 10000)
					throw new Error("Bad news");
			}
			return aStarInfo;
		}
		
		private function calculateAStarNeighbors(pointObject:Object, startingPoint:Point3D, destination:Point3D, unwalkables:Array, openList:ArrayCollection, closedList:ArrayCollection, aStarInfo:ArrayCollection):Object
		{
			var neighbors:ArrayCollection = getAStarNeighbors(pointObject, startingPoint, destination, unwalkables, closedList);
//			if (neighbors.length == 0)
//				throw new Error("Stuck, no open spaces to walk to");
			for each (var neighborObject:Object in neighbors)
			{
				if (!openList.contains(mapPointToPathGrid(neighborObject.node)))
					openList.addItem(mapPointToPathGrid(neighborObject.node as Point3D));
			}	
			var lowestNeighbor:Object = addLowestFScore(neighbors, startingPoint, pointObject, openList, closedList, aStarInfo);
			return lowestNeighbor;
		}
		
		private function addLowestFScore(neighbors:ArrayCollection, startingPoint:Point3D, pointObject:Object, openList:ArrayCollection, closedList:ArrayCollection, aStarInfo:ArrayCollection):Object
		{
			var lowestNeighbor:Object;
			for each (var neighborObject:Object in neighbors)
			{
//				if (!updateGScore(neighborObject, startingPoint))
//				{
//				updateGScore(neighborObject, closedList, aStarInfo);
				if (!lowestNeighbor || (openList.contains(neighborObject.node) && neighborObject.gScore + neighborObject.hScore) < (lowestNeighbor.gScore + lowestNeighbor.hScore))
					lowestNeighbor = neighborObject;
			}
			if (lowestNeighbor)
			{
				closedList.addItem(lowestNeighbor.node);
				var index:int = openList.getItemIndex(lowestNeighbor.node);
				openList.removeItemAt(index);
			}
			else
			{
//				lowestNeighbor = pointObject;
				return null;
			}
			return lowestNeighbor;
		}
		
		private function updateGScore(neighborData:Object, closedList:ArrayCollection, aStarInfo:ArrayCollection):Boolean
		{
//			var startingGScore:Number = Math.abs(startingPoint.x - (neighborData.node as Point3D).x) + Math.abs(startingPoint.z - (neighborData.node as Point3D).z);
//			if (neighborData.gScore > startingGScore)
//			{
//				neighborData.gScore = startingGScore;
//				return true;
//			}
			var neighbors:ArrayCollection = getAllNeighbors(neighborData.node);
			for each (var neighbor:Point3D in neighbors)
			{
				if (neighbor && !equivalent3DPoints(neighbor, closedList[closedList.length-1]) && closedList.contains(neighbor))
				{	
					var index:int = closedList.getItemIndex(neighbor);
					var newParent:Object = aStarInfo.getItemAt(index);
					neighborData.gScore = newParent.gScore + 1;
					neighborData.parentInfo = newParent;
				}
			}
			return false;
		}
		
		private function getAllNeighbors(pt3D:Point3D):ArrayCollection
		{
			var neighbors:ArrayCollection = new ArrayCollection();
			neighbors.addItem(getNeighbor("top", pt3D));
			neighbors.addItem(getNeighbor("bottom", pt3D));
			neighbors.addItem(getNeighbor("left", pt3D));
			neighbors.addItem(getNeighbor("right", pt3D));
			return neighbors;
		}
		
		public function calculatePathGrid(asset:ActiveAsset, currentPoint:Point3D, destination:Point3D, careAboutStructureOccupiedSpaces:Boolean=true, careAboutPeopleOccupiedSpaces:Boolean=false, exemptStructures:ArrayCollection=null, extraStructures:ArrayCollection=null):ArrayCollection
		{
			var pathGridComplete:Boolean = false;
			
			var assetPathFinder:ArrayCollection = initializePath(destination);
			var unorganizedPoints:ArrayCollection = initializeUnorganizedPoints(destination);
			
			var occupiedSpaces:ArrayCollection = updateOccupiedSpaces(careAboutPeopleOccupiedSpaces, careAboutStructureOccupiedSpaces, exemptStructures, extraStructures);
	
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
			for each (var asset:ActiveAsset in _world.assetRenderer.unsortedAssets)
			{
				if (asset.thinger)
				{
					if (asset.thinger is OwnedStructure)
					{
						addToOccupiedSpaces(asset.thinger as OwnedStructure);				
					}
				}
			}
			return occupiedStructures;
		}
		
		public function establishPeopleOccupiedSpaces():ArrayCollection
		{
//			trace("get people occupied spaces");
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

		private function addPointsTo3DObject(originalArray:ArrayCollection, addTo:Array):void
		{
			for each (var pt:Point3D in originalArray)
			{
//				if (addTo[pt.x] && addTo[pt.x][pt.y])
//					addTo[pt.x][pt.y][pt.z] = 1;
//				else
//				{
//					var zObj:Array = new Array();
//					zObj[pt.z] = 1;
//					var yObj:Array = new Array();
//					yObj[pt.y] = zObj; 
//					addTo[pt.x] = yObj;
//				}
				addTo[pt.x][pt.y][pt.z] = 1;
			}			
		}
		
		private function initializeOccupiedSpacesArray(heightBase:int):Array
		{
			var allOccupied:Array = new Array(_world.tilesWide);
			for (var x:int = 0; x <= _world.tilesWide; x++)
			{
				var yArray:Array = new Array(heightBase);
				var zArray:Array = new Array();
				for (var z:int = 0; z <= _world.tilesDeep; z++)
				{
					zArray[z] = 0;
				}
				yArray[heightBase] = zArray;
				allOccupied[x] = yArray;
			}
			return allOccupied;
		}
		
		public function getUnwalkables(avoidPeople:Boolean, avoidStructures:Boolean, exempt:ArrayCollection=null, extra:ArrayCollection=null, heightBase:int=0):Array
		{
			var allOccupied:Array = initializeOccupiedSpacesArray(heightBase);
			if (avoidStructures)
			{	
				var structureOccupied:ArrayCollection = this.getStructureOccupiedSpaces(exempt);
				addPointsTo3DObject(structureOccupied, allOccupied);
			}
			if (avoidPeople)
			{	
				var peopleOccupied:ArrayCollection = establishPeopleOccupiedSpaces();
				addPointsTo3DObject(peopleOccupied, allOccupied);
			}	
			if (extra)
			{
				var extraOccupied:ArrayCollection = getExtraOccupiedSpaces(extra);
				addPointsTo3DObject(extraOccupied, allOccupied);			
			}
			return allOccupied;
		}
		
		public function updateOccupiedSpaces(getPeopleOccupiedSpaces:Boolean, getStructureOccupiedSpaces:Boolean, exemptStructures:ArrayCollection=null, extraStructures:ArrayCollection=null):ArrayCollection
		{
			var allOccupiedSpaces:ArrayCollection = new ArrayCollection();
			var pt:Point3D;
			if (getStructureOccupiedSpaces)
			{
				var structureOccupiedSpaces:ArrayCollection = this.getStructureOccupiedSpaces(exemptStructures);
				allOccupiedSpaces.addAll(structureOccupiedSpaces);			
			}
			if (getPeopleOccupiedSpaces)
			{
				var peopleOccupiedSpaces:ArrayCollection = establishPeopleOccupiedSpaces();	
				allOccupiedSpaces.addAll(peopleOccupiedSpaces);		
			}
			if (extraStructures)
			{
				var extraOccupiedSpaces:ArrayCollection = getExtraOccupiedSpaces(extraStructures);
				allOccupiedSpaces.addAll(extraOccupiedSpaces);
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
		
		public function getStructureOccupiedSpaces(exemptStructures:ArrayCollection=null):ArrayCollection
		{
			var tempStructurePoints:ArrayCollection = this.occupiedByStructures;
			for each (var os:OwnedStructure in exemptStructures)
			{
				var points:ArrayCollection = this.addToOccupiedSpaces(os);
				for each (var pt3D:Point3D in points)
				{
					if (this.occupiedByStructures.contains(pt3D))
					{
						var index:int = tempStructurePoints.getItemIndex(pt3D);
						tempStructurePoints.removeItemAt(index);
					}
				}	
			}	
			return tempStructurePoints;
		}
		
		public function establishStructureOccupiedSpaces(exemptStructures:ArrayCollection=null):ArrayCollection
		{
			var structureOccupiedSpaces:ArrayCollection = getStructureOccupiedSpacesForArray(_world.assetRenderer.unsortedAssets, exemptStructures);
			return structureOccupiedSpaces;
		}
		
		public function updateStructureOccupiedSpaces(exemptStructures:ArrayCollection=null):void
		{
			this.occupiedByStructures = establishStructureOccupiedSpaces(exemptStructures);
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
		
		private function getExtraOccupiedSpaces(rectangles:ArrayCollection):ArrayCollection
		{
			var rectSpaces:ArrayCollection = new ArrayCollection();
			for each (var rect:Rectangle in rectangles)
			{
				rectSpaces.addAll(this.getEstimatedPoint3DForRectangle(rect));
			}
			return rectSpaces;
		}
		
		private function getStructureOccupiedSpacesForArray(sourceArray:ArrayCollection, exemptStructures:ArrayCollection=null):ArrayCollection
		{	
			var structureOccupiedSpaces:ArrayCollection = new ArrayCollection();
			
			for each (var asset:ActiveAsset in sourceArray)
			{				
				// Check if the owned structures in exemptStructures equal asset.thinger; if so, do not add them
				var structureSpaces:ArrayCollection = new ArrayCollection();	
				
				if (asset.thinger is OwnedStructure)
				{
					if (!exemptStructures)
					{
						structureSpaces = addToOccupiedSpaces(asset.thinger as OwnedStructure);						
					}
					else
					{
						var exempt:Boolean = false;
						
						for each (var os:OwnedStructure in exemptStructures)
						{
							if ((os.id == (asset.thinger as OwnedStructure).id) || (os.structure == (asset.thinger as OwnedStructure).structure))
							{
								exempt = true;
							}
						}
						if (!exempt)
						{
							structureSpaces = addToOccupiedSpaces(asset.thinger as OwnedStructure);														
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
			var structurePoints:ArrayCollection = getEstimatedPoint3DForStructure(os);
			return structurePoints;
		}
		
		public function getEstimatedPoint3DForStructure(os:OwnedStructure):ArrayCollection
		{
			// Does not count height			
			var structurePoints:ArrayCollection = getStructurePoints(os);
			return structurePoints;
		}
		
		public function getStructurePoints(os:OwnedStructure):ArrayCollection
		{
			var structurePoints:ArrayCollection = new ArrayCollection();
//			for (var xPt:int = Math.floor(os.x - os.structure.width/2); xPt < Math.ceil(os.x + os.structure.width/2); xPt++)
//			{
//				for (var zPt:int = Math.floor(os.z - os.structure.depth/2); zPt < Math.ceil(os.z + os.structure.depth/2); zPt++)
//				{
//					var osPt3D:Point3D = pathGrid[xPt][os.y][zPt];
//					structurePoints.addItem(osPt3D);										
//				}
//			}
			
			for (var xPt:int = 0; xPt <= os.structure.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = pathGrid[os.x - os.structure.width/2 + xPt][0][os.z - os.structure.depth/2 + zPt];
					structurePoints.addItem(osPt3D);										
				}
			}
						
			if (!os.structure.width || !os.structure.depth)
			{
//				throw new Error("No dimensions specified for structure");
			} 
			return structurePoints;
		}

		public function getEstimatedPoint3DForRectangle(rect:Rectangle, rectHeight:int=0):ArrayCollection
		{		
			var rectSpaces:ArrayCollection = new ArrayCollection();
			for (var xPt:int = rect.left; xPt <= rect.right; xPt++)
			{
				for (var zPt:int = rect.top; zPt <= rect.bottom; zPt++)
				{
					var osPt3D:Point3D = pathGrid[xPt][rectHeight][zPt];
					rectSpaces.addItem(osPt3D);										
				}
			}
			return rectSpaces;
		}

		public function getPoint3DForStructure(asset:ActiveAsset, structureSpaces:ArrayCollection):ArrayCollection
		{
			// Does not count height	
			
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			var bottomLeft:Point3D = _world.getWorldBoundsForAsset(asset);
			
			for (var xPt:int = bottomLeft.x; xPt < (bottomLeft.x + os.structure.width); xPt++)
			{
				for (var zPt:int = bottomLeft.z; zPt < (bottomLeft.z + os.structure.depth); zPt++)
				{
					var osPt3D:Point3D = pathGrid[xPt][os.y][zPt];
					structureSpaces.addItem(osPt3D);										
				}
			}
			if (!os.structure.width || !os.structure.depth)
			{
				throw new Error("No dimensions specified for structure");
			} 
			
			return structureSpaces;
		}
		
		public function getPoint3DForMovingStructure(asset:ActiveAsset):ArrayCollection
		{
			// Does not count height	
			
			var structurePoints:ArrayCollection = new ArrayCollection();
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			
			for (var xPt:int = 0; xPt <= os.structure.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(asset.worldCoords.x - os.structure.width/2 + xPt, 0, asset.worldCoords.z - os.structure.depth/2 + zPt);
					structurePoints.addItem(osPt3D);										
				}
			}
			if (!os.structure.width || !os.structure.depth)
			{
				throw new Error("No dimensions specified for structure");
			} 		
			return structurePoints;
		}
		
		private function getPoint3DForPerson(asset:ActiveAsset):Point3D
		{
			var osPt3D:Point3D;
			if (asset.worldDestination)
			{
				osPt3D = pathGrid[asset.worldDestination.x][asset.worldDestination.y][asset.worldDestination.z];
				return osPt3D;
			}
			else if (asset.worldCoords)
			{
				osPt3D = pathGrid[asset.worldCoords.x][asset.worldCoords.y][asset.worldCoords.z];
				return osPt3D;
			}
			return null;
		}
				
		public function mapPointToPathGrid(point3D:Point3D):Point3D
		{
//			if (point3D.x < 0 || point3D.y < 0 || point3D.z < 0)
//			{
//				return null;
//			}
//			if (pathGrid[point3D.x][point3D.y][point3D.z])
//			{
				return pathGrid[point3D.x][point3D.y][point3D.z];			
//			}
//			return null;
		}
		
		private function determinePath(possiblePoints:ArrayCollection):ArrayCollection
		{
			var index:int = possiblePoints.length - 1;
			var pointData:Object = possiblePoints[index];
			var tempPath:ArrayCollection = new ArrayCollection();
			var finalPath:ArrayCollection = new ArrayCollection();
			tempPath.addItem(pointData.node);
			while (pointData.parentInfo)
			{
				tempPath.addItem(pointData.parentInfo.node);
				pointData = pointData.parentInfo;
			}
			tempPath.removeItemAt(tempPath.length-1);
			for (var i:int = tempPath.length-1; i >= 0; i--)
			{
				finalPath.addItem(tempPath[i]);
			}
			if (finalPath.length == 0)
			{
				throw new Error("No path");
			}
			return finalPath;
		}
		
//		private function determinePath(asset:ActiveAsset, pathGrid:ArrayCollection):ArrayCollection
//		{
//			var index:int = pathGrid.length - 1;
//			var pt:Point3D = pathGrid[index][0];
//			var tileArray:Array;
//			var finalPath:ArrayCollection = new ArrayCollection();
//			var foundValidPoint:Boolean = false;
//			for (var i:int = (pathGrid.length-2); i>=0; i--)
//			{
//				foundValidPoint = false;
//				tileArray = getSurroundingPoints(pt);
//				for (var j:int = 0; j<tileArray.length; j++)
//				{
//					if (foundValidPoint == false)
//					{
//						for (var k:int = 0; k<(pathGrid[i] as Array).length; k++)
//						{
//							if ((tileArray[j] as Point3D).x == (pathGrid[i][k] as Point3D).x && (tileArray[j] as Point3D).y == (pathGrid[i][k] as Point3D).y && (tileArray[j] as Point3D).z == (pathGrid[i][k] as Point3D).z)
//							{
//								var validPoint:Point3D = tileArray[j];
//								finalPath.addItem(validPoint);
//							
//								pt = validPoint;
//								foundValidPoint = true;
//							}
//						}						
//					}
//					else
//					{
//						break;
//					}
//				}
//			}
//			return finalPath;
//		}
		
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