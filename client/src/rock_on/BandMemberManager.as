package rock_on
{
	import customizer.CustomizerEvent;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import models.Creature;
	import models.OwnedLayerable;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import views.BandBoss;
	import views.ContainerUIC;
	import views.UICanvas;
	import views.WorldView;
	
	import world.ActiveAsset;
	import world.ActiveAssetStack;
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
		public var _venue:Venue;
		public var creatures:ArrayCollection;
		public var spawnLocation:Point3D;
		public var myAvatar:BandMember;
		
		public function BandMemberManager(venue:Venue, myWorld:World, source:Array=null)
		{
			super(source);
			creatures = new ArrayCollection();
			_venue = venue;
			_myWorld = myWorld;
			_myWorld.addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);				
			_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDestinationReached);	
			
			_venue.myWorld.addEventListener(WorldEvent.DIRECTION_CHANGED, onVenueDirectionChanged);				
			_venue.myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onVenueFinalDestinationReached);			
		}
		
		public function showBandMembers():void
		{
			trace("band members in creatures: " + _venue.creatureController.creatures.length.toString());
			for each (var c:Creature in _venue.creatureController.creatures)
			{
				if (c.type == "BandMember" || c.type == "Me")
				{
					creatures.addItem(c);
					createBandMember(c);					
				}
			}
		}		
		
		public function createBandMember(c:Creature):void
		{
			var bm:BandMember = new BandMember(c, null, c.layerableOrder, 0.5);
			bm.stageManager = _venue.stageManager;
			bm.venue = _venue;
			bm.addExemptStructures();
			bm.speed = 0.11;
			add(bm);
			
			if (c.type == "Me")
				this.myAvatar = bm;
			
			bm.advanceState(mapVenueStateToBandMemberState(bm));			
		}
		
		public function add(bm:BandMember):void
		{
			if(_myWorld)
			{			
				var destination:Point3D = setSpawnLocation();
				_myWorld.addAsset(bm, destination);				
				addItem(bm);
				bm.myWorld = _myWorld;
				trace("band member added");
			}
			else
			{
				throw new Error("you have to fill your pool before you dive");
			}
		}
		
		public function mapVenueStateToBandMemberState(bm:BandMember):int
		{
			if (_venue.state == Venue.EMPTY_STATE)
			{
				if (bm.creature.type == "Me")
				{
					return BandMember.SING_STATE;
				}
				else
				{
					return BandMember.WAIT_STATE;				
				}
			}
			else if (_venue.state == Venue.ENCORE_STATE)
			{
				return BandMember.STAGE_ENTER_STATE;
			}
			else if (_venue.state == Venue.ENCORE_WAIT_STATE)
			{
				return BandMember.WAIT_STATE;
			}
			else if (_venue.state == Venue.SHOW_STATE)
			{
				return BandMember.STAGE_ENTER_STATE;
			}
			else if (_venue.state == Venue.SHOW_WAIT_STATE)
			{
				if (bm.creature.type == "Me")
				{
					return BandMember.SING_STATE;
				}
				else
				{
					return BandMember.BOB_AND_STRUM_STATE;				
				}			
			}
			else
			{
				throw new Error("Not a legitimate state");
			}
		}			
		
		public function clearFilters():void
		{
			for each (var bm:BandMember in this)
			{
				if (!bm.doNotClearFilters)
				{
					bm.filters = null;				
				}
			}
		}	
		
		public function updateAllBandMemberStates(state:int):void
		{
			for each (var bm:BandMember in this)
			{
				bm.advanceState(state);		
			}
		}
		
		public function moveMyAvatar(destination:Point3D, toWorld:Boolean, toStage:Boolean):void
		{
			if (this.myAvatar)
			{
				(myAvatar as BandMember).destinationLocation = destination;
				
				if (toWorld)
				{
					if (!(myAvatar as BandMember).inWorld)
					{
						(myAvatar as BandMember).exitLocation = _concertStage.stageEntryPoint;
						(myAvatar as BandMember).advanceState(BandMember.EXIT_STAGE_STATE);
					}
					else
					{
						(myAvatar as BandMember).advanceState(BandMember.DIRECTED_MOVE_STATE);
					}
				}
				if (toStage)
				{
					if ((myAvatar as BandMember).state == BandMember.DIRECTED_MOVE_STATE || (myAvatar as BandMember).state == BandMember.DIRECTED_STOP_STATE)
					{
						(myAvatar as BandMember).exitLocation = _venue.mainEntrance;
						(myAvatar as BandMember).advanceState(BandMember.EXIT_OFFSTAGE_STATE);
					}
				}
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
				else if (bm.state == BandMember.EXIT_STAGE_STATE)
				{
					bm.advanceState(BandMember.DIRECTED_MOVE_STATE);
				}
				else if (bm.state == BandMember.DIRECTED_MOVE_STATE)
				{
					bm.checkIfProxiedMove(BandMember.DIRECTED_STOP_STATE);
				}
				else if (bm.state == BandMember.STAGE_ENTER_STATE)
				{
					bm.advanceState(BandMember.STOP_STATE);
					if (bm.itemDropRecipient)
					{
						bm.tossItem(bm.itemDropRecipient.recipient as Person, bm.itemDropRecipient.view as WorldView);						
					}
				}
				else
				{
//					bm.standFacingCrowd();
					bm.walkComplete();
				}
			}
		}

		private function onVenueFinalDestinationReached(evt:WorldEvent):void
		{
			if (evt.activeAsset is BandMember)
			{
				var bm:BandMember = evt.activeAsset as BandMember;				
				if (bm.state == BandMember.DIRECTED_MOVE_STATE)
				{
					bm.checkIfProxiedMove(BandMember.DIRECTED_STOP_STATE);
				}
				else if (bm.state == BandMember.EXIT_OFFSTAGE_STATE)
				{
					bm.checkIfProxiedMove(BandMember.STAGE_ENTER_STATE);
				}
				else
				{
					bm.standFacingCrowd();
				}
			}
		}
		
		public function goToStageAndTossItem(recipient:Person, view:WorldView):void
		{
			myAvatar.itemDropRecipient = {recipient: recipient, view: view};
			if (myAvatar.goToStage())
			{
				myAvatar.tossItem(recipient, view);
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
					return bm;
			}
			return null;
		}
		
		public function setSpawnLocation():Point3D
		{
			var destination:Point3D = pickPointWithinStructure(_concertStage);
			return destination;
		}
		
		public function pickPointWithinStructure(os:OwnedStructure):Point3D
		{
			var destination:Point3D;
			var exempt:ArrayCollection = new ArrayCollection();
			exempt.addItem(os);
			var occupiedSpaces:Array = _myWorld.pathFinder.updateOccupiedSpaces(true, true, exempt);
			do
			{		
//				Get space inside stage that isn't an edge point
				destination = new Point3D(Math.floor(os.width - (Math.random()*(os.width))), os.structure.height, Math.ceil(_myWorld.tilesDeep - Math.random()*(os.depth)));	
			}
			while (occupiedSpaces[destination.x] && occupiedSpaces[destination.x][destination.y] && occupiedSpaces[destination.x][destination.y][destination.z]);	
			return destination;
		}
		
		public function redrawAllBandMembers():void
		{
			var numMembers:int = length;
			for (var i:int = (numMembers - 1); i >= 0; i--)
			{
				var bm:BandMember = this[i] as BandMember;
				remove(bm);				
				addAfterInitializing(bm);				
			}
		}		
		
		public function addAfterInitializing(bm:BandMember):void
		{
			if (_myWorld)
			{
				bm.lastWorldPoint = null;
				bm.worldCoords = null;
				add(bm);
//				cp.advanceState(CustomerPerson.ENTHRALLED_STATE);
			}
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
//			var asset:AssetStack = bm.creature.getConstructedCreature(bm.layerableOrder, animation, 1, 1);
//			asset.doAnimation(animation, 39);
//			return asset;
			return new AssetStack();
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
					remove(person);							
				else 
				{
				}
			}
		}
		
		public function remove(bm:BandMember):void
		{
			if(_myWorld)
			{
				_myWorld.removeAsset(bm);
				var personIndex:Number = getItemIndex(bm);
				removeItemAt(personIndex);
			}
			else 
			{
				throw new Error("how the hell did this happen?");
			}
		}	
		
		public function initializeBandMembers():void
		{
			for each (var c:Creature in this.creatures)
			{	
				createBandMember(c);					
			}
		}		
		
		public function removeBandMembers():void
		{
			var bmLength:int = length;
			for (var i:int = (bmLength - 1); i >= 0; i--)				
			{
				var bm:BandMember = this[i] as BandMember;
				remove(bm);
			}			
		}
		
		private function onDirectionChanged(evt:WorldEvent):void
		{
			trace("direction changed");
			for each (var asset:ActiveAsset in this)
			{
				if (evt.activeAsset == asset)
					(asset as BandMember).setDirectionAnimation((asset as BandMember).getNextPointAlongPath());				}
		}	
		
		private function onVenueDirectionChanged(evt:WorldEvent):void
		{
			for each (var asset:ActiveAsset in this)
			{
				if (evt.activeAsset == asset)
					(asset as BandMember).setDirectionAnimation((asset as BandMember).getNextPointAlongPath());
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