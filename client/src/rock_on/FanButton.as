package rock_on
{
	import mx.controls.Button;

	public class FanButton extends Button
	{
		public var _station:ListeningStation;
		
		public function FanButton()
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
		
	}
}