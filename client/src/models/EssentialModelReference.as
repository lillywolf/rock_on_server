package models
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	public class EssentialModelReference
	{
		public var loadedModels:Dictionary;
		public var classCopies:Array;
		
		public var swfsToLoad:ArrayCollection;
		public var loadedSwfs:ArrayCollection;
		public var classesToLoad:ArrayCollection;
		public var loadedClasses:ArrayCollection;
		public var allInstancesLoaded:ArrayCollection;
				
		public function EssentialModelReference()
		{
			loadedModels = new Dictionary();
			classCopies = new Array();
			initializeArrays();
			Application.application.loadedModels = loadedModels;
		}
		
		public function initializeArrays():void
		{
			swfsToLoad = new ArrayCollection();
			loadedSwfs = new ArrayCollection();
			classesToLoad = new ArrayCollection();
			loadedClasses = new ArrayCollection();
			allInstancesLoaded = new ArrayCollection();			
		}
		
		public static function getClassCopy(className:String):Class
		{
			var klass:Class = Application.application.loadedModels[className].klass;
			return klass;
		}

	}
}