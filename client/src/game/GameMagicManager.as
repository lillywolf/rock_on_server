package game
{
	import controllers.LevelManager;
	import controllers.UserManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import models.Level;
	
	import rock_on.ContentIndex;

	public class GameMagicManager extends EventDispatcher
	{
		public var _levelManager:LevelManager;
		public var _userManager:UserManager;
		public var contentIndex:ContentIndex;		
		
		public function GameMagicManager(levelManager:LevelManager, userManager:UserManager, target:IEventDispatcher=null)
		{
			super(target);
			_levelManager = levelManager;
			_userManager = userManager;
			contentIndex = new ContentIndex();
		}
		
		public function updateXpAndLevel(xpToAdd:int):void
		{
			var neededXp:int = 0;
			var i:int = 0;
			
			_levelManager.sortLevels();
			
			do
			{
				neededXp = neededXp + (_levelManager.levels[i] as Level).xp_diff;
				i++;								
			}
			while (_userManager.user.xp + xpToAdd > neededXp);
			
			_userManager.user.increaseXp(xpToAdd);			
			
			if (_userManager.user.level.order < i)
			{
				_userManager.user.incrementLevel(i);
			}	
		}		
		
	}
}