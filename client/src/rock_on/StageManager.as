package rock_on
{
	import controllers.StructureController;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;

	public class StageManager extends EventDispatcher
	{
		public var _structureController:StructureController;
		public var _myWorld:World;
		public var _myStage:World;
		public var editMirror:Boolean;
		public var stageAsset:ActiveAsset;
		public var stages:ArrayCollection;
		public var concertStage:ConcertStage;
		
		public static const STAGE_DOOR_X:int = 1;
		
		public function StageManager(structureController:StructureController, target:IEventDispatcher=null)
		{
			super(target);
			_structureController = structureController;
			stages = new ArrayCollection();
		}
		
		public function setInMotion():void
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
			
			stageAsset = new ActiveAsset();
			stageAsset.thinger = stageStructures[0];
			var addTo:Point3D = new Point3D(concertStage.x, concertStage.y, concertStage.z);
			concertStage.worldCoords = addTo;
		}
		
		public function addStageDecorations(worldToUpdate:World):void
		{
			var stageDecorations:ArrayCollection = _structureController.getStructuresByType("StageDecoration");
			for each (var os:OwnedStructure in stageDecorations)
			{
				var stageDecoration:StageDecoration = new StageDecoration(this.concertStage, os);
				var asset:ActiveAsset = createStageDecorationAsset(stageDecoration);
				var addTo:Point3D = new Point3D(stageDecoration.x, stageDecoration.y, stageDecoration.z);
				addStageDecorationToWorld(asset, addTo, worldToUpdate);
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
				_myStage.saveStructurePlacement(os);
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
			
			if (editMirror)
			{
				_myStage.addAsset(asset, addTo);
			}
			else
			{
				_myStage.addAsset(asset, addTo);
			}
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