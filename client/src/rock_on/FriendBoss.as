package rock_on
{
	import mx.collections.ArrayCollection;
	
	import world.Point3D;
	import world.World;
	
	public class FriendBoss extends ArrayCollection
	{
		public var _myWorld:World;
		public var _venue:Venue;
		
		public function FriendBoss(venue:Venue, myWorld:World, source:Array=null)
		{
			super(source);
			_myWorld = myWorld;
			_venue = venue;
		}
		
		public function add(friend:Friend):void
		{
			this.addItem(friend);
			friend.myWorld = _myWorld;
					
			var destination:Point3D = _venue.pickRandomAvailablePointWithinRect(_venue.boothsRect, _myWorld, 0, null, true);
			_myWorld.addAsset(friend, destination);
//			friend.addGlowFilter();
			friend.advanceState(Friend.STOPPED_STATE);
		}		
	}
}