package rock_on
{
	import mx.collections.ArrayCollection;
	
	import world.Point3D;
	
	public class PeerBoss extends ArrayCollection
	{
		public var _venue:Venue;
		
		public function PeerBoss(venue:Venue, source:Array=null)
		{
			super(source);
			_venue = venue;
		}
		
		public function add(peer:Peer):void
		{
			this.addItem(peer);
			peer.myWorld = _venue.myWorld;
			var destination:Point3D = _venue.pickRandomAvailablePointWithinRect(_venue.boothsRect, _venue.myWorld, 0, _venue.crowdBufferRect, true, true);
			_venue.myWorld.addAsset(peer, destination);
			peer.advanceState(Peer.STOPPED_STATE);
			peer.setQuestStatus();
		}
	}
}