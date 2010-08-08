package views
{
	import com.flashdynamix.motion.Tweensy;
	import com.flashdynamix.motion.TweensyTimeline;
	
	import fl.motion.easing.Bounce;
	import fl.motion.easing.Cubic;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class BouncyBitmap extends Bitmap
	{
		public var _mc:MovieClip;
		public var bounceHeight:int;
		public static const HEIGHT_BUFFER:int = 10;
		public static const WIDTH_BUFFER:int = 10;
		
		public function BouncyBitmap(mc:MovieClip, scale:Number, bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(bitmapData, pixelSnapping, smoothing);
			
			_mc = mc;
			renderMovieClip(scale);
			this.opaqueBackground = null;	
			this.cacheAsBitmap = true;
		}
		
		public function renderMovieClip(scale:Number):void
		{
			_mc.scaleX = scale;
			_mc.scaleY = scale;
			var bd:BitmapData = new BitmapData(_mc.width + WIDTH_BUFFER, _mc.height + HEIGHT_BUFFER, true, 0x000000);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, _mc.width/2 + WIDTH_BUFFER, _mc.height/scale);
			var rect:Rectangle = new Rectangle(0, 0, _mc.width + WIDTH_BUFFER, _mc.height + HEIGHT_BUFFER);
			matrix.scale(scale, scale);
			bd.draw(_mc, matrix, new ColorTransform(), null, rect);
			this.bitmapData = bd;
		}
		
		public function doBounce(_bounceHeight:int, duration:int = 1):void
		{
			bounceHeight = _bounceHeight;
			var tt:TweensyTimeline = Tweensy.to(this, {x: this.x, y: this.y - bounceHeight}, 1, Cubic.easeIn, 0.5, null, function onUpTweenComplete():void
			{
				tt.dispose();
				doDownTween();
			});	
		}
		
		public function doUpTween():void
		{
			var tt:TweensyTimeline = Tweensy.to(this, {x: this.x, y: this.y - bounceHeight}, 1, Cubic.easeIn, 0.5, null, function onUpTweenComplete():void
			{
				tt.dispose();
				doDownTween();
			});		
		}
		
		public function doDownTween():void
		{
			var tt:TweensyTimeline = Tweensy.to(this, {x: this.x, y: this.y + bounceHeight}, 1, Bounce.easeOut, 0, null, function onDownTweenComplete():void
			{
				tt.dispose();
				doUpTween();
			});				
		}		
	}	
}