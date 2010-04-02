package models
{
	import flash.events.IEventDispatcher;

	public class Humanoid extends Creature
	{
		public var layerableOrder:Array;
		public function Humanoid(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
		}
		
		public function defineLayerableOrder():void
		{
			layerableOrder["walk_toward"] = ["body", "instrument"];
			layerableOrder["walk_away"] = ["instrument", "body"];
		}
	}
}