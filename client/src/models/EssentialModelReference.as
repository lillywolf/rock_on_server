package models
{
	import flash.display.MovieClip;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import game.Leftover;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import spark.components.Application;
	
	public class EssentialModelReference
	{
		public static var loadedModels:Dictionary = new Dictionary();
		public static var numInstancesToLoad:Dictionary = new Dictionary();
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
//				loadedModels = new Dictionary();		
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
				trace("no models");
				return null;
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
			var klass:Class = EssentialModelReference.getClassCopy(className);	
			if (klass)
			{
				var newMc:MovieClip = new klass() as MovieClip;
				newMc.cacheAsBitmap = true;
				return newMc;
			}
			else
			{
				return null;
			}
		}
		
		public static function getMovieClipCopyFromSystem(mc:MovieClip):MovieClip
		{
			var className:String = getQualifiedClassName(mc);
			var klass:Class = getDefinitionByName(className) as Class;
			var newMc:MovieClip = new klass() as MovieClip;
			return newMc;
		}		
		
		public static function getClassForMood(type:String):Class
		{
			switch (type)
			{
				case "hungry":
					return getDefinitionByName("Hamburger") as Class;
				case "thirsty":
					return getDefinitionByName("CoffeeLeftover") as Class;
			}
			return null;
		}
		
		public static function getSetLeftovers(type:String):ArrayCollection
		{
			var leftovers:ArrayCollection = new ArrayCollection();
			switch (type)
			{
				case "Listening Station":
					leftovers.addItem(EssentialModelReference.getCoinsLeftover(false));
					break;
				case "Show":
					break;
			}
			return leftovers;			
		}
		
		public static function getRandomLeftovers(type:String):ArrayCollection
		{
			var leftovers:ArrayCollection = new ArrayCollection();
			switch (type)
			{
				case "Listening Station":
					leftovers.addItem(EssentialModelReference.getFoodLeftover(false));
//					leftovers.addItem(EssentialModelReference.getEggLeftover(false));
//					leftovers.addItem(EssentialModelReference.getShoesLeftover(false));
//					leftovers.addItem(EssentialModelReference.getCoffeeLeftover(false));
//					leftovers.addItem(EssentialModelReference.getRoseLeftover(false));
					leftovers.addItem(EssentialModelReference.getCoinsLeftover(false));
//					leftovers.addItem(EssentialModelReference.getShirtLeftover(false));
					break;
				case "Show":
					break;
			}
			return leftovers;
		}
		
		public static function getFoodLeftover(clickable:Boolean):Leftover
		{
			var mc:Hamburger = new Hamburger();
			mc.cacheAsBitmap = true;
			mc.scaleX = 0.8;
			mc.scaleY = 0.8;
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;			
			leftover.type = "food";
			return leftover;
		}
		
		public static function getShirtLeftover(clickable:Boolean):Leftover
		{
			var mc:ShirtOnGround = new ShirtOnGround();
			mc.cacheAsBitmap = true;
			mc.scaleX = 0.7;
			mc.scaleY = 0.7;
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;			
			leftover.type = "cred";
			return leftover;
		}
		
		public static function getRoseLeftover(clickable:Boolean):Leftover
		{
			var mc:RoseLeftover = new RoseLeftover();
			mc.cacheAsBitmap = true;
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;			
			leftover.type = "cred";
			return leftover;
		}
		
		public static function getShoesLeftover(clickable:Boolean):Leftover
		{
			var mc:ShoesOnGround = new ShoesOnGround();
			mc.cacheAsBitmap = true;
			mc.scaleX = 0.8;
			mc.scaleY = 0.8;
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;			
			leftover.type = "cred";
			return leftover;
		}
		
		public static function getCoinsLeftover(clickable:Boolean):Leftover
		{
			var mc:CoinsLeftover = new CoinsLeftover();
			mc.cacheAsBitmap = true;
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;			
			leftover.type = "coins";
			return leftover;
		}
		
		public static function getCoffeeLeftover(clickable:Boolean):Leftover
		{
			var mc:CoffeeLeftover = new CoffeeLeftover();
			mc.cacheAsBitmap = true;
			mc.scaleX = 1.1;
			mc.scaleY = 1.1;
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "food";
			return leftover;
		}
		
		public static function getCandyLeftover(clickable:Boolean):Leftover
		{
			var mc:CandyLeftover = new CandyLeftover();
			mc.cacheAsBitmap = true;
			mc.scaleX = 1.1;
			mc.scaleY = 1.1;
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "food";			
			return leftover;
		}
		
		public static function getEggLeftover(clickable:Boolean):Leftover
		{
			var mc:EggLeftover = new EggLeftover();
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "rare";
			return leftover;
		}				
		
		public static function getCollectibleHamburgerLeftover(clickable:Boolean):Leftover
		{
			var mc:CollectibleHamburger = new CollectibleHamburger();
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "rare";
			return leftover;
		}	
		
		public static function getCollectiblePizzaLeftover(clickable:Boolean):Leftover
		{
			var mc:CollectiblePizza = new CollectiblePizza();
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "rare";
			return leftover;
		}				
		
		public static function getCollectibleGuitarLeftover(clickable:Boolean):Leftover
		{
			var mc:CollectibleGuitarOrange = new CollectibleGuitarOrange();
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "rare";
			return leftover;
		}		
		
		public static function getCollectiblePianoLeftover(clickable:Boolean):Leftover
		{
			var mc:CollectiblePiano = new CollectiblePiano();
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "rare";
			return leftover;
		}				
		
		public static function getCollectibleCoffeeLeftover(clickable:Boolean):Leftover
		{
			var mc:CollectibleCoffee = new CollectibleCoffee();
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "rare";
			return leftover;
		}				
		
		public static function getCollectibleMicrophoneLeftover(clickable:Boolean):Leftover
		{
			var mc:Heart = new Heart();
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "rare";
			return leftover;
		}				

		public static function getFanCreditsIcon(clickable:Boolean):Leftover
		{
			var mc:CollectibleMicrophone = new CollectibleMicrophone();
			var leftover:Leftover = new Leftover(mc);
			leftover.clickable = clickable;
			leftover.type = "rare";
			return leftover;
		}				
		
	}
}