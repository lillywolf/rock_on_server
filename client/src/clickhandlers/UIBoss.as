package clickhandlers
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import game.MoodBoss;
	
	import helpers.CollectibleDrop;
	
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import org.osmf.events.TimeEvent;
	
	import rock_on.Person;
	import rock_on.Venue;
	import rock_on.VenueEvent;
	
	import views.AssetBitmapData;
	import views.BottomBar;
	import views.CustomizableProgressBar;
	import views.StageView;
	import views.TopBar;
	import views.WorldView;
	
	import world.ActiveAsset;
	import world.MoodEvent;
	import world.World;
	import world.WorldEvent;
	
	public class UIBoss extends EventDispatcher
	{
		public var _worldView:WorldView;
		public var _worldViewMouseHandler:WorldViewClickHandler;
		public var _stageView:StageView;
		public var _stageViewMouseHandler:StageViewClickHandler;
		public var _venue:Venue;
		public var _bottomBar:BottomBar;
		public var _topBar:TopBar;
		
		public static const MAX_FILLERS:int = 6;	
		[Embed(source="../libs/icons/hearts_chain_6.png")]
		public var heartsChain6:Class;		
		[Embed(source="../libs/icons/skin_plain_red.png")]
		public var plainSkinRed:Class;		
		[Embed(source="../libs/icons/skin_plain_black.png")]
		public var plainSkinBlack:Class;		
		
		public function UIBoss(worldView:WorldView, stageView:StageView, bottomBar:BottomBar, target:IEventDispatcher=null)
		{
			super(target);
			_worldView = worldView;
			_stageView = stageView;
			_bottomBar = bottomBar;
			_worldView.addEventListener(VenueEvent.VENUE_INITIALIZED, onVenueInitialized);
			_stageView.addEventListener(VenueEvent.STAGE_INITIALIZED, onStageInitialized);
			
			addDumbButton();
		}
		
		public function addDumbButton():void
		{
			var btn:Button = new Button();
			btn.height = 50;
			btn.width = 50;
			btn.y = 150;
			btn.addEventListener(MouseEvent.CLICK, onDumbButtonClicked);
			_worldView.addChild(btn);
		}
		
		private function onDumbButtonClicked(evt:MouseEvent):void
		{
			_venue.startPostSongExit();
			var tempTimer:Timer = new Timer(300);
			tempTimer.start();
			tempTimer.addEventListener(TimerEvent.TIMER, function onTempTimer():void
			{
				clearBitmap();
				tempTimer.stop();
				tempTimer.removeEventListener(TimerEvent.TIMER, onTempTimer);
				tempTimer = null;
			});
		}
		
		private function onVenueInitialized(evt:VenueEvent):void
		{
			_worldViewMouseHandler = _worldView.mouseHandler as WorldViewClickHandler;	
			_worldViewMouseHandler.addEventListener(UIEvent.COLLECTIBLE_DROP_FROM_STAGE, onCollectibleDropFromStage);
			_worldViewMouseHandler.addEventListener(UIEvent.REPLACE_BOTTOMBAR, onReplaceBottomBar);
			_venue = _worldView.venueManager.venue;
			_venue.addEventListener(MoodEvent.QUEST_INFO_REQUESTED, onQuestInfoRequested);			
		}
		
		private function onStageInitialized(evt:VenueEvent):void
		{
			_stageViewMouseHandler = _stageView.mouseHandler as StageViewClickHandler;
			_stageViewMouseHandler.addEventListener(UIEvent.REPLACE_BOTTOMBAR, onReplaceBottomBar);			
		}
		
		private function doCollectibleDrop(person:Person, action:String):void
		{
			var eventData:Object;
			for each (var reward:Object in person.mood.rewards)
			{
				if (reward.mc)
				{	
					eventData = formatCollectibleEventData(action + "_bonus", person.thinger, reward.total + Math.round(Math.random() * reward.max_bonus), reward.type);
					var klass:Class = getDefinitionByName(reward.mc) as Class;
					var mc:MovieClip = new klass() as MovieClip;
					addCollectible(mc, person, eventData);
				}
			}
			if ((person.mood.possible_rewards as Array).length > 0)
			{
				var collectibleMC:MovieClip = MoodBoss.getRandomItemByMood(person.mood);
				eventData = formatCollectibleEventData(action + "_collection", person.thinger, 0, null, getQualifiedClassName(collectibleMC));
				addCollectible(collectibleMC, person, eventData);			
			}
		}
		
		private function addCollectible(mc:MovieClip, person:Person, precipitatingObject:Object):void
		{
			var radius:Point = new Point(100, 50);
			var collectibleDrop:CollectibleDrop = new CollectibleDrop(person, mc, radius, _worldView.myWorld, _worldView, 0, 400, .001, null, new Point(person.x, person.y - 70));
			collectibleDrop.precipitatingObject = precipitatingObject;
			collectibleDrop.addEventListener(UIEvent.COLLECTIBLE_DROP_CLICKED, onCollectibleDropClicked);
			collectibleDrop.addEventListener("removeCollectible", function onRemoveCollectible():void
			{
				_worldView.myWorld.removeChild(collectibleDrop);
			});
			_worldView.myWorld.addChild(collectibleDrop);							
		}
		
		private function onCollectibleDropFromStage(evt:UIEvent):void
		{
			var bar:CustomizableProgressBar = createHeartProgressBar(evt.asset as Person);
			_venue.bandMemberManager.goToStageAndTossItem(evt.asset as Person, _worldView);
			_venue.bandMemberManager.myAvatar.addEventListener(WorldEvent.ITEM_DROPPED, function onItemTossedByAvatar():void
			{
				_venue.bandMemberManager.myAvatar.removeEventListener(WorldEvent.ITEM_DROPPED, onItemTossedByAvatar);
				(evt.asset as Person).removeMoodClip();
				bar.startBar();
			});				
		}
		
		public function doCollectibleDropByMood(person:Person, parentWorld:World):void
		{
			person.removeMoodClip();
			var eventData:Object;
			for each (var reward:Object in person.mood.rewards)
			{
				if (reward.mc)
				{					
					eventData = formatCollectibleEventData("creature_nurture_bonus", person.thinger, reward.total + Math.round(Math.random() * reward.max_bonus), reward.type);
					var klass:Class = getDefinitionByName(reward.mc) as Class;
					var mc:MovieClip = new klass() as MovieClip;
					createCollectible(mc, person, parentWorld, eventData);
				}
			}
			if ((person.mood.possible_rewards as Array).length > 0)
			{	
				var collectibleMC:MovieClip = MoodBoss.getRandomItemByMood(person.mood);
				eventData = formatCollectibleEventData("creature_nurture_collection", person.thinger, 0, null, getQualifiedClassName(collectibleMC));
				createCollectible(collectibleMC, person, parentWorld, eventData);
			}	
		}
		
		public static function formatCollectibleEventData(action:String, instance:Object, amount:Number=0, amountType:String=null, collectibleClass:String=null):Object
		{
			var eventData:Object = new Object();
			eventData.action = action;
			eventData.source = instance;
			eventData.amount = amount;
			eventData.amountType = amountType;
			eventData.collectible = collectibleClass;
			return eventData;
		}
		
		public function createCollectible(mc:MovieClip, asset:ActiveAsset, parentWorld:World, precipitatingObject:Object):void
		{
			var radius:Point = new Point(100, 50);
			var collectibleDrop:CollectibleDrop = new CollectibleDrop(asset, mc, radius, parentWorld, parentWorld.parent as WorldView, 0, 400, .001, null, new Point(asset.x, asset.y - 70));
			collectibleDrop.precipitatingObject = precipitatingObject;
			collectibleDrop.addEventListener(UIEvent.COLLECTIBLE_DROP_CLICKED, onCollectibleDropClicked);
			collectibleDrop.addEventListener("removeCollectible", function onRemoveCollectible():void
			{
				parentWorld.removeChild(collectibleDrop);
			});
			parentWorld.addChild(collectibleDrop);				
		}
				
		private function onReplaceBottomBar(evt:UIEvent):void
		{
			if (evt.asset && evt.asset is Person)
				_bottomBar.replaceCreatureInfo((evt.asset as Person).creature);
		}
		
		public function createHeartProgressBar(person:Person):CustomizableProgressBar
		{
			var barCoords:Point = getCenterPointAbovePerson(person);
			var img:Image = getProgressBarImage();
			person.doNotClearFilters = true;
			
			var numFillers:int = Math.ceil(Math.random() * MAX_FILLERS);
			var totalTime:int = numFillers * 800;
			var customizableBar:CustomizableProgressBar = new CustomizableProgressBar(21, 24, 22, img, totalTime, 50, HeartEmpty, plainSkinBlack, plainSkinRed, barCoords.x, barCoords.y, numFillers);
			customizableBar.addEventListener(WorldEvent.PROGRESS_BAR_COMPLETE, function onProgressBarComplete():void
			{
				customizableBar.removeEventListener(WorldEvent.PROGRESS_BAR_COMPLETE, onProgressBarComplete);
				person.doNotClearFilters = false;
				_worldView.removeChild(customizableBar);
				doCollectibleDrop(person, "creature_nurture");				
			});
			customizableBar.x = customizableBar.x + (person.width - customizableBar.width)/2 - 35;
			addFilterForHeartProgressBar(person, customizableBar);
			_worldView.addChild(customizableBar);
			return customizableBar;
		}	
		
		private function getProgressBarImage():Image
		{
			var img:Image = new Image();
			img.source = "../libs/icons/hearts_chain_6.png";
			img.width = 135;
			img.height = 25;	
			return img;
		}
		
		public function getCenterPointAbovePerson(person:Person):Point
		{
			var worldRect:Rectangle = _worldView.myWorld.getBounds(_worldView); 
			var wgRect:Rectangle = _worldView.myWorld.wg.getBounds(_worldView.myWorld);
			return new Point(person.realCoords.x + worldRect.x, 
				person.realCoords.y + wgRect.height/2 - person.height/2);			
		}
		
		private function addFilterForHeartProgressBar(asset:Sprite, customizableBar:CustomizableProgressBar):void
		{
			var gf:GlowFilter = new GlowFilter(0xFFDD00, 1, 2, 2, 20, 20);
			asset.filters = [gf];		
			customizableBar.filters = [gf];
		}	
		
		private function pullCreatureFromBitmap(asset:ActiveAsset, toWorld:World):void
		{
			var abd:AssetBitmapData = _worldView.bitmapBlotter.getMatchFromBitmapReferences(asset);
			_worldView.bitmapBlotter.removeRenderedBitmap(asset);
			var index:int = _worldView.bitmapBlotter.bitmapReferences.getItemIndex(abd);
			_worldView.bitmapBlotter.bitmapReferences.removeItemAt(index);
			_worldView.bitmapBlotter.clearBitmaps();
			_worldView.bitmapBlotter.renderInitialBitmap();
		}
		
		public function onCollectibleDropClicked(evt:UIEvent):void
		{
			var drop:CollectibleDrop = evt.currentTarget as CollectibleDrop;
			_venue.doBonusClick(drop.precipitatingObject);
		}
		
		private function clearBitmap():void
		{
			_worldView.bitmapBlotter.clearBitmaps();
		}
		
		private function onQuestInfoRequested(evt:MoodEvent):void
		{
			_bottomBar.expandCreatureCanvas(evt.person.creature);			
		}
	}
}