package controllers
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;

	public class Controller extends EventDispatcher
	{
		[Bindable] public var _essentialModelController:EssentialModelController;
		public function Controller(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(target);
			_essentialModelController = essentialModelController;
		}	
		
		public function getObjectIndexById(arrayCollection:ArrayCollection, id:int):int
		{
			for each (var obj:Object in arrayCollection)
			{
				if (obj.id == id)
				{
					var objectId:int = arrayCollection.getItemIndex(obj);
					return objectId;
				}
			}
			return -1;
		}	
		
		public function set essentialModelController(val:EssentialModelController):void
		{
			_essentialModelController = val;
		}		
		
		public function get essentialModelController():EssentialModelController
		{
			return _essentialModelController;
		}
	}
}