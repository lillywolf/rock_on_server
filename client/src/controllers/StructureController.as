package controllers
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import game.ImposterOwnedStructure;
	
	import models.EssentialModelReference;
	import models.OwnedDwelling;
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
	import world.Point3D;
	import world.World;

	public class StructureController extends Controller
	{
		public static const STRUCTURE_SCALE:Number = 1;
		
		[Bindable] public var structures:ArrayCollection;
		[Bindable] public var owned_structures:ArrayCollection;
		
		public var structureMovieClipsLoaded:int;
		public var ownedStructureParentsAssigned:int;
		
		public var ownedStructuresLoaded:Boolean;
		public var structuresLoaded:Boolean;
		
		public var _serverController:ServerController;
		
		public function StructureController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			structures = essentialModelController.structures;
			owned_structures = essentialModelController.owned_structures;

			structures.addEventListener(CollectionEvent.COLLECTION_CHANGE, onStructuresCollectionChange);
			owned_structures.addEventListener(CollectionEvent.COLLECTION_CHANGE, onOwnedStructuresCollectionChange);
			
//			essentialModelController.addEventListener(EssentialEvent.INSTANCE_LOADED, onInstanceLoaded);
			essentialModelController.addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
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
		
		private function onStructuresCollectionChange(evt:CollectionEvent):void
		{
			if ((evt.items[0] as Structure).mc == null)
			{
				(evt.items[0] as Structure).addEventListener("movieClipLoaded", onStructureMovieClipAssigned); 
			}
			else
			{
				this.structureMovieClipsLoaded++;
				checkIfStructuresFullyLoaded();
				runEssentialChecks();
			}
		}
		
		private function onStructureMovieClipAssigned(evt:DynamicEvent):void
		{
			(evt.target as Structure).removeEventListener("movieClipLoaded", onStructureMovieClipAssigned);
			structureMovieClipsLoaded++;
			checkIfStructuresFullyLoaded();
			runEssentialChecks();
		}
		
		private function checkIfStructuresFullyLoaded():Boolean
		{
			if (checkIfAllStructuresAdded() && checkIfStructureMovieClipsAssigned())
			{
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.STRUCTURES_LOADED);
				this.dispatchEvent(evt);
				return true;
			}
			return false;
		}
		
		private function onOwnedStructuresCollectionChange(evt:CollectionEvent):void
		{
			if ((evt.items[0] as OwnedStructure).structure == null)
			{
				(evt.items[0] as OwnedStructure).addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);			
			}
			else
			{
				this.ownedStructureParentsAssigned++;
				checkIfOwnedStructuresFullyLoaded();
				runEssentialChecks();
			}
//			(evt.items[0] as OwnedStructure).addEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
		}
		
		private function onParentAssigned(evt:EssentialEvent):void
		{
			var os:OwnedStructure = evt.currentTarget as OwnedStructure;
			os.removeEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			ownedStructureParentsAssigned++;
			checkIfOwnedStructuresFullyLoaded();
			runEssentialChecks();
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
		
		public function saveNewOwnedStructure(os:OwnedStructure, od:OwnedDwelling, coords:Point3D):void
		{
			_serverController.sendRequest({user_id: od.user_id, owned_dwelling_id: od.id, structure_id: os.structure.id, x: coords.x, y: coords.y, z: coords.z}, "owned_structure", "create_new");			
		}
		
//		private function onParentMovieClipAssigned(evt:DynamicEvent):void
//		{
//			(evt.target as OwnedStructure).removeEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
//			ownedStructureMovieClipsLoaded++;
//			
//			checkForLoadingComplete();
//		}
		
		private function checkIfOwnedStructuresFullyLoaded():Boolean
		{
			if (checkIfAllOwnedStructureParentsAssigned() && checkIfAllOwnedStructuresAdded())
			{
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.OWNED_STRUCTURES_LOADED);
				this.dispatchEvent(evt);
				return true;
			}
			return false;
		}
		
		private function checkIfStructureMovieClipsAssigned():Boolean
		{
			for each (var s:Structure in structures)
			{
				if (!s.mc)
				{
					return false;
				}
			}
			return true;
		}
		
		private function checkIfAllStructuresAdded():Boolean
		{
			if (structures.length == EssentialModelReference.numInstancesToLoad["structure"])
			{
				return true;
			}
			return false;			
		}
		
		public function checkIfAllOwnedStructureParentsAssigned():Boolean
		{
			if (ownedStructureParentsAssigned == owned_structures.length && owned_structures.length > 0)
			{
				return true;
			}
			return false;
		}	
		
		private function checkIfAllOwnedStructuresAdded():Boolean
		{
			if (owned_structures.length == EssentialModelReference.numInstancesToLoad["owned_structure"] && owned_structures.length > 0)
			{
				return true;
			}
			return false;
		}		
		
//		private function checkForLoadingComplete():void
//		{
//			if (ownedStructureMovieClipsLoaded == EssentialModelReference.numInstancesToLoad["owned_structure"] && ownedStructuresLoaded == EssentialModelReference.numInstancesToLoad["owned_structure"])
//			{
//				essentialModelController.checkIfLoadingAndInstantiationComplete();			
//			}			
//		}
		
		private function runEssentialChecks():void
		{
			essentialModelController.checkIfLoadingAndInstantiationComplete();
		}
		
//		private function onInstanceLoaded(evt:EssentialEvent):void
//		{
//			if (evt.instance is Structure)
//			{
//				structuresLoaded++;
//			}
//			else if (evt.instance is OwnedStructure)
//			{
//				ownedStructuresLoaded++;
//			}
//			essentialModelController.checkIfLoadingAndInstantiationComplete();
//		}
//		
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
		
		public function getStructureToppers(os:OwnedStructure):ArrayCollection
		{
			var toppers:ArrayCollection = new ArrayCollection();
			for each (var topper:OwnedStructure in this.owned_structures)
			{
				if (os.structure.structure_type == "StructureTopper" && topsStructure(topper, os))
					toppers.addItem(topper);
			}
			return toppers;
		}
		
		private function topsStructure(topper:OwnedStructure, os:OwnedStructure):Boolean
		{
			var structureSpaces:ArrayCollection = getPointsForStructure(os);
			var topperSpaces:ArrayCollection = getPointsForStructure(topper);
			for each (var pt:Point3D in structureSpaces)
			{
				for each (var tPt:Point3D in topperSpaces)
				{
					if (pt.x == tPt.x && pt.z == tPt.z)
						return true;
				}
			}
			return false;
		}
		
		public function getPointsForStructure(os:OwnedStructure):ArrayCollection
		{			
			var spaces:ArrayCollection = new ArrayCollection();
			for (var xPt:int = 0; xPt <= os.structure.width; xPt++)
			{
				for (var zPt:int = 0; zPt <= os.structure.depth; zPt++)
				{
					var osPt3D:Point3D = pathGrid[os.x - os.structure.width/2 + xPt][os.y][os.z - os.structure.depth/2 + zPt];
					spaces.addItem(osPt3D);										
				}
			}
			if (!os.structure.width || !os.structure.depth)
			{
				throw new Error("No dimensions specified for structure");
			} 			
			return spaces;
		}		
		
		public function drawTiles(_world:World):void
		{
			for each (var os:OwnedStructure in owned_structures)
			{
				if (os.structure.structure_type == "Tile")
				{
					var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);					
					var asset:ActiveAsset = new ActiveAsset(mc);
					asset.thinger = os;
					_world.addAsset(asset, new Point3D(os.x, os.y, os.z));
				}
			}
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