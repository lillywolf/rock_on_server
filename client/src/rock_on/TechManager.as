package rock_on
{
	import mx.collections.ArrayCollection;
	
	import world.Point3D;
	import world.World;
	
	public class TechManager extends ArrayCollection
	{
		public var _myWorld:World;
		public var _venue:Venue;
		public var techCreatures:ArrayCollection;
		
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
		
		public function removeTechs():void
		{
			var techLength:int = length;
			for (var i:int = (techLength - 1); i >= 0; i--)				
			{
				var tech:Tech = this[i] as Tech;
				remove(tech);
			}
		}
		
		public function remove(tech:Tech):void
		{
			_myWorld.removeAsset(tech);
			var index:int = this.getItemIndex(tech);
			this.removeItemAt(index);
			tech = null;
		}		
		
		public function addAfterInitializing(tech:Tech):void
		{
			_myWorld.removeAsset(tech);
			tech.lastWorldPoint = null;
			tech.proxiedDestination = null;
			tech.worldCoords = null;
			var destination:Point3D = _venue.pickRandomAvailablePointWithinRect(_venue.boothsRect, _venue.myWorld, 0, null, true);
			_myWorld.addAsset(tech, destination);
			tech.reInitialize();
		}			
	}
}