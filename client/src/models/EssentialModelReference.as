package models
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
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
			if (!Application.application.loadedModels)
			{
				loadedModels = new Dictionary();			
				Application.application.loadedModels = loadedModels;
			}
			classCopies = new Array();
			initializeArrays();
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
		
		public static function getMovieClipCopy(mc:MovieClip):MovieClip
		{
			var className:String = flash.utils.getQualifiedClassName(mc);
			var klass:Class = EssentialModelReference.getClassCopy(className);
			var newMc:MovieClip = new klass() as MovieClip;
			return newMc;
		}

	}
}