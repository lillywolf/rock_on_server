package models
{
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	public class CreatureGroup extends EssentialModel
	{
		public var _name:String;
		public var _creatures:ArrayCollection;
		public var _id:int;
		public var _user_id:int;
		public var _owned_dwelling_id:int;
		
		public function CreatureGroup(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			_id = params.id;
			_creatures = new ArrayCollection();
			_creatures.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCreatureAdded);
			
			updateProperties(params);
		}
		
		public function updateProperties(params:Object):void
		{
			_owned_dwelling_id = params.owned_dwelling_id;
			_user_id = params.user_id;
			_name = params.name;
		}
		
		private function onCreatureAdded(evt:CollectionEvent):void
		{
			
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
		
		public function set owned_dwelling_id(val:int):void
		{
			_owned_dwelling_id = val;
		}
		
		public function get owned_dwelling_id():int
		{
			return _owned_dwelling_id;
		}
		
		public function set user_id(val:int):void
		{
			_user_id = val;
		}
		
		public function get user_id():int
		{
			return _user_id;
		}
		
	}
}