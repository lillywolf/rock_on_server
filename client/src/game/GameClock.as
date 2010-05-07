package game
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.DateField;

	public class GameClock extends EventDispatcher
	{
		public static const TIME_BETWEEN_SHOWS:int = 86400000;
		
		public var _lastShowtime:Date;
		public var _lastShowtimeUnix:Number;
		public var sessionTimer:Timer;
		public var hourTimer:Timer;
		public var minuteTimer:Timer;
		public var secondTimer:Timer;
		
		public var displayedCountdownTime:Date;
		public var hoursRemainingUntilShow:Number;
		public var minutesRemainingUntilShow:Number;
		public var secondsRemainingUntilShow:Number;
		public function GameClock(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function convertStringTimeToUnixTime(val:String):int
		{
			// Assumes PST for now
			
			var datePart:String = val.split("T")[0];
			var timePart:String = (val.split("T")[1] as String).split("Z")[0];
			var hours:Number = Number(timePart.split(":")[0]);
			var minutes:Number = Number(timePart.split(":")[1]);
			var seconds:Number = Number(timePart.split(":")[2]);
			var dateObject:Date = DateField.stringToDate(datePart, "YYYY-MM-DD");
			var currentHours:Number = dateObject.setHours(hours, minutes, seconds, 0);
			var unixTime:int = dateObject.getTime()/1000;
			
			return unixTime;
		}	
		
		public static function convertStandardStringTimeToUnixTime(val:String):int
		{
			var datePart:String = val.split(" ")[0];
			var timePart:String = val.split(" ")[1];
			var hours:Number = Number(timePart.split(":")[0]);
			var minutes:Number = Number(timePart.split(":")[1]);
			var seconds:Number = Number(timePart.split(":")[2]);
			var dateObject:Date = DateField.stringToDate(datePart, "YYYY-MM-DD");
			var currentHours:Number = dateObject.setHours(hours, minutes, seconds, 0);
			var unixTime:int = dateObject.getTime()/1000;
			
			return unixTime;						
		}
		
		public function updateLastShowtime(val:String):void
		{
			var datePart:String = val.split("T")[0];
			var timePart:String = (val.split("T")[1] as String).split("Z")[0];
			var hours:Number = Number(timePart.split(":")[0]);
			var minutes:Number = Number(timePart.split(":")[1]);
			var seconds:Number = Number(timePart.split(":")[2]);
			_lastShowtime = DateField.stringToDate(datePart, "YYYY-MM-DD");
			var currentHours:Number = _lastShowtime.setHours(hours, minutes, seconds, 0);
			_lastShowtimeUnix = _lastShowtime.getTime()/1000;
			
			var secondsUntilNextShow:Number = getSecondsUntilNextShow();
			startShowCountdown(secondsUntilNextShow*1000);
		}
		
		public function startShowCountdown(startTime:Number):void
		{
			sessionTimer = new Timer(startTime);
			hourTimer = new Timer(3600000);
			minuteTimer = new Timer(60000);
			secondTimer = new Timer(1000);
			hourTimer.addEventListener(TimerEvent.TIMER, onHourTimer);
			minuteTimer.addEventListener(TimerEvent.TIMER, onMinuteTimer);
			secondTimer.addEventListener(TimerEvent.TIMER, onSecondTimer);
			sessionTimer.start();
			hourTimer.start();
			minuteTimer.start();
			secondTimer.start();
			
			displayedCountdownTime = new Date();
			displayedCountdownTime.setTime(getSecondsUntilNextShow());
			hoursRemainingUntilShow = displayedCountdownTime.getHours();
			minutesRemainingUntilShow = displayedCountdownTime.getMinutes();
			secondsRemainingUntilShow = displayedCountdownTime.getSeconds();
		}
		
		public static function setupCountdownTimers(secondsRemaining:Number):Object
		{
			var hourTime:Timer = new Timer(3600000);
			var minuteTime:Timer = new Timer(60000);
			var secondTime:Timer = new Timer(1000);
			
			var displayedCounter:Date = new Date();
			var millisecondsRemaining:Number = secondsRemaining*1000;
			displayedCounter.setTime(millisecondsRemaining);
			var hoursRemaining:Number = displayedCounter.getHours();
			var minutesRemaining:Number = displayedCounter.getMinutes();
			var secondsRemaining:Number = displayedCounter.getSeconds();
			var timerObject:Object = {hourTimer: hourTime, minuteTimer: minuteTime, secondTimer: secondTime, hoursRemaining: hoursRemaining, minutesRemaining: minutesRemaining, secondsRemaining: secondsRemaining};
			return timerObject;
		}
		
		private function onHourTimer(evt:TimerEvent):void
		{
			hoursRemainingUntilShow--;
		}
		
		private function onMinuteTimer(evt:TimerEvent):void
		{
			minutesRemainingUntilShow--;
		}
		
		private function onSecondTimer(evt:TimerEvent):void
		{
			secondsRemainingUntilShow--;
		}
		
		public function getSecondsUntilNextShow():Number
		{
			var currentDate:Date = new Date();
			var currentUnixTime:Number = currentDate.getTime()/1000;
			var secondsUntilNextShow:Number = TIME_BETWEEN_SHOWS - (currentUnixTime - _lastShowtimeUnix)
			return secondsUntilNextShow;
		}

		public function set lastShowtime(val:Date):void
		{
			_lastShowtime = val;
		}
		
		public function get lastShowtime():Date
		{
			return _lastShowtime;
		}
		
	}
}