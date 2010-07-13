package rock_on
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import helpers.CreatureGenerator;
	
	import models.Creature;
	import models.Layerable;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import world.ActiveAsset;
	import world.ActiveAssetStack;
	import world.AssetStack;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class PasserbyManager extends ArrayCollection
	{
		private var _myWorld:World;	
		public var _creatureGenerator:CreatureGenerator;	
		public var _venue:Venue;
		public var spawnLocation:Point3D;
		public var spawnInterval:int;
		public var spawnTimer:Timer;
		public var _listeningStationBoss:ListeningStationBoss;
		public static const STATIONLISTENER_CONVERSION_PROBABILITY:Number = 0.3;
		public static const SPAWN_INTERVAL_BASE:int = 200;
		public static const SPAWN_INTERVAL_MULTIPLIER:int = 100;
				
		public function PasserbyManager(listeningStationBoss:ListeningStationBoss, myWorld:World, creatureGenerator:CreatureGenerator, venue:Venue, source:Array=null)
		{
			super(source);
			_listeningStationBoss = listeningStationBoss;
			_creatureGenerator = creatureGenerator;
			_venue = venue;
			setWorld(myWorld);
		}
		
		public function startSpawning():void
		{
			resetSpawnInterval();
			spawnTimer = new Timer(spawnInterval);
			spawnTimer.addEventListener(TimerEvent.TIMER, onSpawnTimer);
			spawnTimer.start();			
		}
		
		public function resetSpawnInterval():void
		{			
			spawnInterval = SPAWN_INTERVAL_BASE + Math.floor(Math.random()*SPAWN_INTERVAL_MULTIPLIER);
		}
		
		public function stopSpawning():void
		{
			spawnTimer.stop();
			spawnTimer = null;
		}
		
		public function removeAllRegularPassersBy():void
		{
			var pbLength:int = length;
			for (var i:int = (pbLength - 1); i >= 0; i--)
			{
				var passerby:Passerby = this[i] as Passerby;
				if (!(passerby is StationListener))
				{
					remove(passerby);				
				}
			}
		}		
		
		private function generatePasserby():Passerby
		{
			var c:Creature = _creatureGenerator.createImposterCreature("Passerby");
			var passerby:Passerby = new Passerby(_listeningStationBoss, this, _myWorld, _venue, c, null, c.layerableOrder, 0.5);			
			return passerby;		
		}
		
		private function generateStationListener():StationListener
		{
//			var asset:AssetStack = _creatureGenerator.createCreatureAsset("Passerby", "walk_toward", "StationListener");
			var c:Creature = _creatureGenerator.createImposterCreature("StationListener");
			var sl:StationListener = new StationListener(_listeningStationBoss, this, _myWorld, _venue, c, null, c.layerableOrder, 0.5);	
			return sl;		
		}
		
		private function getOpenStation():ListeningStation
		{
			var openStations:ArrayCollection = new ArrayCollection();
			for each (var station:ListeningStation in _listeningStationBoss.listeningStations)
			{
				if (!station.hasCustomerEnRoute)
				{
					openStations.addItem(station);
				}
			}
			if (openStations.length > 0)
			{
				var stationIndex:int = Math.floor(Math.random()*openStations.length);
				var selectedStation:ListeningStation = openStations.getItemAt(stationIndex) as ListeningStation;
				return selectedStation;
			}
			else
			{
				return null;
			}
		}
		
		private function onSpawnTimer(evt:TimerEvent):void
		{			
			// Criteria for making someone go to stations
			
			if (Math.random()*_listeningStationBoss.listeningStations.length > (1 - STATIONLISTENER_CONVERSION_PROBABILITY) && _listeningStationBoss.isAnyStationAvailable())
			{
				var sl:StationListener = generateStationListener();
				sl.speed = 0.07;
				add(sl);			
			}
			else
			{
				var passerby:Passerby = generatePasserby();				
				passerby.speed = 0.07;
				add(passerby);
			}
				
			var spawnTimer:Timer = evt.currentTarget as Timer;
			spawnTimer.removeEventListener(TimerEvent.TIMER, onSpawnTimer);
			spawnTimer.stop();
		}
		
		public function add(passerby:Passerby):void
		{
			if(_myWorld)
			{			
				setSpawnLocation();
				_myWorld.addAsset(passerby, spawnLocation);				
				addItem(passerby);
				determineNextStep(passerby);
			}
			else
			{
				throw new Error("you have to fill your pool before you dive");
			}
			
			spawnInterval = 4000 + Math.floor(Math.random()*5000);
			var spawnTimer:Timer = new Timer(spawnInterval);
			spawnTimer.addEventListener(TimerEvent.TIMER, onSpawnTimer);
			spawnTimer.start();
		}
		
		public function determineNextStep(person:Passerby):void
		{
			if (person is StationListener)
			{
				person.startRouteState();
			}
			else
			{
				person.startRouteState();	
			}			
		}
		
		public function spawnForStation(station:ListeningStation):void
		{
			for (var i:int = 0; i < station.listenerCount; i++)
			{
				addNewStationListener(station);
			}
		}
		
		public function reinitializeStaticListeners(station:ListeningStation):void
		{
			for each (var listener:StationListener in station.currentListeners)
			{
				remove(listener as Passerby);
				listener.currentStation = station;
				addStationListener(listener);				
			}
		}
		
		public function addNewStationListener(station:ListeningStation):void
		{
			var listener:StationListener = generateStationListener();
			listener.currentStation = station;
			listener.speed = 0.07;		
			addStationListener(listener);
			listener.isStatic = true;
			listener.startEnthralledState();									
		}
		
		public function addStationListener(listener:StationListener):void
		{
			if(_myWorld)
			{			
				spawnLocation = listener.setInitialDestination();
				_myWorld.addAsset(listener, spawnLocation);
				addItem(listener);
			}
			else
			{
				throw new Error("you have to fill your pool before you dive");
			}				
		}
		
		private function onFinalDestinationReached(evt:WorldEvent):void
		{
			if (evt.activeAsset is Passerby)
			{	
				var passerby:Passerby = evt.activeAsset as Passerby;
				if (passerby is StationListener && passerby.state == StationListener.ROUTE_STATE)
				{
					passerby.advanceState(StationListener.ENTHRALLED_STATE);
				}
				else if (passerby.state == Passerby.ROUTE_STATE || passerby.state == StationListener.LEAVING_STATE)
				{
					remove(passerby);
				}
				else
				{
					throw new Error("Which state are you in?");
				}
			}
		}
		
		public function setSpawnLocation():void
		{
			if (Math.random() < 0.5)
			{
				spawnLocation = new Point3D(_myWorld.tilesWide - Math.round(Math.random() * (_myWorld.tilesWide - _venue.venueRect.right)), 0, 0);			
			}
			else
			{
				spawnLocation = new Point3D(_myWorld.tilesWide - Math.round(Math.random() * (_myWorld.tilesWide - _venue.venueRect.right)), 0, _myWorld.tilesDeep);							
			}
		}
		
		public function setStationSpawnLocation(passerby:Passerby):void
		{
			spawnLocation = passerby.setInitialDestination();
		}
		
		public function update(deltaTime:Number):void
		{			
			for each (var person:Passerby in this)
			{
				if (person.update(deltaTime))
				{		
					remove(person);							
				}
				else 
				{
				}
			}			
		}
		
		public function remove(person:Passerby):void
		{
			if(_myWorld)
			{
				_myWorld.removeAsset(person);
//				var movingSkinIndex:Number = _myWorld.assetRenderer.sortedAssets.getItemIndex(person);
//				_myWorld.assetRenderer.sortedAssets.removeItemAt(movingSkinIndex);
				var personIndex:Number = getItemIndex(person);
				removeItemAt(personIndex);
			}
			else 
			{
				throw new Error("how the hell did this happen?");
			}
		}		
		
		private function onDirectionChanged(evt:WorldEvent):void
		{
			for each (var asset:ActiveAsset in this)
			{
				if (evt.activeAsset == asset)
				{
					var nextPoint:Point3D = (asset as Passerby).getNextPointAlongPath();
					(asset as Passerby).setDirection(nextPoint);
				}
			}
		}	
		
		public function setWorld(myWorld:World):void
		{
			_myWorld = myWorld;
			_myWorld.addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);				
			_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDestinationReached);
		}				
						
		public function set myWorld(val:World):void
		{
			if(!_myWorld)
			{
				_myWorld = val;
				_myWorld.addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);				
				_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDestinationReached);
			}
			else
			{
				throw new Error("Don't change this!!");				
			}
		}
		
		public function get myWorld():World
		{
			return _myWorld;
		}
				
		public function getStyles(creatureId:int):ArrayCollection
		{
			var myStyles:ArrayCollection = new ArrayCollection();
			var bodyLayer:OwnedLayerable = new OwnedLayerable({id: -1, layerable_id: 2, creature_id: creatureId, in_use: true});
			var eyeLayer:OwnedLayerable = new OwnedLayerable({id: -1, layerable_id: 1, creature_id: creatureId, in_use:true});
			var bottomLayer:OwnedLayerable = new OwnedLayerable({id: -1, layerable_id: 6, creature_id: creatureId, in_use: true});
			for each (var layerable:Layerable in FlexGlobals.topLevelApplication.gdi.layerableController.layerables)
			{
				if (layerable.symbol_name == "PeachBody")
				{
					bodyLayer.layerable = new Layerable(layerable);
					bodyLayer.layerable.mc = new PeachBody();
				}
				else if (layerable.symbol_name == "Pants4")
				{
					bottomLayer.layerable = new Layerable(layerable);
					bottomLayer.layerable.mc = new Pants4();
				}
			}			
			myStyles.addItem(bodyLayer);
//			myStyles.addItem(eyeLayer);
			return myStyles;
		}		
		
	}
}