package helpers
{
	import mx.collections.ArrayCollection;
	
	import world.World;

	public class SpacesManager extends ArrayCollection
	{
		public var _myWorld:World;
		
		public function SpacesManager(source:Array=null)
		{
			super(source);
		}
		
		public function update():void
		{
			
		}
		
		public function set myWorld(val:World):void
		{
			_myWorld = val;
		}
		
		public function get myWorld():World
		{
			return _myWorld;
		}
		
	}
}