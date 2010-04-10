package controllers
{
	import flash.events.Event;

	public class EssentialEvent extends Event
	{
		public static const INSTANCE_LOADED:String = "Essential:InstanceLoaded";
		public static const PARENT_ASSIGNED:String = "Essential:ParentAssigned";	
		public var _instance:Object;
		public var _model:String;
		
		public function EssentialEvent(type:String, instance:Object=null, model:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_instance = instance;
			_model = model;
		}
		
		public function get instance():Object
		{
			return _instance;
		}
		
		public function get model():String
		{
			return _model;
		}
		
	}
}