package rock_on
{
	import controllers.StructureManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import game.GameClock;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.core.Application;
	import mx.events.DynamicEvent;
	
	import views.VenueManager;
	
	import world.ActiveAsset;
	import world.Point;
	import world.Point3D;
	import world.World;

	public class ListeningStationManager extends EventDispatcher
	{
		public var listeningStations:ArrayCollection;
		public var passerbyManager:PasserbyManager;
		public var _structureManager:StructureManager;
		public var _stageManager:StageManager;
		public var _boothManager:BoothManager;
		public var _customerPersonManager:CustomerPersonManager;
		public var _myWorld:World;
		public var _venue:Venue;
		
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
			if (station.currentListeners.length != station.listenerCount)
			{
				passerbyManager.spawnForStation(station);
			}
			addFanButton(station);
		}
		
		public function addFanButton(station:ListeningStation):void
		{
			var btn:FanButton = new FanButton();
			btn.station = station;
			btn.addEventListener(MouseEvent.CLICK, onFanButtonClicked);
			var actualCoords:Point = World.worldToActualCoords(new Point3D(station.x, station.y, station.z));
			btn.x = actualCoords.x;
			btn.y = actualCoords.y;
			Application.application.addChild(btn);
		}
		
		private function onFanButtonClicked(evt:MouseEvent):void
		{
			var fanButton:FanButton = evt.currentTarget as FanButton;
			letInNewFans(fanButton.station);
		}
		
		private function letInNewFans(station:ListeningStation):void
		{
			station.advanceState(ListeningStation.FAN_COLLECTION_STATE);
			
			var fanCount:int = 0;
			for each (var sl:StationListener in station.currentListeners)
			{
				convertStationListenerToCustomer(sl, fanCount);
				fanCount++;
			}
			_venue.updateFanCount(fanCount);
		}
		
		private function convertStationListenerToCustomer(sl:StationListener, fanIndex:int):void
		{
			var cp:CustomerPerson = new CustomerPerson(sl.movieClipStack, _stageManager.concertStage, _boothManager, sl.layerableOrder, sl.creature, VenueManager.PERSON_SCALE);
			_customerPersonManager.addConvertedFan(cp, sl.worldCoords, fanIndex);
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

			var occupiedSpaces:ArrayCollection = _myWorld.pathFinder.updateOccupiedSpaces(true, true);
			
			var stationFront:Point3D;
				
			do
			{
				stationFront = new Point3D(Math.floor(station.x + station.structure.width/2 + 1 + Math.round(Math.random()*station.radius.x)), 0, Math.floor(station.z - station.structure.depth/2 + Math.round(Math.random()*station.radius.x*2)+1));										
			}			
			while (occupiedSpaces.contains(_myWorld.pathFinder.mapPointToPathGrid(stationFront)));
			return stationFront;
		}
		
		public function isAnyStationAvailable():Boolean
		{
			var freeStation:Boolean = false;
			for each (var ls:ListeningStation in listeningStations)
			{
				if (ls.currentListeners.length != ls.capacity)
				{
					freeStation = true;
				}
			}	
			return freeStation;		
		}
		
		public function getRandomStation(station:ListeningStation=null):ListeningStation
		{
			var selectedStation:ListeningStation = null;

			if (listeningStations.length && !(listeningStations.length == 1 && station) && isAnyStationAvailable())
			{
				do 
				{
					selectedStation = listeningStations.getItemAt(Math.floor(Math.random()*listeningStations.length)) as ListeningStation;			
				}
				while (selectedStation == station);
			}
			return selectedStation;	
		}	
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}
		
		public function set stageManager(val:StageManager):void
		{
			_stageManager = val;
		}
		
		public function set boothManager(val:BoothManager):void
		{
			_boothManager = val;
		}	
		
		public function set customerPersonManager(val:CustomerPersonManager):void
		{
			_customerPersonManager = val;
		}			
		
	}
}