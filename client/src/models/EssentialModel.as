package models
{
	import controllers.EssentialModelManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class EssentialModel extends EventDispatcher
	{			
		public function EssentialModel(params:Object=null, target:IEventDispatcher=null)
		{
			super(target);
		}	
	}
}