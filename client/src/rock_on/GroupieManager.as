package rock_on
{
	import controllers.CreatureManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import world.AssetStack;
	import world.World;

	public class GroupieManager extends EventDispatcher
	{
		public var groupies:ArrayCollection;
		public var _customerPersonManager:CustomerPersonManager;
		public var _creatureManager:CreatureManager;
		public var _myWorld:World;
		public var _booths:ArrayCollection;
		public var _concertStage:ConcertStage;
		
		public function GroupieManager(customerPersonManager:CustomerPersonManager, booths:ArrayCollection, concertStage:ConcertStage, creatureManager:CreatureManager, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_customerPersonManager = customerPersonManager;
			_creatureManager = creatureManager;
			_myWorld = myWorld;
			_booths = booths;
			_concertStage = concertStage;
		}
		
		public function setInMotion():void
		{
			showGroupies();
		}
		
		public function showGroupies():void
		{	
			// Creating ActiveAssets 2x as much as necessary here...
			
			groupies = _creatureManager.getConstructedCreaturesByType("Groupie", 1, 1);
			
			for each (var assetStack:AssetStack in groupies)
			{
				var person:CustomerPerson = new CustomerPerson(assetStack.movieClipStack, assetStack.layerableOrder, assetStack.creature, 0.4);
				person.booths = _booths;
				person.concertStage = _concertStage;
				person.speed = 0.07;
				_customerPersonManager.add(person);
			}
		}		
		
	}
}