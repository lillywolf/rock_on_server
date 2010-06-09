package views
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	
	import world.ActiveAsset;
	import world.AssetStack;

	public class AssetBitmapData
	{
		public var _assetStack:AssetStack;
		public var _activeAsset:ActiveAsset;
		public var _mc:MovieClip;
		public var _bitmap:Bitmap;
		public var _reference:Object;
		public var realCoordX:int;
		public var realCoordY:int;
		public var moving:Boolean;
		public var standing:Boolean;
		public var rendered:Boolean;
		public var newBitmap:Bitmap;
		
		public function AssetBitmapData()
		{
		}
		
		public function set assetStack(val:AssetStack):void
		{
			_assetStack = val;
		}
		
		public function get assetStack():AssetStack
		{
			return _assetStack;
		}
		
		public function set mc(val:MovieClip):void
		{
			_mc = val;
		}
		
		public function get mc():MovieClip
		{
			return _mc;
		}
		
		public function set activeAsset(val:ActiveAsset):void
		{
			_activeAsset = val;
		}
		
		public function get activeAsset():ActiveAsset
		{
			return _activeAsset;
		}
		
		public function set bitmap(val:Bitmap):void
		{
			_bitmap = val;
		}
		
		public function get bitmap():Bitmap
		{
			return _bitmap;
		}
		
		public function set reference(val:Object):void
		{
			_reference = val;
		}
		
		public function get reference():Object
		{
			return _reference;
		}
	}
}