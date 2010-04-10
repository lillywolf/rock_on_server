package controllers
{
	import game.GameDataInterface;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	import server.ServerDataEvent;

	public class FriendManager extends ArrayCollection
	{
		public function FriendManager(source:Array=null)
		{
			super(source);
		}
		
		public function getFriendData(uid:int):void
		{
			var friendMap:Object = checkForFriendData(uid);
			if (friendMap)
			{
				Application.application.showFriendVenuePostLoad(friendMap.gdi);
			}
			else
			{
				createNewFriendMap(uid);
			}
		}
		
		public function createNewFriendMap(uid:int):void
		{
			var gdi:GameDataInterface = new GameDataInterface(Application.application.gameContent);
			gdi.addEventListener(ServerDataEvent.USER_LOADED, onUserLoaded);
			gdi.addEventListener(ServerDataEvent.GAME_CONTENT_LOADED, onGameContentLoaded);
			gdi.addEventListener(ServerDataEvent.USER_CONTENT_LOADED, onUserContentLoaded);	
			
			gdi.getUserContent(uid);
			
			var friendMap:Object = {snid: uid, gdi: gdi};
			addItem(friendMap);			
		}
		
		public function checkForFriendData(uid:int):Object
		{
			for each (var friendMap:Object in this)
			{
				if (friendMap.snid == uid)
				{
					return friendMap;
				}
			}
			return null;
		}
		
		private function onUserLoaded(evt:ServerDataEvent):void
		{
			
		}

		private function onGameContentLoaded(evt:ServerDataEvent):void
		{

		}
		
		private function onUserContentLoaded(evt:ServerDataEvent):void
		{
			var gdi:GameDataInterface = evt.currentTarget as GameDataInterface;
			gdi.checkIfLoadingAndInstantiationComplete();
		}
				
	}
}