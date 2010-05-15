package controllers
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import game.GameDataInterface;
	
	import models.Store;
	import models.StoreOwnedThinger;
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	
	import server.ServerDataEvent;
	
	import stores.StoreEvent;
	import stores.StoreOwnedThingerUIComponent;
	import stores.StoreUIComponent;

	public class StoreManager extends Manager
	{
		[Bindable] public var stores:ArrayCollection;
		[Bindable] public var _user:User;
		[Bindable] public var _gdi:GameDataInterface;
		
		public function StoreManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
			stores = essentialModelManager.stores;
			
			essentialModelManager.users.addEventListener(CollectionEvent.COLLECTION_CHANGE, onUserLoaded);
		}
		
		public function onUserLoaded(evt:CollectionEvent):void
		{
			_user = essentialModelManager.users[0];
			essentialModelManager.users.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onUserLoaded);
		}

		public function getStoreUIComponent(store:Store):UIComponent
		{
			var uic:StoreUIComponent = new StoreUIComponent(store);
			uic.addDefaultStyle();			
			uic.store = store;
			var index:int = 0;
			for each (var sot:StoreOwnedThinger in store.store_owned_thingers)
			{
				var container:StoreOwnedThingerUIComponent = new StoreOwnedThingerUIComponent(sot);
				addStoreOwnedThingerToStore(uic, container, index);
				index++;
			}
			uic.addEventListener(MouseEvent.CLICK, onStoreClicked);
			return uic;
		}
		
		private function addStoreOwnedThingerToStore(uic:StoreUIComponent, container:StoreOwnedThingerUIComponent, index:int):void
		{
			container.x = index * (StoreOwnedThingerUIComponent.CONTAINER_WIDTH + StoreUIComponent.PADDING_X);
			uic.canvas.addChild(container);
		}
		
		public function onStoreClicked(evt:MouseEvent):void
		{
			var store:Store = (evt.currentTarget as StoreUIComponent).store;
			var sot:StoreOwnedThinger;
			if (evt.target is StoreOwnedThingerUIComponent)
			{
				sot = (evt.target as StoreOwnedThingerUIComponent).storeOwnedThinger;
			}
			else if (evt.target is MovieClip)
			{
				sot = (evt.target.parent.parent.parent as StoreOwnedThingerUIComponent).storeOwnedThinger;
			}
			else
			{
				sot = null;
			}
			
			if (sot)
			{	
				if (checkCredits(sot))
				{
					buyThinger(sot, evt.currentTarget as StoreUIComponent);
				}			
			}
		}
		
		public function checkCredits(sot:StoreOwnedThinger):Boolean
		{
			if (_user.credits >= sot.price)
			{
				return true;
			}
			return false;
		}
		
		public function buyThinger(sot:StoreOwnedThinger, storeUI:StoreUIComponent):void
		{
			Application.application.removeChild(storeUI);
			
			var model:String;
			
			if (sot.layerable)
			{
				model = 'layerable';
			}
			else if (sot.structure)
			{
				placeOwnedStructure(sot);
			}
			else if (sot.usable)
			{
				model = 'usable';			
			}			
//			params.id = sot[model].id;
//			params.user_id = _gdi.userManager.user.id;
//			var evt:ServerDataEvent = new ServerDataEvent(ServerDataEvent.INSTANCE_TO_CREATE, 'owned_'+model, params, 'create_new', true, true);			
//			_essentialModelManager.dispatchEvent(evt);
		}
		
		public function placeOwnedStructure(sot:StoreOwnedThinger):void
		{
			// Might want to change how this works
			Application.application.switchToEditView();
			var storeEvent:StoreEvent = new StoreEvent(StoreEvent.THINGER_PURCHASED, sot, true, true);
			dispatchEvent(storeEvent);			
		}
		
		public function savePlacedOwnedStructure(sot:StoreOwnedThinger):void
		{
			var model:String;			
			var params:Object = new Object();			
			params.owned_dwelling_id = Application.application.worldView.venueManager.venue.id;
			params.id = sot.structure.id;			
			params.user_id = _gdi.userManager.user.id;
			var evt:ServerDataEvent = new ServerDataEvent(ServerDataEvent.INSTANCE_TO_CREATE, "owned_structure", params, 'create_new', true, true);			
			_essentialModelManager.dispatchEvent(evt);			
		}
		
		public function getStoreByName(name:String):Store
		{
			for each (var store:Store in stores)
			{
				if (store.name == name)
				{
					return store;
				}
			}
			return null;
		}	
		
		public function set gdi(val:GameDataInterface):void
		{
			_gdi = val;
		}
		
	}
}