package controllers
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	
	import models.OwnedStructure;
	import models.Structure;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import rock_on.BoothManager;
	import rock_on.ListeningStationManager;
	
	import server.ServerController;
	
	import stores.StoreEvent;
	
	import views.WorldView;
	
	import world.ActiveAsset;

	public class StructureManager extends Manager
	{
		[Bindable] public var structures:ArrayCollection;
		[Bindable] public var owned_structures:ArrayCollection;
		public var ownedStructureMovieClipsLoaded:int;
		public var ownedStructuresLoaded:int;
		public var structuresLoaded:int;
		public var _serverController:ServerController;
		
		public function StructureManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
			structures = essentialModelManager.structures;
			owned_structures = essentialModelManager.owned_structures;
			owned_structures.addEventListener(CollectionEvent.COLLECTION_CHANGE, onOwnedStructuresCollectionChange);
			essentialModelManager.addEventListener(EssentialEvent.INSTANCE_LOADED, onInstanceLoaded);
			essentialModelManager.addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			
			structuresLoaded = 0;
			ownedStructuresLoaded = 0;
			ownedStructureMovieClipsLoaded = 0;
		}
		
		public function updateLoadedMovieClips(className:String):int
		{
			if (className == "OwnedStructure")
			{
				var loadedMovieClips:int = 0;
				for each (var os:OwnedStructure in owned_structures)
				{
					if (os.structure.mc != null)
					{
						loadedMovieClips++;
					}
				}
				return loadedMovieClips;
			}
			else
			{
				throw new Error("Invalid class name");
				return 0;
			}
		}
		
		public function getStructuresByType(type:String):ArrayCollection
		{
			var matchingStructures:ArrayCollection = new ArrayCollection();
			for each (var os:OwnedStructure in owned_structures)
			{
				if (os.structure.structure_type == type)
				{
					matchingStructures.addItem(os);
				}
			}
			return matchingStructures;
		}
		
		private function onOwnedStructuresCollectionChange(evt:CollectionEvent):void
		{
			(evt.items[0] as OwnedStructure).addEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
			(evt.items[0] as OwnedStructure).addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
		}
		
		private function onParentAssigned(evt:EssentialEvent):void
		{
			var os:OwnedStructure = evt.currentTarget as OwnedStructure;
			os.removeEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			if (os.structure['mc'])
			{
				ownedStructureMovieClipsLoaded++;
			}		
		}
		
		public function add(structure:Structure):void
		{
			structures.addItem(structure);
		}		
		
		public function remove(structure:Structure):void
		{
			var i:int = structures.getItemIndex(structure);
			structures.removeItemAt(i);
		}		
		
		private function onParentMovieClipAssigned(evt:DynamicEvent):void
		{
			(evt.target as OwnedStructure).removeEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
			ownedStructureMovieClipsLoaded++;
			essentialModelManager.checkIfAllLoadingComplete();
		}
		
		private function onInstanceLoaded(evt:EssentialEvent):void
		{
			if (evt.instance is Structure)
			{
				structuresLoaded++;
			}
			else if (evt.instance is OwnedStructure)
			{
				ownedStructuresLoaded++;
			}
			essentialModelManager.checkIfAllLoadingComplete();
		}
		
		public function getListeningStationTypeByMovieClip(mc:MovieClip):String
		{
			if (mc is Ticket_01)
			{
				return "Gramophone";
			}
			return null;
		}
		
		public function validateBoothCountZero(id:int):void
		{
			_serverController.sendRequest({id: id, client_validate: "true"}, "owned_structure", "update_inventory_count");
		}
		
		public function updateOwnedStructureOnServerResponse(osCopy:OwnedStructure, method:String, worldView:WorldView):void
		{
			for each (var os:OwnedStructure in owned_structures)
			{
				if (os.id == osCopy.id)
				{
					var osReference:OwnedStructure = os;
				}
			}
			if (method == "sell")
			{
				removeOwnedStructureFromSystem(osReference);
			}
//			else if (method == "create_new")
//			{
//				
//			}
			else if (os.structure.structure_type == "Booth")
			{
				updateBoothOnServerResponse(os, method, worldView.boothManager);
			}
			else if (os.structure.structure_type == "ListeningStation")
			{
				updateListeningStationOnServerResponse(os, method, worldView.listeningStationManager);
			}						
		}
		
		private function removeOwnedStructureFromSystem(os:OwnedStructure):void
		{
			var index:int = owned_structures.getItemIndex(os);
			owned_structures.removeItemAt(index);
			var evt:StoreEvent = new StoreEvent(StoreEvent.THINGER_SOLD, os, true, true);
			dispatchEvent(evt);
		}
		
		private function updateBoothOnServerResponse(os:OwnedStructure, method:String, boothManager:BoothManager):void
		{
			boothManager.updateBoothOnServerResponse(os, method);		
		}
		
		public function generateAssetFromOwnedStructure(os:OwnedStructure):ActiveAsset
		{
			var asset:ActiveAsset = new ActiveAsset(os.structure.mc);
			asset.thinger = os;
			return asset;
		}
		
		private function updateListeningStationOnServerResponse(os:OwnedStructure, method:String, listeningStationManager:ListeningStationManager):void
		{
			listeningStationManager.updateStationOnServerResponse(os, method);
		}
		
		public function set serverController(val:ServerController):void
		{
			_serverController = val;
		}
		
		public function get serverController():ServerController
		{
			return _serverController;
		}
	}
}