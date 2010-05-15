package models
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class EssentialModel extends EventDispatcher
	{			
		public var editing:Boolean;
		
		public function EssentialModel(params:Object=null, target:IEventDispatcher=null)
		{
			super(target);
		}	
	}
}