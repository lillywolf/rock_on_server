package game
{
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	import models.StoreOwnedThinger;
	

	public class ImposterOwnedStructure extends OwnedStructure
	{
		public var _sot:StoreOwnedThinger;
		
		public function ImposterOwnedStructure(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
		}
		
		override public function updateProperties(params:Object):void
		{	
			if (params.structure)
			{
				_structure = params.structure;
				_structure_id = params.structure.id;
				setMovieClipCopy();
			}
		}
		
		public function setMovieClipCopy():void
		{
			var className:String = flash.utils.getQualifiedClassName(_structure.mc);
			var klass:Class = EssentialModelReference.getClassCopy(className);
			_structure.mc = new klass();
			_structure.mc.scaleX = 1;
			_structure.mc.scaleY = 1;			
		}
		
		public function set sot(val:StoreOwnedThinger):void
		{
			_sot = val;
		}
		
		public function get sot():StoreOwnedThinger
		{
			return _sot;
		}
		
	}
}