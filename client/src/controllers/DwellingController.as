package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Dwelling;
	import models.EssentialModel;
	import models.EssentialModelReference;
	import models.OwnedDwelling;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import server.ServerController;

	public class DwellingController extends Controller
	{
		public var dwellings:ArrayCollection;
		public var owned_dwellings:ArrayCollection;
		
		public var dwellingsLoaded:Boolean;
		public var ownedDwellingsLoaded:Boolean;
		
		public var ownedDwellingParentsAssigned:int;
		public var dwellingMovieClipsLoaded:int;
		
		public var _serverController:ServerController;
		
		public function DwellingController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			dwellings = essentialModelController.dwellings;
			owned_dwellings = essentialModelController.owned_dwellings;
			
			dwellings.addEventListener(CollectionEvent.COLLECTION_CHANGE, onDwellingsCollectionChange);
			owned_dwellings.addEventListener(CollectionEvent.COLLECTION_CHANGE, onOwnedDwellingsCollectionChange);	
			
//			essentialModelController.addEventListener(EssentialEvent.INSTANCE_LOADED, onInstanceLoaded);
//			essentialModelController.addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);				
		}
		
		public function updateLoadedMovieClips(className:String):int
		{
			if (className == "OwnedDwelling")
			{
				var loadedMovieClips:int = 0;
				for each (var od:OwnedDwelling in owned_dwellings)
				{
					if (od.dwelling.mc != null)
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
		
		public function getDwellingsByType(type:String):ArrayCollection
		{
			var matchingStructures:ArrayCollection = new ArrayCollection();
			for each (var od:OwnedDwelling in owned_dwellings)
			{
				if (od.dwelling.dwelling_type == type)
				{
					matchingStructures.addItem(od);
				}
			}
			return matchingStructures;
		}		
		
		private function onDwellingsCollectionChange(evt:CollectionEvent):void
		{
//			Temporary fix
			
			if ((evt.items[0] as Dwelling).mc == null)
			{
//				(evt.items[0] as Dwelling).addEventListener("movieClipLoaded", onDwellingMovieClipAssigned);
//			}
//			else
//			{
				this.dwellingMovieClipsLoaded++;
				checkIfDwellingsFullyLoaded();
				runEssentialChecks();
			}
		}
		
		private function onDwellingMovieClipAssigned(evt:DynamicEvent):void
		{
			(evt.target as Dwelling).removeEventListener("movieClipLoaded", onDwellingMovieClipAssigned);
			dwellingMovieClipsLoaded++;
			checkIfDwellingsFullyLoaded();
			runEssentialChecks();
		}
		
		private function onOwnedDwellingsCollectionChange(evt:CollectionEvent):void
		{
//			(evt.items[0] as OwnedDwelling).addEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
			if ((evt.items[0] as OwnedDwelling).dwelling == null)
			{
				(evt.items[0] as OwnedDwelling).addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);			
			}
			else
			{
				this.ownedDwellingParentsAssigned++;
				checkIfOwnedDwellingsFullyLoaded();
				runEssentialChecks();
			}
		}
		
		private function checkIfDwellingsFullyLoaded():Boolean
		{
			if (checkIfAllDwellingsAdded())
			{
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.DWELLINGS_LOADED);
				this.dispatchEvent(evt);
				return true;
			}
			return false;
		}
		
		private function checkIfOwnedDwellingsFullyLoaded():Boolean
		{
			if (checkIfAllOwnedDwellingsAdded() && checkIfOwnedDwellingParentsAssigned())
			{
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.OWNED_DWELLINGS_LOADED);
				this.dispatchEvent(evt);
				return true;
			}
			return false;
		}
		
		private function checkIfAllDwellingsAdded():Boolean
		{
			if (this.dwellings.length == EssentialModelReference.numInstancesToLoad["dwelling"] && dwellings.length > 0)
			{
				return true;
			}
			return false;
		}
		
		private function checkIfAllOwnedDwellingsAdded():Boolean
		{
			if (this.owned_dwellings.length == EssentialModelReference.numInstancesToLoad["owned_dwelling"] && owned_dwellings.length > 0)
			{
				return true;
			}
			return false;
		}
		
		private function checkIfOwnedDwellingParentsAssigned():Boolean
		{
			if (this.owned_dwellings.length == this.ownedDwellingParentsAssigned)
			{
				return true;
			}
			return false;
		}
		
		private function onParentAssigned(evt:EssentialEvent):void
		{
			var od:OwnedDwelling = evt.currentTarget as OwnedDwelling;
			od.removeEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			ownedDwellingParentsAssigned++;
			checkIfOwnedDwellingsFullyLoaded();
			runEssentialChecks();
		}
		
//		public function updateOwnedDwellingState(stateName:String, venueId:int):void
//		{
//			_serverController.sendRequest({id: venueId, state_name: stateName}, 'owned_dwelling', 'update_state');										
//		}
		
		public function add(dwelling:Dwelling):void
		{
			dwellings.addItem(dwelling);
		}		
		
		public function remove(dwelling:Dwelling):void
		{
			var i:int = dwellings.getItemIndex(dwelling);
			dwellings.removeItemAt(i);
		}
		
		private function runEssentialChecks():void
		{
			essentialModelController.checkIfLoadingAndInstantiationComplete();				
		}
		
//		private function checkForLoadingComplete():void
//		{
//			if (ownedDwellingMovieClipsLoaded == EssentialModelReference.numInstancesToLoad["owned_dwelling"] && ownedDwellingsLoaded == EssentialModelReference.numInstancesToLoad["owned_dwelling"])
//			{
//				essentialModelController.checkIfLoadingAndInstantiationComplete();	
//			}			
//		}
		
//		private function onParentMovieClipAssigned(evt:DynamicEvent):void
//		{
//			(evt.target as OwnedDwelling).removeEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
//			ownedDwellingMovieClipsLoaded++;
//			
//			checkForLoadingComplete();
//		}
		
//		private function onInstanceLoaded(evt:EssentialEvent):void
//		{
//			if (evt.instance is Dwelling)
//			{
//				dwellingsLoaded++;
//				trace("dwellings loaded: " + dwellingsLoaded.toString());
//			}
//			else if (evt.instance is OwnedDwelling)
//			{
//				ownedDwellingsLoaded++;
//				trace("owned dwellings loaded: " + ownedDwellingsLoaded.toString());
//			}
//			essentialModelController.checkIfLoadingAndInstantiationComplete();
//		}	
		
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