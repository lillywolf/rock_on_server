package models
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import world.AssetStack;

	public class Creature extends EssentialModel
	{
		public var _id:int;
		public var _type:String;
		public var _owned_layerables:ArrayCollection;
		public var layerableOrder:Array;
		
		public function Creature(params:Object, target:IEventDispatcher=null)
		{
			super(null, target);
			
			_owned_layerables = new ArrayCollection();
			
			setPropertiesFromParams(params);
			initializeLayerableOrder();
		}
		
		private function setPropertiesFromParams(params:Object):void
		{
			_id = params.id;
			if (params.creature_type)
			{
				_type = params.creature_type;
			}			
		}
		
		public function initializeLayerableOrder():void
		{
			layerableOrder = new Array();
			layerableOrder['walk_toward'] = ['body', 'eyes', 'instrument'];
			layerableOrder['walk_away'] = ['instrument', 'eyes', 'body'];
			layerableOrder['stand_still_toward'] = ['body', 'eyes', 'instrument'];
			layerableOrder['stand_still_away'] = ['instrument', 'eyes', 'body'];
		}
		
		public function getConstructedCreature(animation:String, sizeX:Number, sizeY:Number):AssetStack
		{
//			var movieClipStack:MovieClip = new MovieClip();
			var constructedCreature:AssetStack = new AssetStack(new MovieClip());
			for each (var str:String in layerableOrder[animation])
			{
				for each (var ol:OwnedLayerable in owned_layerables)
				{
					if (ol.layerable.layer_name == str && ol.in_use)
					{
						var mc:MovieClip = new MovieClip();
						mc = ol.layerable.mc;
						mc.scaleX = sizeX;
						mc.scaleY = sizeY;
						mc.name = ol.layerable.layer_name;
						constructedCreature.movieClipStack.addChild(mc);
					}
				}
			}
			constructedCreature.movieClipStack.buttonMode = true;
//			var hitSprite:Sprite = new Sprite();
//			hitSprite.width = movieClipStack.width;
//			hitSprite.height = movieClipStack.height;
//			movieClipStack.hitArea = hitSprite;
//			trace(movieClipStack.hitArea);	
			constructedCreature.creature = this;
			constructedCreature.layerableOrder = layerableOrder;
			return constructedCreature;
		}	
		
		private function onMouseDown(evt:MouseEvent):void
		{
			
		}
		
		private function onMouseClick(evt:MouseEvent):void
		{
			
		}
		
		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set type(val:String):void
		{
			_type = val;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function set owned_layerables(val:ArrayCollection):void
		{
			_owned_layerables = val;
		}
		
		public function get owned_layerables():ArrayCollection
		{
			return _owned_layerables;
		}
				
	}
}