package controllers
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	
	import helpers.UnprocessedModel;
	
	import models.Creature;
	import models.EssentialModelReference;
	import models.Layerable;
	import models.OwnedStructure;
	import models.OwnedThinger;
	import models.Store;
	import models.StoreOwnedThinger;
	import models.Structure;
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.events.DynamicEvent;
	
	import server.ServerController;
	import server.ServerDataEvent;

	public class EssentialModelManager extends Manager
	{	
		public var instancesToLoad:ArrayCollection;
		public var instancesLoaded:ArrayCollection;		
		
		public var totalRequests:int = 0;
		public var instancesFullyLoaded:int = 0;
		public var applicationDomain:ApplicationDomain;
		public var essentialModelReference:EssentialModelReference;
		[Bindable] public var layerables:ArrayCollection;
		[Bindable] public var owned_layerables:ArrayCollection;
		[Bindable] public var creatures:ArrayCollection;
		[Bindable] public var thingers:ArrayCollection;
		[Bindable] public var owned_thingers:ArrayCollection;
		[Bindable] public var users:ArrayCollection;
		[Bindable] public var stores:ArrayCollection;
		[Bindable] public var store_owned_thingers:ArrayCollection;
		[Bindable] public var structures:ArrayCollection;
		[Bindable] public var owned_structures:ArrayCollection;
		
		public var layerable:Layerable;
		public var creature:Creature;
		public var owned_thinger:OwnedThinger;
		public var user:User;
		public var store:Store;
		public var store_owned_thinger:StoreOwnedThinger;
		public var structure:Structure;
		public var owned_structure:OwnedStructure;
		
		public var baseUrl:String = ServerController.BASE_URL;		
		
		public function EssentialModelManager(target:IEventDispatcher=null)
		{
			super(this, target);
			initializeArrays();
		}	
		
		public function initializeArrays():void
		{
			instancesToLoad = new ArrayCollection();
			instancesLoaded = new ArrayCollection();			
			layerables = new ArrayCollection();
			owned_layerables = new ArrayCollection();
			creatures = new ArrayCollection();	
			thingers = new ArrayCollection();	
			structures = new ArrayCollection();
			owned_structures = new ArrayCollection();
			owned_thingers = new ArrayCollection();
			stores = new ArrayCollection();
			store_owned_thingers = new ArrayCollection();	
			users = new ArrayCollection();
			essentialModelReference = new EssentialModelReference();
		}
		
		public function loadNewInstance(toLoad:UnprocessedModel):void
		{
			instancesToLoad.addItem(toLoad);
			
			var i:int = 0;
			var relationshipName:String;
			
			for each (relationshipName in toLoad.relationshipData.belongs_to)
			{
				var belongsToId:int = toLoad.relationshipData.belongs_to_id[i];
				doesObjectBelongTo(toLoad, belongsToId, relationshipName);
				i++;
			}
			for each (relationshipName in toLoad.relationshipData.has_many)
			{
				doesObjectHaveMany(toLoad, relationshipName);
			}
			if (toLoad.instance == null)
			{
				instantiateAndUpdate(toLoad);			
			}
		}
		
		public function checkIfAllLoadingComplete():void
		{
			var evt:DynamicEvent = new DynamicEvent('instanceLoaded', true, true);
			dispatchEvent(evt);
		}
		
		public function doesObjectBelongTo(toLoad:UnprocessedModel, belongsToId:int, belongsToName:String):void
		{
			for each (var um:UnprocessedModel in essentialModelReference.allInstancesLoaded)
			{
				if (um.model == belongsToName && um.instance.id == belongsToId)
				{
					instantiateAndUpdate(toLoad);
					updateBelongsTo(um, toLoad);
					break;
				}
			}			
		}
		
		public function doesObjectHaveMany(toLoad:UnprocessedModel, hasManyName:String):void
		{
			for each (var um:UnprocessedModel in instancesToLoad)
			{			
				for each (var belongsTo:String in um.relationshipData.belongs_to)
				{
					if (belongsTo == hasManyName && um.relationshipData.belongs_to_id == toLoad.instanceData.id)	
					{
						if (um.instance == null)
						{
							instantiateWithHasMany(um, toLoad);							
						}
	//					Do this later
	//					updateHasMany(obj, toLoad, instance);
					}				
				}
			}				
		}
		
		public function instantiateAndUpdate(um:UnprocessedModel):void
		{
			if (um.instance == null)
			{
				instantiateAndAdd(um);
				removeFromToLoad(um);			
			}
		}
		
		public function updateBelongsTo(belongsTo:UnprocessedModel, isChild:UnprocessedModel):void
		{
			addThisToParent(belongsTo, isChild);
			updateChildWithBelongsTo(belongsTo, isChild);			
		}
		
		public function instantiateWithHasMany(belongsTo:UnprocessedModel, isChild:UnprocessedModel):void
		{
			instantiateAndAdd(belongsTo);
			instantiateAndAdd(isChild);
			removeFromToLoad(belongsTo);	
			removeFromToLoad(isChild);	
		}	
		
		public function updateHasMany(belongsTo:UnprocessedModel, isChild:UnprocessedModel):void
		{
			addThisToParent(belongsTo, isChild);
			updateChildWithBelongsTo(belongsTo, isChild);			
		}	
		
		private function onModelLoaded(model:String):void
		{
			var sde:ServerDataEvent = new ServerDataEvent(ServerDataEvent.MODEL_COLLECTION_LOADED, model, null, null, true, true);
			dispatchEvent(sde);
		}
		
		public function updateChildWithBelongsTo(belongsTo:UnprocessedModel, isChild:UnprocessedModel):void
		{
			isChild.instance[belongsTo.model+'_id'] = belongsTo.instance.id;
			
			if (isChild.instance.hasOwnProperty(belongsTo.model))
			{
				assignParentInstanceToChild(belongsTo, isChild);
				
				if (belongsTo.instance.hasOwnProperty('mc'))
				{
					assignParentMovieClipToChild(belongsTo, isChild);
				}
				else
				{
//					throw new Error("Fix me!");
//					why is this here??
//					classesToLoad.addItem(isChild.instance[belongsTo.model]);					
				}
			}
		}
		
		public function assignParentInstanceToChild(belongsTo:UnprocessedModel, isChild:UnprocessedModel):void
		{
			var className:String = convertToClassCase(belongsTo.model);			
			var newClass:Class = getDefinitionByName('models.'+className) as Class;				
			isChild.instance[belongsTo.model] = new newClass(belongsTo.instance);
			
			var evt:EssentialEvent = new EssentialEvent(EssentialEvent.PARENT_ASSIGNED, isChild.instance, isChild.model, true, true);
			isChild.instance.dispatchEvent(evt);			
			
			// Add our copy to list of class copies
			var classCopiesArray:Array = [belongsTo.instance, isChild.instance[belongsTo.model]];
			essentialModelReference.classCopies.push(classCopiesArray);
//			isChild.instance[belongsTo.model] = belongsTo.instance;			
		}		
		
		public function assignParentMovieClipToChild(belongsTo:UnprocessedModel, isChild:UnprocessedModel):void
		{
			var swfIsLoaded:Boolean = false;
			for each (var obj:Object in essentialModelReference.loadedSwfs)
			{
				if (baseUrl+belongsTo.instance['swf_url'] == obj.url)
				{
					swfIsLoaded = true;
					var appDomain:ApplicationDomain = obj.applicationDomain;
				}
			}
			if (swfIsLoaded)
			{
				var className:String = belongsTo.instance.symbol_name;
				var newClass:Class = appDomain.getDefinition(className) as Class;	
//				var newClass:Class = EssentialModelReference.getClassCopy(className);			
				isChild.instance[belongsTo.model].setMovieClipFromClass(newClass);			
			}
			else if (belongsTo.instance['swf_url'])
			{
//				throw new Error("Fix me!");
//				what the hell am I supposed to have here?				
				essentialModelReference.classesToLoad.addItem(belongsTo.instance);
			}
		}
		
		public function addThisToParent(belongsTo:UnprocessedModel, isChild:UnprocessedModel):void
		{
			if (isChild.model+'s' in belongsTo.instance)
			{
				(belongsTo.instance[isChild.model+'s'] as ArrayCollection).addItem(isChild.instance); 			
			}
		}
		
		public function removeFromToLoad(toLoad:Object):void
		{
			var index:int = instancesToLoad.getItemIndex(toLoad);
			instancesToLoad.removeItemAt(index);
			checkIfAllLoadingComplete();
		}
		
		public function createNewClassInstance(um:UnprocessedModel):void
		{
			var className:String = convertToClassCase(um.model);			
			var newClass:Class = getDefinitionByName('models.'+className) as Class;
			um.instance = new newClass(um.instanceData);	
			essentialModelReference.loadedModels[className] = {klass: newClass, applicationDomain: null};					
		}
		
		public function instantiateAndAdd(um:UnprocessedModel):void
		{
			createNewClassInstance(um);
			
			if (um.instance.hasOwnProperty('swf_url'))
			{
				instantiateAndAddSwf(um);
			}
			else
			{
				var evt:EssentialEvent = new EssentialEvent(EssentialEvent.INSTANCE_LOADED, um.instance, um.model, true, true);
				dispatchEvent(evt);
			}
			
			instancesLoaded.addItem(um);
			essentialModelReference.allInstancesLoaded.addItem(um);
							
			(this[um.model+'s'] as ArrayCollection).addItem(um.instance); 
		}	
		
		public function convertToClassCase(str:String):String
		{
			var arr:Array = str.split('_');
			var result:String = new String();
			for (var i:int = 0; i < arr.length; i++)
			{
				var c:String = (arr[i] as String).charAt(0).toUpperCase();
				var rest:String = (arr[i] as String).substr(1);
				result += c;
				result += rest; 
			}
			return result;
		}
		
		public function instantiateAndAddSwf(um:UnprocessedModel):void
		{
			var isLoaded:Boolean = checkForLoadedSwf(um.instanceData, um.instance);
			essentialModelReference.classesToLoad.addItem(um.instance);
			if (!um.instanceData['symbol_name'] && !um.instanceData['swf_url'])
			{
				// Do nothing?
			}
			else if (!um.instanceData['swf_url'])
			{
				throw new Error("Why are you creating a movie clip without a swf url?");
			}			
		}		
		
		public function checkForLoadedSwf(params:Object, parentInstance:Object):Boolean
		{		
			for each (var obj:Object in essentialModelReference.swfsToLoad)
			{
				if (obj['swf_url'] == params['swf_url'])
				{
					return true;
				}
			}
			loadSwf(params['swf_url']);
			essentialModelReference.swfsToLoad.addItem(params);
			return false;				
		}		
		
		public function loadSwf(swfUrl:String):void
		{		
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onClassesLoaded);
			var request:URLRequest = new URLRequest(baseUrl+swfUrl);
			loader.load(request);	
		}
		
		private function onClassesLoaded(evt:Event):void
		{
			applicationDomain = evt.currentTarget.applicationDomain as ApplicationDomain;
			essentialModelReference.loadedSwfs.addItem({applicationDomain: applicationDomain, url: evt.currentTarget.url});
			loadAssociatedClasses(evt.currentTarget.url, evt.currentTarget.loader, applicationDomain);		
		}
		
		public function loadAssociatedClasses(swfUrl:String, classLoader:Loader, appDomain:ApplicationDomain):void
		{
			for each (var obj:Object in essentialModelReference.classesToLoad)
			{
				if (baseUrl+obj['swf_url'] == swfUrl)
				{
					loadClassInstance(obj, appDomain);											
				}
			}
		}
		
		public function loadClassInstance(obj:Object, appDomain:ApplicationDomain):void
		{
			var className:String = obj['symbol_name'];
			var loadedClass:Class = appDomain.getDefinition(className) as Class;
			essentialModelReference.loadedClasses.addItem(loadedClass);
			essentialModelReference.loadedModels[className] = {klass: loadedClass, applicationDomain: appDomain};			
			obj.setMovieClipFromClass(loadedClass);
			
			updateMovieClipForAnyClassCopies(obj, loadedClass);
			
			var evt:EssentialEvent = new EssentialEvent(EssentialEvent.INSTANCE_LOADED, obj, null, true, true);
			dispatchEvent(evt);					
		}		
		
		private function updateMovieClipForAnyClassCopies(obj:Object, loadedClass:Class):void
		{
			for each (var classCopiesArray:Array in essentialModelReference.classCopies)
			{
				for each (var classCopy:Object in classCopiesArray)
				{
					if (classCopy == obj)
					{
						updateMovieClipForAllCopies(classCopiesArray, loadedClass);
					}
				}
			}			
		}
		
		private function updateMovieClipForAllCopies(classCopiesArray:Array, loadedClass:Class):void
		{
			for each (var classCopy:Object in classCopiesArray)
			{
				classCopy.setMovieClipFromClass(loadedClass);
			}
		}
	}
}