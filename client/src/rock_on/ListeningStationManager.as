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
	import mx.events.DynamicEvent;
	
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
			passerbyManager = new PasserbyManager(this, _myWorld);
			showListeningStations();
			showPassersby();			
		}
		
		private function onFanButtonState(evt:DynamicEvent):void
		{
			var station:ListeningStation = evt.currentTarget as ListeningStation;
			if (station.currentListenerCount != station.listenerCount)
			{
				passerbyManager.spawnForStation(station);
			}
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
				listeningStation.addEventListener("fanButtonState", onFanButtonState);
				listeningStation.createdAt = GameClock.convertStringTimeToUnixTime(os.created_at);
				listeningStation.stationType = _structureManager.getListeningStationTypeByMovieClip(os.structure.mc);
				listeningStations.addItem(listeningStation);
				listeningStation.setInMotion();
				var stationCounter:Canvas = listeningStation.displayCountdown();
				Application.application.addChild(stationCounter);				
				var addTo:Point3D = new Point3D(os.x, os.y, os.z);
				_myWorld.addStaticAsset(asset, addTo);
			}
		}	
		
		public function getStationFront(station:ListeningStation):Point3D
		{	
			// This assumes a particular rotation
			
			var stationFront:Point3D;
				
			do
			{
				stationFront = new Point3D(Math.floor(station.x + station.structure.width/2 + 1 + Math.round(Math.random()*station.radius.x)), 0, Math.floor(station.z - station.structure.depth/2 + Math.round(Math.random()*station.radius.x*2)+1));										
			}			
			while (_myWorld.pathFinder.establishPeopleOccupiedSpaces().contains(_myWorld.pathFinder.mapPointToPathGrid(stationFront)));
			return stationFront;
		}
		
		public function getRandomStation(station:ListeningStation=null):ListeningStation
		{
			var selectedStation:ListeningStation = null;
			if (listeningStations.length && !(listeningStations.length == 1 && station))
			{
				do 
				{
					selectedStation = listeningStations.getItemAt(Math.floor(Math.random()*listeningStations.length)) as ListeningStation;			
				}
				while (selectedStation == station);
			}
			return selectedStation;	
		}					
		
	}
}