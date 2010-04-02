package customizer
{
	import flash.events.Event;

	public class CustomizerEvent extends Event
	{
		public static const LAYER_SELECTED:String = 'Customizer:LayerSelected';
		
		public var _selectedLayer:String;
		
		public function CustomizerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set selectedLayer(val:String):void
		{
			_selectedLayer = val;
		}
		
		public function get selectedLayer():String
		{
			return _selectedLayer;
		}
		
	}
}