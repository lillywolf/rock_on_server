package game
{
	import controllers.CreatureController;
	import controllers.DwellingController;
	import controllers.EssentialEvent;
	import controllers.EssentialModelController;
	import controllers.LayerableController;
	import controllers.LevelController;
	import controllers.SongController;
	import controllers.StoreController;
	import controllers.StructureController;
	import controllers.ThingerController;
	import controllers.UsableController;
	import controllers.UserController;
	
	import flash.events.Event;
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
		[Bindable] public var songController:SongController;
		[Bindable] public var layerableController:LayerableController;
		[Bindable] public var usableController:UsableController;
		[Bindable] public var creatureController:CreatureController;
		[Bindable] public var thingerController:ThingerController;
		[Bindable] public var essentialModelController:EssentialModelController;
		[Bindable] public var storeController:StoreController;
		[Bindable] public var structureController:StructureController;
		[Bindable] public var dwellingController:DwellingController;
		[Bindable] public var levelController:LevelController;
		[Bindable] public var userController:UserController;
		[Bindable] public var user:User;
		
		public var sc:ServerController;
		public var loadCounter:int = 0;
		public var pendingRequests:int = 0;
		public var staticContentLoaded:Boolean;
		public var userContentLoaded:Boolean;
		public var gameClock:GameClock;
		public var initialized:Boolean;
		public var snid:Number;		
		
		public function GameDataInterface(preLoadedContent:Dictionary=null)
		{
			sc = new ServerController(this);
			createManagers(preLoadedContent);
			gameClock = new GameClock();
			essentialModelController.users.addEventListener(CollectionEvent.COLLECTION_CHANGE, setUser);
			essentialModelController.addEventListener(ServerDataEvent.INSTANCE_TO_CREATE, onInstanceToCreate);
//			essentialModelController.addEventListener('instanceLoaded', onInstanceLoaded);	
		}
		
		public function createManagers(preLoadedContent:Dictionary):void
		{
			essentialModelController = new EssentialModelController();
			essentialModelController.gdi = this;
			
			songController = new SongController(essentialModelController);
			layerableController = new LayerableController(essentialModelController);
			usableController = new UsableController(essentialModelController);
			creatureController = new CreatureController(essentialModelController);
			thingerController = new ThingerController(essentialModelController);
			storeController = new StoreController(essentialModelController);
			structureController = new StructureController(essentialModelController);
			dwellingController = new DwellingController(essentialModelController);
			userController = new UserController(essentialModelController);
			levelController = new LevelController(essentialModelController);
			
			userController.levelController = levelController;
			
			if (preLoadedContent)
			{
				setPreLoadedContent(preLoadedContent);
			}			
			
			structureController.serverController = sc;
			creatureController.serverController = sc;
			thingerController.serverController = sc;
			userController.serverController = sc;
			levelController.serverController = sc;
			dwellingController.serverController = sc;
			
			storeController.gdi = this;
		}
		
		public function onInstanceToCreate(evt:ServerDataEvent):void
		{
			createInstance(evt.params, evt.model, evt.method);
		}
		
		public function setPreLoadedContent(preLoadedContent:Dictionary):void
		{
			if (preLoadedContent["essentialModelReference"])
			{
				essentialModelController.essentialModelReference = preLoadedContent["essentialModelReference"];
			}
			if (preLoadedContent["structures"])
			{
				essentialModelController.structures = preLoadedContent["structures"];
				structureController.structures = essentialModelController.structures;
			}
			if (preLoadedContent["layerables"])
			{
				essentialModelController.layerables = preLoadedContent["layerables"];
				layerableController.layerables = essentialModelController.layerables;
			}									
			if (preLoadedContent["usables"])
			{
				essentialModelController.layerables = preLoadedContent["usables"];
				usableController.usables = essentialModelController.usables;
			}									
			if (preLoadedContent["dwellings"])
			{
				essentialModelController.layerables = preLoadedContent["dwellings"];
				dwellingController.dwellings = essentialModelController.dwellings;
			}
			if (preLoadedContent["levels"])
			{
				essentialModelController.levels = preLoadedContent["levels"];
				levelController.levels = essentialModelController.levels;
			}
			if (preLoadedContent["songs"])
			{
				essentialModelController.songs = preLoadedContent["songs"];
				songController.songs = essentialModelController.songs;
			}
		}
		
		public function setUser(evt:CollectionEvent):void
		{
			var collection:ArrayCollection = evt.currentTarget as ArrayCollection;
			if ((collection.getItemAt(collection.length - 1) as User).snid == snid)
			{				
				user = collection.getItemAt(collection.length - 1) as User;
				userController.user = user;
								
				var serverDataEvent:ServerDataEvent = new ServerDataEvent(ServerDataEvent.USER_LOADED, 'user', evt.currentTarget, null, true, true);
				serverDataEvent.user = user;
				dispatchEvent(serverDataEvent);
				essentialModelController.users.removeEventListener(CollectionEvent.COLLECTION_CHANGE, setUser);
			}
		}
		
		public function getUserContent(uid:Number):void
		{
			snid = uid;
			getDataForModel({snid: uid}, "user", "find_by_snid");
		}
		
		public function getBasicUserContent(uid:Number):void
		{
			snid = uid;
			getDataForModel({snid: uid}, "user", "get_basic_info_by_snid");
		}
	
		public function getStaticGameContent():void
		{
			getDataForModel({}, "level", "get_all");
			getDataForModel({}, "layerable", "get_all");
			getDataForModel({}, "structure", "get_all");
			getDataForModel({}, "dwelling", "get_all");
			getDataForModel({}, "store", "get_all");
			getDataForModel({}, "song", "get_all");
			getDataForModel({}, "usable", "get_all");
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
		
		public function addNumberOfInstancesToLoad(requestType:String, numResults:int):void
		{
			if (!EssentialModelReference.numInstancesToLoad[requestType])
			{
				EssentialModelReference.numInstancesToLoad[requestType] = numResults;
			}
			else
			{
				EssentialModelReference.numInstancesToLoad[requestType] += numResults;
			}
		}
		
		public function objectLoaded(objectsLoaded:Object, requestType:String):void
		{	
			var numResults:int = (objectsLoaded as Array).length;
			addNumberOfInstancesToLoad(requestType, numResults);
			
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
			var className:String = essentialModelController.convertToClassCase(obj.model);
			var klass:Class = getDefinitionByName('models.'+className) as Class;
			
			// This should be improved, first way is better
			
			var instance:Object;
			if (obj.model)
			{			
				for each (instance in essentialModelController[obj.model+'s'])
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
					for each (instance in essentialModelController[obj.model])
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
				var evt:ServerDataEvent;
				if (!staticContentLoaded)
				{
					staticContentLoaded = true;
					evt = new ServerDataEvent(ServerDataEvent.GAME_CONTENT_LOADED, null, null, null, true, true);
					dispatchEvent(evt);
					pendingRequests = 0;
					loadCounter = 0;
				}
				else
				{
					userContentLoaded = true;
					essentialModelController.userContentLoaded = true;				
					evt = new ServerDataEvent(ServerDataEvent.USER_CONTENT_LOADED, null, null, null, true, true);
					dispatchEvent(evt);	
				}
			}
		}
				
		public function loadObject(obj:Object, requestType:String):void
		{
			var toLoad:UnprocessedModel = new UnprocessedModel(requestType, obj, obj.instance[requestType]);
			essentialModelController.loadNewInstance(toLoad);				
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
		
		public function checkForLoadedMovieClips():void
		{
			checkForLoadedDwellings();
			checkForLoadedStructures();
			checkForLoadedLayerables();
			checkForLoadedSongs();
			checkForLoadedUsables();
		}
		
		public function checkIfLoadingAndInstantiationComplete():void
		{
			essentialModelController.checkIfLoadingAndInstantiationComplete();
		}
		
		public function checkForLoadedSongs():void
		{
			if (songController.ownedSongsLoaded != 0)
			{
				songController.fullyLoaded = true;
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.OWNED_SONGS_LOADED);
				evt.user = this.user;
				evt.gdi = this;
				dispatchEvent(evt);
			}
		}
		
		public function checkForLoadedStructures():void
		{
			if (structureController.ownedStructureMovieClipsLoaded == structureController.ownedStructuresLoaded && structureController.ownedStructuresLoaded != 0)
			{
				structureController.fullyLoaded = true;
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.OWNED_STRUCTURES_LOADED);
				evt.user = this.user;
				evt.gdi = this;
				dispatchEvent(evt);
			}	
		}

		public function checkForLoadedUsables():void
		{
			if (usableController.ownedUsableMovieClipsLoaded == usableController.ownedUsablesLoaded && usableController.ownedUsablesLoaded != 0)
			{
				usableController.fullyLoaded = true;
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.OWNED_USABLES_LOADED);
				evt.user = this.user;
				evt.gdi = this;
				dispatchEvent(evt);
			}	
		}
		
		public function checkForLoadedLayerables():void
		{
			if (layerableController.ownedLayerableReferencesUpdated == EssentialModelReference.numInstancesToLoad["owned_layerable"] && EssentialModelReference.numInstancesToLoad["layerable"] == layerableController.layerableMovieClipsLoaded)
			{
				layerableController.fullyLoaded = true;
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.OWNED_LAYERABLES_LOADED);
				evt.user = this.user;
				evt.gdi = this;
				dispatchEvent(evt);
			}			
		}	
		
		public function checkForLoadedDwellings():void
		{
			if (dwellingController.ownedDwellingMovieClipsLoaded == dwellingController.ownedDwellingsLoaded && dwellingController.ownedDwellingsLoaded != 0)
			{
				dwellingController.fullyLoaded = true;
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.OWNED_DWELLINGS_LOADED);
				evt.user = this.user;
				evt.gdi = this;
				dispatchEvent(evt);
			}
		}

	}
}