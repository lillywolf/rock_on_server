package models
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import world.AssetStack;
	import world.Point3D;

	public class Creature extends EssentialModel
	{
		public var _id:int;
		public var _user_id:int;
		public var _type:String;
		public var _owned_layerables:ArrayCollection;
		public var _additional_info:String;
		public var _name:String;
		public var location:Point3D;
		public var layerableOrder:Array;
		
		public function Creature(params:Object, target:IEventDispatcher=null)
		{
			super(null, target);
			
			_owned_layerables = new ArrayCollection();			
			setPropertiesFromParams(params);
			initializeLayerableOrder();
		}
		
		public function setPropertiesFromParams(params:Object):void
		{
			_id = params.id;
			_user_id = params.id;
			
			if (params.creature_type)
			{
				_type = params.creature_type;
			}		
			if (params.additional_info)
			{
				_additional_info = params.additional_info;				
			}	
			if (params.x != null)
			{
				location = new Point3D(params.x, 0, 0);
			}
			if (params.y != null)
			{
				location.y = params.y;
			}
			if (params.z != null)
			{
				location.z = params.z;
			}
			if (params.name)
			{
				_name = params.name;
			}
		}
		
		public function initializeLayerableOrder():void
		{
			layerableOrder = new Array();
			layerableOrder['walk_toward'] = ["body", "hair back", "eyes", "shoes", "bottom", "top", "hair front", "instrument"];
			layerableOrder['walk_away'] = ["instrument", "eyes", "body", "shoes", "bottom", "top", "hair front"];
			layerableOrder['stand_still_toward'] = ["body", "hair back", "eyes", "shoes", "bottom", "top", "hair front", "instrument"];
			layerableOrder['stand_still_away'] = ["instrument", "eyes", "body", "shoes", "bottom", "top", "hair front"];
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
		
		public function set additional_info(val:String):void
		{
			_additional_info = val;
		}
		
		public function get additional_info():String
		{
			return _additional_info;
		}
		
		public function set name(val:String):void
		{
			_name = val;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set user_id(val:int):void
		{
			_user_id = val;
		}
		
		public function get user_id():int
		{
			return _user_id;
		}
				
	}
}