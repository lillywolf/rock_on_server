package rock_on
{
	import mx.collections.ArrayCollection;
	
	import world.Point3D;
	import world.World;
	
	public class FriendBoss extends ArrayCollection
	{
		public var _myWorld:World;
		public var _venue:Venue;
		public var friendCreatures:ArrayCollection;
		
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
		
		public function removeFriends():void
		{
			var friendLength:int = length;
			for (var i:int = (friendLength - 1); i >= 0; i--)				
			{
				var friend:Friend = this[i] as Friend;
				remove(friend);
			}
		}
		
		public function remove(friend:Friend):void
		{
			var index:int = this.getItemIndex(friend);
			this.removeItemAt(index);
			_myWorld.removeAsset(friend);
			friend = null;
		}		
		
		public function addAfterInitializing(friend:Friend):void
		{
			_myWorld.removeAsset(friend);
			friend.lastWorldPoint = null;
			friend.proxiedDestination = null;
			friend.currentDestination = null;
			friend.worldCoords = null;
			var destination:Point3D = _venue.pickRandomAvailablePointWithinRect(_venue.boothsRect, _venue.myWorld, 0, null, true);
			_myWorld.addAsset(friend, destination);
			friend.reInitialize();
		}			
	}
}