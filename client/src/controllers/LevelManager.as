package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Level;
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import server.ServerController;

	public class LevelManager extends Manager
	{
		public var _level:Level;
		[Bindable] public var _levels:ArrayCollection;
		public var _serverController:ServerController;
		
		[Embed(source="../libs/icons/musicnotes.png")]
		public var musicIconClass:Class;
		[Embed(source="../libs/icons/guitar.png")]
		public var guitarIconClass:Class;
		[Embed(source="../libs/icons/heart.png")]
		public var heartIconClass:Class;
		[Embed(source="../libs/icons/pizza.png")]
		public var pizzaIconClass:Class;		
		[Embed(source="../libs/icons/coffee.png")]
		public var coffeeIconClass:Class;
		[Embed(source="../libs/icons/energydrink.png")]
		public var energyDrinkIconClass:Class;		
		[Embed(source="../libs/icons/hamburger.png")]
		public var hamburgerIconClass:Class;		
		
		public function LevelManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
			_levels = essentialModelManager.levels;
		}
		
		public function setLevelOnUser(myUser:User):Level
		{
			var lvl:Level = getLevelByOrder(myUser.level_id);
			myUser.level = lvl;
			_level = lvl;
			return lvl;
		}
		
		public function getLevelByOrder(rank:int):Level
		{
			for each (var lvl:Level in _levels)
			{
				if (lvl.rank == rank)
				{
					return lvl;
				}
			}
			return null;
		}
				
		public function getLevelByXp(xp:int):Level
		{
			var neededXp:int = 0;
			sortLevels();
			for (var i:int = 0; i < levels.length; i++)
			{
				neededXp += (levels[i] as Level).xp_diff;
				if (xp < neededXp)
				{
					return levels[i-1] as Level;
				}
			}
			return levels[i-1] as Level;
		}
		
		public function getLevelProgressPercentage(level:Level, xp:int):Number
		{
			sortLevels();
			var nextLevel:Level;
			var discardableXp:int = 0;
			for (var i:int = 0; i < levels.length; i++)
			{
				if (level.rank >= (levels[i] as Level).rank)
				{
					discardableXp += (levels[i] as Level).xp_diff;
				}
				else
				{
					nextLevel = levels[i] as Level;
					break;
				}
			}
			if (level.rank == levels.length)
			{
				return 1;
			}
			var xpFraction:Number = (xp - discardableXp)/nextLevel.xp_diff;
			return xpFraction;			
		}
		
		public function getNextXpThreshold(myUser:User):int
		{
			sortLevels();
			var totalXp:int = 0;
			for each (var level:Level in levels)
			{
				if (level.rank <= (myUser.level.rank + 1))
				{
					totalXp += level.xp_diff;
				}
			}	
			if (myUser.level.rank == levels.length)
			{
				return myUser.xp;
			}
			return totalXp;		
		}	
		
		public function getLevelByUser(myUser:User):Level
		{
			for each (var level:Level in levels)
			{
				if (level.id == myUser.level_id)
				{
					return level;
				}
			}
			return null;
		}
		
		public function getLevelIconByUser(myUser:User):Class
		{
			var myLevel:Level = this.getLevelByUser(myUser);
			switch (myLevel.rank)
			{
				case 1:
					return coffeeIconClass;
					break;
				case 2:
					return hamburgerIconClass;
					break;
				case 3:
					return energyDrinkIconClass;
					break;		
			}
			return null;
		}	
		
		public function set serverController(val:ServerController):void
		{
			_serverController = val;
		}	
		
		public function set levels(val:ArrayCollection):void
		{
			_levels = val;
		}
		
		public function get levels():ArrayCollection
		{
			return _levels;
		}
		
		public function set level(val:Level):void
		{
			_level = val;
		}	
		
		public function get level():Level
		{
			return _level;
		}	
		
		public function sortLevels():void
		{
			var sort:Sort = new Sort();
			var sortField:SortField = new SortField("rank");
			sortField.numeric = true;
			sort.fields = [sortField];
			_levels.sort = sort;
			_levels.refresh();
		}	
		
	}
}