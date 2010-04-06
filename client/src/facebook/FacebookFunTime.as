package facebook
{
	import com.facebook.Facebook;
	import com.facebook.commands.friends.GetFriends;
	import com.facebook.commands.users.GetInfo;
	import com.facebook.data.friends.GetFriendsData;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.data.users.GetInfoData;
	import com.facebook.data.users.GetInfoFieldValues;
	import com.facebook.events.FacebookEvent;
	import com.facebook.net.FacebookCall;
	import com.facebook.utils.FacebookSessionUtil;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.Application;
	
	public class FacebookFunTime
	{
		protected var session:FacebookSessionUtil;
		protected var fbook:Facebook;
		protected const API_KEY:String = "eb67822b00a98a91c049e1347be7e657";
		protected const SECRET:String = "93822524c73ff1b5acc09be6f357a0fa";
		[Bindable] protected var facebookUser:FacebookUser;
		[Bindable] protected var facebookFriends:Array;
		[Bindable] protected var facebookFriendData:Array;
		
		public function FacebookFunTime()
		{
			session = new FacebookSessionUtil(API_KEY, SECRET, Application.application.loaderInfo);
			fbook = session.facebook;
			session.login();
			
			facebookUser = new FacebookUser();
			
			session.addEventListener(FacebookEvent.CONNECT, onConnect);
			session.addEventListener(FacebookEvent.WAITING_FOR_LOGIN, onWaitLogin);
		}
		
		protected function onConnect(evt:FacebookEvent):void
		{
			if (evt.success)
			{
				setUserData(evt);
				setFriendData(evt);
			}
			else
			{
				Alert.show("Error connecting to Facebook", "Error");
			}
		}
		
		protected function onWaitLogin(evt:FacebookEvent):void
		{
			var alert:Alert = Alert.show("Click OK after you log into Facebook", "Waiting for Login");
			alert.addEventListener(Event.CLOSE, onClose);
		}
		
		protected function onClose(evt:Event):void
		{
			session.validateLogin();
		}
		
		protected function setUserData(evt:FacebookEvent):void
		{
			var call:FacebookCall = fbook.post(new GetInfo([fbook.uid], [com.facebook.data.users.GetInfoFieldValues.ALL_VALUES]));
			call.addEventListener(FacebookEvent.COMPLETE, onGetInfo);
		}
		
		protected function setFriendData(evt:FacebookEvent):void
		{
			var call:FacebookCall = fbook.post(new GetFriends());
			call.addEventListener(FacebookEvent.COMPLETE, onGetFriends);
		}
		
		protected function onGetInfo(evt:FacebookEvent):void
		{
			if (evt.success)
			{
				facebookUser = (evt.data as GetInfoData).userCollection.getItemAt(0) as FacebookUser;
			}
			else
			{
				Alert.show("Error getting Facebook user data", "Error");
			}
		}
		
		protected function onGetFriends(evt:FacebookEvent):void
		{
			if (evt.success)
			{
				facebookFriends = (evt.data as GetFriendsData).friends.source;
				var uids:Array = [];
				for (var i:uint=0; i<facebookFriends.length; i++)
				{
					uids.push(facebookFriends[i].uid);
				}
				var call:GetInfo = new GetInfo(uids.slice(0, Math.min(uids.length, 20)), [GetInfoFieldValues.FIRST_NAME, GetInfoFieldValues.PIC_SQUARE]);
				call.addEventListener(FacebookEvent.COMPLETE, onFriendsGetInfo);
				fbook.post(call);
			}
			else
			{
				Alert.show("An error occurred while loading friends", "Error");
			}
		}
		
		protected function onFriendsGetInfo(evt:FacebookEvent):void
		{
			(evt.target as GetInfo).removeEventListener(FacebookEvent.COMPLETE, onFriendsGetInfo);
			if (evt.success)
			{
				facebookFriendData = (evt.data as GetInfoData).userCollection.source;				
			}
			else
			{
				Alert.show("Error getting friend data", "Error");
			}
		}
		
		public function getFriendData():Array
		{
			return facebookFriendData;
		}

	}
}