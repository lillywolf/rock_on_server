package rock_on
{
	import controllers.StructureManager;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;

	public class StageManager extends EventDispatcher
	{
		public var _structureManager:StructureManager;
		public var _myWorld:World;
		public var stageAsset:ActiveAsset;
		public var stages:ArrayCollection;
		public var concertStage:ConcertStage;
		
		public function StageManager(structureManager:StructureManager, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_structureManager = structureManager;
			_myWorld = myWorld;
			stages = new ArrayCollection();
		}
		
		public function setInMotion():void
		{
			addStage();
		}
		
		public function tearDown():void
		{
			removeStage();
		}
		
		private function addStage():void
		{
			var stageStructures:ArrayCollection = _structureManager.getStructuresByType("ConcertStage");
			concertStage = new ConcertStage(stageStructures[0]);
			
			stageAsset = new ActiveAsset(new MovieClip());
			stageAsset.thinger = stageStructures[0];
			var addTo:Point3D = new Point3D(concertStage.x, concertStage.y, concertStage.z);
			concertStage.worldCoords = addTo;
			_myWorld.addAsset(stageAsset, addTo);
		}
		
		public function removeStage():void
		{
			_myWorld.removeAsset(stageAsset);
			stageAsset = null;
			concertStage = null;
		}
		
	}
}