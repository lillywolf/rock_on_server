package helpers
{
	import controllers.LayerableManager;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import models.Creature;
	import models.EssentialModelReference;
	import models.Layerable;
	import models.OwnedLayerable;
	
	import rock_on.BoothManager;
	import rock_on.ConcertStage;
	import rock_on.CustomerPerson;
	
	import world.AssetStack;

	public class CreatureGenerator extends EventDispatcher
	{
		public var layerableOrder:Array;
		public var _layerableManager:LayerableManager;
		public var _boothManager:BoothManager;
		public var _concertStage:ConcertStage;
		public var sortedLayerables:Dictionary;
		public static const GENERIC_X:Number = 1;
		public static const GENERIC_Y:Number = 1;
		
		public function CreatureGenerator(layerableManager:LayerableManager, boothManager:BoothManager, concertStage:ConcertStage, target:IEventDispatcher=null)
		{
			super(target);
			_layerableManager = layerableManager;
			_boothManager = boothManager;
			_concertStage = concertStage;
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
		
		public function createCustomer(type:String, animation:String):CustomerPerson
		{
			if (type == "generic")
			{
				var constructedCreature:AssetStack = new AssetStack(new MovieClip());
				var creature:Creature = new Creature({id: -1});
				
				for each (var str:String in layerableOrder[animation])
				{
					var layerableIndex:int = Math.floor(Math.random()*(sortedLayerables[str] as Array).length);
					
					var mc:MovieClip = new MovieClip();
					var layerable:Layerable = sortedLayerables[str][layerableIndex] as Layerable;
					var ol:OwnedLayerable = new OwnedLayerable({id: -1, layerable_id: layerable.id, creature_id: creature.id, in_use: true});
					ol.layerable = layerable;
					creature.owned_layerables.addItem(ol);
					
					var klass:Class = EssentialModelReference.getClassCopy(flash.utils.getQualifiedClassName(layerable.mc));
					mc = new klass() as MovieClip;
					mc.scaleX = GENERIC_X;
					mc.scaleY = GENERIC_Y;
					constructedCreature.movieClipStack.addChild(mc);
				}	
			}
			constructedCreature.movieClipStack.buttonMode = true;	
			var cp:CustomerPerson = new CustomerPerson(constructedCreature.movieClipStack, _concertStage, _boothManager, layerableOrder, creature, 0.4);
			return cp;		
		}		
		
		private function isLayerableType(layerable:Layerable, layerName:String, index:int, arr:Array):Boolean 
		{
            return (layerable.layer_name == layerName);
        }		
		
	}
}