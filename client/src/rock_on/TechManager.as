package rock_on
{
	import mx.collections.ArrayCollection;
	
	import world.Point3D;
	import world.World;
	
	public class TechManager extends ArrayCollection
	{
		public var _myWorld:World;
		public var _venue:Venue;
		
		public function TechManager(venue:Venue, myWorld:World, source:Array=null)
		{
			super(source);
			
			_venue = venue;
			_myWorld = myWorld;
		}
		
		public function add(tech:Tech):void
		{
			tech.myWorld = _myWorld;
			tech.venue = _venue;
			addItem(tech);
			
			var destination:Point3D = _venue.pickRandomAvailablePointWithinRect(_venue.boothsRect, _myWorld, 0);
			_myWorld.addAsset(tech, destination);
			tech.advanceState(Tech.STOPPED_STATE);
		}
	}
}