package stores
{
	import models.Store;
	
	import mx.core.UIComponent;

	public class StoreUIComponent extends UIComponent
	{
		public var _store:Store;
		
		public function StoreUIComponent(store:Store)
		{
			super();
			_store = store;
		}
		
		public function set store(val:Store):void
		{
			_store = val;
		}
		
		public function get store():Store
		{
			return _store;
		}
		
	}
}