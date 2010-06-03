package helpers
{
	import flash.events.Event;
	
	import models.Creature;
	
	import world.AssetStack;

	public class CreatureEvent extends Event
	{
		public static const CREATURE_CLICKED:String = "CreatureEvent:CreatureClicked";
		public var _creature:Creature;
		public var _asset:AssetStack;
				
		public function CreatureEvent(type:String, asset:AssetStack, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_asset = asset;
			super(type, bubbles, cancelable);
		}
		
		public function get asset():AssetStack
		{
			return _asset;
		}
		
		public function get creature():Creature
		{
			return _creature;
		}
		
	}
}