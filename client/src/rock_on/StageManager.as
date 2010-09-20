package rock_on
{
	import controllers.StructureController;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;

	public class StageManager extends EventDispatcher
	{
		public var _structureController:StructureController;
		public var _myWorld:World;
		public var _myStage:World;
		public var _venue:Venue;
		public var editMirror:Boolean;
		public var stageAsset:ActiveAsset;
		public var stages:ArrayCollection;
		public var concertStage:ConcertStage;
		public var stageDecorations:ArrayCollection;
		public var stageDecorationAssets:ArrayCollection;
		
		public static var STAGE_DOOR_X:int;
		
		public function StageManager(structureController:StructureController, venue:Venue, target:IEventDispatcher=null)
		{
			super(target);
			_structureController = structureController;
			_venue = venue;
			stages = new ArrayCollection();
			stageDecorationAssets = new ArrayCollection();
		}
		
		public function initialize():void
		{
			createStage();
		}
		
		public function tearDown():void
		{
			removeStage();
		}
		
		public function createStage():void
		{
			var stageStructures:ArrayCollection = _structureController.getStructuresByType("ConcertStage");
			concertStage = new ConcertStage(stageStructures[0]);
			
			stageAsset = new ActiveAsset(EssentialModelReference.getMovieClipCopy(concertStage.structure.mc));
			stageAsset.thinger = stageStructures[0];
			var addTo:Point3D = new Point3D(concertStage.x, concertStage.y, concertStage.z);
			concertStage.worldCoords = addTo;
			
			STAGE_DOOR_X = concertStage.depth - 1;
		}	
		
		public function drawTiles(_world:World):void
		{
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if (os.structure.structure_type == "Tile")
				{
					var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);					
					var asset:ActiveAsset = new ActiveAsset(mc);
					asset.thinger = os;					
					_world.addAsset(asset, new Point3D(os.x, os.y, os.z));
				}
			}			
		}
		
		public function drawBitmappedTiles(_world:World):void
		{
			var uic:UIComponent = new UIComponent();
			for each (var os:OwnedStructure in _structureController.owned_structures)
			{
				if (os.structure.structure_type == "Tile")
				{
					var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);					
					var asset:ActiveAsset = new ActiveAsset(mc);
					asset.thinger = os;
					_world.addAsset(asset, new Point3D(os.x, os.y, os.z));
					asset.bitmap.x += asset.realCoords.x;
					asset.bitmap.y += asset.realCoords.y;
					_world.removeAsset(asset);
					uic.addChild(asset.bitmap);
				}
			}
			_world.addChild(uic);
		}		
		
		public function addStageDecorations(worldToUpdate:World):void
		{
			stageDecorations = _structureController.getStructuresByType("StageDecoration");
			for each (var os:OwnedStructure in stageDecorations)
			{
				if (os.in_use)
				{
					var stageDecoration:StageDecoration = new StageDecoration(this.concertStage, os);
					var asset:ActiveAsset = createStageDecorationAsset(stageDecoration);
					stageDecorationAssets.addItem(asset);
					var addTo:Point3D = new Point3D(stageDecoration.x, stageDecoration.y, stageDecoration.z);
					addStageDecorationToWorld(asset, addTo, worldToUpdate);
				}
			}
		}
		
		public function addStageDecorationToWorld(asset:ActiveAsset, addTo:Point3D, worldToUpdate:World):void
		{
			worldToUpdate.addStaticAsset(asset, addTo);
		}
		
		public function createStageDecorationAsset(stageDecoration:StageDecoration):ActiveAsset
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(stageDecoration.structure.mc);
			mc.cacheAsBitmap = true;
			var asset:ActiveAsset = new ActiveAsset(mc);
			asset.thinger = stageDecoration;
			return asset;
		}
		
		public function updateRenderedStageDecorations(os:OwnedStructure, method:String):void
		{
			if (method == "save_placement")
			{
				_structureController.savePlacement(os, new Point3D(os.x, os.y, os.z));				
				_myStage.saveStructurePlacement(os);
				_venue.redrawAllBandMembers();
			}
			else if (method == "create_new")
			{
				_myStage.createNewStructure(os);
			}			
		}
		
		public function updateRenderedTiles(os:OwnedStructure, method:String):void
		{
			if (method == "save_placement")
			{
				_myStage.saveStructurePlacement(os);
			}
			else if (method == "create_new")
			{
				_myStage.createNewStructure(os);
			}
		}
		
		public function addStageToWorld(asset:ActiveAsset, addTo:Point3D, myStage:World):void
		{
			_myStage = myStage;	
			_myStage.addAsset(asset, addTo);
			_myStage.addToPrioritizedRenderList(asset);
		}
		
		public function set myStage(val:World):void
		{
			_myStage = val;
		}
		
		public function get myStage():World
		{
			return _myStage;
		}
		
		public function set myWorld(val:World):void
		{
			_myWorld = val;
			concertStage.stageEntryPoint = new Point3D(STAGE_DOOR_X, concertStage.structure.height, _myWorld.tilesDeep);			
		}
		
		public function get myWorld():World
		{
			return _myWorld;
		}
		
		public function removeStage():void
		{
			_myStage.removeAsset(stageAsset);
			stageAsset = null;
			concertStage = null;
		}
		
	}
}