package stores
{
	import controllers.StoreController;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import models.Store;
	import models.StoreOwnedThinger;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.core.UIComponent;
	
	import views.TiledItemList;

	public class StoreUIComponent extends UIComponent
	{
		public var _storeController:StoreController;
		public var storeContainer:TiledItemList;
		
		public static const STORE_WIDTH:int = 600;
		public static const STORE_HEIGHT:int = 360;
		public static const ITEM_PADDING_X:int = 12;
		public static const ITEM_PADDING_Y:int = 12;
		public static const PADDING_X:int = 20;
		public static const PADDING_Y:int = 20;
		
		public function StoreUIComponent(storeController:StoreController)
		{
			super();
			_storeController = storeController;
			
//			this.addEventListener(StoreEvent.THINGER_CLICKED, onThingerClicked);
		}
		
		private function onStoreItemClicked(evt:MouseEvent):void
		{
			var sot:StoreOwnedThinger = (evt.currentTarget as StoreOwnedThingerUIComponent).storeOwnedThinger;
			if (_storeController.checkCredits(sot))
				_storeController.buyThinger(sot, this);
		}
		
		public function addStyle():void
		{
			this.width = STORE_WIDTH;
			this.height = STORE_HEIGHT;
			
			var tileBtn:Button = new Button();
			tileBtn.addEventListener(MouseEvent.CLICK, onTileBtnClicked);
			tileBtn.x = 30;
			styleButton(tileBtn);
			this.addChild(tileBtn);
			
			var boothBtn:Button = new Button();
			boothBtn.addEventListener(MouseEvent.CLICK, onBoothBtnClicked);
			boothBtn.x = 80;
			styleButton(boothBtn);
			this.addChild(boothBtn);	

			var decorationBtn:Button = new Button();
			decorationBtn.addEventListener(MouseEvent.CLICK, onDecorationBtnClicked);
			decorationBtn.x = 130;
			styleButton(decorationBtn);
			this.addChild(decorationBtn);	
			
			addCloseButton();			
		}
			
		public function styleButton(btn:Button):void
		{
			btn.height = 40;
			btn.width = 40;
			btn.y = 20;
		}	
		
		private function onTileBtnClicked(evt:MouseEvent):void
		{
			var store:Store = _storeController.getStoreByName("Clothing Store");
			showStore(store);
		}
		
		private function onBoothBtnClicked(evt:MouseEvent):void
		{
			var store:Store = _storeController.getStoreByName("Structure Store");
			showStore(store);
		}	

		private function onDecorationBtnClicked(evt:MouseEvent):void
		{
			var store:Store = _storeController.getStoreByName("Decorations");
			showStore(store);
		}	
		
		private function showStore(store:Store):void
		{			
			if (storeContainer)
				removeChild(storeContainer);
			var itemContainers:ArrayCollection = new ArrayCollection();
			for each (var sot:StoreOwnedThinger in store.store_owned_thingers)
			{
				var container:StoreOwnedThingerUIComponent = new StoreOwnedThingerUIComponent(sot);
				container.addEventListener(MouseEvent.CLICK, onStoreItemClicked);
				itemContainers.addItem(container);
			}	
			storeContainer = new TiledItemList(itemContainers, 3, StoreOwnedThingerUIComponent.NUM_COLUMNS);
			addChild(storeContainer);
		}
		
		public function addDefaultStyle():void
		{
			width = STORE_WIDTH;
			height = STORE_HEIGHT;
			var backCanvas:Canvas = StoreOwnedThingerUIComponent.createContainer();
			backCanvas.width = STORE_WIDTH + 12;
			backCanvas.height = STORE_HEIGHT + 16;
			backCanvas.x = -6;
			backCanvas.y = -10;
			addChild(backCanvas);
			
//			canvas = new Canvas();
//			canvas.setStyle("backgroundColor", 0x333333);
//			canvas.setStyle("cornerRadius", "14");
//			canvas.setStyle("borderColor", 0x333333);
//			canvas.setStyle("borderStyle", "solid");
//			canvas.width = STORE_WIDTH;
//			canvas.height = STORE_HEIGHT;
			addCloseButton();
//			addChild(canvas);
		}
		
		public function addCloseButton():void
		{
			var btn:Button = new Button();
			btn.width = 30;
			btn.height = 20;
			btn.setStyle("right", 10);
			btn.setStyle("top", 10);
			btn.addEventListener(MouseEvent.CLICK, onCloseButtonClicked);
			this.addChild(btn);
		}
		
		private function onCloseButtonClicked(evt:MouseEvent):void
		{
			parent.removeChild(this);
		}
		
		public function set storeController(val:StoreController):void
		{
			_storeController = val;
		}
		
		public function get storeController():StoreController
		{
			return _storeController;
		}
		
	}
}