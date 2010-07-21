package views
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.TimeEvent;
	
	import world.ActiveAsset;
	import world.AssetStack;

	public class AssetBitmapData
	{
		public var _assetStack:AssetStack;
		public var _activeAsset:ActiveAsset;
		public var _mc:MovieClip;
		public var _bitmap:Bitmap;
		public var _reference:Object;
		public var reflected:Boolean;
		public var realCoordX:int;
		public var realCoordY:int;
		public var moving:Boolean;
		public var standing:Boolean;
		public var rendered:Boolean;
		public var newBitmap:Bitmap;
		public var transformedWidth:Number;
		public var transformedHeight:Number;
		
		public var moodClip:ExpandingMovieclip;
		public var mood:Object;
		
		public function AssetBitmapData()
		{
		}
		
		public function startMoodClipBounce():void
		{
			if (moodClip)
			{
				var t:Timer = new Timer(Math.random() * 1000);
				t.addEventListener(TimerEvent.TIMER, onBounceWaitComplete);
				t.start();
			}
		}
		
		private function onBounceWaitComplete(evt:TimerEvent):void
		{
			moodClip.doBounce(20);
			var t:Timer = evt.target as Timer;
			t.removeEventListener(TimerEvent.TIMER, onBounceWaitComplete);
			t.stop();
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