package controllers
{
	import com.facebook.data.stream.StreamFilterCollection;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	import models.EssentialModelReference;
	import models.OwnedSong;
	import models.Song;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	import server.ServerController;
	
	public class SongController extends Controller
	{
		public var _serverController:ServerController;
		public var _songs:ArrayCollection;
		public var _owned_songs:ArrayCollection;
		
		public var songsLoaded:Boolean;
		public var ownedSongsLoaded:Boolean;
		
		public var ownedSongParentsAssigned:int;
		
		public function SongController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			_songs = essentialModelController.songs;
			_owned_songs = essentialModelController.owned_songs;
			
			_songs.addEventListener(CollectionEvent.COLLECTION_CHANGE, onSongsCollectionChange);
			_owned_songs.addEventListener(CollectionEvent.COLLECTION_CHANGE, onOwnedSongsCollectionChange);
			
//			essentialModelController.addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
//			essentialModelController.addEventListener(EssentialEvent.INSTANCE_LOADED, onInstanceLoaded);			
		}
		
		private function onOwnedSongsCollectionChange(evt:CollectionEvent):void
		{
			if ((evt.items[0] as OwnedSong).song == null)
			{
				(evt.items[0] as OwnedSong).addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);			
			}
			else
			{
				this.ownedSongParentsAssigned++;
				checkIfOwnedSongsFullyLoaded();
				runEssentialChecks();
			}
		}	
		
		private function onSongsCollectionChange(evt:CollectionEvent):void
		{
			checkIfSongsFullyLoaded();
			runEssentialChecks();
		}
		
		private function checkIfSongsFullyLoaded():Boolean
		{
			if (checkIfAllSongsAdded())
			{
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.SONGS_LOADED);
				this.dispatchEvent(evt);
				return true;
			}
			return false;
		}
		
		public function getSong(s:Song):void
		{
//			_serverController.sendRequest({id: s.id}, "song", "get_song");
			var folder:String = s.url.split("/")[0];
			var songNamePieces:Array = (s.url.split("/")[1] as String).split(" ");
			var songName:String = songNamePieces[0];
			for (var i:int = 1; i < songNamePieces.length; i++)
			{
				var toAdd:String = "+" + songNamePieces[i];
				songName = songName.concat(toAdd);
			}
			var url:String = ServerController.BASE_MP3_URL + folder + "/" + songName;
			var req:URLRequest = new URLRequest(url);
			var snd:Sound = new Sound();
			snd.addEventListener(Event.COMPLETE, onSoundLoaded);
			snd.load(req);
		}
		
		private function onSoundLoaded(evt:Event):void
		{
			var localSound:Sound = evt.target as Sound;
			localSound.play();
		}
		
		private function checkIfAllSongsAdded():Boolean
		{
			if (_songs.length == EssentialModelReference.numInstancesToLoad["song"] && _songs.length > 0)
			{
				return true;
			}
			return false;
		}
		
		private function checkIfOwnedSongsFullyLoaded():Boolean
		{
			if (checkIfAllOwnedSongsAdded() && checkIfOwnedSongParentsAssigned())
			{
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.OWNED_SONGS_LOADED);
				this.dispatchEvent(evt);
				return true;
			}
			return false;
		}
		
		private function checkIfAllOwnedSongsAdded():Boolean
		{
			if (_owned_songs.length == EssentialModelReference.numInstancesToLoad["owned_song"] && _owned_songs.length > 0)
			{
				return true;
			}
			return false;
		}
		
		private function checkIfOwnedSongParentsAssigned():Boolean
		{
			if (this.ownedSongParentsAssigned == _owned_songs.length)
			{
				return true;
			}
			return false;
		}
		
		private function onParentAssigned(evt:EssentialEvent):void
		{
			var os:OwnedSong = evt.currentTarget as OwnedSong;
			os.removeEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);	
			ownedSongParentsAssigned++;
			checkIfOwnedSongsFullyLoaded();
			runEssentialChecks();
		}	
		
//		private function onInstanceLoaded(evt:EssentialEvent):void
//		{
//			if (evt.instance is Song)
//			{
//				songsLoaded++;
//			}
//			else if (evt.instance is OwnedSong)
//			{
//				ownedSongsLoaded++;
//			}
//			checkForLoadingComplete();
//		}	
		
		private function runEssentialChecks():void
		{
			essentialModelController.checkIfLoadingAndInstantiationComplete();
		}
		
//		private function checkForLoadingComplete():void
//		{
//			if (ownedSongsLoaded == EssentialModelReference.numInstancesToLoad["owned_song"])
//			{
//				essentialModelController.checkIfLoadingAndInstantiationComplete();
//			}
//		}
		
		public function set serverController(val:ServerController):void
		{
			_serverController = val;
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