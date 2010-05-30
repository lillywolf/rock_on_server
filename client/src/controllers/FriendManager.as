package controllers
{
	import com.facebook.data.users.FacebookUser;
	
	import game.GameDataInterface;
	
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.events.DynamicEvent;
	
	import server.ServerDataEvent;

	public class FriendManager extends ArrayCollection
	{
		public var mainGDI:GameDataInterface;
		public var basicFriendData:ArrayCollection;
		public var facebookFriends:Array;
		public var facebookUser:FacebookUser;
		public function FriendManager(gdi:GameDataInterface, source:Array=null)
		{
			super(source);
			mainGDI = gdi;
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
		
		public function getFriendBasicInfo(uid:Number):User
		{
			for each (var friendUser:User in basicFriendData)
			{
				if (friendUser.snid == uid)
				{
					return friendUser;
				}
			}
			return null;
		}
		
		public function setFacebookData(facebookFriends:Array, facebookUser:FacebookUser):void
		{
			this.facebookFriends = facebookFriends;
			this.facebookUser = facebookUser;			
		}
		
		public function retrieveBasicFriendInfoFromServer():void
		{
			basicFriendData = new ArrayCollection();
			basicFriendData.addItem(mainGDI.user);
			for each (var friend:FacebookUser in facebookFriends)
			{
				if (friend.uid != this.facebookUser.uid)
				{
					mainGDI.sc.sendRequest({snid: friend.uid}, "user", "get_friend_basics");							
				}
			}
		}
		
		public function processBasicFriendData(friendUser:User, method:String):void
		{
			basicFriendData.addItem(friendUser);
			if (basicFriendData.length == (facebookFriends.length + 1))
			{
				var evt:DynamicEvent = new DynamicEvent("friendDataLoaded", true, true);
				dispatchEvent(evt);
			}
		}
		
		public function createNewFriendMap(uid:int):Object
		{
			var gdi:GameDataInterface = new GameDataInterface(Application.application.gameContent);
			gdi.addEventListener(ServerDataEvent.USER_LOADED, onUserLoaded);
			gdi.addEventListener(ServerDataEvent.GAME_CONTENT_LOADED, onGameContentLoaded);
			gdi.addEventListener(ServerDataEvent.USER_CONTENT_LOADED, onUserContentLoaded);	
			
			gdi.getUserContent(uid);
			
			var friendMap:Object = {snid: uid, gdi: gdi};
			addItem(friendMap);			
			return friendMap;
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