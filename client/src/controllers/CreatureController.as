package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Creature;
	import models.CreatureGroup;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	
	import server.ServerController;
	
	import views.CreatureCustomizer;
	
	import world.AssetStack;

	public class CreatureController extends Controller
	{
		public var _creatures:ArrayCollection;
		public var _owned_layerables:ArrayCollection;
		public var _serverController:ServerController;
		public var _creature_groups:ArrayCollection;
		
		public function CreatureController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			_creatures = essentialModelController.creatures;
			_owned_layerables = essentialModelController.owned_layerables;
			_creature_groups = essentialModelController.creature_groups;
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
					var layerableOrder:Array = getLayerableOrderByCreatureType(creature.type);
					assetStack = creature.getConstructedCreature(layerableOrder, 'walk_toward', sizeX, sizeY);
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
					var layerableOrder:Array = getLayerableOrderByCreatureType(creature.type);
					var assetStack:AssetStack = creature.getConstructedCreature(layerableOrder, 'walk_toward', sizeX, sizeY);
					break;
				}
			}	
			return assetStack;		
		}
		
//		public function getConstructedCreature(creature:Creature, animation:String):void
//		{
//			for each (var layer:String in creature.layerableOrder[animation])
//			{
//				creature.owned_layerables.get
//			}
//		}
		
		public function getLayerableOrderByCreatureType(creatureType:String):Array
		{
			var layerableOrder:Array = new Array();
			if (creatureType == "BandMember")
			{
//				layerableOrder['walk_toward'] = ["body", "hair back", "eyes", "shoes", "bottom", "top", "hair front", "instrument"];
//				layerableOrder['walk_away'] = ["instrument", "eyes", "body", "shoes", "bottom", "top", "hair front"];
//				layerableOrder['stand_still_toward'] = ["body", "hair back", "eyes", "shoes", "bottom", "top", "hair front", "instrument"];
//				layerableOrder['stand_still_away'] = ["instrument", "eyes", "body", "shoes", "bottom", "top", "hair front"];				
				layerableOrder['walk_toward'] = ["body"];
				layerableOrder['walk_away'] = ["body"];
				layerableOrder['stand_still_toward'] = ["body"];
				layerableOrder['stand_still_away'] = ["body"];				
			}
			else if (creatureType == "Groupie")
			{
//				layerableOrder['walk_toward'] = ["body", "hair back", "eyes", "shoes", "bottom", "top", "hair front"];
//				layerableOrder['walk_away'] = ["eyes", "body", "shoes", "bottom", "top", "hair front"];
//				layerableOrder['stand_still_toward'] = ["body", "hair back", "eyes", "shoes", "bottom", "top", "hair front"];
//				layerableOrder['stand_still_away'] = ["eyes", "body", "shoes", "bottom", "top", "hair front"];								
				layerableOrder['walk_toward'] = ["body", "hair back", "shoes", "bottom", "top", "hair front"];
				layerableOrder['walk_away'] = ["body", "shoes", "bottom", "top", "hair front"];
				layerableOrder['stand_still_toward'] = ["body", "hair back", "shoes", "bottom", "top", "hair front"];
				layerableOrder['stand_still_away'] = ["body", "shoes", "bottom", "top", "hair front"];								
			}
			else
			{
//				layerableOrder['walk_toward'] = ["body", "hair back", "eyes", "shoes", "bottom", "top", "hair front"];
//				layerableOrder['walk_away'] = ["eyes", "body", "shoes", "bottom", "top", "hair front"];
//				layerableOrder['stand_still_toward'] = ["body", "hair back", "eyes", "shoes", "bottom", "top", "hair front"];
//				layerableOrder['stand_still_away'] = ["eyes", "body", "shoes", "bottom", "top", "hair front"];								
				layerableOrder['walk_toward'] = ["hair back", "shoes", "bottom", "top", "hair front"];
				layerableOrder['walk_away'] = ["shoes", "bottom", "top", "hair front"];
				layerableOrder['stand_still_toward'] = ["hair back", "shoes", "bottom", "top", "hair front"];
				layerableOrder['stand_still_away'] = ["shoes", "bottom", "top", "hair front"];								
			}
			return layerableOrder;
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
		
		public function getCreatureGroupByOwnedDwellingId(odId:int):CreatureGroup
		{
			for each (var cg:CreatureGroup in this.creature_groups)
			{
				if (cg.owned_dwelling_id == odId)
				{
					return cg;
				}
			}
			return null;
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
		
		public function get creature_groups():ArrayCollection
		{
			return _creature_groups;
		}
			
	}
}