package stores
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	import models.StoreOwnedThinger;

	public class StoreMouseEvent extends MouseEvent
	{
		public var storeOwnedThinger:StoreOwnedThinger;
		
		public function StoreMouseEvent(type:String, sot:StoreOwnedThinger, bubbles:Boolean=true, cancelable:Boolean=false, localX:Number=null, localY:Number=null, relatedObject:InteractiveObject=null, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false, buttonDown:Boolean=false, delta:int=0)
		{
			super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
			storeOwnedThinger = sot;
		}
		
	}
}