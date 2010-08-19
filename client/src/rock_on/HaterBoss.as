package rock_on
{
	import mx.collections.ArrayCollection;
	
	import world.Point3D;
	import world.World;
	
	public class HaterBoss extends ArrayCollection
	{
		public var _myWorld:World;
		public var _venue:Venue;
		public var haterCreatures:ArrayCollection;
		
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
		
		public function removeHaters():void
		{
			var haterLength:int = length;
			for (var i:int = (haterLength - 1); i >= 0; i--)			
			{
				var hater:Hater = this[i] as Hater;
				remove(hater);
			}
		}
		
		public function remove(hater:Hater):void
		{
			_myWorld.removeAsset(hater);
			var index:int = this.getItemIndex(hater);
			this.removeItemAt(index);
			hater = null;
		}
//				
//		public function addAfterInitializing(hater:Hater):void
//		{
//			_myWorld.removeAsset(hater);
//			hater.reInitialize();
//			hater.lastWorldPoint = null;
//			hater.proxiedDestination = null;
//			var destination:Point3D = _venue.pickRandomAvailablePointWithinRect(_venue.boothsRect, _myWorld, 0);
//			_myWorld.addAsset(hater, destination);
//		}
		
		
	}
}