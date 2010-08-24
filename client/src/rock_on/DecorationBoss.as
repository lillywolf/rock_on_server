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
				if (os.structure.structure_type == "StructureTopper")
					updateTopperPlacement(os);
			}
		}
		
		public function updateTopperPlacement(topper:OwnedStructure):void
		{
			var asset:ActiveAsset;
			for each (asset in _myWorld.assetRenderer.unsortedAssets)
			{
				if (asset.toppers && asset.toppers.contains(topper))
					var oldAsset:ActiveAssetStack = asset as ActiveAssetStack;
				if (asset.thinger is OwnedStructure)
					asset.toppers = _structureController.getStructureToppers(asset.thinger as OwnedStructure); 
				if (asset.toppers && asset.toppers.contains(topper))
					var newAsset:ActiveAssetStack = asset as ActiveAssetStack;
			}
			redrawToppedStructures(oldAsset, newAsset);
		}
		
		private function doRedraw(oldAsset:ActiveAssetStack):void
		{
			_myWorld.removeAsset(oldAsset);
			var temp:ActiveAssetStack = new ActiveAssetStack(null, oldAsset.movieClip);
			temp.worldCoords = new Point3D(oldAsset.worldCoords.x, oldAsset.worldCoords.y, oldAsset.worldCoords.z);
			temp.toppers = oldAsset.toppers;
			temp.thinger = oldAsset.thinger;
			temp.setMovieClipsForStructure(temp.toppers);
			temp.reflected = false;
			temp.movieClip.gotoAndStop(0);			
			temp.bitmapWithToppers();
			_myWorld.addAsset(temp, temp.worldCoords);			
		}
		
		private function redrawToppedStructures(oldAsset:ActiveAssetStack, newAsset:ActiveAssetStack):void
		{
			doRedraw(newAsset);
			if (oldAsset != newAsset)
				doRedraw(oldAsset);
		}
	}
}