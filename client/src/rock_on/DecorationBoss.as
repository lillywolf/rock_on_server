package rock_on
{
	import controllers.StructureController;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	
	import world.ActiveAsset;
	import world.ActiveAssetStack;
	import world.Point3D;
	import world.World;
	
	public class DecorationBoss extends EventDispatcher
	{
		public var _structureController:StructureController;
		public var _myWorld:World;
		public var _venue:Venue;
		public var decorations:ArrayCollection;
		public var decorationAssets:ArrayCollection;
		
		public function DecorationBoss(structureController:StructureController, myWorld:World, venue:Venue, target:IEventDispatcher=null)
		{
			super(target);
			_structureController = structureController;
			_myWorld = myWorld;
			_venue = venue;
			
			decorations = new ArrayCollection();
			decorationAssets = new ArrayCollection();
		}
		
		public function initialize():void
		{
			decorations = _structureController.getStructuresByType("Decoration");
			for each (var os:OwnedStructure in decorations)
			{
				if (os.in_use)
				{
					var asset:ActiveAssetStack = World.createStandardAssetStackFromStructure(os);
					decorationAssets.addItem(asset);
					asset.toppers = _structureController.getStructureToppers(os);
					asset.setMovieClipsForStructure(asset.toppers);
					asset.bitmapWithToppers();
					_myWorld.addStandardStructureToWorld(os, asset);
				}
			}
		}		
		
		public function updateRenderedDecorations(os:OwnedStructure, method:String):void
		{
			if (method == "save_placement")
			{
				if (os.structure.structure_type != "StructureTopper")
				{
					_myWorld.saveStructurePlacement(os, false, null, _venue.stageRects);
					_venue.redrawAllMovers();
				}
				else
					_venue.redrawAllStructures();
			}	
			else if (method == "save_placement_and_rotation")
			{
				if (os.structure.structure_type != "StructureTopper")
				{
					_myWorld.saveStructurePlacement(os, true, null, _venue.stageRects);
					_venue.redrawAllMovers();
				}
			}
			else if (method == "create_new")
			{
				if (os.structure.structure_type != "StructureTopper")
				{
					_myWorld.updateUnwalkables(os, null, _venue.stageRects);					
					_myWorld.createNewStructure(os);				
					_venue.redrawAllMovers();
				}
				else
					_venue.redrawAllStructures();
			}
		}
		
		public function updateTopperPlacement(topper:OwnedStructure):void
		{
			var asset:ActiveAsset;
			var toRedraw:ArrayCollection = new ArrayCollection();
			for each (asset in _myWorld.assetRenderer.unsortedAssets)
			{
				if (asset.thinger is OwnedStructure && (asset.thinger as OwnedStructure).structure.height > 0)
				{
					asset.toppers = _structureController.getStructureToppers(asset.thinger as OwnedStructure); 
					trace("id: " + (asset.thinger as OwnedStructure).id);
					trace("toppers: " + asset.toppers.length.toString());
					toRedraw.addItem(asset);
				}	
			}
			redrawToppedStructures(toRedraw);
		}
		
		private function doRedraw(asset:ActiveAsset):void
		{
			_myWorld.removeAsset(asset);
			var temp:ActiveAssetStack = new ActiveAssetStack(null, asset.movieClip);
			temp.copyFromActiveAsset(asset);
			temp.setMovieClipsForStructure(temp.toppers);
			temp.bitmapWithToppers();
			_myWorld.addAsset(temp, temp.worldCoords);			
		}
		
		private function redrawToppedStructures(toRedraw:ArrayCollection):void
		{
			for each (var asset:ActiveAsset in toRedraw)
			{
				doRedraw(asset);			
			}
		}
	}
}