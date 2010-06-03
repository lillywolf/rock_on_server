package helpers
{
	import controllers.LayerableManager;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import game.ImposterCreature;
	import game.ImposterOwnedLayerable;
	
	import models.EssentialModelReference;
	import models.Layerable;
	
	import rock_on.BoothManager;
	import rock_on.ConcertStage;
	import rock_on.CustomerPerson;
	
	import world.AssetStack;

	public class CreatureGenerator extends EventDispatcher
	{
		public var layerableOrder:Array;
		public var _layerableManager:LayerableManager;
		public var sortedLayerables:Dictionary;
		public static const GENERIC_X:Number = 1;
		public static const GENERIC_Y:Number = 1;
		
		public function CreatureGenerator(layerableManager:LayerableManager, target:IEventDispatcher=null)
		{
			super(target);
			_layerableManager = layerableManager;
			initializeLayerableOrder();
		}
		
		private function initializeLayerableOrder():void
		{
			layerableOrder = new Array();
			layerableOrder['walk_toward'] = ["body", "eyes", "shoes", "bottom", "top", "hair front"];
			layerableOrder['walk_away'] = ["eyes", "body", "shoes", "bottom", "top", "hair front"];
			layerableOrder['stand_still_toward'] = ["body", "eyes", "shoes", "bottom", "top", "hair front"];
			layerableOrder['stand_still_away'] = ["eyes", "body", "shoes", "bottom", "top", "hair front"];
			
			sortedLayerables = new Dictionary();
			
			for each (var str:String in layerableOrder["walk_toward"])
			{
				sortedLayerables[str] = new Array();
				for each (var layerable:Layerable in _layerableManager.layerables)
				{
					if (layerable.layer_name == str)
					{
						(sortedLayerables[str] as Array).push(layerable);
					}
				}	
			}		
		}
		
		public function createImposterCreature(creatureType:String=null):ImposterCreature
		{
			var params:Object = {creature_type: creatureType};
			var imposter:ImposterCreature = new ImposterCreature({});
			imposter.type = creatureType;
			return imposter;
		}
		
		public function addLayerToCreature(layerName:String, creature:ImposterCreature, asset:AssetStack):void
		{
			var index:int = Math.floor(Math.random()*(sortedLayerables[layerName] as Array).length);
			var layerable:Layerable = sortedLayerables[layerName][index] as Layerable;
			var ol:ImposterOwnedLayerable = new ImposterOwnedLayerable({layerable: layerable, creature_id: creature.id, in_use: true});
			creature.owned_layerables.addItem(ol);
			validateAndAddOwnedLayerable(ol, asset);		
		}
		
		public function validateAndAddOwnedLayerable(ol:ImposterOwnedLayerable, asset:AssetStack):void
		{
			if (ol.layerable.mc)
			{
				var mc:MovieClip = EssentialModelReference.getMovieClipCopy(ol.layerable.mc);
				addMovieClipToCreature(mc, asset);	
			}
			else
			{
//				throw new Error("Layerable " + layerable.id + " has no mc"); 
			}			
		}
		
		public function addMovieClipToCreature(mc:MovieClip, asset:AssetStack):void
		{
			mc.scaleX = GENERIC_X;
			mc.scaleY = GENERIC_Y;
			asset.movieClipStack.addChild(mc);			
		}
		
		public function createCustomer(type:String, animation:String, concertStage:ConcertStage, boothManager:BoothManager):CustomerPerson
		{
			var imposter:ImposterCreature = createImposterCreature(type);
			var asset:AssetStack = addLayersToCreatureByType(type, animation, imposter);
			asset.movieClipStack.buttonMode = true;	
			var cp:CustomerPerson = new CustomerPerson(asset.movieClipStack, concertStage, boothManager, layerableOrder, imposter, 0.4);
			return cp;		
		}
		
		public function createCreatureAsset(type:String, animation:String, creatureType:String=null):AssetStack
		{
			var imposter:ImposterCreature = createImposterCreature(creatureType);
			var asset:AssetStack = addLayersToCreatureByType(type, animation, imposter);
			asset.movieClipStack.buttonMode = true;	
			return asset;
		}
				
		public function addLayersToCreatureByType(type:String, animation:String, imposter:ImposterCreature):AssetStack
		{
			var asset:AssetStack = new AssetStack(new MovieClip());		
			asset.creature = imposter;	
			asset.layerableOrder = layerableOrder;		
			if (type == "Concert Goer" || type == "Passerby")
			{	
				for each (var str:String in layerableOrder[animation])
				{					
					addLayerToCreature(str, imposter, asset);
				}	
			}				
			return asset;		
		}
		
		private function isLayerableType(layerable:Layerable, layerName:String, index:int, arr:Array):Boolean 
		{
            return (layerable.layer_name == layerName);
        }		
		
	}
}