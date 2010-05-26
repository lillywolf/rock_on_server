package views
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.core.UIComponent;
	
	import world.ActiveAsset;
	import world.World;

	public class OwnedStructureEditOptions extends UIComponent
	{
		public var canvas:Canvas;
		public var _asset:ActiveAsset;
		public var _myWorld:World;
		public var _editMode:EditMode;
		
		public function OwnedStructureEditOptions(asset:ActiveAsset, myWorld:World, editMode:EditMode)
		{
			super();
			_asset = asset;
			_myWorld = myWorld;
			_editMode = editMode;
			
			createCanvas();
			addEditButtons();
			addChild(canvas);
		}
		
		public function createCanvas():void
		{
			canvas = new Canvas();
			canvas.width = 100;
			canvas.height = 60;
			canvas.x = World.worldToActualCoords(_asset.worldCoords).x + _myWorld.x;
			canvas.y = World.worldToActualCoords(_asset.worldCoords).y + _myWorld.y;
		}
		
		public function addEditButtons():void
		{
			var moveBtn:Button = new Button();
			moveBtn.addEventListener(MouseEvent.CLICK, onMoveButtonClicked);
			moveBtn.width = 30;
			moveBtn.height = 20;
			moveBtn.x = 10;
			moveBtn.y = 10;
			canvas.addChild(moveBtn);
			var sellBtn:Button = new Button();
			sellBtn.addEventListener(MouseEvent.CLICK, onSellButtonClicked);
			sellBtn.width = 30;
			sellBtn.height = 20;
			sellBtn.x = 50;
			sellBtn.y = 10;
			canvas.addChild(sellBtn);			
		}
		
		private function onMoveButtonClicked(evt:MouseEvent):void
		{
			_editMode.moveButtonClicked();
			parent.removeChild(this);
			removeEventListener(MouseEvent.CLICK, onMoveButtonClicked);
		}
		
		private function onSellButtonClicked(evt:MouseEvent):void
		{
			_editMode.sellButtonClicked();
			parent.removeChild(this);
			removeEventListener(MouseEvent.CLICK, onSellButtonClicked);
		}
		
	}
}