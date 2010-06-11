package world
{
	import flash.events.TimerEvent;
	
	public class WorldTimerEvent extends TimerEvent
	{
		public static const MOVE_DELAY_COMPLETE:String = "World:MoveDelayComplete";
		
		public var _asset:ActiveAsset;
		public var _destination:Point3D;
		public var _avoidStructures:Boolean;
		public var _avoidPeople:Boolean;
		
		public function WorldTimerEvent(type:String, asset:ActiveAsset, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_asset = asset;
			super(type, bubbles, cancelable);
		}
		
		public function set destination(val:Point3D):void
		{
			_destination = val;
		}
		
		public function get destination():Point3D
		{
			return _destination;
		}
		
		public function set avoidStructures(val:Boolean):void
		{
			_avoidStructures = val;
		}
		
		public function get avoidStructures():Boolean
		{
			return _avoidStructures;
		}
		
		public function set avoidPeople(val:Boolean):void
		{
			_avoidPeople = val;
		}
		
		public function get avoidPeople():Boolean
		{
			return _avoidPeople;
		}
	}
}