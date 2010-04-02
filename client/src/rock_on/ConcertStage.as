package rock_on
{
	import flash.events.IEventDispatcher;
	
	import models.Structure;
	
	import world.Point3D;

	public class ConcertStage extends Structure
	{
		public var stageRadiusLeft:Number;
		public var stageRadiusRight:Number;
		public var stageRadiusTop:Number;
		public var stageRadiusBottom:Number;
		
		public var _worldCoords:Point3D;		
		
		public function ConcertStage(params:Object=null, loadedClass:Class=null, target:IEventDispatcher=null)
		{
			super(params, loadedClass, target);
			width = 6;
			height = 2;
			depth = 6;
			
			stageRadiusLeft = 0;
			stageRadiusRight = 6;
			stageRadiusTop = 0;
			stageRadiusBottom = 6;		
		}
		
		override public function setProperties(params:Object):void
		{
			
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