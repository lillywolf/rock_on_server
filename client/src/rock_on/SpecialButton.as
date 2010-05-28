package rock_on
{
	import mx.controls.Button;

	public class SpecialButton extends Button
	{
		public var _station:ListeningStation;
		public var _booth:Booth;
		public var _layerName:String;
		
		public function SpecialButton()
		{
			super();
		}
		
		public function setStyles(x:int=0, y:int=0, width:int=0, height:int=0):void
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public function set station(val:ListeningStation):void
		{
			_station = val;
		}
		
		public function get station():ListeningStation
		{
			return _station;
		}
		
		public function set booth(val:Booth):void
		{
			_booth = val;
		}		
		
		public function get booth():Booth
		{
			return _booth;
		}
		
		public function set layerName(val:String):void
		{
			_layerName = val;
		}
		
		public function get layerName():String
		{
			return _layerName;
		}
		
	}
}