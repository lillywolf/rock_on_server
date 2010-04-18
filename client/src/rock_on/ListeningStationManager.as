package rock_on
{
	import controllers.StructureManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import game.GameClock;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.core.Application;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;

	public class ListeningStationManager extends EventDispatcher
	{
		public var listeningStations:ArrayCollection;
		public var passerbyManager:PasserbyManager;
		public var _structureManager:StructureManager;
		public var _myWorld:World;
		public function ListeningStationManager(structureManager:StructureManager, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_myWorld = myWorld;		
			_structureManager = structureManager;
		}
		
		public function setInMotion():void
		{
			listeningStations = new ArrayCollection();
			passerbyManager = new PasserbyManager();
			passerbyManager.myWorld = _myWorld;	
			showListeningStations();
			showPassersby();			
		}
		
		public function showPassersby():void
		{
			passerbyManager.startSpawning();
		}		
		
		public function showListeningStations():void
		{
			var listeningStructures:ArrayCollection = _structureManager.getStructuresByType("ListeningStation");
			for each (var os:OwnedStructure in listeningStructures)
			{
				var asset:ActiveAsset = new ActiveAsset(os.structure.mc);
				asset.thinger = os;
				var listeningStation:ListeningStation = new ListeningStation(os);
				listeningStation.createdAt = GameClock.convertStringTimeToUnixTime(os.created_at);
				listeningStation.stationType = _structureManager.getListeningStationTypeByMovieClip(os.structure.mc);
				listeningStations.addItem(listeningStation);
				var stationCounter:Canvas = listeningStation.displayCountdown();
				Application.application.addChild(stationCounter);				
				var addTo:Point3D = new Point3D(os.x, os.y, os.z);
				_myWorld.addStaticAsset(asset, addTo);
			}
			passerbyManager.listeningStations = listeningStations;
		}		
		
	}
}