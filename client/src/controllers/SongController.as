package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.OwnedSong;
	import models.Song;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	public class SongController extends Controller
	{
		public var _songs:ArrayCollection;
		public var _owned_songs:ArrayCollection;
		public var songsLoaded:int;
		public var ownedSongsLoaded:int;
		public var fullyLoaded:Boolean;
		
		public function SongController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			_songs = essentialModelController.songs;
			_owned_songs = essentialModelController.owned_songs;
		}
		
		private function onOwnedSongsCollectionChange(evt:CollectionEvent):void
		{
			(evt.items[0] as OwnedSong).addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
		}		
		
		private function onParentAssigned(evt:EssentialEvent):void
		{
			var os:OwnedSong = evt.currentTarget as OwnedSong;
			os.removeEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);		
		}	
		
		private function onInstanceLoaded(evt:EssentialEvent):void
		{
			if (evt.instance is Song)
			{
				songsLoaded++;
			}
			else if (evt.instance is OwnedSong)
			{
				ownedSongsLoaded++;
			}
			essentialModelController.checkIfLoadingAndInstantiationComplete();
		}		
		
		public function add(song:Song):void
		{
			songs.addItem(song);
		}		
		
		public function remove(song:Song):void
		{
			var i:int = songs.getItemIndex(song);
			songs.removeItemAt(i);
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