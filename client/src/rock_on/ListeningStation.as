package rock_on
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import game.Counter;
	import game.CounterEvent;
	import game.Leftover;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import world.ActiveAsset;
	import world.Point3D;
	import world.World;

	public class ListeningStation extends Booth
	{
		public static const START_STATE:int = 0;
		public static const READY_TO_COLLECT_STATE:int = 1;
		public static const FAN_COLLECTION_STATE:int = 2;
		public static const FAN_ENTRY_STATE:int = 3;
		
		public static const PERMANENT_SLOT_PROBABILITY:Number = 0.02;
		public static const COLLECTION_BUFFER_TIME:int = 30;
		
		public var activeAsset:ActiveAsset;
		public var listenerCount:int;
		public var currentListenerCount:int;
		public var currentListeners:ArrayCollection;
		public var createdAt:int;
		public var stationType:String;
		public var radius:Point3D;
		public var stationTimer:Timer;
		public var counter:Counter;
		public var secondsRemaining:Number;
		
		public var _listeningStationBoss:ListeningStationBoss;
		
		public function ListeningStation(listeningStationBoss:ListeningStationBoss, boothBoss:BoothBoss, venue:Venue, params:Object=null, target:IEventDispatcher=null)
		{
			super(boothBoss, venue, params, target);
			
			_listeningStationBoss = listeningStationBoss;
			setProperties();
			currentListeners = new ArrayCollection();
		}
			
		public function setInMotion():void
		{
			initializeTimeAndState();			
		}	
				
		public function setProperties():void
		{
			radius = new Point3D(0, 0, 0);
			radius.x = Math.ceil(structure.capacity/structure.depth);
			radius.z = structure.depth;
		}	
		
		public function displayCountdown():void
		{
			counter = new Counter(secondsRemaining*1000);
			counter.addEventListener(CounterEvent.COUNTER_COMPLETE, onCounterComplete);
			counter.displayCounter();
			var uiCoordinates:flash.geom.Point = World.worldToActualCoords(new Point3D(x, y, z));
			counter.counterCanvas.x = uiCoordinates.x;
			counter.counterCanvas.y = uiCoordinates.y;
			FlexGlobals.topLevelApplication.addChild(counter.counterCanvas);
		}
		
		private function onCounterComplete(evt:CounterEvent):void
		{
			updateTimeAndState();
		}
		
		public function initializeTimeAndState():void
		{
			updateSecondsRemaining();	
			initializeListenerCount();
			
			if (secondsRemaining <= 0 && state != READY_TO_COLLECT_STATE)
			{
				advanceState(READY_TO_COLLECT_STATE);
			}	
			else
			{
				advanceState(FAN_COLLECTION_STATE);
			}							
		}
		
		private function updateTimeAndState():void
		{
			updateSecondsRemaining();				
			updateListenerCount();			
		}
		
		private function initializeListenerCount():void
		{
			listenerCount = Math.floor((structure.capacity * structure.collection_time - secondsRemaining) / structure.collection_time);
			if (listenerCount > structure.capacity)
			{
				listenerCount = structure.capacity;
			}
		}
		
		private function updateListenerCount():void
		{
			if (listenerCount < structure.capacity)
			{
				var neededListeners:int = structure.capacity - listenerCount;
			}
		}
		
		private function setupStationTimer():void
		{
			stationTimer = new Timer(secondsRemaining*1000);
			stationTimer.addEventListener(TimerEvent.TIMER, onStationTimerComplete);
			stationTimer.start();
		}
		
		public function updateSecondsRemaining():void
		{
			var currentDate:Date = new Date();
			var currentTime:Number = currentDate.getTime()/1000 + (currentDate.timezoneOffset * 60);
			secondsRemaining = (structure.collection_time * structure.capacity) - (currentTime - createdAt);
			if (secondsRemaining < 0)
			{
				secondsRemaining = 0;
			}
		}
		
		private function onStationTimerComplete(evt:TimerEvent):void
		{
			advanceState(READY_TO_COLLECT_STATE);
			removeCounter();
		}
		
		public function removeCounter():void
		{
			if (FlexGlobals.topLevelApplication.contains(counter.counterCanvas))
			{
				FlexGlobals.topLevelApplication.removeChild(counter.counterCanvas);
			}
			if (counter)
			{
				counter = null;
			}			
		}
		
		override public function advanceState(destinationState:int):void
		{
			switch (state)
			{	
				case START_STATE:
					endStartState();
					break;
				case READY_TO_COLLECT_STATE:
					endReadyToCollectState();				
					break;	
				case FAN_COLLECTION_STATE:
					endFanCollectionState();
					break;						
				case FAN_ENTRY_STATE:
					endFanEntryState();
					break;						
				default: throw new Error('no state to advance from!');
			}
			switch (destinationState)
			{
				case READY_TO_COLLECT_STATE:
					startReadyToCollectState();
					break;
				case FAN_COLLECTION_STATE:
					startFanCollectionState();
					break;
				case FAN_ENTRY_STATE:
					startFanEntryState();
					break;
				default: throw new Error('no state to advance to!');	
			}
		}
		
		private function startFanEntryState():void
		{
			state = FAN_ENTRY_STATE;
			this.in_use = false;
//			playListeningStationDestruction();
			letInNewFans();
		}
		
		private function endFanEntryState():void
		{
			
		}
		
		private function playListeningStationDestruction():void
		{
			// Play animation on movie clip and remove from server and client			
			_listeningStationBoss.remove(this);
		}
		
		private function startReadyToCollectState():void
		{
			state = READY_TO_COLLECT_STATE;
//			_listeningStationBoss.addListeners(this);
			
			if (!friendMirror)
				initializeCollectListeners();
		}	
		
		private function initializeCollectListeners():void
		{
			this.activeAsset.addEventListener(MouseEvent.CLICK, onCollectionClick);
		}
		
		private function onCollectionClick(evt:MouseEvent):void
		{
			this.activeAsset.removeEventListener(MouseEvent.CLICK, onCollectionClick);
			advanceState(ListeningStation.FAN_ENTRY_STATE);	
		}
		
		private function letInNewFans():void
		{
//			var fanCount:int = 0;	
			var fans:ArrayCollection = new ArrayCollection();
			for each (var sl:StationListener in currentListeners)
			{
				_venue.convertStationListenerToCustomer(sl, fans.length);
				removeStationListener(sl);
				fans.addItem(sl.creature);
//				fanCount++;
			}
			_venue.updateFanCount(fans, _venue, this);
			_venue.checkForMinimumFancount();
		}		
		
		private function removeStationListener(sl:StationListener):void
		{
			_venue.myWorld.removeAsset(sl);
			var index:int = this.currentListeners.getItemIndex(sl);
			this.currentListeners.removeItemAt(index);
			this.currentListenerCount--;
		}
		
		public function isSlotAvailable():Boolean
		{
			if (structure.capacity > currentListeners.length)
				return true;
			return false;
		}
		
		public function isPermanentSlotAvailable():Boolean
		{
			updateSecondsRemaining();
			var permanentSlotsAvailable:int = Math.ceil(((structure.collection_time * structure.capacity) - secondsRemaining) / structure.collection_time);
			var permanentConversionProbability:Number = (PasserbyManager.STATIONLISTENER_CONVERSION_PROBABILITY * ((PasserbyManager.SPAWN_INTERVAL_BASE + Math.floor(Math.random()*PasserbyManager.SPAWN_INTERVAL_MULTIPLIER))/1000)) / structure.collection_time;
			var temp:int = (structure.capacity * structure.collection_time) - (structure.collection_time * listenerCount + secondsRemaining);
			var secondsUntilCollectionPeriodComplete:int = structure.collection_time - temp;
			if (permanentSlotsAvailable > listenerCount && Math.random() < permanentConversionProbability)
			{
				return true;
			}
			else if (permanentSlotsAvailable - listenerCount == 1 && secondsUntilCollectionPeriodComplete < COLLECTION_BUFFER_TIME)
				return true;
			else if (permanentSlotsAvailable - listenerCount > 1)
				return true;
			return false;
		}	
			
		public function addLeftoverToStation(leftover:Leftover):void
		{
			var asset:ActiveAsset = new ActiveAsset(leftover.mc);
			asset.thinger = leftover;
			var destination:Point3D = new Point3D(this.x + this.structure.width/2 + Math.random()*this.radius.x + 2, 0, this.z - this.radius.z + Math.random()*(this.radius.z*2));
			_venue.myWorld.addAsset(asset, destination);		
		}		

		private function startFanCollectionState():void
		{
			state = FAN_COLLECTION_STATE;
			displayCountdown();
			_listeningStationBoss.addListeners(this);
			updateSecondsRemaining();
		}
			
		private function endStartState():void
		{
			
		}
		
		private function endReadyToCollectState():void
		{
		
		}
		
		private function endFanCollectionState():void
		{
			if (stationTimer)
			{
				stationTimer.stop();
				stationTimer.removeEventListener(TimerEvent.TIMER, onStationTimerComplete);
			}
		}
		
		public function isStationAvailable():Boolean
		{
			var isFree:Boolean = true;
			if (structure.capacity == currentListeners.length)
				isFree = false;
			return isFree;
		}	
		
	}
}