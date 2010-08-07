package rock_on
{
	import mx.collections.ArrayCollection;
	
	import world.Point3D;
	import world.World;
	
	public class HaterBoss extends ArrayCollection
	{
		public var _myWorld:World;
		public var _venue:Venue;
		
		public function HaterBoss(venue:Venue, myWorld:World, source:Array=null)
		{
			super(source);
			_venue = venue;
			_myWorld = myWorld;
		}
		
		public function add(hater:Hater):void
		{
			this.addItem(hater);
			hater.myWorld = _myWorld;
			
			var destination:Point3D = _venue.pickRandomAvailablePointWithinRect(_venue.boothsRect, _myWorld, 0);
			_myWorld.addAsset(hater, destination);
//			hater.addGlowFilter();
			hater.advanceState(Hater.STOPPED_STATE);
		}
	}
}