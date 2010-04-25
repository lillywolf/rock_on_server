package rock_on
{
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import game.GameClock;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.events.DynamicEvent;
	
	import world.Point;
	import world.Point3D;
	import world.World;

	public class ListeningStation extends Booth
	{
		public static const START_STATE:int = 0;
		public static const FAN_BUTTON:int = 1;
		public static const FAN_COLLECTION:int = 2;
		
		public var state:int;
		public var listenerCount:int;
		public var currentListenerCount:int;
		public var capacity:int;
		public var createdAt:int;
		public var stationType:String;
		public var radius:Point3D;
		public var listeningTime:int;
		public var stationTimer:Timer;
		
		public var counterLabel:Label;
		public var hoursRemaining:Number;
		public var minutesRemaining:Number;
		public var secondsRemaining:Number;
		
		public function ListeningStation(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			setProperties();
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
				capacity = 2;
				listeningTime = 172800;				
			}
			else if (_structure.mc is Booth_01)
			{
				stationType = "RecordPlayer";
				radius = new Point3D(2, 0, 1);
				capacity = 3;
				listeningTime = 86400;
			}
		}	
		
		public function displayCountdown():Canvas
		{
			var counterInfo:Object = GameClock.setupCountdownTimers(secondsRemaining);
			(counterInfo.secondTimer as Timer).addEventListener(TimerEvent.TIMER, onSecondTimer);
			(counterInfo.secondTimer as Timer).start();
			
			var canvas:Canvas = new Canvas();
			counterLabel = new Label();
			hoursRemaining = counterInfo.hoursRemaining;
			minutesRemaining = counterInfo.minutesRemaining;
			secondsRemaining = counterInfo.secondsRemaining;
			updateCounterLabel();
			canvas.addChild(counterLabel);
			var uiCoordinates:Point = World.worldToActualCoords(new Point3D(x, y, z));
			canvas.x = uiCoordinates.x;
			canvas.y = uiCoordinates.y;
			return canvas;
		}
		
		private function checkIfComplete():void
		{
			if (hoursRemaining == 0 && minutesRemaining == 0 && secondsRemaining == 0)		
			{
				Alert.show("Time's up!");
			}	
		}
		
		private function onSecondTimer(evt:TimerEvent):void
		{
			if (secondsRemaining%60 > 0)
			{
				secondsRemaining = secondsRemaining - 1;			
			}
			else if (secondsRemaining%60 == 0 && minutesRemaining%60 > 0)
			{
				minutesRemaining = minutesRemaining - 1;
				secondsRemaining = 59;
			}
			else if (secondsRemaining%60 == 0 && minutesRemaining%60 == 0 && hoursRemaining > 0)
			{
				hoursRemaining = hoursRemaining - 1;
				minutesRemaining = 59;
				secondsRemaining = 59;
			}
			else
			{
				checkIfComplete();
			}
			updateCounterLabel();
		}
		
		private function updateCounterLabel():void
		{
			if (minutesRemaining < 10)
			{
				var minutesString:String = "0" + minutesRemaining.toString();
			}
			else
			{
				minutesString = minutesRemaining.toString();
			}
			if (secondsRemaining < 10)
			{
				var secondsString:String = "0" + secondsRemaining.toString();
			}
			else
			{
				secondsString = secondsRemaining.toString();
			}
			counterLabel.text = hoursRemaining.toString() + ":" + minutesString + ":" + secondsString;
		}
		
		private function updateTimeAndState():void
		{
			updateSecondsRemaining();	
			
			updateListenerCount();
			
			if (secondsRemaining < 0 && state != FAN_BUTTON)
			{
				advanceState(FAN_BUTTON);
			}	
			else
			{
				advanceState(FAN_COLLECTION);
			}				
		}
		
		private function updateListenerCount():void
		{
			listenerCount = Math.round(capacity * (listeningTime - secondsRemaining) / listeningTime);
			if (listenerCount > capacity)
			{
				listenerCount = capacity;
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
			var currentTime:Number = new Date().getTime()/1000;
			secondsRemaining = listeningTime - (currentTime - createdAt);
		}
		
		private function onStationTimerComplete(evt:TimerEvent):void
		{
			advanceState(FAN_BUTTON);
		}
		
		public function advanceState(destinationState:int):void
		{
			switch (state)
			{	
				case START_STATE:
					endStartState();
					break;
				case FAN_BUTTON:
					endFanButtonState();				
					break;	
				case FAN_COLLECTION:
					endFanCollectionState();
					break;						
				default: throw new Error('no state to advance from!');
			}
			switch (destinationState)
			{
				case FAN_BUTTON:
					startFanButtonState();
					break;
				case FAN_COLLECTION:
					startFanCollectionState();
					break;
				default: throw new Error('no state to advance to!');	
			}
		}
		
		private function startFanButtonState():void
		{
			state = FAN_BUTTON;
			var evt:DynamicEvent = new DynamicEvent("fanButtonState", true, true);
			dispatchEvent(evt);
		}		
		
		private function startFanCollectionState():void
		{
			state = FAN_COLLECTION;
			updateSecondsRemaining();
			setupStationTimer();			
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
	}
}