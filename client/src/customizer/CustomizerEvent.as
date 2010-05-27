package customizer
{
	import flash.events.Event;
	
	import world.AssetStack;

	public class CustomizerEvent extends Event
	{
		public static const LAYER_SELECTED:String = 'Customizer:LayerSelected';
		public static const CREATURE_SELECTED:String = "Customizer:CreatureSelected";
		
		public var _selectedLayer:String;
		public var _selectedCreatureAsset:AssetStack;
		
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
		
		public function set selectedCreatureAsset(val:AssetStack):void
		{
			_selectedCreatureAsset = val;
		}
		
		public function get selectedCreatureAsset():AssetStack
		{
			return _selectedCreatureAsset;
		}
		
	}
}