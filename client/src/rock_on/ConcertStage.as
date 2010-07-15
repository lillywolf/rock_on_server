package rock_on
{
	import flash.events.IEventDispatcher;
	
	import models.OwnedStructure;
	
	import world.Point3D;

	public class ConcertStage extends OwnedStructure
	{
		public var stageRadiusLeft:Number;
		public var stageRadiusRight:Number;
		public var stageRadiusTop:Number;
		public var stageRadiusBottom:Number;
		
		public var stageEntryPoint:Point3D;
		public var _worldCoords:Point3D;		
				
		public function ConcertStage(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			
			stageRadiusLeft = 0;
			stageRadiusRight = 6;
			stageRadiusTop = 0;
			stageRadiusBottom = 6;						
		}	
		
		public function set worldCoords(val:Point3D):void
		{
			_worldCoords = val;
		}
		
		public function get worldCoords():Point3D
		{
			return _worldCoords;
		}		
		
	}
}