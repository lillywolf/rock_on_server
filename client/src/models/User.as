package models
{
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import stores.StoreEvent;

	public class User extends EssentialModel
	{
		public var _id:int;
		public var _snid:int;
		public var _xp:int;
		public var _credits:int;
		public var _premium_credits:int;
		
		public var _owned_layerables:ArrayCollection;
		public var _owned_structures:ArrayCollection;
		
		public function User(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			
			_owned_layerables = new ArrayCollection();
			_owned_structures = new ArrayCollection();
			_owned_layerables.addEventListener(CollectionEvent.COLLECTION_CHANGE, onLayerableAdded);
			_owned_structures.addEventListener(CollectionEvent.COLLECTION_CHANGE, onStructureAdded);
			
			if (params)
			{			
				setEssentialProperties(params);			
			}
		}
		
		public function setEssentialProperties(params:Object):void
		{
			_id = params.id;
			_xp = params.xp;
			_credits = params.credits;
			_premium_credits = params.premium_credits;	
			_snid = params.snid;		
		}
		
		private function onStructureAdded(evt:CollectionEvent):void
		{
			var ownedStructure:OwnedStructure = evt.items[0] as OwnedStructure;
			ownedStructure.addEventListener('parentLoaded', onParentLoaded);
		}
		
		private function onLayerableAdded(evt:CollectionEvent):void
		{
			var ownedLayerable:OwnedLayerable = evt.items[0] as OwnedLayerable;
			ownedLayerable.addEventListener('parentLoaded', onParentLoaded);
		}
		
		private function onParentLoaded(evt:DynamicEvent):void
		{	
			var thingerParent:Object = evt.thinger;
			if (thingerParent.mc)
			{
				var storeEvent:StoreEvent = new StoreEvent(StoreEvent.THINGER_PURCHASED, evt.thinger, true, true);
				dispatchEvent(storeEvent);				
			}
			else
			{
				(thingerParent as EssentialModel).addEventListener('movieClipLoaded', onMovieClipLoaded);
			}
			
			var thinger:EssentialModel = evt.target as EssentialModel;
			thinger.removeEventListener('parentLoaded', onParentLoaded);
		}
		
		private function onMovieClipLoaded(evt:DynamicEvent):void
		{
			var storeEvent:StoreEvent = new StoreEvent(StoreEvent.THINGER_PURCHASED, evt.thinger, true, true);
			dispatchEvent(storeEvent);
			
			var thinger:EssentialModel = evt.target as EssentialModel;
			thinger.removeEventListener('movieClipLoaded', onMovieClipLoaded);
		}
		
		public function updateProperties(params:Object):void
		{
			_id = params.id;
			_xp = params.xp;
			_credits = params.credits;
			_premium_credits = params.premium_credits;			
		}

		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set owned_layerables(val:ArrayCollection):void
		{
			_owned_layerables = val;
		}
		
		public function get owned_layerables():ArrayCollection
		{
			return _owned_layerables;
		}
		
		public function set owned_structures(val:ArrayCollection):void
		{
			_owned_structures = val;
		}
		
		public function get owned_structures():ArrayCollection
		{
			return _owned_structures;
		}
		
		public function set credits(val:int):void
		{
			_credits = val;
		}
		
		public function get credits():int
		{
			return _credits;
		}
		
		public function set snid(val:int):void
		{
			_snid = val;
		}
		
		public function get snid():int
		{
			return _snid;
		}
		
	}
}