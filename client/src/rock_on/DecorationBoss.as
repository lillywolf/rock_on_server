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
		
		public function DecorationBoss(structureController:StructureController, myWorld:World, venue:Venue, target:IEventDispatcher=null)
		{
			super(target);
			_structureController = structureController;
			_myWorld = myWorld;
			_venue = venue;
		}
		
		public function updateRenderedDecorations(os:OwnedStructure, method:String):void
		{
			if (method == "save_placement")
			{
//				if (os.structure.structure_type == "StructureTopper")
//					updateTopperPlacement(os);
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