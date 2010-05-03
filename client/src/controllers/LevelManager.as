package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Level;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import server.ServerController;

	public class LevelManager extends Manager
	{
		public var _level:Level;
		[Bindable] public var _levels:ArrayCollection;
		public var _serverController:ServerController;
		
		public function LevelManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
			_levels = essentialModelManager.levels;
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
			var sortField:SortField = new SortField("order");
			sortField.numeric = true;
			var sort:Sort = new Sort();
			sort.fields = [sortField];
			_levels.sort = sort;
			_levels.refresh();
		}	
		
	}
}