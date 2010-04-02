package models
{
	import flash.utils.Dictionary;
	
	import mx.core.Application;
	
	public class EssentialModelReference
	{
		public var loadedModels:Dictionary;
		public function EssentialModelReference()
		{
			loadedModels = new Dictionary();
			Application.application.loadedModels = loadedModels;
		}
		
		public static function getClassCopy(className:String):Class
		{
			var klass:Class = Application.application.loadedModels[className].klass;
			return klass;
		}

	}
}