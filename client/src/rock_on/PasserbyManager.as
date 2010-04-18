package rock_on
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.Creature;
	import models.Layerable;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	import world.ActiveAsset;
	import world.AssetStack;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class PasserbyManager extends ArrayCollection
	{
		private var _myWorld:World;		
		public var spawnLocation:Point3D;
		public var spawnInterval:int;
		public var _listeningStations:ArrayCollection;
		public static const VENUE_BOUND_X:int = 14;	
				
		public function PasserbyManager(source:Array=null)
		{
			super(source);
		}
		
		public function startSpawning():void
		{
			spawnInterval = 2000 + Math.floor(Math.random()*5000);
			var spawnTimer:Timer = new Timer(spawnInterval);
			spawnTimer.addEventListener(TimerEvent.TIMER, onSpawnTimer);
			spawnTimer.start();			
		}
		
		private function onSpawnTimer(evt:TimerEvent):void
		{
			var creature:Creature = new Creature({id: -1, creature_type: "Passerby"});
			var ownedLayerables:ArrayCollection = getStyles(-1);
			creature.owned_layerables = ownedLayerables;
			var assetStack:AssetStack = creature.getConstructedCreature("walk_toward", 1, 1);
			
			// Criteria for making someone go to stations
			var passerby:*;
			if (Math.random()*listeningStations.length > 0.7)
			{
				passerby = new StationListener(assetStack.movieClipStack, this, assetStack.layerableOrder, assetStack.creature, 0.4);
				
				var stationIndex:int = Math.floor(Math.random()*_listeningStations.length);	
				while ((_listeningStations.getItemAt(stationIndex) as ListeningStation).hasCustomerEnRoute)
				{
					stationIndex = Math.floor(Math.random()*_listeningStations.length);				
				}		
									
				(passerby as StationListener).listeningStation = listeningStations[stationIndex];
			}
			else
			{
				passerby = new Passerby(assetStack.movieClipStack, assetStack.layerableOrder, assetStack.creature, 0.4);			
			}
			
			passerby.speed = 0.08;
			add(passerby);
			
			var spawnTimer:Timer = evt.currentTarget as Timer;
			spawnTimer.removeEventListener(TimerEvent.TIMER, onSpawnTimer);
			spawnTimer.stop();
		}
		
		public function add(person:Passerby):void
		{
			if(_myWorld)
			{			
				setSpawnLocation();
				_myWorld.addAsset(person, spawnLocation);				
				addItem(person);
				person.myWorld = _myWorld;
				person.startEnterState();
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
		
		private function onFinalDestinationReached(evt:WorldEvent):void
		{
			if (evt.activeAsset is Passerby)
			{	
				var passerby:Passerby = evt.activeAsset as Passerby;
				if (passerby is StationListener && passerby.state == Person.ENTER_STATE)
				{
					passerby.advanceState(Person.STOP_STATE);
				}
				else if (passerby.state == Person.ROAM_STATE)
				{
					
				}
				else if (passerby.state == Person.ENTER_STATE || passerby.state == Person.LEAVING_STATE)
				{
					remove(passerby);
					passerby.advanceState(Person.GONE_STATE);
				}
			}
		}
		
		public function setSpawnLocation():void
		{
			if (Math.random() < 0.5)
			{
				spawnLocation = new Point3D(Math.floor(VENUE_BOUND_X + Math.random()*(_myWorld.tilesWide - VENUE_BOUND_X)), 0, 0);			
			}
			else
			{
				spawnLocation = new Point3D(Math.floor(VENUE_BOUND_X + Math.random()*(_myWorld.tilesWide - VENUE_BOUND_X)), 0, _myWorld.tilesDeep);							
			}
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
				var movingSkinIndex:Number = _myWorld.assetRenderer.sortedAssets.getItemIndex(person);
				_myWorld.assetRenderer.sortedAssets.removeItemAt(movingSkinIndex);
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
					(asset as Passerby).setDirection(asset.worldDestination);
				}
			}
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
			for each (var layerable:Layerable in Application.application.gdi.layerableManager.layerables)
			{
				if (layerable.symbol_name == "PeachBody")
				{
					bodyLayer.layerable = layerable;
				}
			}			
			myStyles.addItem(bodyLayer);
//			myStyles.addItem(eyeLayer);
			return myStyles;
		}		
		
		public function set listeningStations(val:ArrayCollection):void
		{
			_listeningStations = val;
		}					
		
		public function get listeningStations():ArrayCollection
		{
			return _listeningStations;
		}
		
	}
}