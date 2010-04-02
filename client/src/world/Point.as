package world
{
	public class Point
	{
		public var _x:Number;
		public var _y:Number;
		public function Point(x:Number, y:Number)
		{
			_x = x;
			_y = y;
		}
		
		public function set x(val:Number):void
		{
			_x = val;
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set y(val:Number):void
		{
			_y = val;
		}
		
		public function get y():Number
		{
			return _y;
		}		

	}
}