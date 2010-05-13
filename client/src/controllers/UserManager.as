package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Level;
	import models.User;
	
	import server.ServerController;

	public class UserManager extends Manager
	{
		public var _user:User;
		public var _levelManager:LevelManager;
		public var _serverController:ServerController;		
		
		public function UserManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
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
			setLevel();
		}	
		
		public function get user():User
		{
			return _user;
		}
		
		public function setLevel():void
		{
			for each (var lvl:Level in levelManager.levels)
			{
				if (lvl.id == _user.level_id)
				{
					_user.level = lvl;
				}
			}
		}
		
		public function set levelManager(val:LevelManager):void
		{
			_levelManager = val;
		}
		
		public function get levelManager():LevelManager
		{
			return _levelManager;
		}
	}
}