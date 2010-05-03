package rock_on
{
	import mx.controls.Button;

	public class SpecialButton extends Button
	{
		public var _station:ListeningStation;
		public var _booth:Booth;
		
		public function SpecialButton()
		{
			super();
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
		
	}
}