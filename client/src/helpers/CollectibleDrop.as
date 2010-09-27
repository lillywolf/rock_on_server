package helpers
{
	import clickhandlers.UIEvent;
	
	import com.flashdynamix.motion.Tweensy;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.events.DynamicEvent;
	import mx.events.TweenEvent;
	
	import views.WorldView;
	
	import world.ActiveAsset;
	import world.World;
	import world.WorldEvent;
	
	public class CollectibleDrop extends MovieClip
	{
		public var _view:WorldView;
		public var _world:World;
		public var _mc:MovieClip;
		
		public var subject:ActiveAsset;
		public var delay:Number;
		public var rate:Point;
		public var startTime:Number;
		public var totalTime:Number;
		public var accelerationY:Number;
		public var dropDestination:Point;
		public var bounds:Point;
		public var origin:Point;
		public var precipitatingObject:Object;
		
		public function CollectibleDrop(_subject:ActiveAsset, mc:MovieClip, _bounds:Point, world:World, view:WorldView, _delay:Number=0, _totalTime:Number=1000, _accelerationY:Number=.001, guidedDropDestination:Point=null, guidedDropOrigin:Point=null)
		{
			super();
			subject = _subject;
			_mc = mc;
			addChild(_mc);
			
			delay = _delay;
			startTime = getTimer();
			totalTime = _totalTime;
			bounds = _bounds;
			accelerationY = _accelerationY;
			_view = view;
			_world = world;
			
			setDestination(guidedDropDestination);
			setOrigin(guidedDropOrigin);
			setRate();
		
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.addEventListener(MouseEvent.CLICK, onMouseClicked);
		}
		
		public function setOrigin(guidedDropOrigin:Point):void
		{
			rate = new Point();
			if (guidedDropOrigin)
			{
				origin = guidedDropOrigin;
			}
			else
			{
				origin = new Point(subject.x, subject.y);
			}
		}
		
		public function setRate():void
		{
				rate.x = (dropDestination.x - origin.x)/totalTime;
				rate.y = (dropDestination.y - origin.y - (accelerationY * totalTime * totalTime))/(totalTime);						
		}
		
		public function setDestination(guidedDropDestination:Point):void
		{
			if (guidedDropDestination)
			{
				dropDestination = guidedDropDestination;
			}
			else
			{
				dropDestination = new Point();
				dropDestination.x = subject.x + (bounds.x - (Math.random() * bounds.x * 2));
				dropDestination.y = subject.y + Math.random() * bounds.y;
			}
		}
		
		public function onMouseClicked(evt:MouseEvent):void
		{
			var rect:Rectangle = this.getBounds(_world);
			Tweensy.to(this, {x: this.x, y: this.y - 500, scaleX: 0.3, scaleY: 0.3}, 0.4, null, delay, null, onTweenEnd, null);
			this.removeEventListener(MouseEvent.CLICK, onMouseClicked);
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			var uiEvt:UIEvent = new UIEvent(UIEvent.COLLECTIBLE_DROP_CLICKED, true);
			dispatchEvent(uiEvt);
		}
		
		private function onTweenEnd():void
		{
			var event:DynamicEvent = new DynamicEvent("removeCollectible", true, true);
			this.dispatchEvent(event);			
		}

		public function onEnterFrame(evt:Event):void
		{
			var deltaTime:Number = getTimer() - startTime;
			if (deltaTime < totalTime)
			{
				x = origin.x + (rate.x * deltaTime);
				y = origin.y + (rate.y * deltaTime) + accelerationY * (deltaTime * deltaTime);
			}
			else
			{
				x = dropDestination.x;
				y = dropDestination.y;
				var event:WorldEvent = new WorldEvent(WorldEvent.ITEM_DROPPED, subject);
				dispatchEvent(event);
			}
		}
	}	
}