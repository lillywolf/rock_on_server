package helpers
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import views.WorldView;
	
	import world.ActiveAsset;
	
	public class CollectibleDrop extends MovieClip
	{
		public var _view:WorldView;
		public var subject:ActiveAsset;
		public var delay:Number;
		public var rate:Point;
		public var startTime:Number;
		public var totalTime:Number;
		public var accelerationY:Number = .001;
		public var _mc:MovieClip;
		public var dropDestination:Point;
		public var bounds:Point;
		
		public function CollectibleDrop(_subject:ActiveAsset, mc:MovieClip, _bounds:Point, _delay:Number=0, _totalTime:Number=1000)
		{
			super();
			subject = _subject;
			_mc = mc;
			addChild(_mc);
			
			delay = _delay;
			startTime = getTimer();
			totalTime = _totalTime;
			bounds = _bounds;
			
			setDestination();
			rate = new Point();
			rate.x = (dropDestination.x - subject.x)/totalTime;
			rate.y = (dropDestination.y - subject.y - (accelerationY * totalTime * totalTime))/(totalTime);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function setDestination():void
		{
			dropDestination = new Point();
			dropDestination.x = subject.x + Math.random() * bounds.x;
			dropDestination.y = subject.y + Math.random() * bounds.y;
		}
		
		public function onItemClicked(evt:Event):void
		{
//			var dropDestination:Rectangle = this.getBounds(_view);
//			Tweensy.to(this, {x: dropDestination.top, y: dropDestination.y}, 0.5, null, delay, null, null);
		}
		
		public function onEnterFrame(evt:Event):void
		{
			var deltaTime:Number = getTimer() - startTime;
			if (deltaTime < totalTime)
			{
				x = subject.x + (rate.x * deltaTime);
				y = subject.y + (rate.y * deltaTime) + accelerationY * (deltaTime * deltaTime);
			}
			else
			{
				x = dropDestination.x;
				y = dropDestination.y;
			}
		}
	}	
}