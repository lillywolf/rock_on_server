package views
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Button;
	import mx.core.UIComponent;
	
	public class TiledItemList extends UIComponent
	{
		public var _items:ArrayCollection;
		public var _numRows:int;
		public var _numColumns:int;
		public var _page:int;
		public var paddingX:int = 50;
		public var paddingY:int = 80;
		public var itemPaddingX:int = 10;
		public var itemPaddingY:int = 10;
		
		public function TiledItemList(items:ArrayCollection, numRows:int, numColumns:int)
		{
			super();
			_items = items;
			_numRows = numRows;
			_numColumns = numColumns;	
			
			showList();
		}
		
		public function addScrollButtons():void
		{			
			var scrollRight:Button = new Button();
			styleButton(scrollRight);
			scrollRight.y = 100;
			scrollRight.x = this.width - scrollRight.width;
			scrollRight.addEventListener(MouseEvent.CLICK, onScrollRight);
			this.addChild(scrollRight);
			
			var scrollLeft:Button = new Button();
			scrollLeft.y = 100;
			styleButton(scrollLeft);
			scrollLeft.addEventListener(MouseEvent.CLICK, onScrollLeft);
			this.addChild(scrollLeft);
		}
		
		public function styleButton(btn:Button):void
		{
			btn.height = 40;
			btn.width = 40;
		}			
		
		private function onScrollRight(evt:MouseEvent):void
		{
			if (_page < Math.floor((_items.length-1)/(_numRows*_numColumns)))
			{
				_page = _page + 1;
				showList();
			}
		}
		
		private function onScrollLeft(evt:MouseEvent):void
		{
			if (_page > 0)
			{
				_page = _page - 1;
				showList();
			}
		}
		
		public function showList():void
		{
			var numKids:int = this.numChildren;
			for (var i:int = 0; i < numKids; i++)
			{
				this.removeChildAt(0);
			}
			for each (var obj:DisplayObject in _items)
			{
				var index:int = _items.getItemIndex(obj);
				if (Math.floor(index/(_numRows*_numColumns)) == _page)
					addItemToList(_items.getItemAt(index) as DisplayObject, index%(_numRows*_numColumns));
			}
			addScrollButtons();
		}
		
		private function addItemToList(obj:DisplayObject, index:int):void
		{
			obj.x = index%_numColumns * (obj.width + itemPaddingX) + paddingX;
			obj.y = Math.floor(index/_numColumns) * (obj.height + itemPaddingY) + paddingY;
			this.addChild(obj);
		}
	}
}