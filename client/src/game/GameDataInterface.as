package game
{
	import controllers.CreatureManager;
	import controllers.EssentialModelManager;
	import controllers.LayerableManager;
	import controllers.OwnedLayerableManager;
	import controllers.StoreManager;
	import controllers.StructureManager;
	import controllers.ThingerManager;
	import controllers.UserManager;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import helpers.UnprocessedModel;
	
	import models.User;
	
	import mx.core.Application;
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
		[Bindable] public var userManager:UserManager;
		[Bindable] public var user:User;
		
		public var sc:ServerController;
		public var loadCounter:int = 0;
		public var pendingRequests:int = 0;
		public var gameClock:GameClock;
		
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
			userManager = new UserManager(essentialModelManager);
			if (preLoadedContent)
			{
				setPreLoadedContent(preLoadedContent);
			}			
			
			creatureManager.serverController = sc;
			thingerManager.serverController = sc;
			userManager.serverController = sc;
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
		}
		
		public function setUser(evt:CollectionEvent):void
		{
			user = essentialModelManager.users[0];
			userManager.user = user;
			
			gameClock.updateLastShowtime(userManager.user.last_showtime);
			
			var serverDataEvent:ServerDataEvent = new ServerDataEvent(ServerDataEvent.USER_LOADED, 'user', evt.currentTarget, null, true, true);
			dispatchEvent(serverDataEvent);
			essentialModelManager.users.removeEventListener(CollectionEvent.COLLECTION_CHANGE, setUser);
		}
		
		public function getUserContent(uid:int):void
		{
			getDataForModel({snid: uid}, "user", "find_by_snid");
		}
	
		public function getStaticGameContent():void
		{
			getDataForModel({}, "layerable", "get_all");
			getDataForModel({}, "structure", "get_all");
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
				if (obj.already_loaded)
				{
					updateProperties(obj, requestType);
					return;
				}
				loadObject(obj, requestType);
			}
			checkIfLoadingComplete();
//			dispatchLoadEvent(obj, requestType);			
		}	
		
		public function updateProperties(obj:Object, requestType:String):void
		{
			var className:String = essentialModelManager.convertToClassCase(requestType);
			var klass:Class = essentialModelManager.essentialModelReference.loadedModels[className].klass;
			
			for each (var instance:Object in essentialModelManager[requestType+'s'])
			{
				if (instance.id == obj.instance[requestType].id)
				{
					instance.updateProperties(obj.instance[requestType]);
				}
			}
			
			// Handles user class case
			
			for each (instance in essentialModelManager[requestType])
			{
				if (instance.id == obj.instance[requestType].id)
				{
					instance.updateProperties(obj.instance[requestType]);
				}
			}
		}
		
		public function checkIfLoadingComplete():void
		{
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
			if (essentialModelManager.instancesToLoad.length == 0 && pendingRequests == loadCounter)
			{
				if (isLoggedInUser())
				{
					Application.application.instancesLoadedForGameUser();				
				}
				else
				{
					Application.application.instancesLoadedForFriend();
				}
				checkForLoadedMovieClips();
			}			
		}
		
		public function checkForLoadedMovieClips():void
		{
			// This number is currently adjusted for stages without MCs!! CHANGE LATER!!
			if (structureManager.ownedStructureMovieClipsLoaded == structureManager.ownedStructuresLoaded - 1)
			{
				if (isLoggedInUser())
				{
					Application.application.attemptToInitializeVenueForUser();											
				}
				else
				{
					Application.application.attemptToShowFriendVenue(this);
				}
			}
		}
		
		public function isLoggedInUser():Boolean
		{
			if (Application.application.facebookInterface.snid == user.snid)
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