package controllers
{
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import game.GameDataInterface;
	
	import models.Store;
	import models.StoreOwnedThinger;
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	
	import server.ServerDataEvent;
	
	import stores.StoreEvent;
	import stores.StoreOwnedThingerUIComponent;
	import stores.StoreUIComponent;

	public class StoreController extends Controller
	{
		[Bindable] public var stores:ArrayCollection;
		[Bindable] public var _user:User;
		[Bindable] public var _gdi:GameDataInterface;
		
		public function StoreController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			stores = essentialModelController.stores;
			
			essentialModelController.users.addEventListener(CollectionEvent.COLLECTION_CHANGE, onUserLoaded);
		}
		
		public function onUserLoaded(evt:CollectionEvent):void
		{
			_user = essentialModelController.users[0];
			essentialModelController.users.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onUserLoaded);
		}

		public function getStoreUIComponent():UIComponent
		{
			var uic:StoreUIComponent = new StoreUIComponent(this);
			uic.addStyle();
//			uic.addEventListener(MouseEvent.CLICK, onStoreClicked);
			return uic;
		}
		
		public function onStoreClicked(evt:MouseEvent):void
		{
//			var store:Store = (evt.currentTarget as StoreUIComponent).store;
//			var sot:StoreOwnedThinger;
//			if (evt.target is StoreOwnedThingerUIComponent)
//			{
//				sot = (evt.target as StoreOwnedThingerUIComponent).storeOwnedThinger;
//			}
//			else if (evt.target.parent is StoreOwnedThingerUIComponent)
//			{
//				sot = (evt.target.parent as StoreOwnedThingerUIComponent).storeOwnedThinger;
//			}
//			else if (evt.target.parent.parent is StoreOwnedThingerUIComponent)
//			{
//				sot = (evt.target.parent.parent as StoreOwnedThingerUIComponent).storeOwnedThinger;
//			}
//			else if (evt.target.parent.parent.parent is StoreOwnedThingerUIComponent)
//			{
//				sot = (evt.target.parent.parent.parent as StoreOwnedThingerUIComponent).storeOwnedThinger;
//			}
//			else
//			{
//				sot = null;
//			}
			
//			if (sot)
//			{	
//				if (checkCredits(sot))
//				{
//					buyThinger(sot, evt.currentTarget as StoreUIComponent);
//				}			
//			}
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
			(storeUI.parent as Canvas).removeChild(storeUI);
			
			var model:String;			
			if (sot.layerable)
				model = 'layerable';
			else if (sot.structure)
				placeOwnedStructure(sot);
			else if (sot.usable)
				model = 'usable';			
		}
		
		public function placeOwnedStructure(sot:StoreOwnedThinger):void
		{
			// Might want to change how this works
			FlexGlobals.topLevelApplication.switchToEditView();
			var storeEvent:StoreEvent = new StoreEvent(StoreEvent.THINGER_PURCHASED, sot, true, true);
			dispatchEvent(storeEvent);			
		}
		
		public function savePlacedOwnedStructure(sot:StoreOwnedThinger):void
		{
			var model:String;			
			var params:Object = new Object();			
			params.owned_dwelling_id = FlexGlobals.topLevelApplication.worldView.venueManager.venue.id;
			params.id = sot.structure.id;			
			params.user_id = _gdi.userController.user.id;
			var evt:ServerDataEvent = new ServerDataEvent(ServerDataEvent.INSTANCE_TO_CREATE, "owned_structure", params, 'create_new', true, true);			
			_essentialModelController.dispatchEvent(evt);			
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