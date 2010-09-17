package clickhandlers
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import world.ActiveAsset;
	import world.World;
	
	public class UIEvent extends Event
	{
		public static const COLLECTIBLE_DROP:String = "UIEvent:CollectibleDrop";
		public static const COLLECTIBLE_DROP_BY_MOOD:String = "UIEvent:CollectibleDropByMood";
		public static const COLLECTIBLE_DROP_FROM_STAGE:String = "UIEvent:CollectibleDropFromStage";
		public static const REPLACE_BOTTOMBAR:String = "UIEvent:ReplaceBottomBar";
		
		public var xCoord:Number;
		public var yCoord:Number;
		public var asset:ActiveAsset;
		public var mc:MovieClip;
		public var parentWorld:World;
		
		public function UIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}