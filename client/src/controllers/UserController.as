package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Level;
	import models.User;
	
	import server.ServerController;

	public class UserController extends Controller
	{
		public var _user:User;
		public var _levelController:LevelController;
		public var _serverController:ServerController;		
		
		public function UserController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
		}	

		public function addAmountToUserOnClient(updateUser:User, amount:Number, type:String):void
		{
			if (type == "xp")
			{
				updateUser.xp += amount;
				var level:Level = this.levelController.getLevelByXp(updateUser.xp);
				updateUser.level = level;
				updateUser.level_id = level.rank;
			}
			else if (type == "credits")
				updateUser.credits += amount;
			else if (type == "premium_credits")
				updateUser.premium_credits += amount;
			else if (type == "music_credits")
				updateUser.music_credits += amount;
			else if (type == "fan_credits")
				updateUser.fan_hearts += amount;
		}
		
		public function incrementCredits(toAdd:int):void
		{
			_serverController.sendRequest({id: _user.id, to_add: toAdd}, 'user', 'add_credits');							
		}
		
		public function getFacebookFriendData():void
		{
			_serverController.sendRequest({id: _user.id}, 'site', 'index');
		}
		
		public function set serverController(val:ServerController):void
		{
			_serverController = val;
		}	
		
		public function set user(val:User):void
		{
			_user = val;
			_user.userController = this;
			_levelController.setLevelOnUser(_user);
		}	
		
		public function get user():User
		{
			return _user;
		}
		
		public function set levelController(val:LevelController):void
		{
			_levelController = val;
		}
		
		public function get levelController():LevelController
		{
			return _levelController;
		}
	}
}