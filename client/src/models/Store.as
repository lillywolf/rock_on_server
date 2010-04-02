package models
{
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;

	public class Store extends EssentialModel
	{
		public var _store_owned_thingers:ArrayCollection;
		public var _id:int;
		public var _name:String;
		
		public function Store(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			store_owned_thingers = new ArrayCollection();
			_id = params.id;
			_name = params.name;						
		}
		
		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set name(val:String):void
		{
			_name = val;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set store_owned_thingers(val:ArrayCollection):void
		{
			_store_owned_thingers = val;
		}
		
		public function get store_owned_thingers():ArrayCollection
		{
			return _store_owned_thingers;
		}				
		
	}
}