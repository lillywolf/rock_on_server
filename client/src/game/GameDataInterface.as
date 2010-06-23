package game
{
	import controllers.CreatureManager;
	import controllers.DwellingManager;
	import controllers.EssentialModelManager;
	import controllers.LayerableManager;
	import controllers.LevelManager;
	import controllers.OwnedLayerableManager;
	import controllers.StoreManager;
	import controllers.StructureManager;
	import controllers.ThingerManager;
	import controllers.UserManager;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import helpers.UnprocessedModel;
	
	import models.EssentialModelReference;
	import models.OwnedDwelling;
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import server.ServerController;
	import server.ServerDataEvent;
	
	public class GameDataInterface extends EventDispatcher
	{
		[Bindable] public var layerableManager:LayerableManager;
		[Bindable] public var ownedLayerableManager:OwnedLayerableManager;
		[Bindable] public var creatureManager:CreatureManager;
		[Bindable] public var thingerManager:ThingerManager;
		[Bindable] public var essentialModelManager:EssentialModelManager;
		[Bindable] public var storeManager:StoreManager;
		[Bindable] public var structureManager:StructureManager;
		[Bindable] public var dwellingManager:DwellingManager;
		[Bindable] public var levelManager:LevelManager;
		[Bindable] public var userManager:UserManager;
		[Bindable] public var user:User;
		
		public var sc:ServerController;
		public var loadCounter:int = 0;
		public var pendingRequests:int = 0;
		public var gameClock:GameClock;
		public var initialized:Boolean;
		public var snid:Number;
		
		public function GameDataInterface(preLoadedContent:Dictionary=null)
		{
			sc = new ServerController(this);
			createManagers(preLoadedContent);
			gameClock = new GameClock();
			essentialModelManager.users.addEventListener(CollectionEvent.COLLECTION_CHANGE, setUser);
			essentialModelManager.addEventListener(ServerDataEvent.INSTANCE_TO_CREATE, onInstanceToCreate);
			essentialModelManager.addEventListener('instanceLoaded', onInstanceLoaded);	
		}
		
		public function createManagers(preLoadedContent:Dictionary):void
		{
			essentialModelManager = new EssentialModelManager();
			layerableManager = new LayerableManager(essentialModelManager);
			ownedLayerableManager = new OwnedLayerableManager(essentialModelManager);
			creatureManager = new CreatureManager(essentialModelManager);
			thingerManager = new ThingerManager(essentialModelManager);
			storeManager = new StoreManager(essentialModelManager);
			structureManager = new StructureManager(essentialModelManager);
			dwellingManager = new DwellingManager(essentialModelManager);
			userManager = new UserManager(essentialModelManager);
			levelManager = new LevelManager(essentialModelManager);
			
			userManager.levelManager = levelManager;
			
			if (preLoadedContent)
			{
				setPreLoadedContent(preLoadedContent);
			}			
			
			structureManager.serverController = sc;
			creatureManager.serverController = sc;
			thingerManager.serverController = sc;
			userManager.serverController = sc;
			levelManager.serverController = sc;
			dwellingManager.serverController = sc;
			
			storeManager.gdi = this;
		}
		
		public function onInstanceToCreate(evt:ServerDataEvent):void
		{
			createInstance(evt.params, evt.model, evt.method);
		}
		
		public function setPreLoadedContent(preLoadedContent:Dictionary):void
		{
			if (preLoadedContent["essentialModelReference"])
			{
				essentialModelManager.essentialModelReference = preLoadedContent["essentialModelReference"];
			}
			if (preLoadedContent["structures"])
			{
				essentialModelManager.structures = preLoadedContent["structures"];
				structureManager.structures = essentialModelManager.structures;
			}
			if (preLoadedContent["layerables"])
			{
				essentialModelManager.layerables = preLoadedContent["layerables"];
				layerableManager.layerables = essentialModelManager.layerables;
			}									
			if (preLoadedContent["dwellings"])
			{
				essentialModelManager.layerables = preLoadedContent["dwellings"];
				dwellingManager.dwellings = essentialModelManager.dwellings;
			}
			if (preLoadedContent["levels"])
			{
				essentialModelManager.levels = preLoadedContent["levels"];
				levelManager.levels = essentialModelManager.levels;
			}									
		}
		
		public function setUser(evt:CollectionEvent):void
		{
			var collection:ArrayCollection = evt.currentTarget as ArrayCollection;
			if ((collection.getItemAt(collection.length - 1) as User).snid == snid)
			{				
				user = collection.getItemAt(collection.length - 1) as User;
				userManager.user = user;
								
				var serverDataEvent:ServerDataEvent = new ServerDataEvent(ServerDataEvent.USER_LOADED, 'user', evt.currentTarget, null, true, true);
				dispatchEvent(serverDataEvent);
				essentialModelManager.users.removeEventListener(CollectionEvent.COLLECTION_CHANGE, setUser);
			}
		}
		
		public function getUserContent(uid:Number):void
		{
			snid = uid;
			getDataForModel({snid: uid}, "user", "find_by_snid");
		}
	
		public function getStaticGameContent():void
		{
			getDataForModel({}, "level", "get_all");
			getDataForModel({}, "layerable", "get_all");
			getDataForModel({}, "structure", "get_all");
			getDataForModel({}, "dwelling", "get_all");
			getDataForModel({}, "store", "get_all");
		}
		
		public function getDataForModel(params:Object, modelName:String, methodName:String):void
		{
			pendingRequests++;
			sc.sendRequest(params, modelName, methodName);	
		}
		
		public function createInstance(params:Object, modelName:String, methodName:String):void
		{
			sc.sendRequest(params, modelName, methodName);
		}
		
		public function objectLoaded(objectsLoaded:Object, requestType:String):void
		{				
			for each (var obj:Object in objectsLoaded)
			{
				if (obj.has_many)
				{
					requestChildrenFromServer(obj, requestType);
				}
				if (obj.has_one)
				{
					requestChildrenFromServer(obj, requestType);					
				}
				if (obj.created_from_client)
				{
					loadObject(obj, requestType);
				}
				
				if (obj.already_loaded)
				{
					updateProperties(obj);
				}
				else
				{
					loadObject(obj, requestType);				
				}
			}
			checkIfLoadingComplete();
			// Dispatch load event?
		}	
		
		public function dispatchServerUpdateEvent(instance:Object, model:String, method:String):void
		{
			var evt:ServerDataEvent = new ServerDataEvent(ServerDataEvent.UPDATE_COMPLETE, model, instance, method);
			dispatchEvent(evt); 
		}
		
		public function updateProperties(obj:Object):void
		{
			var className:String = essentialModelManager.convertToClassCase(obj.model);
			var klass:Class = getDefinitionByName('models.'+className) as Class;
			
			// This should be improved, first way is better
			
			var instance:Object;
			if (obj.model)
			{			
				for each (instance in essentialModelManager[obj.model+'s'])
				{
					if (instance.id == obj.instance[obj.model].id)
					{
						instance.updateProperties(obj.instance[obj.model]);
						dispatchServerUpdateEvent(instance, obj.model, obj.method);
					}
				}
			}	
			else
			{
				throw new Error("No model specified for server response");
			}
			
			// Handles user class case
			
			if (obj.instance[obj.model].snid)
			{
				if (isGameUser(obj.instance[obj.model].snid))
				{
					for each (instance in essentialModelManager[obj.model])
					{
						if (instance.id == obj.instance[obj.model].id)
						{
							instance.updateProperties(obj.instance[obj.model]);
						}
					}
				}
			}
		}
		
		public function isGameUser(snid:int):Boolean
		{
			if (snid == FlexGlobals.topLevelApplication.facebookInterface.snid)
			{
				return true;
			}
			return false;
		}
		
		public function checkIfLoadingComplete():void
		{
			// Really, this way sucks...
			
			loadCounter++;
			if (pendingRequests == loadCounter)
			{
				var evt:ServerDataEvent = new ServerDataEvent(ServerDataEvent.USER_CONTENT_LOADED, null, null, null, true, true);
				dispatchEvent(evt);
			}
		}
				
		public function loadObject(obj:Object, requestType:String):void
		{
			var toLoad:UnprocessedModel = new UnprocessedModel(requestType, obj, obj.instance[requestType]);
			essentialModelManager.loadNewInstance(toLoad);				
		}
		
		public function requestChildrenFromServer(parentObject:Object, requestType:String):void
		{
			var dict:Dictionary = new Dictionary();
			var i:int;
			
			for each (var str:String in parentObject.has_many)
			{
				var keyString:String = parentObject.model+'_id';
				dict[keyString] = parentObject.instance[requestType].id;
				var methodName:String = 'find_by_' + parentObject.model + '_id';
				getDataForModel(dict as Object, str, methodName);
			}			
		}
		
		private function onInstanceLoaded(evt:DynamicEvent):void
		{
			checkIfLoadingAndInstantiationComplete();
		}
		
		public function checkIfLoadingAndInstantiationComplete():void
		{
//			Alert.show(pendingRequests.toString() + "::" + loadCounter.toString());
			if (essentialModelManager.instancesToLoad.length == 0 && pendingRequests == loadCounter)
			{
//				Use true for testing in non-Facebook environment				
				
				if (isLoggedInUser())
//				if (true)
				{
					FlexGlobals.topLevelApplication.instancesLoadedForGameUser();				
				}
				else
				{
					FlexGlobals.topLevelApplication.instancesLoadedForFriend();
				}
				checkForLoadedMovieClips();
			}			
		}
		
		public function checkForLoadedMovieClips():void
		{
			checkForLoadedStructures();
			checkForLoadedLayerables();
		}
		
		private function checkForLoadedStructures():void
		{
// 			This number is currently adjusted for stages without MCs!! CHANGE LATER!!
//			trace (structureManager.ownedStructureMovieClipsLoaded.toString() + "::" + structureManager.ownedStructuresLoaded.toString());
			if (structureManager.ownedStructureMovieClipsLoaded == structureManager.ownedStructuresLoaded)
			{
//				Use true for non-Facebook testing					
				if (isLoggedInUser() && !structureManager.fullyLoaded && (dwellingManager.owned_dwellings[0] as OwnedDwelling).dwelling)
//				if (true)
				{
					FlexGlobals.topLevelApplication.attemptToInitializeVenueForUser();	
					structureManager.fullyLoaded = true;
				}
				else if (isLoggedInUser() && !structureManager.fullyLoaded && !(dwellingManager.owned_dwellings[0] as OwnedDwelling).dwelling)
				{
					throw new Error("Dwelling not set");
				}
				else
				{
					FlexGlobals.topLevelApplication.friendGDILoaded(this);
				}
			}	
		}
		
		private function checkForLoadedLayerables():void
		{
			if (layerableManager.ownedLayerableMovieClipsLoaded == layerableManager.ownedLayerablesLoaded)
			{
				if (isLoggedInUser() && !layerableManager.fullyLoaded)
				{
					FlexGlobals.topLevelApplication.attemptToPopulateVenueForUser();
					layerableManager.fullyLoaded = true;
				}
				else
				{
//					Code for friend creature initialization
				}
			}			
		}
		
		public function isLoggedInUser():Boolean
		{
			if (FlexGlobals.topLevelApplication.facebookInterface.snid == user.snid)
			{
				return true;				
			}
			else
			{
				return false;
			}			
		}		

	}
}