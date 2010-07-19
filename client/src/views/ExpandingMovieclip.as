package views
{
	import com.flashdynamix.motion.Tweensy;
	
	import fl.motion.easing.Bounce;
	import fl.motion.easing.Cubic;
	import fl.motion.easing.Linear;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import mx.events.TweenEvent;
	
	public class ExpandingMovieclip extends MovieClip
	{
		public var currentScale:Number;
		public var currentStep:int;
		public var steps:int;
		public var mc:MovieClip;
		public var bounceHeight:int;
		
		public function ExpandingMovieclip(scale:Number, mc:MovieClip, steps:int=32)
		{
			super();
			this.mc = mc;
			this.addChild(mc);
			this.mc.scaleX = scale;
			this.mc.scaleY = scale;
			currentScale = scale;
			currentStep = 0;
			this.steps = steps;
//			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function doBounce(_bounceHeight:int, duration:int = 1):void
		{
			bounceHeight = _bounceHeight;
			Tweensy.to(this, {x: this.x, y: this.y - bounceHeight}, 1, Cubic.easeIn, 0.5, null, function onUpTweenComplete():void
			{
				doDownTween();
			});	
		}
		
		public function doUpTween():void
		{
			Tweensy.to(this, {x: this.x, y: this.y - bounceHeight}, 1, Cubic.easeIn, 0.5, null, function onUpTweenComplete():void
			{
				doDownTween();
			});		
		}
		
		public function doDownTween():void
		{
			Tweensy.to(this, {x: this.x, y: this.y + bounceHeight}, 1, Bounce.easeOut, 0, null, function onDownTweenComplete():void
			{
				doUpTween();
			});				
		}
		
		private function onEnterFrame(evt:Event):void
		{
			if (currentStep < steps/2)
			{
				currentScale += 0.01;
			}
			else
			{
				currentScale -= 0.01;
			}
			if (currentStep == 31)
			{
				currentStep = 0;
			}
			else
			{
				currentStep++;			
			}
			this.mc.scaleX = currentScale;
			this.mc.scaleY = currentScale;
		}
		
	}
}