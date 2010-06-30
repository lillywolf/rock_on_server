package game
{
	import controllers.LevelController;
	import controllers.UserController;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import models.Level;
	
	import rock_on.ContentIndex;

	public class GameMagicManager extends EventDispatcher
	{
		public var _levelController:LevelController;
		public var _userController:UserController;
		public var contentIndex:ContentIndex;		
		
		public function GameMagicManager(levelController:LevelController, userController:UserController, target:IEventDispatcher=null)
		{
			super(target);
			_levelController = levelController;
			_userController = userController;
			contentIndex = new ContentIndex();
		}
		
		public function updateXpAndLevel(xpToAdd:int):void
		{
			trace("update xp");
			var neededXp:int = 0;
			var i:int = 0;
			
			_levelController.sortLevels();
			
			do
			{
				neededXp = neededXp + (_levelController.levels[i] as Level).xp_diff;
				i++;								
			}
			while (_userController.user.xp + xpToAdd > neededXp);
			
			_userController.user.increaseXp(xpToAdd);			
			
			if (_userController.user.level.rank < i)
			{
				_userController.user.incrementLevel(i);
			}	
			trace("xp updated");
		}		
		
	}
}