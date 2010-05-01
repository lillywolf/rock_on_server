package rock_on
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;

	public class PasserbyEvent extends MouseEvent
	{
		public static const CLICK:String = "PasserbyEvent:Click";
		
		public var _station:ListeningStation;
		
		public function PasserbyEvent(type:String, station:ListeningStation, bubbles:Boolean=true, cancelable:Boolean=false, localX:Number=null, localY:Number=null, relatedObject:InteractiveObject=null, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false, buttonDown:Boolean=false, delta:int=0)
		{
			_station = station;
			super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
		}
		
	}
}