package game
{
	import flash.display.MovieClip;
	
	public class Leftover extends MovieClip
	{
		public var mc:MovieClip;
		public var type:String;
		public var clickable:Boolean;
		
		public function Leftover(mc:MovieClip)
		{
			super();
			this.mc = mc;
			this.addChild(mc);
		}
	}
}