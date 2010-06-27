package music
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class MusicManager extends EventDispatcher
	{
		public function MusicManager(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}