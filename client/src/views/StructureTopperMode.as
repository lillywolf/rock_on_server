package views
{
	import controllers.StructureController;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	import rock_on.Venue;
	
	import world.ActiveAsset;
	import world.World;
	
	public class StructureTopperMode extends UIComponent
	{
		public var _structureController:StructureController;
		public var _editView:EditView;
		public var _venue:Venue;
		
		public var structureWorld:World;
		public var tileLayer:World;
		public var structureEditing:Boolean;
		public var currentStructure:ActiveAsset;
		public var currentStructurePoints:ArrayCollection;		
		
		public function StructureTopperMode(editView:EditView, worldWidth:int, worldDepth:int, tileSize:int)
		{
			super();
			_editView = editView;
			_structureController = _editView.structureController;
			_venue = _editView.venueManager.venue;
			createStructureWorld(worldWidth, worldDepth, tileSize);
			currentStructurePoints = new ArrayCollection();			
		}
		
		private function onAdded(evt:Event):void
		{
			width = parent.width;
			height = parent.height;	
			tileLayer.x = _editView.worldOriginX;
			tileLayer.y = _editView.worldOriginY;
			structureWorld.x = _editView.worldOriginX;
			structureWorld.y = _editView.worldOriginY;
		}
		
		public function createStructureWorld(worldWidth:int, worldDepth:int, tileSize:int):void
		{
			addTileLayer(worldWidth, worldDepth, tileSize);
			structureWorld = new World(worldWidth, worldDepth, tileSize);
			addChild(structureWorld);
			showStructures();
		}		
		
		public function addTileLayer(worldWidth:int, worldDepth:int, tileSize:int):void
		{
			tileLayer = new World(worldWidth, worldDepth, tileSize);
			addChild(tileLayer);
			showTiles();
		}
		
		public function showStructures():void
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if (os.in_use && os.structure.structure_type != "Tile")
				{
					addStructureAsset(os, structureWorld);
				}
			}
		}
		
		public function showTiles():void
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if (os.in_use && os.structure.structure_type == "Tile")
				{
					addStructureAsset(os, tileLayer);
				}
			}
		}		
	}
}