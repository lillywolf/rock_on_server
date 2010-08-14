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
					var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
					var asset:ActiveAsset = new ActiveAsset(mc);
					asset.thinger = os;
					tileWorld.addAsset(asset, new Point3D(os.x, os.y, os.z));
				}
			}
		}
		
		public function selectTile(asset:ActiveAsset):void
		{
			currentTile = asset;
			currentTile.speed = 1;
			currentTile.alpha = 0.5;
			tileEditing = true;
			_editView.addEventListener(MouseEvent.MOUSE_MOVE, onTileMouseMove);
		}
		
		public function onClick(evt:MouseEvent):void
		{
			var clickTarget:DisplayObject = evt.target as DisplayObject;
			if (!tileEditing && clickTarget is ActiveAsset)
			{
				selectTile(clickTarget as ActiveAsset);
			}
			else if (tileEditing)
			{
				placeTile();
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
		
		public function resetEditMode():void
		{
			_editView.removeEventListener(MouseEvent.MOUSE_MOVE, onTileMouseMove);
			tileEditing = false;
			currentTile = null;
		}
		
		public function saveTileCoords(asset:ActiveAsset):void
		{
			
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
				var topPoint:Point3D = new Point3D(currentTile.worldCoords.x - (TILE_SCALE / 2), currentTile.worldCoords.y, currentTile.worldCoords.z + (TILE_SCALE / 2));
				var bottomPoint:Point3D = new Point3D(currentTile.worldCoords.x + (TILE_SCALE / 2), currentTile.worldCoords.y, currentTile.worldCoords.z + (TILE_SCALE / 2));
				var leftPoint:Point3D = new Point3D(currentTile.worldCoords.x - (TILE_SCALE / 2), currentTile.worldCoords.y, currentTile.worldCoords.z - (TILE_SCALE / 2));
				var rightPoint:Point3D = new Point3D(currentTile.worldCoords.x + (TILE_SCALE / 2), currentTile.worldCoords.y, currentTile.worldCoords.z + (TILE_SCALE / 2));
				if (_venue.isPointInVenueBounds(topPoint) && _venue.isPointInVenueBounds(bottomPoint) && _venue.isPointInVenueBounds(leftPoint) && _venue.isPointInVenueBounds(rightPoint))
				{
					showValidTileFilters();
				}
				else
				{
					showInvalidTileFilters();
				}
			}
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
		
		public function replaceTile(asset:OwnedStructure):void
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