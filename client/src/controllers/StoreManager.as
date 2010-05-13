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
			uic.store = store;
			for each (var sot:StoreOwnedThinger in store.store_owned_thingers)
			{
				var container:StoreOwnedThingerUIComponent = new StoreOwnedThingerUIComponent(sot);
				uic.addChild(container);
			}
			uic.addEventListener(MouseEvent.CLICK, onStoreClicked);
			return uic;
		}
		
		public function onStoreClicked(evt:MouseEvent):void
		{
			var store:Store = (evt.currentTarget as StoreUIComponent).store;
			if (evt.target is MovieClip)
			{
				var sot:StoreOwnedThinger = (evt.target.parent as StoreOwnedThingerUIComponent).storeOwnedThinger;
				if (checkCredits(sot))
				{
					buyThinger(sot);
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
		
		public function buyThinger(sot:StoreOwnedThinger):void
		{
			var model:String;
			var params:Object = new Object();
			
			if (sot.layerable)
			{
				model = 'layerable';
			}
			else if (sot.structure)
			{
				model = 'structure';
				
				// Might want to change how this works
				params.owned_dwelling_id = Application.application.worldView.venueManager.venue.id;
			}
			else if (sot.usable)
			{
				model = 'usable';			
			}
			
			params.id = sot[model].id;
			params.user_id = _gdi.userManager.user.id;
			var evt:ServerDataEvent = new ServerDataEvent(ServerDataEvent.INSTANCE_TO_CREATE, 'owned_'+model, params, 'create_new', true, true);			
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