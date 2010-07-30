package views
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	
	public class ExpandingCanvas extends Canvas
	{
		public static const EXPANSION_MULTIPLIER:Number = 0.3;
		
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
			this.addEventListener(Event.ENTER_FRAME, expandOnEnterFrame);	
			pushComponents = _pushComponents;
		}
		
		public function shrink():void
		{
			this.addEventListener(Event.ENTER_FRAME, shrinkOnEnterFrame);
		}
		
		private function shrinkOnEnterFrame(evt:Event):void
		{
			var time:Number = getTimer();
			var deltaTime:Number = time - lastTime;
			var lockedDelta:Number = Math.min(100, deltaTime);
			lastTime = time;
			var shrinkBy:Number = lockedDelta * EXPANSION_MULTIPLIER;
			var shrinkCompleteEvent:DynamicEvent;			
			
			if ((expandDirection == "up" || expandDirection == "down") && (this.height <= this.originalHeight + shrinkBy))
			{
				this.removeEventListener(Event.ENTER_FRAME, shrinkOnEnterFrame);
				shrinkCompleteEvent = new DynamicEvent("shrinkComplete", true);
				dispatchEvent(shrinkCompleteEvent);		
				shrinkBy = this.height - this.originalHeight;
			}	
			else if ((expandDirection == "right" || expandDirection == "left") && (this.width <= this.originalWidth + shrinkBy))
			{
				this.removeEventListener(Event.ENTER_FRAME, shrinkOnEnterFrame);
				shrinkCompleteEvent = new DynamicEvent("shrinkComplete", true);
				dispatchEvent(shrinkCompleteEvent);	
				shrinkBy = this.width = this.originalWidth;
			}	
			doShrink(shrinkBy);
		}
		
		private function expandOnEnterFrame(evt:Event):void
		{
			var time:Number = getTimer();
			var deltaTime:Number = time - lastTime;
			var lockedDelta:Number = Math.min(100, deltaTime);
			lastTime = time;
			var expandBy:Number = lockedDelta * EXPANSION_MULTIPLIER;
			
			if ((expandDirection == "up" || expandDirection == "down") && this.height >= (this.originalHeight + this.expandAmount - lockedDelta * EXPANSION_MULTIPLIER))
			{
				this.removeEventListener(Event.ENTER_FRAME, expandOnEnterFrame);
				expandBy = this.expandAmount + this.originalHeight - this.height;
			}	
			else if ((expandDirection == "right" || expandDirection == "left") && this.width >= (this.originalWidth + this.expandAmount - lockedDelta * EXPANSION_MULTIPLIER))
			{
				this.removeEventListener(Event.ENTER_FRAME, expandOnEnterFrame);	
				expandBy = this.expandAmount + this.originalWidth - this.width;
			}	
			doExpansion(expandBy);
		}
		
		private function doShrink(shrinkBy:Number):void
		{
			if (expandDirection == "up")
			{
				this.height -= shrinkBy;
				this.y += shrinkBy;
			}
			else if (expandDirection == "right")
			{
				this.width -= shrinkBy;
			}
			else if (expandDirection == "down")
			{
				this.height -= shrinkBy;
			}
			else if (expandDirection == "left")
			{
				this.width -= shrinkBy;
				this.x += shrinkBy;
			}
			
			if (pushComponents)
			{
				shrinkPushComponents(shrinkBy);
			}			
		}
		
		private function doExpansion(expandBy:Number):void
		{
			if (expandDirection == "up")
			{
				this.height += expandBy;
				this.y -= expandBy;
			}
			else if (expandDirection == "right")
			{
				this.width += expandBy;
			}
			else if (expandDirection == "down")
			{
				this.height += expandBy;
			}
			else if (expandDirection == "left")
			{
				this.width += expandBy;
				this.x -= expandBy;
			}
			
			if (pushComponents)
			{
				expandPushComponents(expandBy);
			}
		}
		
		private function expandPushComponents(expandBy:Number):void
		{
			for each (var uic:UIComponent in pushComponents)
			{
				if (expandDirection == "up")
				{
					uic.y -= expandBy;
				}
				else if (expandDirection == "right")
				{
					uic.x += expandBy;
				}
				else if (expandDirection == "down")
				{
					uic.y += expandBy;
				}
				else if (expandDirection == "left")
				{
					uic.x -= expandBy;
				}				
			}
		}

		private function shrinkPushComponents(shrinkBy:Number):void
		{
			for each (var uic:UIComponent in pushComponents)
			{
				if (expandDirection == "up")
				{
					uic.y += shrinkBy;
				}
				else if (expandDirection == "right")
				{
					uic.x -= shrinkBy;
				}
				else if (expandDirection == "down")
				{
					uic.y -= shrinkBy;
				}
				else if (expandDirection == "left")
				{
					uic.x += shrinkBy;
				}				
			}
		}
	}
}