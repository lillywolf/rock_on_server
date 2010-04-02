package controllers
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;

	public class Manager extends EventDispatcher
	{
		[Bindable] public var _essentialModelManager:EssentialModelManager;
		public function Manager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(target);
			_essentialModelManager = essentialModelManager;
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
		
		public function set essentialModelManager(val:EssentialModelManager):void
		{
			_essentialModelManager = val;
		}		
		
		public function get essentialModelManager():EssentialModelManager
		{
			return _essentialModelManager;
		}
	}
}