package rock_on
{
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import game.Counter;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	import world.ActiveAsset;
	import world.Point;
	import world.Point3D;
	import world.World;

	public class ListeningStation extends Booth
	{
		public static const START_STATE:int = 0;
		public static const FAN_BUTTON_STATE:int = 1;
		public static const FAN_COLLECTION_STATE:int = 2;
		public static const FAN_ENTRY_STATE:int = 3;
		
		public var activeAsset:ActiveAsset;
		public var listenerCount:int;
		public var currentListenerCount:int;
		public var currentListeners:ArrayCollection;
//		public var capacity:int;
		public var createdAt:int;
		public var stationType:String;
		public var radius:Point3D;
//		public var listeningTime:int;
		public var stationTimer:Timer;
		public var counter:Counter;
		public var secondsRemaining:Number;
		
		public var _listeningStationManager:ListeningStationManager;
		
		public function ListeningStation(listeningStationManager:ListeningStationManager, boothManager:BoothManager, venue:Venue, params:Object=null, target:IEventDispatcher=null)
		{
			super(boothManager, venue, params, target);
			
			_listeningStationManager = listeningStationManager;
			setProperties();
			currentListeners = new ArrayCollection();
		}
			
		public function setInMotion():void
		{
			updateTimeAndState();
		}	
				
		public function setProperties():void
		{
			if (_structure.mc is Ticket_01)
			{
				stationType = "Gramophone";
				radius = new Point3D(1, 0, 1);
//				capacity = 2;
//				listeningTime = 172800;				
			}
			else if (_structure.mc is Booth_01)
			{
				stationType = "RecordPlayer";
				radius = new Point3D(2, 0, 1);
//				capacity = 3;
//				listeningTime = 86400;
			}
		}	
		
		public function displayCountdown():void
		{
			counter = new Counter(secondsRemaining*1000);
			counter.displayCounter();
			var uiCoordinates:Point = World.worldToActualCoords(new Point3D(x, y, z));
			counter.counterCanvas.x = uiCoordinates.x;
			counter.counterCanvas.y = uiCoordinates.y;
			Application.application.addChild(counter.counterCanvas);
		}
		
		private function updateTimeAndState():void
		{
			updateSecondsRemaining();	
			
			updateListenerCount();
			
			if (secondsRemaining < 0 && state != FAN_BUTTON_STATE)
			{
				advanceState(FAN_BUTTON_STATE);
			}	
			else
			{
				advanceState(FAN_COLLECTION_STATE);
			}				
		}
		
		private function updateListenerCount():void
		{
			listenerCount = Math.floor((structure.capacity * structure.collection_time - secondsRemaining) / structure.collection_time);
			if (listenerCount > structure.capacity)
			{
				listenerCount = structure.capacity;
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
		}
		
		private function onStationTimerComplete(evt:TimerEvent):void
		{
			advanceState(FAN_BUTTON_STATE);
		}
		
		override public function advanceState(destinationState:int):void
		{
			switch (state)
			{	
				case START_STATE:
					endStartState();
					break;
				case FAN_BUTTON_STATE:
					endFanButtonState();				
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
				case FAN_BUTTON_STATE:
					startFanButtonState();
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
			playListeningStationDestruction();
		}
		
		private function endFanEntryState():void
		{
			
		}
		
		private function playListeningStationDestruction():void
		{
			// Play animation on movie clip
			
			// Remove from server and client
			
			_listeningStationManager.remove(this);
		}
		
		private function startFanButtonState():void
		{
			state = FAN_BUTTON_STATE;
			_listeningStationManager.addListeners(this);
			_listeningStationManager.onFanButtonState(this);
		}		
		
		private function startFanCollectionState():void
		{
			state = FAN_COLLECTION_STATE;
			displayCountdown();
			_listeningStationManager.addListeners(this);
			updateSecondsRemaining();
		}
			
		private function endStartState():void
		{
			
		}
		
		private function endFanButtonState():void
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
			{
				isFree = false;
			}
			return isFree;
		}	
		
	}
}