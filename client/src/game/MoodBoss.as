package game
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
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
		
		public static const GROUPIE:String = "Groupie";
		public static const BAND_MEMBER:String = "BandMember";
		public static const CONCERT_GOER:String = "Concert Goer";
		
		public static const XP:String = "XP";
		public static const COINS:String = "COINS";
		public static const MUSIC_CREDITS:String = "MUSIC_CREDITS";
		public static const FAN_CREDITS:String = "FAN_CREDITS";
		public static const RANDOM_ITEM:String = "RANDOM_ITEM";
		
		public static const HAMBURGER:String = "Hamburger";
		public static const COFFEE:String = "CoffeeLeftover";
		
		public static const TEXT_BUFFER:int = 5;
		
		public static const MOODS:Object = {
			HUNGRY: {								
				creature_types:[BAND_MEMBER],
				symbol_name: HAMBURGER,
				message: "Wants food",
				music_credits: 1, 	
				fan_credits: 0, 	
				coins: 0, 					
				requires:[],
				min_level: 1,
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2}, {type: MUSIC_CREDITS, total: 2, min_bonus: 1, max_bonus: 4}],
				possible_rewards: []
			},
			THIRSTY: {							
				creature_types:[BAND_MEMBER],
				symbol_name: COFFEE,
				message: "Wants coffee",
				music_credits: 1, 	
				fan_credits: 0,		
				coins: 0,					 
				requires:[],
				min_level: 1,
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2}, {type: MUSIC_CREDITS, total: 2, min_bonus: 1, max_bonus: 4}],
				possible_rewards: []
			},				
			WANTS_HAMBURGER: {				
				creature_types:[GROUPIE, CONCERT_GOER],	
				symbol_name: HAMBURGER,
				message: "Wants burger",
				music_credits: 3,		
				fan_credits: 0,  
				coins: 0,						
				requires:[],
				min_level: 1,
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2}, {type: FAN_CREDITS, total: 1, min_bonus: 1, max_bonus: 4}],
				possible_rewards: []
			},
			WANTS_COFFEE: {
				creature_types:[GROUPIE, CONCERT_GOER],	
				symbol_name: COFFEE,
				message: "Wants coffee",
				music_credits: 2,  
				fan_credits: 0,  
				coins: 0,						
				requires:[],
				min_level: 1,
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2}, {type: FAN_CREDITS, total: 1, min_bonus: 1, max_bonus: 4}],
				possible_rewards: []
			},
			WANTS_PINK_HEADPHONES: {
				creature_types:[GROUPIE, CONCERT_GOER],		
				symbol_name: null,
				message: "Wants headphones",
				music_credits: 5,  
				fan_credits: 0,  
				coins: 0,						
				requires:["Pink Paint", "Headphones"],
				min_level: 3,
				rewards: [{type: XP, total: 3, min_bonus: 1, max_bonus: 4}, {type: FAN_CREDITS, total: 3, min_bonus: 1, max_bonus: 3}, {type: COINS, total: 6, min_bonus: 1, max_bonus: 4}],
				possible_rewards: [{type: RANDOM_ITEM, probability: 0.2}]
			},
			WANTS_RED_HEADPHONES: {
				creature_types:[GROUPIE, CONCERT_GOER],	
				symbol_name: null,
				message: "Wants headphones",
				music_credits: 5,  
				fan_credits: 0,  
				coins: 0, 					
				requires:["Red Paint", "Headphones"],
				min_level: 4, 
				rewards: [{type: XP, total: 3, min_bonus: 1, max_bonus: 4}, {type: FAN_CREDITS, total: 3, min_bonus: 1, max_bonus: 3}, {type: COINS, total: 6, min_bonus: 1, max_bonus: 4}],
				possible_rewards: [{type: RANDOM_ITEM, probability: 0.3}]
			},
			IS_HEARTBROKEN:	{
				creature_types:[BAND_MEMBER],
				symbol_name: null,
				message: "Has broken heart",
				music_credits: 10, 
				fan_credits: 0,  
				coins: 0,						
				requires:["Love Potion"],
				min_level: 10,
				rewards: [{type: XP, total: 10, min_bonus: 4, max_bonus: 8}, {type: MUSIC_CREDITS, total: 4, min_bonus: 2, max_bonus: 6}],
				possible_rewards: [{type: RANDOM_ITEM, probability: 0.5}]
			},
			FEELS_HOT: {
				creature_types:[GROUPIE, CONCERT_GOER],	
				symbol_name: null,
				message: "Feels hot",
				music_credits: 0,  
				fan_credits: 0,  
				coins: 0,      
				requires:["Space Heater"],
				min_level: 3,
				rewards: [{type: XP, total: 2, min_bonus: 1, max_bonus: 3}, {type: FAN_CREDITS, total: 2, min_bonus: 1, max_bonus: 1}], 
				possible_rewards: []
			},
			FEELS_COLD:	{
				creature_types:[GROUPIE, CONCERT_GOER],		
				symbol_name: HAMBURGER,
				message: "Feels cold",
				music_credits: 0,  
				fan_credits: 0,  
				coins: 0,      
				requires:["Cooling Fan"],
				min_level: 3,
				rewards: [{type: XP, total: 2, min_bonus: 1, max_bonus: 3}, {type: FAN_CREDITS, total: 2, min_bonus: 1, max_bonus: 1}], 
				possible_rewards: []
			},
			WANTS_AUTOGRAPH: {
				creature_types:[GROUPIE, CONCERT_GOER],	
				symbol_name: HAMBURGER,
				message: "Wants autograph",
				music_credits: 3,  
				fan_credits: 0,  
				coins: 0,      
				requires:[],
				min_level: 1,
				rewards: [{type: XP, total: 3, min_bonus: 1, max_bonus: 3}, {type: FAN_CREDITS, total: 2, min_bonus: 1, max_bonus: 5}], 
				possible_rewards: []				
			},
			IS_SLEEPY: {
				creature_types:[BAND_MEMBER],
				symbol_name: COFFEE,
				message: "Feels sleepy",
				music_credits: 0,  
				fan_credits: 2,  
				coins: 0,      
				requires:["Pillow"],
				min_level: 4,
				rewards: [{type: XP, total: 1, min_bonus: 1, max_bonus: 2}, {type: MUSIC_CREDITS, total: 2, min_bonus: 1, max_bonus: 1}], 
				possible_rewards: []				
			}
		}
		
		public function MoodBoss(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function assignMoodByString(moodName:String):Object
		{
			return MoodBoss.MOODS[moodName];
		}
		
		public static function assignMoodByCreatureType(creatureType:String, userLevel:int):Object
		{
			var potentialMoods:ArrayCollection = new ArrayCollection();
			for each (var mood:Object in MoodBoss.MOODS)
			{
				if (mood.min_level < (userLevel + 1))
				{
					for each (var ct:String in mood.creature_types)
					{
						if (ct == creatureType)
						{
							potentialMoods.addItem(mood);
							break;
						}
					}
				}
			}
			var rand:Number = Math.floor(Math.random() * potentialMoods.length);
			return potentialMoods[rand];
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
				coinsText.text = "Need: " + mood.coins.toString();
				WorldBitmapInterface.setStylesForNurtureText(coinsText);
				fanText.y += coinsText.textHeight + TEXT_BUFFER;
				musicText.y += coinsText.textHeight + TEXT_BUFFER;
				uic.addChild(coinsText);
			}
			if (mood.fan_credits > 0)
			{
				fanText.text = "Need: " + mood.fan_credits.toString();
				WorldBitmapInterface.setStylesForNurtureText(fanText);
				musicText.y += fanText.textHeight + TEXT_BUFFER;
				uic.addChild(fanText);
			}
			if (mood.music_credits > 0)
			{
				musicText.text = "Need: " + mood.music_credits.toString();
				WorldBitmapInterface.setStylesForNurtureText(musicText);
				uic.addChild(musicText);
			}
			return uic;
		}
	}
}