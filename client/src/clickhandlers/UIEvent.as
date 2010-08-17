package clickhandlers
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import world.ActiveAsset;
	
	public class UIEvent extends Event
	{
		public static const COLLECTIBLE_DROP:String = "UIEvent:CollectibleDrop";
		public static const REPLACE_BOTTOMBAR:String = "UIEvent:ReplaceBottomBar";
		
		public var xCoord:Number;
		public var yCoord:Number;
		public var asset:ActiveAsset;
		public var mc:MovieClip;
		
		public function UIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}