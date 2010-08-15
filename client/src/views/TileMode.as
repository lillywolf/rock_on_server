package views
{
	import controllers.StructureController;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	
	import mx.core.UIComponent;
	import mx.events.DynamicEvent;
	
	import rock_on.Venue;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;
	
	public class TileMode extends UIComponent
	{
		public var _structureController:StructureController;
		public var _editView:EditView;
		public var _venue:Venue;
		
		public var tileWorld:World;
		public var tileEditing:Boolean;
		public var currentTile:ActiveAsset;
		
		public static const TILE_SCALE:int = 2;

		public function TileMode(editView:EditView, worldWidth:int, worldDepth:int, tileSize:int)
		{
			super();
			
			_editView = editView;
			_structureController = _editView.structureController;
			_venue = _editView.venueManager.venue;
			createTileWorld(worldWidth, worldDepth, tileSize);
//			_editView.addEventListener(MouseEvent.CLICK, onClick);
			
			this.addEventListener(Event.ADDED, onAdded);
		}
		
		private function onAdded(evt:Event):void
		{
			width = parent.width;
			height = parent.height;	
			tileWorld.x = _editView.myWorld.x;
			tileWorld.y = _editView.myWorld.y;
		}
		
		public function createTileWorld(worldWidth:int, worldDepth:int, tileSize:int):void
		{
			tileWorld = new World(worldWidth, worldDepth, tileSize);
			tileWorld.addEventListener(MouseEvent.CLICK, onClick);
			addChild(tileWorld);
			showTiles();
		}
		
		public function showTiles():void
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if (os.structure.structure_type == "Tile" && os.in_use)
				{
					addTileAsset(os);
				}
			}
		}
		
		public function addTileAsset(os:OwnedStructure):ActiveAsset
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
			var asset:ActiveAsset = new ActiveAsset(mc);
			asset.thinger = os;
			tileWorld.addAsset(asset, new Point3D(os.x, os.y, os.z));	
			return asset;
		}
		
		public function selectTile(asset:ActiveAsset):void
		{
			currentTile = asset;
			currentTile.speed = 1;
			currentTile.alpha = 0.5;
			tileEditing = true;
			_editView.addEventListener(MouseEvent.MOUSE_MOVE, onTileMouseMove);
		}

		public function getAccurateClickedTile(coords:Point3D):ActiveAsset
		{
			for each (var asset:ActiveAsset in tileWorld.assetRenderer.unsortedAssets)
			{
				if (coords.x >= asset.worldCoords.x - 1 && 
					coords.x < asset.worldCoords.x + 1 &&
					coords.z >= asset.worldCoords.z - 1 &&
					coords.z < asset.worldCoords.z + 1)
				{
					return asset;
				}
			}
			return null;
		}
		
		public function onClick(evt:MouseEvent):void
		{
			var coords:Point3D = World.actualToWorldCoords(new Point(tileWorld.mouseX, tileWorld.mouseY));
			var asset:ActiveAsset = getAccurateClickedTile(coords);
			
			if (!tileEditing && asset)
			{
				selectTile(asset);
			}
			else if (tileEditing && asset)
			{
				if (isTileInBounds(asset))
				{
					placeTile();				
				}
				else
				{
					revertTile();
				}
			}
		}
		
		public function placeTile():void
		{
			var replaceStructure:OwnedStructure = isTileOccupied(currentTile);
			if (replaceStructure)
			{
				replaceTile(replaceStructure);
			}
			currentTile.alpha = 1;
			saveTileCoords(currentTile);
			resetEditMode();
		}
		
		public function revertTile():void
		{
			if (isOwned(currentTile))
			{
				var os:OwnedStructure = currentTile.thinger as OwnedStructure;
				tileWorld.moveAssetTo(currentTile, new Point3D(os.x, os.y, os.z));
			}
			else
			{
				removeImposterTile(currentTile);
			}
			resetEditMode();
		}
		
		public function removeImposterTile(asset:ActiveAsset):void
		{
			tileWorld.removeAsset(asset);
		}
		
		public function isOwned(asset:ActiveAsset):Boolean
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if ((asset.thinger as OwnedStructure).id && (asset.thinger as OwnedStructure).id == os.id)
				{
					return true;
				}
			}
			return false;
		}
		
		public function resetEditMode():void
		{
			_editView.removeEventListener(MouseEvent.MOUSE_MOVE, onTileMouseMove);
			tileEditing = false;
			currentTile = null;
		}
		
		public function saveTileCoords(asset:ActiveAsset):void
		{
			if (isOwned(asset))
			{
				var evt:DynamicEvent = new DynamicEvent("structurePlaced", true, true);
				evt.asset = asset;
				evt.currentPoint = asset.worldCoords;
				dispatchEvent(evt);
			}
			else
			{
				_structureController.saveNewOwnedStructure(asset.thinger as OwnedStructure, _venue, asset.worldCoords);
			}
		}
		
		public function onTileMouseMove(evt:MouseEvent):void
		{
			var destination:Point3D = World.actualToWorldCoords(new Point(tileWorld.mouseX, tileWorld.mouseY));
			destination.x = Math.round(destination.x);
			destination.y = Math.round(destination.y);
			destination.z = Math.round(destination.z);
			tileWorld.moveAssetTo(currentTile, destination);
			updateTileFilters();
		}
		
		public function updateTileFilters():void
		{
			if (currentTile)
			{
				if (isTileInBounds(currentTile))
				{
					showValidTileFilters();
				}
				else
				{
					showInvalidTileFilters();
				}
			}
		}
		
		public function isTileInBounds(asset:ActiveAsset):Boolean
		{
			var topPoint:Point3D = new Point3D(asset.worldCoords.x - (TILE_SCALE / 2), asset.worldCoords.y, asset.worldCoords.z + (TILE_SCALE / 2));
			var bottomPoint:Point3D = new Point3D(asset.worldCoords.x + (TILE_SCALE / 2), asset.worldCoords.y, asset.worldCoords.z + (TILE_SCALE / 2));
			var leftPoint:Point3D = new Point3D(asset.worldCoords.x - (TILE_SCALE / 2), asset.worldCoords.y, asset.worldCoords.z - (TILE_SCALE / 2));
			var rightPoint:Point3D = new Point3D(asset.worldCoords.x + (TILE_SCALE / 2), asset.worldCoords.y, asset.worldCoords.z + (TILE_SCALE / 2));
			if (_venue.isPointInVenueBounds(topPoint) && _venue.isPointInVenueBounds(bottomPoint) && _venue.isPointInVenueBounds(leftPoint) && _venue.isPointInVenueBounds(rightPoint))
			{			
				return true;
			}
			return false;
		}
		
		public function showValidTileFilters():void
		{
			if (currentTile)
			{
				currentTile.alpha = 0.5;
				currentTile.filters = null;
			}
		}
		
		public function showInvalidTileFilters():void
		{
			if (currentTile)
			{
				currentTile.alpha = 1;
				var gf:GlowFilter = new GlowFilter(0xFF2655, 1, 2, 2, 20, 20);
				currentTile.filters = [gf];			
			}
		}
		
		public function replaceTile(os:OwnedStructure):void
		{

		}
		
		public function isTileOccupied(asset:ActiveAsset):OwnedStructure
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if (os.structure.structure_type == "Tile" && 
					asset.worldCoords.x == os.x &&
					asset.worldCoords.y == os.y &&
					asset.worldCoords.z == os.z &&
					(asset.thinger as OwnedStructure).id != os.id)
				{
					return os;
				}
			}
			return null;
		}
	}
}