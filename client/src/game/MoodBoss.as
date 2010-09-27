package game
{
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import models.EssentialModelReference;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	import rock_on.CustomerPerson;
	
	import views.WorldBitmapInterface;
	
	public class MoodBoss extends EventDispatcher
	{
		public static const HUNGRY:String = "HUNGRY";
		public static const THIRSTY:String = "THIRSTY";
		public static const WANTS_HAMBURGER:String = "WANTS_HAMBURGER";
		public static const WANTS_COFFEE:String = "WANTS_COFFEE";
		public static const WANTS_PINK_HEADPHONES:String  = "WANTS_PINK_HEADPHONES";
		public static const WANTS_RED_HEADPHONES:String  = "WANTS_RED_HEADPHONES";
		public static const WANTS_BLUE_HEADPHONES:String  = "WANTS_BLUE_HEADPHONES";
		public static const WANTS_GREEN_HEADPHONES:String  = "WANTS_GREEN_HEADPHONES";
		public static const WANTS_WHITE_HEADPHONES:String  = "WANTS_WHITE_HEADPHONES";
		public static const WANTS_CANDY:String = "WANTS_CANDY";
		public static const IS_HEARTBROKEN:String = "IS_HEARTBROKEN";
		public static const WANTS_TSHIRT:String = "WANTS_TSHIRT";
		public static const IS_BORED:String = "IS_BORED";
		public static const FEELS_LAZY:String = "FEELS_LAZY";
		public static const IS_SLEEPY:String = "IS_SLEEPY";
		public static const WANTS_POSTER:String = "WANTS_POSTER";
		public static const WANTS_STICKER:String = "WANTS_STICKER";
		public static const WANTS_AUTOGRAPH:String = "WANTS_AUTOGRAPH";
		public static const WANTS_BACKSTAGE_PASS:String = "WANTS_BACKSTAGE_PASS";
		public static const FEELS_HOT:String = "FEELS_HOT";
		public static const FEELS_COLD:String = "FEELS_COLD";
		public static const WANTS_HIPHOP_MUSIC:String = "WANTS_HIPHOP_MUSIC";
		public static const WANTS_ROCK_MUSIC:String = "WANTS_ROCK_MUSIC";
		public static const WANTS_POP_MUSIC:String = "WANTS_POP_MUSIC";
		public static const WANTS_MUSIC_VIDEO:String = "WANTS_MUSIC_VIDEO";
		public static const WANTS_INTERVIEW:String = "WANTS_INTERVIEW";
		public static const WANTS_PET_CAT:String = "WANTS_PET_CAT";
		public static const WANTS_PET_TIGER:String = "WANTS_PET_TIGER";
		public static const WANTS_MP3_PLAYER:String = "WANTS_MP3_PLAYER";
		public static const WANTS_MUSIC_BOOK:String = "WANTS_MUSIC_BOOK";
		public static const NEEDS_THERAPY:String = "NEEDS_THERAPY";
		public static const WANTS_RED_SUNGLASSES:String = "WANTS_RED_SUNGLASSES";
		public static const WANTS_BLACK_SUNGLASSES:String = "WANTS_BLACK_SUNGLASSES";
		public static const WANTS_MAGAZINE:String = "WANTS_MAGAZINE";
		public static const WANTS_DANCE_LESSON:String = "WANTS_DANCE_LESSON";
		
		public static const BASIC:String = "BASIC";
		
		public static const GROUPIE:String = "Groupie";
		public static const BAND_MEMBER:String = "BandMember";
		public static const CONCERT_GOER:String = "Concert Goer";
		public static const FAN:String = "Fan";
		public static const NEW_FAN:String = "New Fan";
		public static const RIVAL:String = "Rival";
		public static const FRIEND:String = "Friend";
		
		public static const STATIC:int = 0;
		public static const SUPER:int = 1;
		public static const MOVING:int = 2;
		
		public static const XP:String = "xp";
		public static const COINS:String = "credits";
		public static const MUSIC_CREDITS:String = "music_credits";
		public static const FAN_CREDITS:String = "fan_hearts";
		public static const RANDOM_ITEM:String = "RANDOM_ITEM";
		
		public static const HAMBURGER:String = "Hamburger";
		public static const COFFEE:String = "CollectibleCoffee";
		public static const HEART:String = "Heart";
		public static const RED_HEADPHONES:String = "RoseLeftover";
		public static const PINK_HEADPHONES:String = "CandyLeftover";
		public static const CANDY:String = "CandyLeftover";
		public static const EGG:String = "EggLeftover";
		public static const MUSIC_CREDITS_ICON:String = "MusicCredits";
		public static const FAN_CREDITS_ICON:String = "Heart";	
		public static const CREDITS_ICON:String = "CoinsLeftover";
		public static const PIZZA:String = "CollectiblePizza";
		public static const GUITAR:String = "CollectibleGuitarOrange";
		public static const MICROPHONE:String = "CollectibleMicrophone";
		public static const PIANO:String = "CollectiblePiano";
		
		public static const TEXT_BUFFER:int = 5;
		
		public static const RANDOM_ITEMS:Object = {
			BASIC: [MICROPHONE, PIZZA, GUITAR, EGG, CANDY, COFFEE, HAMBURGER, PIANO]
		}
		
		public static const MOODS:Object = {
			HUNGRY: {								
				creature_types:[BAND_MEMBER],
				person_types:[MOVING],
				symbol_name: HAMBURGER,
				message: "Feed me!",
				music_credits: 1, 	
				fan_credits: 0, 	
				coins: 0, 					
				requires:[],
				min_level: 1,
				move_to: true,
				animation: null,	
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2, mc: GUITAR}, {type: MUSIC_CREDITS, total: 2, min_bonus: 1, max_bonus: 4, mc: MUSIC_CREDITS_ICON}],
				possible_rewards: []
			},
			THIRSTY: {							
				creature_types:[BAND_MEMBER],
				person_types:[MOVING],
				symbol_name: COFFEE,
				message: "I'm thirsty",
				music_credits: 1, 	
				fan_credits: 0,		
				coins: 0,					 
				requires:[],
				min_level: 1,
				move_to: true,
				animation: null,	
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2, mc: GUITAR}, {type: MUSIC_CREDITS, total: 2, min_bonus: 1, max_bonus: 4, mc: MUSIC_CREDITS_ICON}],
				possible_rewards: []
			},				
			WANTS_HAMBURGER: {				
				creature_types:[GROUPIE, CONCERT_GOER, FAN],	
				person_types:[MOVING],
				symbol_name: HAMBURGER,
				message: "Can I get a burger?",
				music_credits: 3,		
				fan_credits: 0,  
				coins: 0,						
				requires:[],
				min_level: 1,
				move_to: true,
				animation: null,	
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2, mc: GUITAR}, {type: FAN_CREDITS, total: 1, min_bonus: 1, max_bonus: 4, mc: FAN_CREDITS_ICON}],
				possible_rewards: []
			},
			WANTS_COFFEE: {
				creature_types:[GROUPIE, CONCERT_GOER, FAN],	
				person_types:[MOVING],
				symbol_name: COFFEE,
				message: "I need caffeine",
				music_credits: 2,  
				fan_credits: 0,  
				coins: 0,						
				requires:[],
				min_level: 1,
				move_to: true,
				animation: null,	
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2, mc: GUITAR}, {type: FAN_CREDITS, total: 1, min_bonus: 1, max_bonus: 4, mc: FAN_CREDITS_ICON}],
				possible_rewards: []
			},
			WANTS_CANDY: {
				creature_types:[GROUPIE, CONCERT_GOER, NEW_FAN, FAN],	
				person_types:[MOVING, SUPER, STATIC],
				symbol_name: CANDY,
				message: "I want candy!",
				music_credits: 5,  
				fan_credits: 0,  
				coins: 0,						
				requires:[],
				min_level: 1,
				move_to: true,
				animation: null,
				rewards: [{type: XP, total: 3, min_bonus: 1, max_bonus: 4, mc: HAMBURGER}, {type: FAN_CREDITS, total: 3, min_bonus: 1, max_bonus: 3, mc: FAN_CREDITS_ICON}, {type: COINS, total: 6, min_bonus: 1, max_bonus: 4, mc: CREDITS_ICON}],
				possible_rewards: [{type: RANDOM_ITEM, probability: 0.2, group: BASIC}]
			},
			WANTS_PINK_HEADPHONES: {
				creature_types:[GROUPIE, CONCERT_GOER, NEW_FAN, FAN],	
				person_types:[MOVING, SUPER, STATIC],
				symbol_name: HAMBURGER,
				message: "Looking for the pink headphones",
				music_credits: 5,  
				fan_credits: 0,  
				coins: 0,						
				requires:["Pink Paint", "Headphones"],
				min_level: 1,
				move_to: true,
				animation: null,
				rewards: [{type: XP, total: 3, min_bonus: 1, max_bonus: 4, mc: HAMBURGER}, {type: FAN_CREDITS, total: 3, min_bonus: 1, max_bonus: 3, mc: FAN_CREDITS_ICON}, {type: COINS, total: 6, min_bonus: 1, max_bonus: 4, mc: CREDITS_ICON}],
				possible_rewards: [{type: RANDOM_ITEM, probability: 0.2, group: BASIC}]
			},
			WANTS_RED_HEADPHONES: {
				creature_types:[GROUPIE, CONCERT_GOER, NEW_FAN, FAN],
				person_types:[MOVING, SUPER, STATIC],
				symbol_name: RED_HEADPHONES,
				message: "I want red heaphones",
				music_credits: 5,  
				fan_credits: 0,  
				coins: 0, 					
				requires:["Red Paint", "Headphones"],
				min_level: 1, 
				move_to: true,
				animation: null,
				rewards: [{type: XP, total: 3, min_bonus: 1, max_bonus: 4, mc: HAMBURGER}, {type: FAN_CREDITS, total: 3, min_bonus: 1, max_bonus: 3, mc: FAN_CREDITS_ICON}, {type: COINS, total: 6, min_bonus: 1, max_bonus: 4, mc: CREDITS_ICON}],
				possible_rewards: [{type: RANDOM_ITEM, probability: 0.3, group: BASIC}]
			},
			IS_HEARTBROKEN:	{
				creature_types:[BAND_MEMBER],
				person_types:[MOVING],
				symbol_name: HEART,
				message: "My heart's broken",
				music_credits: 10, 
				fan_credits: 0,  
				coins: 0,						
				requires:["Love Potion"],
				min_level: 10,
				move_to: false,
				animation: null,
				rewards: [{type: XP, total: 10, min_bonus: 4, max_bonus: 8, mc: HAMBURGER}, {type: MUSIC_CREDITS, total: 4, min_bonus: 2, max_bonus: 6, mc: MUSIC_CREDITS_ICON}],
				possible_rewards: [{type: RANDOM_ITEM, probability: 0.5, group: BASIC}]
			},
			FEELS_HOT: {
				creature_types:[GROUPIE, CONCERT_GOER, FAN],
				person_types:[MOVING],
				symbol_name: HAMBURGER,
				message: "It's too warm in here",
				music_credits: 0,  
				fan_credits: 0,  
				coins: 0,      
				requires:["Cooling Fan"],
				min_level: 3,
				move_to: true,
				animation: null,
				rewards: [{type: XP, total: 2, min_bonus: 1, max_bonus: 3, mc: HAMBURGER}, {type: FAN_CREDITS, total: 2, min_bonus: 1, max_bonus: 1}], 
				possible_rewards: []
			},
			FEELS_COLD:	{
				creature_types:[GROUPIE, CONCERT_GOER, FAN],
				person_types:[MOVING],
				symbol_name: HAMBURGER,
				message: "It's cold in here",
				music_credits: 0,  
				fan_credits: 0,  
				coins: 0,      
				requires:["Space Heater"],
				min_level: 3,
				move_to: true,
				animation: null,
				rewards: [{type: XP, total: 2, min_bonus: 1, max_bonus: 3, mc: HAMBURGER}, {type: FAN_CREDITS, total: 2, min_bonus: 1, max_bonus: 1, mc: FAN_CREDITS_ICON}], 
				possible_rewards: []
			},
			WANTS_AUTOGRAPH: {
				creature_types:[GROUPIE, CONCERT_GOER, NEW_FAN, FAN, FRIEND, RIVAL],
				person_types:[MOVING],
				symbol_name: HAMBURGER,
				message: "Can I get an autograph?",
				music_credits: 3,  
				fan_credits: 0,  
				coins: 0,      
				requires:[],
				min_level: 1,
				move_to: true,
				animation: null,
				rewards: [{type: XP, total: 3, min_bonus: 1, max_bonus: 3, mc: HAMBURGER}, {type: FAN_CREDITS, total: 2, min_bonus: 1, max_bonus: 5, mc: FAN_CREDITS_ICON}], 
				possible_rewards: []				
			},
			IS_SLEEPY: {
				creature_types:[BAND_MEMBER],
				person_types:[MOVING],
				symbol_name: COFFEE,
				message: "I'm sleepy...",
				music_credits: 0,  
				fan_credits: 2,  
				coins: 0,      
				requires:["Pillow"],
				min_level: 4,
				move_to: true,
				animation: null,
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2, mc: HAMBURGER}, {type: MUSIC_CREDITS, total: 2, min_bonus: 1, max_bonus: 1, mc: MUSIC_CREDITS_ICON}], 
				possible_rewards: []				
			}
		}
		
		public function MoodBoss(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function getMovieClipForMood(mood:Object):MovieClip
		{
			var className:String = mood.symbol_name;
			var klass:Class = getDefinitionByName(className) as Class;
			return new klass() as MovieClip;
		}
		
		public static function getRandomItemByMood(mood:Object):MovieClip
		{
			if ((mood.possible_rewards as Array).length > 0)
			{
				var randomGroup:String = mood.possible_rewards[0].group;
				var rand:int = Math.floor(Math.random() * (MoodBoss.RANDOM_ITEMS[randomGroup] as Array).length);
				var className:String = MoodBoss.RANDOM_ITEMS[randomGroup][rand];
				var klass:Class = getDefinitionByName(className) as Class;
				return new klass() as MovieClip;
			}
			return null;
		}
		
		public static function assignMoodByString(moodName:String):Object
		{
			return MoodBoss.MOODS[moodName];
		}
		
		public static function assignMoodByCreatureAndPersonType(creatureType:String, personType:int, userLevel:int):Object
		{
			var potentialMoods:ArrayCollection = new ArrayCollection();
			for each (var mood:Object in MoodBoss.MOODS)
			{
				if (mood.min_level < (userLevel + 1))
				{
					for each (var pt:int in mood.person_types)
					{
						for each (var ct:String in mood.creature_types)
						{
							if (pt == personType && ct == creatureType)
							{
								potentialMoods.addItem(mood);
								break;
							}
						}
					}
				}
			}
			if (potentialMoods.length > 0)
			{
				var rand:Number = Math.floor(Math.random() * potentialMoods.length);
				return potentialMoods[rand];			
			}
			return null;
		}
		
		public static function getUIComponentForMoodCost(mood:Object):UIComponent
		{
			var uic:UIComponent = new UIComponent();
			var coinsText:Text = new Text();
			coinsText.y = 0;
			var fanText:Text = new Text();
			fanText.y = 0;
			var musicText:Text = new Text();
			musicText.y = 0;
			if (mood.coins > 0)
			{
				coinsText.text = mood.coins.toString();
				WorldBitmapInterface.setStylesForNurtureText(coinsText);
				fanText.y += coinsText.textHeight + TEXT_BUFFER;
				musicText.y += coinsText.textHeight + TEXT_BUFFER;
				uic.addChild(coinsText);
			}
			if (mood.fan_credits > 0)
			{
				fanText.text = mood.fan_credits.toString();
				WorldBitmapInterface.setStylesForNurtureText(fanText);
				musicText.y += fanText.textHeight + TEXT_BUFFER;
				uic.addChild(fanText);
			}
			if (mood.music_credits > 0)
			{
				musicText.text = mood.music_credits.toString();
				WorldBitmapInterface.setStylesForNurtureText(musicText);
				uic.addChild(musicText);
			}
			return uic;
		}
	}
}