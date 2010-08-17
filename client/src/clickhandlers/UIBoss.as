package clickhandlers
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import helpers.CollectibleDrop;
	
	import mx.events.FlexEvent;
	
	import rock_on.VenueEvent;
	
	import views.BottomBar;
	import views.WorldView;
	
	public class UIBoss extends EventDispatcher
	{
		public var _worldView:WorldView;
		public var _worldViewMouseHandler:WorldViewClickHandler;
		public var _bottomBar:BottomBar;
		
		public function UIBoss(worldView:WorldView, target:IEventDispatcher=null)
		{
			super(target);
			_worldView = worldView;
			_worldView.addEventListener(VenueEvent.VENUE_INITIALIZED, onVenueInitialized);
		}
		
		private function onVenueInitialized(evt:VenueEvent):void
		{
			_worldViewMouseHandler = _worldView.mouseHandler as WorldViewClickHandler;			
			_worldViewMouseHandler.addEventListener(UIEvent.COLLECTIBLE_DROP, onCollectibleDrop);
			_worldViewMouseHandler.addEventListener(UIEvent.REPLACE_BOTTOMBAR, onReplaceBottomBar);			
		}
		
		private function onCollectibleDrop(evt:UIEvent):void
		{
			var radius:Point = new Point(100, 50);
			var collectibleDrop:CollectibleDrop = new CollectibleDrop(evt.asset, evt.mc, radius, _worldView.myWorld, _worldView, 0, 400, .001, null, new Point(evt.asset.x, evt.asset.y - 70));
			collectibleDrop.addEventListener("removeCollectible", function onRemoveCollectible():void
			{
				_worldView.myWorld.removeChild(collectibleDrop);
			});
			_worldView.myWorld.addChild(collectibleDrop);				
		}
		
		private function onReplaceBottomBar(evt:UIEvent):void
		{
			
		}
	}
}