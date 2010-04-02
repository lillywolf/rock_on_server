package world
{
	public class Point3D
	{
		public var _x:Number;
		public var _y:Number;
		public var _z:Number;
		public function Point3D(x:Number, y:Number, z:Number)
		{
			_x = x;
			_y = y;
			_z = z;
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
		
		public function set z(val:Number):void
		{
			_z = val;
		}
		
		public function get z():Number
		{
			return _z;
		}

	}
}