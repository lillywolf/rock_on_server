package rock_on
{
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import game.GameClock;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Label;
	
	import world.Point;
	import world.Point3D;
	import world.World;

	public class ListeningStation extends Booth
	{
		public var numAttractedFans:int;
		public var createdAt:int;
		public var stationType:String;
		public var radius:Point3D;
		
		public var counterLabel:Label;
		public var hoursRemaining:Number;
		public var minutesRemaining:Number;
		public var secondsRemaining:Number;
		
		public function ListeningStation(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			setRadius();
		}
				
		public function setRadius():void
		{
			if (_structure.mc is Ticket_01)
			{
				stationType = "Gramophone";
				radius = new Point3D(1, 0, 1);
			}
			else if (_structure.mc is Booth_01)
			{
				stationType = "RecordPlayer";
				radius = new Point3D(2, 0, 1);
			}
		}	
		
		public function displayCountdown():Canvas
		{
			var secondsLeft:Number = getSecondsRemaining();
			var counterInfo:Object = GameClock.setupCountdownTimers(secondsLeft);
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
		
		public function getSecondsRemaining():Number
		{
			var listeningTime:Number;
			if (stationType == "Gramophone")
			{
				listeningTime = 172800;
			}
			else
			{
				throw new Error("Listening station type not recognized");
			}
			var currentTime:Number = new Date().getTime()/1000;
			var secondsRemaining:Number = listeningTime - (currentTime - createdAt);
			return secondsRemaining;
		}
		
	}
}