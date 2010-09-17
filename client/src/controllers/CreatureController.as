package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Creature;
	import models.CreatureGroup;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	import server.ServerController;
	
	import views.CreatureCustomizer;
	
	import world.ActiveAssetStack;
	import world.AssetStack;

	public class CreatureController extends Controller
	{
		public var _creatures:ArrayCollection;
		public var _friend_creatures:ArrayCollection;
		public var _owned_layerables:ArrayCollection;
		public var _serverController:ServerController;
		public var _creature_groups:ArrayCollection;
		
		public function CreatureController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			_creatures = essentialModelController.creatures;
			_friend_creatures = essentialModelController.friend_creatures;
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
					_serverController.sendRequest({id: ol.id}, 'owned_layerable', 'make_in_use');				
			}
			for each (ol in oldLayerables)
			{
				if (ol.in_use)
					_serverController.sendRequest({id: ol.id}, 'owned_layerable', 'remove_from_in_use');
			}
		}
		
		public function makeSureOwnedLayerablesAreAssignedToCreatures():void
		{
			for each (var ol:OwnedLayerable in owned_layerables)
			{
				for each (var c:Creature in _creatures)
				{
					if (ol.creature_id == c.id)
					{
						if (!c.owned_layerables.contains(ol))
							c.owned_layerables.addItem(ol);
					}
				}
			}
		}
				
		public function getConstructedCreaturesByType(type:String):ArrayCollection
		{
			var matchingCreatures:ArrayCollection = new ArrayCollection();
			for each (var creature:Creature in _creatures)
			{
				if (creature.type == type)
				{
					var layerableOrder:Array = getLayerableOrderByCreatureType(creature.type);
					matchingCreatures.addItem(creature);
				}
			}
			return matchingCreatures;
		}
		
		public function getConstructedCreatureById(id:int, sizeX:Number, sizeY:Number):ActiveAssetStack
		{
			for each (var creature:Creature in _creatures)
			{
				if (creature.id == id)
				{
					var layerableOrder:Array = getLayerableOrderByCreatureType(creature.type);
					var asset:ActiveAssetStack = creature.getConstructedCreature(layerableOrder, 'walk_toward', sizeX);
					break;
				}
			}	
			return asset;		
		}
		
		public function getLayerableOrderByCreatureType(creatureType:String):Array
		{
			var layerableOrder:Array = new Array();
			if (creatureType == "BandMember")
			{			
				layerableOrder['walk_toward'] = ["body"];
				layerableOrder['walk_away'] = ["body"];
				layerableOrder['stand_still_toward'] = ["body"];
				layerableOrder['stand_still_away'] = ["body"];				
			}
			else if (creatureType == "Groupie")
			{							
				layerableOrder['walk_toward'] = ["body", "hair back", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];
				layerableOrder['walk_away'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];
				layerableOrder['stand_still_toward'] = ["body", "hair back", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];
				layerableOrder['stand_still_away'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];								
				layerableOrder['head_bob_away'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];								
			}
			else if (creatureType == "Hater")
			{							
				layerableOrder['walk_toward'] = ["body", "hair back", "shoes", "bottom", "top", "hair front", "hair band"];
				layerableOrder['walk_away'] = ["body", "shoes", "bottom", "top", "hair front", "hair band"];
				layerableOrder['stand_still_toward'] = ["body", "hair back", "shoes", "bottom", "top", "hair front", "hair band"];
				layerableOrder['stand_still_away'] = ["body", "shoes", "bottom", "top", "hair front", "hair band"];	
				layerableOrder['head_bob_away'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];												
			}
			else
			{							
				layerableOrder['walk_toward'] = ["hair back", "shoes", "bottom", "top", "hair front"];
				layerableOrder['walk_away'] = ["shoes", "bottom", "top", "hair front"];
				layerableOrder['stand_still_toward'] = ["hair back", "shoes", "bottom", "top", "hair front"];
				layerableOrder['stand_still_away'] = ["shoes", "bottom", "top", "hair front"];	
				layerableOrder['head_bob_away'] = ["body", "shoes", "bottom", "top", "hair front", "hair band"];												
			}
			return layerableOrder;
		}
		
		public function getFans():ArrayCollection
		{
			var matchingCreatures:ArrayCollection = new ArrayCollection();
			for each (var c:Creature in _creatures)
			{
				if (c.user_id == FlexGlobals.topLevelApplication.gdi.user.id && c.type == "Fan")
				{
//					var matchId:int = int(c.additional_info.split(": ")[1]);
					var creature:Creature = this.getCreatureById(c.reference_id);
					matchingCreatures.addItem(creature);
				}				
			}
			return matchingCreatures;
		}
		
		public function getCreaturesByType(type:String):ArrayCollection
		{
			var matchingCreatures:ArrayCollection = new ArrayCollection();
			for each (var creature:Creature in _creatures)
			{
				if (creature.type == type)
					matchingCreatures.addItem(creature);
			}
			return matchingCreatures;
		}
		
		public function getPeers(uid:int):ArrayCollection
		{
			var matchingCreatures:ArrayCollection = new ArrayCollection();
			for each (var creature:Creature in _creatures)
			{
				if (creature.user_id == uid && creature.type != "Fan")
					matchingCreatures.addItem(creature);
			}
			return matchingCreatures;
		}
		
		public function getCreatureById(id:int):Creature
		{
			for each (var creature:Creature in _creatures)
			{
				if (creature.id == id)
					return creature;
			}
			return null;
		}
		
		public function getGameOwnedCreatures():ArrayCollection
		{
			var gameOwned:ArrayCollection = new ArrayCollection();
			for each (var c:Creature in _creatures)
			{
				if (c.user_id == -1 && c.type == "Fan")
					gameOwned.addItem(c);
			}
			return gameOwned;
		}
		
		public function getRandomGameOwnedCreature(exclude:ArrayCollection):Creature
		{
			var gameOwned:ArrayCollection = getGameOwnedCreatures();
			var random:Creature = gameOwned.getItemAt(Math.floor(Math.random()*gameOwned.length)) as Creature;
			if (exclude.length > gameOwned.length)
				return random;
			while (exclude.contains(random))
			{
				random = gameOwned.getItemAt(Math.floor(Math.random()*gameOwned.length)) as Creature;
			}
			return random;
		}
		
		public function getRandomCreatureByType(type:String):Creature
		{
			for each (var creature:Creature in _creatures)
			{
				if (creature.type == type)
					return creature;
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
					return cg;
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

		public function get serverController():ServerController
		{
			return _serverController;
		}
				
		public function get creatures():ArrayCollection
		{
			return _creatures;
		}
		
		public function get friend_creatures():ArrayCollection
		{
			return _friend_creatures;
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