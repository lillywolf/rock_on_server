package models
{
	import flash.display.MovieClip;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import spark.components.Application;
	
	public class EssentialModelReference
	{
		public static var loadedModels:Array = new Array();
		public var classCopies:Array;
		
		public var swfsToLoad:ArrayCollection;
		public var loadedSwfs:ArrayCollection;
		public var classesToLoad:ArrayCollection;
		public var loadedClasses:ArrayCollection;
		public var allInstancesLoaded:ArrayCollection;
		
		public static var creatureNames:Array = 
			["Julie", "Ed", "Harrison", "Sarah", "Brad", "Latoya", "Eunice", "Aidan", "Rachel", "Maria", "Candace", "Victoria", "Roopa",
			"Jaya", "Evan", "Will", "Alice", "Erin", "Tasha", "Ana", "Miguel", "Mike", "Aspeth", "Oprah", "Chris", "Liberace"
			];
				
		public function EssentialModelReference()
		{
//			if (!FlexGlobals.topLevelApplication.loadedModels)
//			{
//				loadedModels = new Array();		
//				FlexGlobals.topLevelApplication.loadedModels = loadedModels;
//			}
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
		
		public static function updateLoadedModels(className:String, klass:Class, appDomain:ApplicationDomain):void
		{
			loadedModels[className] = {klass: klass, applicationDomain: appDomain};
		}
		
		public static function returnLoadedModel(className:String):Class
		{
			return loadedModels[className].klass;
		}
		
		public static function getClassCopy(className:String):Class
		{
			if (!loadedModels[className])
			{
				throw new Error("no models");
			}
			var klass:Class = loadedModels[className].klass;
			return klass;
		}
		
		public static function getMovieClipCopyFunction():Function
		{
			return getMovieClipCopy;
		}
		
		public static function getMovieClipCopy(mc:MovieClip):MovieClip
		{
			var className:String = flash.utils.getQualifiedClassName(mc);
			if (className == "PeachBody")
			{
				return new PeachBody() as MovieClip;
			}
			if (className == "NavyEyes")
			{
				return new NavyEyes() as MovieClip;
			}
			if (className == "AndrogynousHairFront")
			{
				return new AndrogynousHairFront() as MovieClip;
			}
			if (className == "ElectricGuitarBasic")
			{
				return new ElectricGuitarBasic() as MovieClip;
			}
			if (className == "Shoes4")
			{
				return new Shoes4() as MovieClip;
			}
			if (className == "TealSlippers")
			{
				return new TealSlippers() as MovieClip;
			}
			if (className == "PinkSlippers")
			{
				return new PinkSlippers() as MovieClip;
			}
			if (className == "YellowSlippers")
			{
				return new YellowSlippers() as MovieClip;
			}
			if (className == "YellowSkirt")
			{
				return new YellowSkirt() as MovieClip;
			}
			if (className == "BrownSkirt")
			{
				return new BrownSkirt() as MovieClip;
			}
			if (className == "PurpleSkirt")
			{
				return new PurpleSkirt() as MovieClip;
			}
			if (className == "OrangeShirt")
			{
				return new OrangeShirt() as MovieClip;
			}
			if (className == "PinkShirt")
			{
				return new PinkShirt() as MovieClip;
			}
			if (className == "TealShirt")
			{
				return new TealShirt() as MovieClip;
			}
			if (className == "Shirt3")
			{
				return new Shirt3() as MovieClip;
			}
			if (className == "Shirt4")
			{
				return new Shirt4() as MovieClip;
			}
			if (className == "Shirt5")
			{
				return new Shirt5() as MovieClip;
			}
			if (className == "Hair1Black")
			{
				return new Hair1Black() as MovieClip;
			}
			if (className == "Hair1Lime")
			{
				return new Hair1Lime() as MovieClip;
			}
			if (className == "Hair1Pink")
			{
				return new Hair1Pink() as MovieClip;
			}
			if (className == "Hair1PurpleBlk")
			{
				return new Hair1PurpleBlk() as MovieClip;
			}
			if (className == "Hair1RedBld")
			{
				return new Hair1RedBld() as MovieClip;
			}
			if (className == "Hair2Blue")
			{
				return new Hair2Blue() as MovieClip;
			}
			if (className == "Hair2Brown")
			{
				return new Hair2Brown() as MovieClip;
			}
			if (className == "Hair2Purple")
			{
				return new Hair2Purple() as MovieClip;
			}
			if (className == "Hair2Rainbow")
			{
				return new Hair2Rainbow() as MovieClip;
			}
			if (className == "Hair2Red")
			{
				return new Hair2Red() as MovieClip;
			}
			if (className == "Pants3")
			{
				return new Pants3() as MovieClip;
			}
			if (className == "Pants4")
			{
				return new Pants4() as MovieClip;
			}
			if (className == "Pants5")
			{
				return new Pants5() as MovieClip;
			}
			var klass:Class = EssentialModelReference.getClassCopy(className);	
			var newMc:MovieClip = new klass() as MovieClip;
			return newMc;
		}
		
	}
}