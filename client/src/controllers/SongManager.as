package controllers
{
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	public class SongManager extends Manager
	{
		public var _songs:ArrayCollection;
		public var _owned_songs:ArrayCollection;
		public var songsLoaded:int;
		public var fullyLoaded:Boolean;
		
		public function SongManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
			_songs = essentialModelManager.songs;
			_owned_songs = essentialModelManager.owned_songs;
		}
		
		public function set songs(val:ArrayCollection):void
		{
			_songs = val;
		}
		
		public function get songs():ArrayCollection
		{
			return _songs;
		}
		
		public function get owned_songs():ArrayCollection
		{
			return _owned_songs;
		}
	}
}