package views
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class ExpandingMovieclip extends MovieClip
	{
		public var currentScale:Number;
		public var currentStep:int;
		public var steps:int;
		public var mc:MovieClip;
		
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
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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