package world
{
	import flash.geom.Rectangle;
	
	import models.OwnedStructure;
	
	import mx.charts.AreaChart;
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
		public var occupiedByStructures:Array;
		public var occupiedByPeople:Array;
		public var _world:World;
				
		public function PathFinder(world:World, worldHeight:int=0, source:Array=null)
		{
			super(source);
			_world = world;
			createPathGrid(worldHeight);
		}
		
		public function add(asset:ActiveAsset, fallBack:Boolean=false, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exemptStructures:ArrayCollection=null, heightBase:int=0, extraStructures:ArrayCollection=null, skipAStar:Boolean=false):ArrayCollection
		{
			addItem(asset);
			var finalPath:ArrayCollection = calculateNaivePath(asset.lastWorldPoint, asset.worldDestination, avoidStructures, avoidPeople, exemptStructures, extraStructures);
			if (fallBack && (finalPath.length == 0 || !equivalent3DPoints(finalPath[finalPath.length-1], asset.worldDestination)) && !skipAStar)
				finalPath = calculateAStarPath(asset.lastWorldPoint, asset.worldDestination, avoidStructures, avoidPeople, exemptStructures, extraStructures);	
			else if (!fallBack && finalPath.length == 0)
				pathfindingFailed(asset);
			else if (!fallBack && isStandingOnPerson(asset, finalPath[finalPath.length-1]))
				tackOnAdditionalPath(asset, finalPath, avoidStructures, avoidPeople, exemptStructures, extraStructures, heightBase);
			else if (!fallBack && !equivalent3DPoints(finalPath[finalPath.length-1], asset.worldDestination))
				adjustAssetDestination(asset, finalPath);
			else if (fallBack && skipAStar)
				finalPath = calculatePathGrid(asset, asset.lastWorldPoint, asset.worldDestination, avoidStructures, avoidPeople, exemptStructures, extraStructures);
			return finalPath;
		}
		
		private function tackOnAdditionalPath(asset:ActiveAsset, finalPath:ArrayCollection, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exempt:ArrayCollection=null, extra:ArrayCollection=null, heightBase:int=0):void
		{
//			Pick a new point that isn't the last node in the finalPath array
			var destination:Point3D = pickNewDestination(finalPath[finalPath.length-1] as Point3D, avoidStructures, avoidPeople, exempt, extra, heightBase);			
			while (equivalent3DPoints(destination, finalPath[finalPath.length-1] as Point3D))
			{
				destination = pickNewDestination(finalPath[finalPath.length-1] as Point3D, avoidStructures, avoidPeople, exempt, extra, heightBase);			
			}
			var additionalPath:ArrayCollection = calculateAStarPath(finalPath[finalPath.length-1] as Point3D, destination, avoidStructures, avoidPeople, exempt, extra);
			if (additionalPath)
			{	
				finalPath.addAll(additionalPath);
				adjustAssetDestination(asset, additionalPath);
			}	
			else
				throw new Error("write a new escape");
		}
		
		private function pickNewDestination(currentPoint:Point3D, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exempt:ArrayCollection=null, extra:ArrayCollection=null, heightBase:int=0):Point3D
		{
			var unwalkables:Array = updateOccupiedSpaces(avoidPeople, avoidStructures, exempt, extra);
			var destination:Point3D = new Point3D(Math.round(Math.random()*_world.tilesWide), currentPoint.y, Math.round(Math.random()*_world.tilesDeep));		
			while (unwalkables[destination.x] && unwalkables[destination.x][destination.y] && unwalkables[destination.x][destination.y][destination.z])
			{
				destination = new Point3D(Math.round(Math.random()*_world.tilesWide), currentPoint.y, Math.round(Math.random()*_world.tilesDeep));		
			}
			return destination;
		}

		private function pickNewDestinationBasedOnOrientation(currentPoint:Point3D, orientation:Object, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exempt:ArrayCollection=null, extra:ArrayCollection=null, heightBase:int=0):Point3D
		{
			var unwalkables:Array = updateOccupiedSpaces(avoidPeople, avoidStructures, exempt, extra);
			var destination:Point3D = getDestinationBasedOnOrientation(orientation, currentPoint); 
			while (unwalkables[destination.x] && unwalkables[destination.x][destination.y] && unwalkables[destination.x][destination.y][destination.z])
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
			if (asset.thinger is OwnedStructure && this.occupiedByStructures)
				removeStructureUnwalkables(asset);
		}
		
		public function removeStructureUnwalkables(asset:ActiveAsset, maxHeight:int=0):void
		{
			for (var i:int = 0; i <= _world.tilesWide; i++)
			{
				if (this.occupiedByStructures[i])
				{
					for (var j:int = 0; j <= maxHeight; j++)
					{
						if (this.occupiedByStructures[i][j])
						{
							for (var k:int = 0; k <= _world.tilesDeep; k++)
							{
								if (this.occupiedByStructures[i][j][k] && this.occupiedByStructures[i][j][k] == asset)
									this.occupiedByStructures[i][j][k] = 0;
							}
						}
					}
				}
			}
		}
		
		public function addStructureUnwalkables(asset:ActiveAsset):void
		{
			var unwalkables:ArrayCollection = this.getStructurePointsWithBuffer(asset.thinger as OwnedStructure);
			for each (var pt:Point3D in unwalkables)
			{
				addPointTo3DArray(pt, asset, this.occupiedByStructures);
			}
		}
		
		public function createPathGrid(worldHeight:int=0):void
		{
			pathGrid = new ArrayCollection();
			addPlanesToPathGrid(worldHeight);
		}
		
		public function populateOccupiedSpaces():void
		{
			this.occupiedByStructures = getStructureOccupiedSpacesForArray(_world.assetRenderer.unsortedAssets);
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
		
		public function validateDestination(asset:ActiveAsset, destination:Point3D, occupiedSpaces:Array):void
		{
			if (!asset.worldDestination)
			{
//				throw new Error("No destination specified");
			}
			else if (occupiedSpaces[asset.worldDestination.x] &&
				occupiedSpaces[asset.worldDestination.x][asset.worldDestination.y] &&
				occupiedSpaces[asset.worldDestination.x][asset.worldDestination.y][asset.worldDestination.z])
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
		
		public function getAStarNeighbors(currentObject:Object, startingPt:Point3D, destination:Point3D, unwalkables:Array, closedList:Array):ArrayCollection
		{
			var neighbors:ArrayCollection = new ArrayCollection();
			var pt:Point3D;
			pt = getNeighbor("top", currentObject.node);
			if (pt && pt.x < 14 && pt.z > 12)
				var blah:int = 0;
			if (pt && (!unwalkables[pt.x] || !unwalkables[pt.x][pt.y][pt.z]) && (!closedList[pt.x] || !closedList[pt.x][pt.y][pt.z]))
			{
				addAStarNeighbor(neighbors, startingPt, destination, pt, currentObject);
			}
			pt = getNeighbor("bottom", currentObject.node);
			if (pt && (!unwalkables[pt.x] || !unwalkables[pt.x][pt.y][pt.z]) && (!closedList[pt.x] || !closedList[pt.x][pt.y][pt.z]))
			{
				addAStarNeighbor(neighbors, startingPt, destination, pt, currentObject);			
			}
			pt = getNeighbor("right", currentObject.node);
			if (pt && (!unwalkables[pt.x] || !unwalkables[pt.x][pt.y][pt.z]) && (!closedList[pt.x] || !closedList[pt.x][pt.y][pt.z]))
			{
				addAStarNeighbor(neighbors, startingPt, destination, pt, currentObject);		
			}
			pt = getNeighbor("left", currentObject.node);
			if (pt && (!unwalkables[pt.x] || !unwalkables[pt.x][pt.y][pt.z]) && (!closedList[pt.x] || !closedList[pt.x][pt.y][pt.z]))
			{
				addAStarNeighbor(neighbors, startingPt, destination, pt, currentObject);
			}
			return neighbors;
		}
		
		public function getNeighboringPoints(asset:ActiveAsset, assetPathFinder:ArrayCollection, index:int, occupiedSpaces:Array, unorganizedPoints:ArrayCollection):Array
		{	
			var coordsArray:Array = new Array();
			var pt:Point3D;
			var hasAvailableNextPoint:Boolean = false;
			for (var i:int = 0; i < assetPathFinder[index-1].length; i++)
			{
				var reference:Point3D = assetPathFinder[index-1][i];
				pt = getNeighbor('top', reference);
				if (pt != null && checkIfValid(asset, pt, occupiedSpaces, unorganizedPoints))
				{
					coordsArray.push(pt);
					unorganizedPoints.addItem(pt);					
				}	
				pt = getNeighbor('bottom', reference);
				if (pt != null && checkIfValid(asset, pt, occupiedSpaces, unorganizedPoints))
				{
					coordsArray.push(pt);
					unorganizedPoints.addItem(pt);					
				}	
				pt = getNeighbor('left', reference);
				if (pt != null && checkIfValid(asset, pt, occupiedSpaces, unorganizedPoints))
				{
					coordsArray.push(pt);
					unorganizedPoints.addItem(pt);					
				}
				pt = getNeighbor('right', reference);
				if (pt != null && checkIfValid(asset, pt, occupiedSpaces, unorganizedPoints))
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
					return true;
				if (pt.x == startPoint.x && pt.y == startPoint.y && pt.z == startPoint.z)
				{
					trace ("Start point found, different instance");
					return true;
				}
			}
			return false;
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
			var closedList:Array = new Array();
			var openList:Array = new Array();
			var fauxOpenList:ArrayCollection = new ArrayCollection();
			var unwalkables:Array = getUnwalkables(avoidPeople, avoidStructures, exempt, extra);
			var lowestFScoreObject:Object;
			addPointTo3DArray(startingPoint, {parentInfo: null, node: startingPoint, hScore: getHScore(startingPoint, destination), gScore: 0}, openList); //add starting point to open list
			fauxOpenList.addItem({parentInfo: null, node: startingPoint, hScore: getHScore(startingPoint, destination), gScore: 0});
			var iteration:int;
			while(openList.length != 0)  // quit if open list is emptied, ie. no path
			{
				lowestFScoreObject = getLowestFScore(fauxOpenList);	//get the last/lowest FscoreObject from the open list
				var index:int = fauxOpenList.getItemIndex(lowestFScoreObject);	
				fauxOpenList.removeItemAt(index);
				openList[lowestFScoreObject.node.x][lowestFScoreObject.node.y][lowestFScoreObject.node.z] = 0; //remove the last object with the lowest Fscore from open list
				addPointTo3DArray(lowestFScoreObject.node, lowestFScoreObject, closedList);     //add that lowest FScoreObject to the closed List							
				if (equivalent3DPoints(new Point3D(lowestFScoreObject.node.x, lowestFScoreObject.node.y, lowestFScoreObject.node.z), destination)) return determinePath(closedList, lowestFScoreObject); // exit while loop if we've hit the end
				var neighbors:ArrayCollection = updateAStarNeighbors(startingPoint, destination, lowestFScoreObject, unwalkables, openList, closedList, fauxOpenList);
				fauxOpenList.addAll(neighbors);
				iteration++;
				
				if (neighbors.length == 0)
				{
					removePointFrom3DArray(lowestFScoreObject.node as Point3D, closedList);
					addPointTo3DArray(lowestFScoreObject.node, lowestFScoreObject, unwalkables);
				}
				if (iteration > 1000)
					return determinePath(closedList, lowestFScoreObject);
			}
			return null;
		}
		
		private function addPointTo3DArray(pt:Point3D, obj:Object, addTo:Array):void
		{
			if (addTo[pt.x] && addTo[pt.x][pt.y])
			{	
				addTo[pt.x][pt.y][pt.z] = obj;
			}
			else if (addTo[pt.x])
			{
				addTo[pt.x][pt.y] = new Array();
				addTo[pt.x][pt.y][pt.z] = obj;
			}
			else
			{
				addTo[pt.x] = new Array();
				addTo[pt.x][pt.y] = new Array();
				addTo[pt.x][pt.y][pt.z] = obj;
			}
		}			
		
		private function removePointFrom3DArray(pt:Point3D, removeFrom:Array):void
		{
			if (removeFrom[pt.x] && removeFrom[pt.x][pt.y] && removeFrom[pt.x][pt.y][pt.z])
				removeFrom[pt.x][pt.y][pt.z] = 0;
		}
		
		private function updateAStarNeighbors(startingPt:Point3D, destination:Point3D, lastObject:Object, unwalkables:Array, openList:Array, closedList:Array, fauxOpenList:ArrayCollection):ArrayCollection
		{
			var neighbors:ArrayCollection = getAStarNeighbors(lastObject, startingPt, destination, unwalkables, closedList);
			for each (var obj:Object in neighbors)    
			{
				if (!inOpenList(obj, openList))   //for each neighbor that isn't yet on the open list
				{	
					addPointTo3DArray(new Point3D(obj.node.x, obj.node.y, obj.node.z), obj, openList);
					fauxOpenList.addItem(obj);
				}
			}
			return neighbors;
		}
		
		private function inOpenList(obj:Object, openList:Array):Boolean
		{		
			if (openList[obj.node.x] && openList[obj.node.x][obj.node.y][obj.node.z])
				return true;
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
		
		private function getLowestFScore(fauxOpenList:ArrayCollection):Object
		{
			// This function finds the last node with the lowest F score in the open list
			// returns an object corresponding to that lowest node
			var lowest:Object = fauxOpenList[fauxOpenList.length-1];
			
			for (var i:int = 0; i < fauxOpenList.length; i++)
			{
				if (fauxOpenList[i].hScore + fauxOpenList[i].gScore <= lowest.hScore + lowest.gScore)
					lowest = fauxOpenList[i];
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
//			var nextObject:Object = calculateAStarNeighbors(startObject, startingPoint, destination, unwalkables, openList, closedList, aStarInfo);
//			aStarInfo.addItem(startObject);
//			aStarInfo.addItem(nextObject);
			
			while (!closedList.contains(mapPointToPathGrid(destination)))
			{	
//				var newObject:Object = calculateAStarNeighbors(nextObject, startingPoint, destination, unwalkables, openList, closedList, aStarInfo);
//				if (newObject)
//				{
//					nextObject = newObject;
//					aStarInfo.addItem(newObject);
//				}
//				else
//				{
//					return aStarInfo;
//				}
//				if (closedList.length > 1000 || openList.length > 10000)
//					throw new Error("Bad news");
			}
			return aStarInfo;
		}
		
		private function calculateAStarNeighbors(pointObject:Object, startingPoint:Point3D, destination:Point3D, unwalkables:Array, openList:Array, closedList:Array, aStarInfo:ArrayCollection):Object
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
		
		private function addLowestFScore(neighbors:ArrayCollection, startingPoint:Point3D, pointObject:Object, openList:Array, closedList:Array, aStarInfo:ArrayCollection):Object
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
				return null;
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
		
		public function establishOwnedStructures():ArrayCollection
		{
			var occupiedStructures:ArrayCollection = new ArrayCollection();
			for each (var asset:ActiveAsset in _world.assetRenderer.unsortedAssets)
			{
				if (asset.thinger)
				{
					if (asset.thinger is OwnedStructure)
						getStructurePoints(asset.thinger as OwnedStructure);				
				}
			}
			return occupiedStructures;
		}
		
		public function getPeopleOccupiedSpacesForArray(sourceArray:ArrayCollection):Array
		{
			var spaces:Array = new Array();
			for each (var asset:ActiveAsset in sourceArray)
			{
				if (asset is Person)
				{	
					var pt:Point3D = getPoint3DForPerson(asset);
					addPointTo3DArray(pt, asset, spaces);
				}	
			}
			return spaces;
		}
		
		public function addPeopleOccupiedSpaces(addTo:Array, sourceArray:ArrayCollection):void
		{
			for each (var asset:ActiveAsset in sourceArray)
			{
				if (asset is Person)
				{	
					var pt:Point3D = getPoint3DForPerson(asset);
					addPointTo3DArray(pt, asset, addTo);
				}	
			}
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
		
		private function copy3DArray(toCopy:Array):Array
		{
			var result:Array = new Array();
			for (var i:int = 0; i < toCopy.length; i++)
			{
				if (toCopy[i])
				{	
					result[i] = new Array();
					for (var j:int = 0; j < toCopy[i].length; j++)
					{
						if (toCopy[i][j])
						{
							result[i][j] = new Array();
							for (var k:int = 0; k < toCopy[i][j].length; k++)
							{
								result[i][j][k] = toCopy[i][j][k];
							}
						}
					}
				}	
			}
			return result;
		}
		
		public function getUnwalkables(avoidPeople:Boolean, avoidStructures:Boolean, exempt:ArrayCollection=null, extra:ArrayCollection=null, heightBase:int=0):Array
		{
			var allOccupied:Array = initializeOccupiedSpacesArray(heightBase);
			if (avoidStructures)
			{	
				allOccupied = copy3DArray(occupiedByStructures);
				addStructureOccupiedSpaces(allOccupied, exempt);
			}	
			if (avoidPeople)
				addPeopleOccupiedSpaces(allOccupied, _world.assetRenderer.unsortedAssets);
			if (extra)
				addExtraOccupiedSpaces(allOccupied, extra);		
			return allOccupied;
		}
		
		public function updateOccupiedSpaces(getPeople:Boolean, getStructures:Boolean, exempt:ArrayCollection=null, extra:ArrayCollection=null):Array
		{
			var spaces:Array = new Array();
			if (getStructures)	
			{
				spaces = copy3DArray(occupiedByStructures);
				addStructureOccupiedSpaces(spaces, exempt);
			}	
			if (getPeople)
				addPeopleOccupiedSpaces(spaces, _world.assetRenderer.unsortedAssets);
			if (extra)
				addExtraOccupiedSpaces(spaces, extra);
			return spaces;
		}
		
		public function validateOccupiedSpaces(occupiedSpaces:ArrayCollection):void
		{
			if (occupiedSpaces.length >= _world.tilesDeep*_world.tilesWide)
				throw new Error("No free spaces! That's crazy pills! total spaces: " + _world.tilesDeep.toString() + "::" + _world.tilesWide.toString());
		}
		
		public function getStructureOccupiedSpaces(exemptStructures:ArrayCollection=null):Array
		{
			var spaces:Array = copy3DArray(occupiedByStructures);
			for each (var os:OwnedStructure in exemptStructures)
			{
				var pts:ArrayCollection;
				if (os.structure.outerPoints)
					pts = getStructurePointsWithBuffer(os);
				else
					pts = getStructurePoints(os);
				for each (var pt:Point3D in pts)
				{
					if (this.occupiedByStructures[pt.x] && this.occupiedByStructures[pt.x][pt.y] && this.occupiedByStructures[pt.x][pt.y][pt.z])
						spaces[pt.x][pt.y][pt.z] = 0;
				}
			}
			return spaces;
		}

		public function addStructureOccupiedSpaces(addTo:Array, exemptStructures:ArrayCollection=null):void
		{
			for each (var os:OwnedStructure in exemptStructures)
			{
				var pts:ArrayCollection;
				if (os.structure.outerPoints)
					pts = getStructurePointsWithBuffer(os);
				else
					pts = getStructurePoints(os);
				for each (var pt:Point3D in pts)
				{
					if (this.occupiedByStructures[pt.x] && this.occupiedByStructures[pt.x][pt.y] && this.occupiedByStructures[pt.x][pt.y][pt.z])
						addTo[pt.x][pt.y][pt.z] = 0;
				}
			}
		}
		
		public function updateStructureOccupiedSpaces(exemptStructures:ArrayCollection=null):void
		{
			this.occupiedByStructures = getStructureOccupiedSpacesForArray(_world.assetRenderer.unsortedAssets, exemptStructures);
		}
		
		private function getExtraOccupiedSpaces(rectangles:ArrayCollection):Array
		{
			var spaces:Array = new Array();
			for each (var rect:Rectangle in rectangles)
			{
				spaces.concat(getEstimatedPoints3DForRectangle(rect));
			}
			return spaces;
		}

		private function addExtraOccupiedSpaces(addTo:Array, rectangles:ArrayCollection):void
		{
			for each (var rect:Rectangle in rectangles)
			{
				addEstimatedPoints3DForRectangle(addTo, rect);
			}
		}
		
		private function getStructureOccupiedSpacesForArray(assetSource:ArrayCollection, exemptStructures:ArrayCollection=null):Array
		{	
			var spaces:Array = new Array();			
			for each (var asset:ActiveAsset in assetSource)
			{				
				// Check if the owned structures in exemptStructures equal asset.thinger; if so, do not add them
				if (asset.thinger is OwnedStructure)
				{
					if (!exemptStructures)
					{
						if ((asset.thinger as OwnedStructure).structure.outerPoints)
							addStructurePointsWithBuffer(asset, spaces);	
						else
							addStructurePoints(asset, spaces);
					}
					else
					{
						var exempt:Boolean = false;				
						for each (var os:OwnedStructure in exemptStructures)
						{
							if ((os.id == (asset.thinger as OwnedStructure).id) || (os.structure == (asset.thinger as OwnedStructure).structure))
								exempt = true;
						}
						if (!exempt)
							addStructurePoints(asset, spaces);														
					}		
				}
			}
			return spaces;
		}
		
		private function addStructurePoints(asset:ActiveAsset, addTo:Array):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			for (var xPt:int = 0; xPt <= os.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(os.x - os.width/2 + xPt), os.y, Math.round(os.z - os.depth/2 + zPt));
					if (isInBounds(osPt3D) && (!addTo[osPt3D.x] || !addTo[osPt3D.x][osPt3D.y] || !addTo[osPt3D.x][osPt3D.y][osPt3D.z]))
						addPointTo3DArray(osPt3D, asset, addTo);										
				}
			}			
		}

		private function addStructurePointsWithBuffer(asset:ActiveAsset, addTo:Array):void
		{
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			for (var xPt:int = -1; xPt <= os.width + 1; xPt++)
			{
				for (var zPt:int = -1; zPt <= os.depth + 1; zPt++)
				{
					var osPt3D:Point3D = new Point3D(Math.round(os.x - os.width/2 + xPt), os.y, Math.round(os.z - os.depth/2 + zPt));
					if (isInBounds(osPt3D) && (!addTo[osPt3D.x] || !addTo[osPt3D.x][osPt3D.y] || !addTo[osPt3D.x][osPt3D.y][osPt3D.z]))
						addPointTo3DArray(osPt3D, asset, addTo);										
				}
			}			
		}
		
		public function isInBounds(pt:Point3D):Boolean
		{
			if (pt.x >= 0 && pt.x <= _world.tilesWide && pt.z >= 0 && pt.z <= _world.tilesDeep)
				return true;
			return false;
		}
		
		public function getStructurePoints(os:OwnedStructure):ArrayCollection
		{
			var structurePoints:ArrayCollection = new ArrayCollection();			
			for (var xPt:int = 0; xPt <= os.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(os.x - os.width/2 + xPt, 0, os.z - os.depth/2 + zPt);
					if (isInBounds(osPt3D))
						structurePoints.addItem(osPt3D);										
				}
			}			
			return structurePoints;
		}
		
		private function getStructurePointsWithBuffer(os:OwnedStructure):ArrayCollection
		{
			var structurePoints:ArrayCollection = new ArrayCollection();			
			for (var xPt:int = -1; xPt <= os.width + 1; xPt++)
			{
				for (var zPt:int = -1; zPt <= os.depth + 1; zPt++)
				{
					var osPt3D:Point3D = new Point3D(os.x - os.width/2 + xPt, 0, os.z - os.depth/2 + zPt);
					if (isInBounds(osPt3D))
						structurePoints.addItem(osPt3D);										
				}
			}			
			return structurePoints;			
		}

		public function getInnerStructurePoints(os:OwnedStructure):ArrayCollection
		{
			var structurePoints:ArrayCollection = new ArrayCollection();
			for (var xPt:int = 1; xPt < os.width; xPt++)
			{
				for (var zPt:int = 1; zPt < os.depth; zPt++)
				{
					var osPt3D:Point3D = pathGrid[os.x - os.width/2 + xPt][0][os.z - os.depth/2 + zPt];
					structurePoints.addItem(osPt3D);										
				}
			}
			return structurePoints;
		}

		public function getEstimatedPoints3DForRectangle(rect:Rectangle, rectHeight:int=0):Array
		{		
			var rectSpaces:Array = new Array();
			for (var xPt:int = rect.left; xPt <= rect.right; xPt++)
			{
				for (var zPt:int = rect.top; zPt <= rect.bottom; zPt++)
				{
					var osPt3D:Point3D = pathGrid[xPt][rectHeight][zPt];
					addPointTo3DArray(osPt3D, rect, rectSpaces);								
				}
			}
			return rectSpaces;
		}

		public function addEstimatedPoints3DForRectangle(addTo:Array, rect:Rectangle, rectHeight:int=0):void
		{		
			for (var xPt:int = rect.left; xPt <= rect.right; xPt++)
			{
				for (var zPt:int = rect.top; zPt <= rect.bottom; zPt++)
				{
					var osPt3D:Point3D = pathGrid[xPt][rectHeight][zPt];
					addPointTo3DArray(osPt3D, rect, addTo);								
				}
			}
		}

		public function getPoint3DForStructure(asset:ActiveAsset, structureSpaces:ArrayCollection):ArrayCollection
		{
			// Does not count height	
			
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			var bottomLeft:Point3D = _world.getWorldBoundsForAsset(asset);
			
			for (var xPt:int = bottomLeft.x; xPt < (bottomLeft.x + os.width); xPt++)
			{
				for (var zPt:int = bottomLeft.z; zPt < (bottomLeft.z + os.depth); zPt++)
				{
					var osPt3D:Point3D = pathGrid[xPt][os.y][zPt];
					structureSpaces.addItem(osPt3D);										
				}
			}
			if (!os.width || !os.depth)
				throw new Error("No dimensions specified for structure");
			
			return structureSpaces;
		}
		
		public function getPoint3DForMovingStructure(asset:ActiveAsset):ArrayCollection
		{
			// Does not count height	
			
			var structurePoints:ArrayCollection = new ArrayCollection();
			var os:OwnedStructure = asset.thinger as OwnedStructure;
			
			for (var xPt:int = 0; xPt <= os.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.depth; zPt++)
				{
					var osPt3D:Point3D = new Point3D(asset.worldCoords.x - os.width/2 + xPt, 0, asset.worldCoords.z - os.depth/2 + zPt);
					structurePoints.addItem(osPt3D);										
				}
			}
			if (!os.width || !os.depth)
				throw new Error("No dimensions specified for structure");
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
			return pathGrid[point3D.x][point3D.y][point3D.z];			
		}
		
		private function determinePath(possiblePoints:Array, lastObject:Object):ArrayCollection
		{
			var tempPath:ArrayCollection = new ArrayCollection();
			var finalPath:ArrayCollection = new ArrayCollection();
			tempPath.addItem(lastObject.node);
			while (lastObject.parentInfo)
			{
				tempPath.addItem(lastObject.parentInfo.node);
				lastObject = lastObject.parentInfo;
			}
			tempPath.removeItemAt(tempPath.length-1);
			for (var i:int = tempPath.length-1; i >= 0; i--)
			{
				finalPath.addItem(tempPath[i]);
			}
			if (finalPath.length == 0)
				throw new Error("No path");
			return finalPath;
		}
		
		private function checkIfValid(asset:ActiveAsset, pt:Point3D, occupiedSpaces:Array, unorganizedPoints:ArrayCollection):Boolean
		{		
			if (unorganizedPoints.contains(pt))
				return false;
			if (occupiedSpaces[pt.x] && occupiedSpaces[pt.x][pt.y] && occupiedSpaces[pt.x][pt.y][pt.z] && occupiedSpaces[pt.x][pt.y][pt.z] != asset)
				return false;
			return true;
		}
		
		public function isAvailablePoint(pt:Point3D, asset:ActiveAsset):Boolean
		{
			if (this.occupiedByStructures[pt.x] && this.occupiedByStructures[pt.x][pt.y] && this.occupiedByStructures[pt.x][pt.y][pt.z] && 
				this.occupiedByStructures[pt.x][pt.y][pt.z] != asset)
				return false;
			if (!isInBounds(pt))
				return false;
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
		
		public function calculatePathGrid(asset:ActiveAsset, currentPoint:Point3D, destination:Point3D, avoidStructures:Boolean=true, avoidPeople:Boolean=false, exempt:ArrayCollection=null, extra:ArrayCollection=null):ArrayCollection
		{
			var pathGridComplete:Boolean = false;
			
			var assetPathFinder:ArrayCollection = initializePath(destination);
			var unorganizedPoints:ArrayCollection = initializeUnorganizedPoints(destination);
			
			var occupiedSpaces:Array = updateOccupiedSpaces(avoidPeople, avoidStructures, exempt, extra);
			
//			validateDestination(asset, destination, occupiedSpaces);		
			
//			var startPoint:Point3D = mapPointToPathGrid(currentPoint);
			var start:Point3D = new Point3D(currentPoint.x, currentPoint.y, currentPoint.z);
			var startPointReached:Boolean = false;
			var index:int = 1;
			
			// Until I add a point that's the same as my start point, keep adding points to the list
			
			if (!(currentPoint.x == destination.x && currentPoint.y == destination.y && currentPoint.z == destination.z))
			{
				do
				{
					var coordsArray:Array = getNeighboringPoints(asset, assetPathFinder, index, occupiedSpaces, unorganizedPoints);
					startPointReached = isStartPointReached(coordsArray, start);
					if (startPointReached)
					{
						coordsArray = new Array();
						coordsArray.push(start);
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
			
			return getBasicAlgorithmPath(asset, assetPathFinder);		
		}			
		
		public function getPeopleOccupiedSpacesForBitmap(sourceArray:ArrayCollection):ArrayCollection
		{
			var peopleOccupiedSpaces:ArrayCollection = new ArrayCollection();
			for each (var abd:AssetBitmapData in sourceArray)
			{
				var asset:ActiveAsset = abd.activeAsset;
				if (asset is Person)
					peopleOccupiedSpaces.addItem(getPoint3DForPerson(asset));
			}
			return peopleOccupiedSpaces;
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
		
		public function set world(val:World):void
		{
			_world = val;
		}
		
		public function get world():World
		{
			return _world;
		}
		
		
		
		private function getNeighbor(direction:String, pt:Point3D):Point3D
		{
			var neighbor:Point3D;
			if (isInBounds(pt))
			{			
				if (direction == 'top')
				{
					if (pt.z + 1 <= _world.tilesDeep)
						neighbor = pathGrid[pt.x][pt.y][pt.z + 1];									
				}
				else if (direction == 'bottom')
				{
					if (pt.z - 1 >= 0)
						neighbor = pathGrid[pt.x][pt.y][pt.z - 1];					
				}
				else if (direction == 'left')
				{
					if (pt.x + 1 <= _world.tilesWide)
						neighbor = pathGrid[pt.x + 1][pt.y][pt.z];
				}
				else if (direction == 'right')
				{
					if (pt.x - 1 >= 0)
						neighbor = pathGrid[pt.x - 1][pt.y][pt.z];
				}
			}	
			return neighbor;
		}
		
		private function getBasicAlgorithmPath(asset:ActiveAsset, grid:ArrayCollection):ArrayCollection
		{
			var index:int = grid.length - 1;
			var pt:Point3D = grid[index][0];
			var tileArray:Array;
			var finalPath:ArrayCollection = new ArrayCollection();
			var foundValidPoint:Boolean = false;
			for (var i:int = (grid.length-2); i>=0; i--)
			{
				foundValidPoint = false;
				tileArray = getSurroundingPoints(pt);
				for (var j:int = 0; j<tileArray.length; j++)
				{
					if (foundValidPoint == false)
					{
						for (var k:int = 0; k<(grid[i] as Array).length; k++)
						{
							if ((tileArray[j] as Point3D).x == (grid[i][k] as Point3D).x && (tileArray[j] as Point3D).y == (grid[i][k] as Point3D).y && (tileArray[j] as Point3D).z == (grid[i][k] as Point3D).z)
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
						structureSpaces = getStructurePoints(asset.thinger as OwnedStructure);						
					else
					{
						for each (var os:OwnedStructure in exemptStructures)
						{
							if (!(os.id == (asset.thinger as OwnedStructure).id && os.structure == (asset.thinger as OwnedStructure).structure))
								structureSpaces = getStructurePoints(asset.thinger as OwnedStructure);							
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
	}
}