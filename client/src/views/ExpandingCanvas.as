package views
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class ExpandingCanvas extends Canvas
	{
		public static const EXPANSION_MULTIPLIER:Number = 0.15;
		
		public var expandDirection:String;
		public var expandAmount:Number;
		public var originalHeight:Number;
		public var originalWidth:Number;
		public var pushComponents:ArrayCollection;
		public var lastTime:Number = 0;			
		
		public function ExpandingCanvas()
		{
			super();
			this.addEventListener(Event.ADDED, onAdded);
		}
		
		private function onAdded(evt:Event):void
		{
			this.removeEventListener(Event.ADDED, onAdded);
			this.originalHeight = this.height.valueOf();
			this.originalWidth = this.width.valueOf();
		}
		
		public function expand(direction:String, amount:Number, _pushComponents:ArrayCollection=null):void
		{
			expandDirection = direction;
			expandAmount = amount;
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);	
			pushComponents = _pushComponents;
		}
		
		private function onEnterFrame(evt:Event):void
		{
			var time:Number = getTimer();
			var deltaTime:Number = time - lastTime;
			var lockedDelta:Number = Math.min(100, deltaTime);
			lastTime = time;
			
			if ((expandDirection == "up" || expandDirection == "down") && (this.height >= this.originalHeight + this.expandAmount))
			{
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}	
			else if ((expandDirection == "right" || expandDirection == "left") && (this.width >= this.originalWidth + this.expandAmount))
			{
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}	
			else
			{
				doExpansion(lockedDelta);
			}
		}
		
		private function doExpansion(lockedDelta:Number):void
		{
			if (expandDirection == "up")
			{
				this.height += lockedDelta * EXPANSION_MULTIPLIER;
				this.y -= lockedDelta * EXPANSION_MULTIPLIER;
			}
			else if (expandDirection == "right")
			{
				this.width += lockedDelta * EXPANSION_MULTIPLIER;
			}
			else if (expandDirection == "down")
			{
				this.height += lockedDelta * EXPANSION_MULTIPLIER;
			}
			else if (expandDirection == "left")
			{
				this.width = lockedDelta * EXPANSION_MULTIPLIER;
				this.x -= lockedDelta * EXPANSION_MULTIPLIER;
			}
			
			if (pushComponents)
			{
				expandPushComponents(lockedDelta);
			}
		}
		
		private function expandPushComponents(lockedDelta:Number):void
		{
			for each (var uic:UIComponent in pushComponents)
			{
				if (expandDirection == "up")
				{
					uic.y -= lockedDelta * EXPANSION_MULTIPLIER;
				}
				else if (expandDirection == "right")
				{
					uic.x += lockedDelta * EXPANSION_MULTIPLIER;
				}
				else if (expandDirection == "down")
				{
					uic.y += lockedDelta * EXPANSION_MULTIPLIER;
				}
				else if (expandDirection == "left")
				{
					uic.x -= lockedDelta * EXPANSION_MULTIPLIER;
				}				
			}
		}
	}
}