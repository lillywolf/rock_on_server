package clickhandlers
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import views.StageView;
	import views.WorldView;
	
	public class MouseBoss extends EventDispatcher
	{
		public var _worldMouseHandler:WorldViewClickHandler;
		public var _stageMouseHandler:StageViewClickHandler;
		
		public function MouseBoss(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function set worldMouseHandler(val:WorldViewClickHandler):void
		{
			_worldMouseHandler = val;
		}
		
		public function set stageMouseHandler(val:StageViewClickHandler):void
		{
			_stageMouseHandler = val;
		}
		
		public function checkIfWorldViewHovering():Boolean
		{
			if (_worldMouseHandler && _worldMouseHandler.objectOfInterest)
				return true;
			return false;
		}
	}
}