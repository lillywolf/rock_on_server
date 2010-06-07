package game
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Label;

	public class Counter extends EventDispatcher
	{
		public var displayedTime:Date;
		public var secondTimer:Timer;
		
		public var totalTime:int;
		public var hoursRemaining:Number;
		public var minutesRemaining:Number;
		public var secondsRemaining:Number;
		public var counterCanvas:Canvas;
		public var counterLabel:Label;
		
		public function Counter(totalTime:int, target:IEventDispatcher=null)
		{
			super(target);
			totalTime = totalTime;
			
			displayedTime = new Date();
			secondTimer = new Timer(1000);
			
			updateCounter(totalTime);
			startTimers();
		}
		
		public function updateCounter(totalTime:int):void
		{
			displayedTime.setTime(totalTime);
			hoursRemaining = displayedTime.getUTCHours();
			minutesRemaining = displayedTime.getUTCMinutes();
			secondsRemaining = displayedTime.getUTCSeconds();
		}
		
		public function startTimers():void
		{
			secondTimer.addEventListener(TimerEvent.TIMER, onSecondTimer);
			secondTimer.start();			
		}	
		
		public function displayCounter():void
		{
			counterCanvas = new Canvas();
			counterLabel = new Label();
			updateCounterLabel();
			counterCanvas.addChild(counterLabel);
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
		
		private function checkIfComplete():void
		{
			if (hoursRemaining == 0 && minutesRemaining == 0 && secondsRemaining == 0)		
			{
				secondTimer.stop();
				var evt:CounterEvent = new CounterEvent(CounterEvent.COUNTER_COMPLETE, true, true);
				dispatchEvent(evt);
			}	
		}				
				
	}
}