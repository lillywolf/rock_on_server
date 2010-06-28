package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Dwelling;
	import models.OwnedDwelling;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import server.ServerController;

	public class DwellingController extends Controller
	{
		public var dwellings:ArrayCollection;
		public var owned_dwellings:ArrayCollection;
		public var dwellingsLoaded:int;
		public var ownedDwellingsLoaded:int;
		public var ownedDwellingMovieClipsLoaded:int;
		public var _serverController:ServerController;
		
		public function DwellingController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			dwellings = essentialModelController.dwellings;
			owned_dwellings = essentialModelController.owned_dwellings;
			essentialModelController.addEventListener(EssentialEvent.INSTANCE_LOADED, onInstanceLoaded);
			essentialModelController.addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			
			dwellingsLoaded = 0;
			ownedDwellingsLoaded = 0;
			ownedDwellingMovieClipsLoaded = 0;						
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
		
		private function onOwnedDwellingsCollectionChange(evt:CollectionEvent):void
		{
			(evt.items[0] as OwnedDwelling).addEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
			(evt.items[0] as OwnedDwelling).addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
		}
		
		private function onParentAssigned(evt:EssentialEvent):void
		{
			var od:OwnedDwelling = evt.currentTarget as OwnedDwelling;
			od.removeEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			if (od.dwelling['mc'])
			{
				ownedDwellingMovieClipsLoaded++;
			}		
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
		
		private function onParentMovieClipAssigned(evt:DynamicEvent):void
		{
			(evt.target as OwnedDwelling).removeEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
			ownedDwellingMovieClipsLoaded++;
			essentialModelController.checkIfAllLoadingComplete();
		}
		
		private function onInstanceLoaded(evt:EssentialEvent):void
		{
			if (evt.instance is Dwelling)
			{
				dwellingsLoaded++;
			}
			else if (evt.instance is OwnedDwelling)
			{
				ownedDwellingsLoaded++;
			}
			essentialModelController.checkIfAllLoadingComplete();
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