package controllers
{
	import flash.events.Event;
	
	import game.GameDataInterface;
	
	import models.User;

	public class EssentialEvent extends Event
	{
		public static const INSTANCE_LOADED:String = "Essential:InstanceLoaded";
		public static const PARENT_ASSIGNED:String = "Essential:ParentAssigned";	
		public static const LOADING_AND_INSTANTIATION_COMPLETE:String = "Essential:LoadingAndInstantiationComplete";
		public static const OWNED_SONGS_LOADED:String = "Essential:OwnedSongsLoaded";	
		public static const OWNED_STRUCTURES_LOADED:String = "Essential:OwnedStructuresLoaded";	
		public static const OWNED_LAYERABLES_LOADED:String = "Essential:OwnedLayerablesLoaded";	
		public static const OWNED_DWELLINGS_LOADED:String = "Essential:OwnedDwellingsLoaded";	
		public static const OWNED_USABLES_LOADED:String = "Essential:OwnedUsablesLoaded";	
		public var _instance:Object;
		public var _model:String;
		public var _user:User;
		public var _gdi:GameDataInterface;
		
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
		
		public function set user(val:User):void
		{
			_user = val;
		}
		
		public function get user():User
		{
			return _user;
		}
		
		public function set gdi(val:GameDataInterface):void
		{
			_gdi = val;
		}
		
		public function get gdi():GameDataInterface
		{
			return _gdi;
		}
		
	}
}