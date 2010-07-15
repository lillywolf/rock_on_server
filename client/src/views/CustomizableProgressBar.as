package views
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Image;
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;
	
	public class CustomizableProgressBar extends UIComponent
	{
		public var progressBar:ProgressBar;
		public var maxFillables:int;
		public var barMask:Image;
		public var barHeight:int;
		public var trackSkin:Class;
		public var barSkin:Class;
		public var overlayHeight:int;
		public var overlayWidth:int;
		public var barMax:int;
		public var barMin:int;
		public var t:Timer;
		public var timerInterval:int;
		public var totalTime:int;
		public var numFillables:int;
		
		public function CustomizableProgressBar(_barHeight:int, _overlayHeight:int, _overlayWidth:int, _barMask:Image = null, _totalTime:int = 1000, _timerInterval:int = 50, overlaySource:Class = null, _trackSkin:Class = null, _barSkin:Class = null, _x:int = 0, _y:int = 0, _numFillables:int = 5, _maxFillables:int = 5, _max:int = 100, _min:int = 0)
		{
			super();
			
			this.x = _x;
			this.y = _y;
			
			barHeight = _barHeight;
			numFillables = _numFillables;
			maxFillables = _maxFillables;
			barMax = _max;
			barMin = _min;
			overlayHeight = _overlayHeight;
			overlayWidth = _overlayWidth;
			barMask = _barMask;
			
			this.width = numFillables * _overlayWidth;
			progressBar = new ProgressBar();
			progressBar.mode = "manual";
			progressBar.visible = true;
			progressBar.minimum = _min;
			progressBar.maximum = _max;
			progressBar.height = barHeight;	
			progressBar.width = numFillables * _overlayWidth;
			setBarMask(_barMask);
			
			this.addChild(progressBar);			
			
			if (_trackSkin || _barSkin)
			{
				setSkins(_trackSkin, _barSkin);			
			}
			
			timerInterval = _timerInterval;
			totalTime = _totalTime;			
			setTimer();
			
			addFillablesToMask(overlaySource);
			addChildComponents();
		}
		
		public function setSkins(_trackSkin:Class = null, _barSkin:Class = null):void
		{
			if (_trackSkin)
			{
				trackSkin = _trackSkin;
				progressBar.setStyle("trackSkin", trackSkin);
			}
			if (_barSkin)
			{
				barSkin = _barSkin;
				progressBar.setStyle("barSkin", barSkin);
			}
		}
		
		public function startBar():void
		{
			t.start();
		}
		
		public function setTimer():void
		{
			t = new Timer(timerInterval);			
			t.addEventListener(TimerEvent.TIMER, function onProgressTimerComplete():void
			{
				progressBar.setProgress(t.currentCount*(barMax/(totalTime/timerInterval)), barMax);
				if (t.currentCount == totalTime/timerInterval)
				{
					t.stop();
					t.removeEventListener(TimerEvent.TIMER, onProgressTimerComplete);
				}
			});						
		}
		
		public function addFillablesToMask(overlaySource:Class):void
		{	
			for (var i:int = 0; i < numFillables; i++)
			{
				var overlayImage:Image = new Image();
				overlayImage.height = overlayHeight;
				overlayImage.source = overlaySource;
				overlayImage.width = overlayWidth;
				overlayImage.x = i * overlayWidth;
				this.addChild(overlayImage);
			}
		}
		
		public function setBarMask(barMask:Image):void
		{	
			barMask.cacheAsBitmap = true;
			progressBar.cacheAsBitmap = true;			
			progressBar.mask = barMask;			
		}
		
		public function addChildComponents():void
		{		
			this.addChild(barMask);
			progressBar.setProgress(0, 0);
		}
	}
}