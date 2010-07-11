package rock_on
{
	import controllers.CreatureController;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	
	import world.AssetStack;
	import world.World;

	public class GroupieBoss extends EventDispatcher
	{
		public var groupies:ArrayCollection;
		public var friendMirror:Boolean;
		public var _customerPersonManager:CustomerPersonManager;
		public var _creatureController:CreatureController;
		public var _myWorld:World;
		public var _venue:Venue;
		public var _boothBoss:BoothBoss;
		public var _concertStage:ConcertStage;
		
		public function GroupieBoss(customerPersonManager:CustomerPersonManager, boothBoss:BoothBoss, concertStage:ConcertStage, creatureController:CreatureController, myWorld:World, venue:Venue, target:IEventDispatcher=null)
		{
			super(target);
			_customerPersonManager = customerPersonManager;
			_creatureController = creatureController;
			_myWorld = myWorld;
			_boothBoss = boothBoss;
			_concertStage = concertStage;
			_venue = venue;
		}
		
		public function setInMotion():void
		{
			showGroupies();
		}
		
		public function tearDown():void
		{
			removeGroupies();
		}
		
		public function showGroupies():void
		{	
			// Creating ActiveAssets 2x as much as necessary here...
			
			groupies = new ArrayCollection();
//			var groupieAssets:ArrayCollection = _creatureController.getConstructedCreaturesByType("Groupie", 1, 1);
//			
//			for each (var assetStack:AssetStack in groupieAssets)
//			{
//				var cp:CustomerPerson = new CustomerPerson(assetStack.movieClips, _concertStage, _boothBoss, assetStack.layerableOrder, assetStack.creature, 0.4);
//				cp.speed = 0.06;
//				_customerPersonManager.add(cp, true, -1, _venue.boothsRect);
//				groupies.addItem(cp);
//			}
			
			for each (var c:Creature in _creatureController.creatures)
			{
				if (c.type == "Groupie")
				{
					var cp:CustomerPerson = new CustomerPerson(_boothBoss, c, null, c.layerableOrder, 0.5);
					cp.speed = 0.06;
					cp.doInitialAnimation("walk_toward");
					cp.stageManager = _venue.stageManager;
					_customerPersonManager.add(cp, true, -1, _venue.boothsRect);
					groupies.addItem(cp);
				}
			}
		}		
		
		public function removeGroupies():void
		{
			for each (var cp:CustomerPerson in groupies)
			{
				_customerPersonManager.remove(cp);
			}
			groupies.removeAll();
		}
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}
		
		public function get venue():Venue
		{
			return _venue;
		}
		
	}
}