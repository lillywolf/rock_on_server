package controllers
{
	import com.facebook.data.users.FacebookUser;
	
	import game.GameDataInterface;
	
	import models.Creature;
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.DynamicEvent;
	
	import server.ServerDataEvent;

	public class FriendController extends ArrayCollection
	{
		public var mainGDI:GameDataInterface;
		public var basicFriendData:ArrayCollection;
		public var randomBandMembers:ArrayCollection;
		public var facebookFriends:Array;
		public var facebookUser:FacebookUser;
		public function FriendController(gdi:GameDataInterface, source:Array=null)
		{
			super(source);
			mainGDI = gdi;
		}
		
		public function getFriendData(uid:Number):void
		{
			var friendMap:Object = checkForFriendData(uid);
			if (friendMap)
			{
				FlexGlobals.topLevelApplication.showFriendVenuePostLoad(friendMap.gdi);
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
		
		public function getFriendUser(uid:Number):User
		{
			for each (var friendMap:Object in this)
			{
				if (friendMap.gdi.user.snid == uid)
				{
					return friendMap.gdi.user;
				}
			}
			return null;
		}
		
		public function getFriendGDI(uid:Number):GameDataInterface
		{
			for each (var friendMap:Object in this)
			{
				if (friendMap.gdi.user.snid == uid)
				{
					return friendMap.gdi;
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
			addMainUser();
			for each (var friend:FacebookUser in facebookFriends)
			{
				mainGDI.sc.sendRequest({snid: friend.uid}, "user", "get_friend_basics");							
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
		
		public function getFriendGDIs():void
		{
			for each (var friend:FacebookUser in facebookFriends)
			{
				createNewFriendMap(Number(friend.uid));
			}			
		}
		
		public function friendGDILoaded(friendGDI:GameDataInterface):void
		{
			var friendMap:Object = {snid: friendGDI.user.snid, gdi: friendGDI};
			addItem(friendMap);						
			if (length == facebookFriends.length)
			{
				addItem({snid: mainGDI.user.snid, gdi: mainGDI});
				var evt:DynamicEvent = new DynamicEvent("friendDataLoaded", true, true);
				dispatchEvent(evt);
			}			
		}
		
		public function processRandomBandMemberData(creature:Creature, method:String):void
		{
			randomBandMembers.addItem({creature: creature, id: creature.user_id});
			if (randomBandMembers.length == (facebookFriends.length + 1))
			{
				var evt:DynamicEvent = new DynamicEvent("friendDataLoaded", true, true);
				dispatchEvent(evt);							
			}
		}
		
		public function addMainUser():void
		{
			basicFriendData.addItem(mainGDI.user);		
			if (!mainGDI.user)
			{
				throw new Error("user is null");
			}	
		}
		
		public function createNewFriendMap(uid:Number):Object
		{
			var gdi:GameDataInterface = new GameDataInterface(FlexGlobals.topLevelApplication.gameContent);
			gdi.addEventListener(ServerDataEvent.USER_LOADED, onUserLoaded);
			gdi.addEventListener(ServerDataEvent.GAME_CONTENT_LOADED, onGameContentLoaded);
			gdi.addEventListener(ServerDataEvent.USER_CONTENT_LOADED, onUserContentLoaded);	
			
			gdi.getUserContent(uid);
			
			var friendMap:Object = {snid: uid, gdi: gdi};
			return friendMap;
		}
		
		public function checkForFriendData(uid:Number):Object
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