package world
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import models.Creature;
	import models.EssentialModelReference;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	public class ActiveAssetStack extends ActiveAsset
	{
		public var _displayMovieClips:ArrayCollection;
		public var _allMovieClips:ArrayCollection;
		public var _animation:String;
		public var _frameNumber:int;
		public var _creature:Creature;
		public var _layerableOrder:Array;
		
		public function ActiveAssetStack(creature:Creature, movieClip:MovieClip=null, layerableOrder:Array=null, scale:Number=1)
		{
			super(movieClip);
			
			_creature = creature;
			_scale = scale;
			
			setMovieClips();
			setLayerableOrder(layerableOrder);
		}
		
		override public function switchToBitmap():void
		{
			var mc:Sprite = createMovieClipsForBitmap();
			bitmapData = new BitmapData(mc.width, mc.height, true, 0x000000);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, mc.width/2, mc.height);
			scaleMovieClip(mc);
			var rect:Rectangle = new Rectangle(0, 0, mc.width, mc.height);
			scaleMatrix(matrix);
			bitmapData.draw(mc, matrix, new ColorTransform(), null, rect);
			bitmap = new Bitmap(bitmapData);
			bitmap.x = -mc.width/2;
			bitmap.y = -mc.height;
			bitmap.opaqueBackground = null;
			clearMovieClips();
			addChild(bitmap);
		}
		
		public function createMovieClipsForBitmap():Sprite
		{
			var newClip:Sprite = new Sprite();
			for each (var mc:MovieClip in _displayMovieClips)
			{
				mc.scaleX = 1;
				mc.scaleY = 1;
				newClip.addChild(mc);
			}
			return newClip;
		}
		
		public function setLayerableOrder(layerableOrder:Array=null):void
		{
			if (!layerableOrder)
			{
				_layerableOrder = _creature.layerableOrder;
			}
			else
			{
				_layerableOrder = layerableOrder;			
			}			
		}
				
		public function set scale(val:Number):void
		{
			_scale = val;
		}
		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function changeScaleX(newScaleX:Number):void
		{
			for each (var mc:MovieClip in _displayMovieClips)
			{
				mc.scaleX = newScaleX;
			}
			if (newScaleX < 0)
			{
				reflected = true;
			}
		}
		
		public function set layerableOrder(val:Array):void
		{
			_layerableOrder = val;
		}
		
		public function get layerableOrder():Array
		{
			return _layerableOrder;
		}
		
		public function doAnimation(animation:String, move:Boolean=false, frameNumber:int=-1):void
		{
			_animation = animation;
			
			if (frameNumber != -1)
			{
				_frameNumber = frameNumber;			
			}
			
			clearMovieClips();
			
			if (!_layerableOrder[animation])
			{
				throw new Error("No order for this animation");
			}
			
			for each (var str:String in _layerableOrder[animation])
			{
				for each (var ol:OwnedLayerable in _creature.owned_layerables)
				{
					if (ol.layerable.layer_name == str && ol.in_use)
					{
						var className:String = getQualifiedClassName(ol.layerable.mc);
						var mc:MovieClip = getMovieClipFromClassName(className);
						animateMc(move, animation, frameNumber, mc);
						_displayMovieClips.addItem(mc);
					}
				}
			}
		}
		
		public function animateMc(move:Boolean, animation:String, frameNumber:int, mc:MovieClip):void
		{
			if (move)
			{
				mc.gotoAndPlay(animation);
			}
			else
			{
				mc.gotoAndStop(frameNumber);
			}
		}
		
		public function doInitialAnimation(animation:String):void
		{
			_animation = animation;
			
			for each (var str:String in _layerableOrder[animation])
			{
				for each (var ol:OwnedLayerable in _creature.owned_layerables)
				{
					if (ol.layerable.layer_name == str && ol.in_use)
					{
						var className:String = getQualifiedClassName(ol.layerable.mc);
						var mc:MovieClip = getMovieClipFromClassName(className);
						_displayMovieClips.addItem(mc);
					}
				}
			}			
		}	
		
		public function getMovieClipStackCopy(animation:String, frameNumber:int):ArrayCollection
		{
			var newMovieClips:ArrayCollection = new ArrayCollection();
			
			for each (var str:String in _layerableOrder[animation])
			{
				for each (var ol:OwnedLayerable in _creature.owned_layerables)
				{
					if (ol.layerable.layer_name == str)
					{
						var newMc:MovieClip = EssentialModelReference.getMovieClipCopy(ol.layerable.mc);
						newMc.gotoAndStop(frameNumber);
						newMovieClips.addItem(newMc);
					}
				}
			}
			return newMovieClips;
		}		
		
		public function clearMovieClips():void
		{
			_displayMovieClips.removeAll();
		}
		
		public function initializeMovieClips():void
		{
			for each (var mc:MovieClip in _displayMovieClips)
			{
				mc.scaleX = _scale;
				mc.scaleY = _scale;
				addChild(mc);
			}
		}
		
		public function getMovieClipFromClassName(className:String):MovieClip
		{
			for each (var mc:MovieClip in _allMovieClips)
			{
				if (getQualifiedClassName(mc) == className)
				{
					return mc;
				}
			}
			return null;
		}
		
		public function setMovieClips():void
		{
			_allMovieClips = new ArrayCollection();
			_displayMovieClips = new ArrayCollection();
			_displayMovieClips.addEventListener(CollectionEvent.COLLECTION_CHANGE, onDisplayMovieClipsCollectionChange);
			
			for each (var ol:OwnedLayerable in _creature.owned_layerables)
			{
				if (ol.in_use)
				{
					var mc:MovieClip = EssentialModelReference.getMovieClipCopy(ol.layerable.mc);
					mc.scaleX = _scale;
					mc.scaleY = _scale;
					_allMovieClips.addItem(mc);
				}
			}
		}
		
		private function onDisplayMovieClipsCollectionChange(evt:CollectionEvent):void
		{
			var item:DisplayObject;
			if (evt.kind == CollectionEventKind.ADD)
			{
				for each (item in evt.items)
				{				
					addChild(item);
				}
			}
			if (evt.kind == CollectionEventKind.REMOVE)
			{
				for each (item in evt.items)
				{
					if (this.contains(item))
					{
						removeChild(item);					
					}
				}
			}
		}
		
		public function set creature(val:Creature):void
		{
			_creature = val;
			setMovieClips();
		}
		
		public function get creature():Creature
		{
			return _creature;
		}
		
		public function set displayMovieClips(val:ArrayCollection):void
		{
			_displayMovieClips = val;
			initializeMovieClips();
			_displayMovieClips.addEventListener(CollectionEvent.COLLECTION_CHANGE, onDisplayMovieClipsCollectionChange);
		}
		
		public function get displayMovieClips():ArrayCollection
		{
			return _displayMovieClips;
		}
		
		public function set animation(val:String):void
		{
			_animation = val;
		}
		
		public function get animation():String
		{
			return _animation;
		}
		
		public function set frameNumber(val:int):void
		{
			_frameNumber = val;
		}
		
		public function get frameNumber():int
		{
			return _frameNumber;
		}
	}
}