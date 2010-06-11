package rock_on
{
	import customizer.CustomizerEvent;
	
	import flash.events.MouseEvent;
	
	import models.Creature;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	
	import views.ContainerUIC;
	import views.UICanvas;
	
	import world.ActiveAsset;
	import world.AssetStack;
	import world.Point3D;
	import world.World;
	import world.WorldEvent;

	public class BandMemberManager extends ArrayCollection
	{
		public static const ENTER_STATE:int = 0;
		public static const ROAM_STATE:int = 1;
		public static const STOP_STATE:int = 3;
		public static const LEAVING_STATE:int = 2;
		public static const GONE_STATE:int = 5;	
			
		private var _myWorld:World;		
		private var _concertStage:ConcertStage;
		public var spawnLocation:Point3D;				
		
		public function BandMemberManager(source:Array=null)
		{
			super(source);
		}
		
		public function add(person:BandMember):void
		{
			if(_myWorld)
			{			
				setSpawnLocation();
				_myWorld.addAsset(person, spawnLocation);				
				addItem(person);
				person.myWorld = _myWorld;
			}
			else
			{
				throw new Error("you have to fill your pool before you dive");
			}
		}
		
		public function updateAllBandMemberStates(state:int):void
		{
			for each (var bm:BandMember in this)
			{
				bm.advanceState(state);		
			}
		}
		
		private function onFinalDestinationReached(evt:WorldEvent):void
		{
			if (evt.activeAsset is BandMember)
			{	
				var bm:BandMember = evt.activeAsset as BandMember;
				if (bm.state == ROAM_STATE && Math.random() < 0.5)
				{
					bm.findNextPath();
				}
				else if (bm.state == ROAM_STATE)
				{
					bm.advanceState(STOP_STATE);
				}
				else
				{
					bm.standFacingCrowd();
				}
			}
		}
		
		public function updateRenderedBandMembers(ol:OwnedLayerable, creature:Creature, method:String):void
		{
			if (method == "make_in_use")
			{
				var bm:BandMember = getBandMemberById(creature.id);
				bm.swapMovieClipsByOwnedLayerable(ol, "walk_toward");
			}
		}
		
		public function getBandMemberById(id:int):BandMember
		{
			for each (var bm:BandMember in this)
			{
				if (bm.creature.id == id)
				{
					return bm;
				}
			}
			return null;
		}
		
		public function setSpawnLocation():void
		{
			spawnLocation = new Point3D(Math.floor(_concertStage.structure.width - (Math.random()*_concertStage.structure.width)), 0, Math.floor(_myWorld.tilesDeep - Math.random()*(_concertStage.structure.depth)));	
		}
		
		
		public function putBandMembersInCustomizer(animation:String):UICanvas
		{
			var customizerUI:UICanvas = getCustomizerUI();
			var index:int = 0;
			for each (var bm:BandMember in this)
			{
				var asset:AssetStack = getBandMemberAssetCopy(bm, animation);
				asset.creature = bm.creature;
				asset.addEventListener(MouseEvent.CLICK, onBandMemberClicked);
				asset.x = asset.width * index + asset.width/2;
				asset.y = asset.height;
				var uic:ContainerUIC = new ContainerUIC();
				uic.thinger = bm;
				uic.addChild(asset);
				customizerUI.addChild(uic);
			}
			return customizerUI;
		}
		
		private function onBandMemberClicked(evt:MouseEvent):void
		{
			var asset:AssetStack = evt.currentTarget as AssetStack;
			asset.removeEventListener(MouseEvent.CLICK, onBandMemberClicked);
			var customizerEvent:CustomizerEvent = new CustomizerEvent(CustomizerEvent.CREATURE_SELECTED, true, true);
			customizerEvent.selectedCreatureAsset = asset;
			dispatchEvent(customizerEvent);
		}
		
		public function getBandMemberAssetCopy(bm:BandMember, animation:String):AssetStack
		{
			var asset:AssetStack = bm.creature.getConstructedCreature(bm.layerableOrder, animation, 1, 1);
			asset.doAnimation(animation, 39);
			return asset;
		}	
		
		public function getCustomizerUI():UICanvas
		{
			var ui:UICanvas = new UICanvas();
			ui.setStyles(0xffffff, 0x333333, 14, 500, 400);
			return ui;
		}	
		
		public function update(deltaTime:Number):void
		{			
			for each (var person:BandMember in this)
			{
				if (person.update(deltaTime))
				{		
					remove(person);							
				}
				else 
				{
				}
			}			
		}
		
		public function remove(person:BandMember):void
		{
			if(_myWorld)
			{
				_myWorld.removeChild(person);
				var movingSkinIndex:Number = _myWorld.assetRenderer.sortedAssets.getItemIndex(person);
				_myWorld.assetRenderer.sortedAssets.removeItemAt(movingSkinIndex);
				var personIndex:Number = getItemIndex(person);
				removeItemAt(personIndex);
			}
			else 
			{
				throw new Error("how the hell did this happen?");
			}
		}		
		
		private function onDirectionChanged(evt:WorldEvent):void
		{
			for each (var asset:ActiveAsset in this)
			{
				if (evt.activeAsset == asset)
				{
					(asset as BandMember).setDirection(asset.worldDestination);
				}
			}
		}	
						
		public function set myWorld(val:World):void
		{
			if(!_myWorld)
			{
				_myWorld = val;
				_myWorld.addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);				
				_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDestinationReached);
			}
			else
			{
				throw new Error("Don't change this!!");				
			}
		}
		
		public function get myWorld():World
		{
			return _myWorld;
		}	
		
		public function set concertStage(val:ConcertStage):void
		{
			if(!_concertStage)
			{
				_concertStage = val;				
			}
			else
			{
//				throw new Error("Don't change this!!");				
			}
		}
		
		public function get concertStage():ConcertStage
		{
			return _concertStage;
		}						
		
	}
}