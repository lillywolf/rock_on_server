package controllers
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import game.ImposterOwnedStructure;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	import models.Structure;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import rock_on.BoothBoss;
	import rock_on.ListeningStationBoss;
	import rock_on.Venue;
	
	import server.ServerController;
	
	import stores.StoreEvent;
	
	import views.WorldView;
	
	import world.ActiveAsset;

	public class StructureController extends Controller
	{
		public static const STRUCTURE_SCALE:Number = 1;
		
		[Bindable] public var structures:ArrayCollection;
		[Bindable] public var owned_structures:ArrayCollection;
		public var ownedStructureMovieClipsLoaded:int;
		public var ownedStructuresLoaded:int;
		public var structuresLoaded:int;
		public var fullyLoaded:Boolean;
		public var _serverController:ServerController;
		
		public function StructureController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			structures = essentialModelController.structures;
			owned_structures = essentialModelController.owned_structures;
			owned_structures.addEventListener(CollectionEvent.COLLECTION_CHANGE, onOwnedStructuresCollectionChange);
			essentialModelController.addEventListener(EssentialEvent.INSTANCE_LOADED, onInstanceLoaded);
			essentialModelController.addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			
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
			
			checkForLoadingComplete();
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
			
			checkForLoadingComplete();
		}
		
		private function checkForLoadingComplete():void
		{
			if (ownedStructureMovieClipsLoaded == EssentialModelReference.numInstancesToLoad["owned_structure"] && ownedStructuresLoaded == EssentialModelReference.numInstancesToLoad["owned_structure"])
			{
				essentialModelController.checkIfLoadingAndInstantiationComplete();			
			}			
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
			essentialModelController.checkIfLoadingAndInstantiationComplete();
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
		
		public function updateOwnedStructureOnServerResponse(osCopy:OwnedStructure, method:String, venue:Venue):void
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
			
			if (osReference.structure.structure_type == "Booth")
			{
				updateBoothOnServerResponse(osReference, method, venue.boothBoss);
			}
			else if (osReference.structure.structure_type == "ListeningStation")
			{
				updateListeningStationOnServerResponse(osReference, method, venue.listeningStationBoss);
			}						
		}
		
		private function assignNewOwnedStructureToImposter(osCopy:OwnedStructure):void
		{
			if (FlexGlobals.topLevelApplication.currentState == "editView")
			{
				for each (var asset:ActiveAsset in FlexGlobals.topLevelApplication.worldView.myWorld.assetRenderer)
				{
					if (asset.thinger is ImposterOwnedStructure)
					{
						(asset.thinger as OwnedStructure).updateProperties(osCopy);
					}
				}
			}
			else
			{
				throw new Error("Handle race condition");
			}			
		}
		
		private function removeOwnedStructureFromSystem(os:OwnedStructure):void
		{
			var index:int = owned_structures.getItemIndex(os);
			owned_structures.removeItemAt(index);
			var evt:StoreEvent = new StoreEvent(StoreEvent.THINGER_SOLD, os, true, true);
			dispatchEvent(evt);
		}
		
		private function updateBoothOnServerResponse(os:OwnedStructure, method:String, boothBoss:BoothBoss):void
		{
			boothBoss.updateBoothOnServerResponse(os, method);		
		}
		
		public function generateAssetFromOwnedStructure(os:OwnedStructure):ActiveAsset
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
			mc.cacheAsBitmap = true;
			var asset:ActiveAsset = new ActiveAsset(mc);
			asset.thinger = os;
			return asset;
		}
		
		public function findAssetFromOwnedStructure(assets:ArrayCollection, os:OwnedStructure):ActiveAsset
		{
			for each (var asset:ActiveAsset in assets)
			{
				if (asset.thinger)
				{
					if (doesOwnedStructureMatchThingerId(asset.thinger, os.id))
					{
						return asset;
					}
				}
			}
			return null;
		}
		
		public function doesOwnedStructureMatchThingerId(thinger:Object, osId:int):Boolean
		{
			if (thinger.hasOwnProperty("id"))
			{
				if (thinger.id == osId)
				{
					return true;
				}
			}
			return false;
		}
		
		private function updateListeningStationOnServerResponse(os:OwnedStructure, method:String, listeningStationBoss:ListeningStationBoss):void
		{
			listeningStationBoss.updateStationOnServerResponse(os, method);
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