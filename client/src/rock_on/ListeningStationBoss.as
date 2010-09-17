package rock_on
{
	import controllers.LayerableController;
	import controllers.StructureController;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import game.GameClock;
	
	import helpers.CreatureGenerator;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	
	import views.UILayer;
	import views.VenueManager;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;

	public class ListeningStationBoss extends EventDispatcher
	{
		public var listeningStations:ArrayCollection;
		public var listeningStationAssets:ArrayCollection;
		public var passerbyManager:PasserbyManager;
		public var creatureGenerator:CreatureGenerator;
		public var friendMirror:Boolean;
		public var editMirror:Boolean;
		public var _structureController:StructureController;
		public var _stageManager:StageManager;
		public var _boothBoss:BoothBoss;
		public var _layerableController:LayerableController;
		public var _customerPersonManager:CustomerPersonManager;
		public var _myWorld:World;
		public var _venue:Venue;
		public var _uiLayer:UILayer;
		
		public function ListeningStationBoss(structureController:StructureController, layerableController:LayerableController, _stageManager:StageManager, myWorld:World, venue:Venue, boothBoss:BoothBoss, customerPersonManager:CustomerPersonManager, target:IEventDispatcher=null)
		{
			super(target);
			_myWorld = myWorld;	
			_layerableController = layerableController;	
			_structureController = structureController;
			_venue = venue;
			_boothBoss = boothBoss;
			_customerPersonManager = customerPersonManager;
			
			creatureGenerator = new CreatureGenerator(layerableController);
			listeningStations = new ArrayCollection();
		}
		
		public function initialize():void
		{
			passerbyManager = new PasserbyManager(this, _myWorld, creatureGenerator, _venue);
			showListeningStations();
		}
		
		public function tearDown():void
		{
			removeListeningStations();
			removePassersby();
		}
		
		public function reInitializeListeningStations():void
		{
			passerbyManager.removeAllRegularPassersBy();
			
			for each (var station:ListeningStation in listeningStations)
			{
				passerbyManager.reinitializeStaticListeners(station);				
			}
		}				
		
		public function addListeners(station:ListeningStation):void
		{
			if (station.currentListeners.length < station.listenerCount)
				passerbyManager.spawnForStation(station);
		}
		
		public function onFanButtonState(station:ListeningStation):void
		{
			addFanButton(station);
		}
		
		public function addFanButton(station:ListeningStation):void
		{
//			var btn:SpecialButton = new SpecialButton();
//			btn.station = station;
//			btn.addEventListener(MouseEvent.CLICK, onFanButtonClicked);
//			var actualCoords:flash.geom.Point = World.worldToActualCoords(new Point3D(station.x, station.y, station.z));
//			btn.x = actualCoords.x + _myWorld.x;
//			btn.y = actualCoords.y + _myWorld.y;
		}
		
		public function showPassersby():void
		{
			passerbyManager.startSpawning();
		}	
		
		public function removePassersby():void
		{
			passerbyManager.stopSpawning();
			passerbyManager.removeAllRegularPassersBy();
		}
		
		public function showListeningStations():void
		{
			listeningStationAssets = new ArrayCollection();
			var listeningStructures:ArrayCollection = _structureController.getStructuresByType("ListeningStation");
			for each (var os:OwnedStructure in listeningStructures)
			{
				var listeningStation:ListeningStation = createListeningStation(os);
				listeningStation.activeAsset = _myWorld.addStandardStructureToWorld(listeningStation);
				listeningStationAssets.addItem(listeningStation.activeAsset);
				listeningStation.setInMotion();
			}
		}
		
		public function updateRenderedStations(os:OwnedStructure, method:String):void
		{
			if (method == "save_placement")
			{
				_myWorld.saveStructurePlacement(os);
				reInitializeListeningStations();			
			}
			else if (method == "create_new")
				_myWorld.createNewStructure(os);
		}
		
		public function addStaticStationListeners():void
		{
			for each (var ls:ListeningStation in this.listeningStations)
			{
				if (ls.in_use)
					ls.setInMotion();
			}			
		}
		
		public function removeListeningStations():void
		{
			for each (var asset:ActiveAsset in listeningStationAssets)
			{
				_myWorld.removeAsset(asset);
			}
			listeningStationAssets.removeAll();
			listeningStations.removeAll();
		}
		
		public function createListeningStation(os:OwnedStructure):ListeningStation
		{
			var station:ListeningStation = new ListeningStation(this, _boothBoss, _venue, os);
//			station.friendMirror = friendMirror;
//			station.editMirror = editMirror;
			station.createdAt = GameClock.convertStringTimeToUnixTime(os.created_at);
			station.stationType = _structureController.getListeningStationTypeByMovieClip(os.structure.mc);			
			listeningStations.addItem(station);
			return station;
		}			
		
		public function getStationFront(stationAsset:ActiveAsset):Point3D
		{				
			var occupiedSpaces:Array = _myWorld.pathFinder.updateOccupiedSpaces(true, true);		
			return stationAsset.getStructureFrontByRotation();		
		}
		
		public function isAnyStationAvailable(occupiedSpaces:Array):Boolean
		{
			var freeStation:Boolean = false;
			for each (var ls:ListeningStation in listeningStations)
			{
				var front:Point3D = ls.getStructureFrontByRotation();
				if (ls.currentListeners.length != ls.structure.capacity && 
					ls.in_use &&
					!(occupiedSpaces[front.x] && occupiedSpaces[front.x][front.y] && occupiedSpaces[front.x][front.y][front.z]))
				{
					freeStation = true;					
				}
			}	
			return freeStation;		
		}
		
		public function getRandomStation(station:ListeningStation=null):ListeningStation
		{
//			This assumes one listener per station
			var selectedStation:ListeningStation = null;
			var occupiedSpaces:Array = _myWorld.pathFinder.updateOccupiedSpaces(true, true);

			if (listeningStations.length && !(listeningStations.length == 1 && station) && isAnyStationAvailable(occupiedSpaces))
			{
				do 
				{
					selectedStation = listeningStations.getItemAt(Math.floor(Math.random()*listeningStations.length)) as ListeningStation;			
				}
				while (selectedStation == station || selectedStation.currentListeners.length > 0 || !selectedStation.in_use);
			}
			trace ("selected station");
			return selectedStation;	
		}	
		
		public function remove(station:ListeningStation):void
		{
			if(_myWorld)
			{				
				_myWorld.assetRenderer.removeAsset(station.activeAsset);
				var stationIndex:Number = listeningStations.getItemIndex(station);
				listeningStations.removeItemAt(stationIndex);
			}
			else 
			{
				throw new Error("how the hell did this happen?");
			}
		}	
		
		public function updateStationOnServerResponse(os:OwnedStructure, method:String):void
		{
			var station:ListeningStation = getStationById(os.id);
						
			if (method == "validate_usage_complete")
				removeStationWhenFinished(station);					
			if (method == "save_placement")
			{
				station.updateProperties(os);
				moveStationUIComponents(station);
			}				
		}
		
		public function getStationById(id:int):ListeningStation
		{
			for each (var station:ListeningStation in listeningStations)
			{
				if (station.id == id)
				{
					return station;
				}
			}
			return null;
		}	
		
		private function moveStationUIComponents(station:ListeningStation):void
		{
			if (station.state == ListeningStation.READY_TO_COLLECT_STATE && station.collectionButton)
				moveStationCollectionButton(station.collectionButton, station);
		}
		
		private function moveStationCollectionButton(btn:SpecialButton, station:ListeningStation):void
		{
			var actualCoords:Point = World.worldToActualCoords(new Point3D(station.x, station.y, station.z));
			btn.x = actualCoords.x + _myWorld.x;
			btn.y = actualCoords.y + _myWorld.y;			
		}				
		
		public function removeStationWhenFinished(station:ListeningStation):void
		{
			remove(station);
		}
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}
		
		public function set stageManager(val:StageManager):void
		{
			_stageManager = val;
		}
		
		public function set boothBoss(val:BoothBoss):void
		{
			_boothBoss = val;
		}	
		
		public function set customerPersonManager(val:CustomerPersonManager):void
		{
			_customerPersonManager = val;
		}	
		
		public function set uiLayer(val:UILayer):void
		{
			_uiLayer = val;
		}
		
		public function get uiLayer():UILayer
		{
			return _uiLayer;
		}					
		
	}
}