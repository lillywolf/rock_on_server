package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.EssentialModelReference;
	import models.OwnedUsable;
	import models.Usable;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import server.ServerController;
	
	public class UsableController extends Controller
	{
		[Bindable] public var usables:ArrayCollection;
		[Bindable] public var owned_usables:ArrayCollection;
		public var ownedUsableMovieClipsLoaded:int;
		public var ownedUsablesLoaded:int;
		public var usablesLoaded:int;
		public var fullyLoaded:Boolean;
		public var _serverController:ServerController;		
		
		public function UsableController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			usables = essentialModelController.usables;
			owned_usables = essentialModelController.owned_usables;
			owned_usables.addEventListener(CollectionEvent.COLLECTION_CHANGE, onOwnedUsablesCollectionChange);
			essentialModelController.addEventListener(EssentialEvent.INSTANCE_LOADED, onInstanceLoaded);
			essentialModelController.addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			
			usablesLoaded = 0;
			ownedUsablesLoaded = 0;
			ownedUsableMovieClipsLoaded = 0;			
		}
		
		public function updateLoadedMovieClips(className:String):int
		{
			if (className == "OwnedUsable")
			{
				var loadedMovieClips:int = 0;
				for each (var ou:OwnedUsable in owned_usables)
				{
					if (ou.usable.mc != null)
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
		
		private function onOwnedUsablesCollectionChange(evt:CollectionEvent):void
		{
			(evt.items[0] as OwnedUsable).addEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
			(evt.items[0] as OwnedUsable).addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
		}
		
		private function onParentAssigned(evt:EssentialEvent):void
		{
			var ou:OwnedUsable = evt.currentTarget as OwnedUsable;
			ou.removeEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			if (ou.usable['mc'])
			{
				ownedUsableMovieClipsLoaded++;
			}	
			
			checkForLoadingComplete();
		}
		
		public function add(usable:Usable):void
		{
			usables.addItem(usable);
		}		
		
		public function remove(usable:Usable):void
		{
			var i:int = usables.getItemIndex(usable);
			usables.removeItemAt(i);
		}		
		
		private function onParentMovieClipAssigned(evt:DynamicEvent):void
		{
			(evt.target as OwnedUsable).removeEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
			ownedUsableMovieClipsLoaded++;
			
			checkForLoadingComplete();
		}
		
		private function checkForLoadingComplete():void
		{
			if (ownedUsableMovieClipsLoaded == EssentialModelReference.numInstancesToLoad["owned_usable"] && ownedUsablesLoaded == EssentialModelReference.numInstancesToLoad["owned_usable"])
			{
				essentialModelController.checkIfLoadingAndInstantiationComplete();			
			}			
		}
		
		private function onInstanceLoaded(evt:EssentialEvent):void
		{
			if (evt.instance is Usable)
			{
				usablesLoaded++;
			}
			else if (evt.instance is OwnedUsable)
			{
				ownedUsablesLoaded++;
			}
			essentialModelController.checkIfLoadingAndInstantiationComplete();
		}	
		
		public function getUsableByMood(mood:String):Usable
		{
			var usable:Usable;
			switch (mood)
			{
				case "hungry":
					usable = getUsableByName("Hamburger");
					break;
				case "thirsty":
					usable = getUsableByName("Coffee");
					break;
			}
			return usable;
		}
		
		public function getNurtureMessageByUsable(usable:Usable):String
		{
			switch (usable.name)
			{
				case "Hamburger":
					return "Feed burger";
					break;
				case "Coffee":
					return "Caffeinate";
					break;
			}
			return null;
		}
		
		public function getNumberOfOwnedUsablesByMood(mood:String):int
		{
			var usable:Usable = getUsableByMood(mood);
			var numberOfOwnedUsables:int = 0;
			for each (var ou:OwnedUsable in owned_usables)
			{
				if (ou.usable.id == usable.id)
				{
					numberOfOwnedUsables++;
				}
			}
			return numberOfOwnedUsables;
		}
		
		public function getUsableByName(name:String):Usable
		{
			for each (var u:Usable in usables)
			{
				if (u.name == name)
				{
					return u;
				}
			}
			return null;
		}
	}
}