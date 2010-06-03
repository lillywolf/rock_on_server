package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Creature;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	
	import server.ServerController;
	
	import views.CreatureCustomizer;
	
	import world.AssetStack;

	public class CreatureManager extends Manager
	{
		public var _creatures:ArrayCollection;
		public var _owned_layerables:ArrayCollection;
		public var _serverController:ServerController;
		
		public function CreatureManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
			_creatures = essentialModelManager.creatures;
			_owned_layerables = essentialModelManager.owned_layerables;
		}
		
		public function addInstantiatedCreatures():void
		{
			for each (var creature:Creature in _creatures)
			{
				add(creature);
			}
		}
		
		public function saveCustomLayers(creature:Creature, newLayerables:ArrayCollection, oldLayerables:ArrayCollection):void
		{
			var ol:OwnedLayerable;
			
			for each (ol in newLayerables)
			{
				if (!ol.in_use)
				{
					_serverController.sendRequest({id: ol.id}, 'owned_layerable', 'make_in_use');				
				}
			}
			for each (ol in oldLayerables)
			{
				if (ol.in_use)
				{
					_serverController.sendRequest({id: ol.id}, 'owned_layerable', 'remove_from_in_use');
				}
			}
		}
		
		public function getConstructedCreaturesByType(type:String, sizeX:Number, sizeY:Number):ArrayCollection
		{
			var matchingCreatures:ArrayCollection = new ArrayCollection();
			var assetStack:AssetStack;
			for each (var creature:Creature in _creatures)
			{
				if (creature.type == type)
				{
					assetStack = creature.getConstructedCreature('walk_toward', sizeX, sizeY);
					matchingCreatures.addItem(assetStack);
				}
			}
			return matchingCreatures;
		}
		
		public function getConstructedCreatureById(id:int, sizeX:Number, sizeY:Number):AssetStack
		{
			for each (var creature:Creature in _creatures)
			{
				if (creature.id == id)
				{
					var assetStack:AssetStack = creature.getConstructedCreature('walk_toward', sizeX, sizeY);
					break;
				}
			}	
			return assetStack;		
		}
		
		public function getCreaturesByType(type:String):ArrayCollection
		{
			var matchingCreatures:ArrayCollection = new ArrayCollection();
			for each (var creature:Creature in _creatures)
			{
				if (creature.type == type)
				{
					matchingCreatures.addItem(creature);
				}
			}
			return matchingCreatures;
		}
		
		public function getCreatureById(id:int):Creature
		{
			for each (var creature:Creature in _creatures)
			{
				if (creature.id == id)
				{
					return creature;
				}
			}
			return null;
		}
		
		public function getRandomCreatureByType(type:String):Creature
		{
			for each (var creature:Creature in _creatures)
			{
				if (creature.type == type)
				{
					return creature;
				}
			}
			return null;
		}
		
		public function generateCreatureCustomizer(creature:Creature):CreatureCustomizer
		{
			var creatureCustomizer:CreatureCustomizer = new CreatureCustomizer(creature, this);
			return creatureCustomizer;
		}		
		
		public function add(creature:Creature):void
		{
			
		}
		
		public function remove(creature:Creature):void
		{
			
		}
		
		public function set serverController(val:ServerController):void
		{
			_serverController = val;
		}
				
		public function get creatures():ArrayCollection
		{
			return _creatures;
		}
		
		public function get owned_layerables():ArrayCollection
		{
			return _owned_layerables;
		}
			
	}
}