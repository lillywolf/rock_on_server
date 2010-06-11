package world
{
	public class CreatureData
	{
		public var _asset:AssetStack;
		public var drawIndex:int;
		public var realCoordY:Number;
		public var realCoordX:Number;
		
		public function CreatureData(asset:AssetStack)
		{
			_asset = asset;
		}
		
		public function get asset():AssetStack
		{
			return _asset;
		}

	}
}