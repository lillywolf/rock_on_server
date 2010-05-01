package rock_on
{
	import flash.events.IEventDispatcher;
	
	import models.OwnedDwelling;
	
	import mx.collections.ArrayCollection;
	
	import world.Point3D;

	public class Venue extends OwnedDwelling
	{
		public var lastShowTime:int;
		public var mainEntrance:Point3D;
		public var entryPoints:ArrayCollection;
		
		public function Venue(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			
			entryPoints = new ArrayCollection();
			setEntrance(params);
			
			if (params['dwelling'])
			{
				dwelling = params.dwelling;
			}			
		}
		
		private function setEntrance(params:Object=null):void
		{
			mainEntrance = new Point3D(14, 0, 10);
		}
		
		public function updateFanCount(fansToAdd:int):void
		{
			
		}
		
	}
}