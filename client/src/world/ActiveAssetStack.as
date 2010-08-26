package world
{
	import controllers.StructureController;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import models.Creature;
	import models.EssentialModelReference;
	import models.OwnedLayerable;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.DynamicEvent;
	
	import rock_on.CustomerPerson;
	
	import views.BouncyBitmap;
	import views.ExpandingMovieclip;
	
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
			
			this.cacheAsBitmap = true;
		}
		
		override public function switchToBitmap():void
		{
			var mc:Sprite = createMovieClipsForBitmap();
			removeCurrentChildren();
			
			if (mc)
			{
				scaleMovieClip(mc);
				addChild(mc);
				var mcBounds:Rectangle = mc.getBounds(this);
				removeChild(mc);
				var heightDiff:Number = getHeightDifferential(mcBounds);
				var widthDiff:Number = getWidthDifferential(mcBounds);
				bitmapData = new BitmapData(mc.width + 10, mc.height + 8, true, 0x000000);
				var matrix:Matrix = new Matrix(1, 0, 0, 1, mc.width + 10, heightDiff/_scale);
				var rect:Rectangle = new Rectangle(0, 0, mc.width + 10, mc.height + 8);
				scaleMatrix(matrix, mc.width + 10);
				bitmapData.draw(mc, matrix, new ColorTransform(), null, rect);
				bitmap = new Bitmap(bitmapData);
//				bitmap.x = -mc.width/2;
//				bitmap.y = -heightDiff;
				placeBitmap(bitmap, mc, heightDiff, mc.width + 10);
				bitmap.opaqueBackground = null;
				bitmap.cacheAsBitmap = true;
				addChild(bitmap);
			}
		}
		
		public function bitmapWithToppers():void
		{
			var mc:Sprite = createStaticMovieClipsForBitmap();
			removeCurrentChildren();
			
			if (mc)
			{
				var mcBounds:Rectangle = mc.getBounds(_world);
				var heightDiff:Number = Math.abs(mcBounds.top - this.y);
				var widthDiff:Number = getWidthDifferential(mcBounds);			
				scaleMovieClip(mc);
				bitmapData = new BitmapData(mc.width, mc.height, true, 0x000000);
				var matrix:Matrix = new Matrix(1, 0, 0, 1, widthDiff/2, heightDiff);
				var rect:Rectangle = new Rectangle(0, 0, mc.width, mc.height + Y_BITMAP_BUFFER);
				scaleMatrix(matrix, mc.width);
				bitmapData.draw(mc, matrix, new ColorTransform(), null, rect);
				bitmap = new Bitmap(bitmapData);
				bitmap.x = -mc.width/2;
				bitmap.y = -heightDiff * _scale;
				bitmap.opaqueBackground = null;
				addChild(bitmap);					
			}
		}		
		
		override public function placeBitmap(bitmap:Bitmap, mc:Sprite, heightDiff:Number, tx:Number = 0):void
		{
			bitmap.y = -heightDiff;
			bitmap.x = -mc.width/2;
		}
		
		public function createMovieClipsForBitmap():Sprite
		{
			var newClip:Sprite = new Sprite();
			for each (var mc:MovieClip in _displayMovieClips)
			{
				mc.scaleX = 1;
				mc.scaleY = 1;
				mc.cacheAsBitmap = true;
				newClip.addChild(mc);	
			}
			return newClip;
		}
		
		public function createStaticMovieClipsForBitmap():Sprite
		{
			var newClip:Sprite = new Sprite();
			for each (var mc:MovieClip in _displayMovieClips)
			{
				mc.scaleY = 1;
				mc.cacheAsBitmap = true;
				newClip.addChild(mc);	
				if (rotated && mc.framesLoaded > 1)
					mc.gotoAndStop(2);
				else
					mc.gotoAndStop(1);
				if (flipped)
					mc.scaleX = -1;
				else
					mc.scaleX = 1;
			}
			return newClip;			
		}
		
		public function setLayerableOrder(layerableOrder:Array=null):void
		{
			if (!layerableOrder)
			{
				if (_creature)
					_layerableOrder = _creature.layerableOrder;
			}
			else
			{
				_layerableOrder = layerableOrder;			
			}			
		}
		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function reset():void
		{
			clearMovieClips();
			removeCurrentChildren();
		}
		
		public function changeScale(newScaleX:Number, newScaleY:Number=1):void
		{
			for each (var mc:MovieClip in _displayMovieClips)
			{
				mc.scaleX = newScaleX;
				mc.scaleY = newScaleY;
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
		
		public function doAnimation(animation:String, move:Boolean=false, frameNumber:int=-1, loops:int=0):void
		{
			_animation = animation;
			
			if (frameNumber != -1)
			{
				_frameNumber = frameNumber;			
			}
			
			clearMovieClips();
			clearBitmap();
			
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
						mc.cacheAsBitmap = true;
						animateMc(move, animation, frameNumber, mc, loops);
						_displayMovieClips.addItem(mc);
					}
				}
			}
		}
		
		public function doBitmappedAnimation(mc:MovieClip):void
		{
			removeCurrentChildren();
			scaleMovieClip(mc);
//			addChild(mc);
			var mcBounds:Rectangle = mc.getBounds(this);
//			removeChild(mc);
			var heightDiff:Number = getHeightDifferential(mcBounds);
			var widthDiff:Number = getWidthDifferential(mcBounds);
			bitmapData = new BitmapData(mc.width + 10, mc.height + 8, true, 0x000000);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, mc.width + 10, heightDiff/_scale);
			var rect:Rectangle = new Rectangle(0, 0, mc.width + 10, mc.height + 8);
			scaleMatrix(matrix, mc.width + 10);
			bitmapData.draw(mc, matrix, new ColorTransform(), null, rect);
			bitmap = new Bitmap(bitmapData);
			placeBitmap(bitmap, mc, heightDiff, mc.width + 10);
			bitmap.opaqueBackground = null;
			addChild(bitmap);			
		}
		
		public function doComplexAnimation(complexAnimation:String, layeredAnimations:Object):void
		{			
			clearMovieClips();
			clearBitmap();
			
			if (!_layerableOrder[complexAnimation])
			{
				throw new Error("No order for this animation");
			}			
			
			for each (var str:String in _layerableOrder[complexAnimation])
			{
				if (!layeredAnimations[str])
				{
					throw new Error("no animation exists for this layer");
				}
				else
				{
					var layerAnimation:String = layeredAnimations[str];
					for each (var ol:OwnedLayerable in _creature.owned_layerables)
					{
						if (ol.layerable.layer_name == str && ol.in_use)
						{
							var className:String = getQualifiedClassName(ol.layerable.mc);
							var mc:MovieClip = getMovieClipFromClassName(className);
							animateMc(true, layerAnimation, -1, mc);
							_displayMovieClips.addItem(mc);
						}
					}
				}
			}	
			changeScale(_scale, _scale);
		}	
		
		public function animateMc(move:Boolean, animation:String, frameNumber:int, mc:MovieClip, loops:int=0):void
		{
			var hasLabel:Boolean = false;
			for (var i:int = 0; i < mc.currentLabels.length; i++)
			{
				if (mc.currentLabels[i].name == animation)
				{
					hasLabel = true;
				}
			}
			
			if (move && hasLabel)				
			{
//				if (loops != 0)
//				{
//					animateLoopedMc(mc, animation, loops);
//				}
//				else
//				{
					mc.gotoAndPlay(animation);				
//				}
			}
			else if (move && !hasLabel)
			{
				mc.gotoAndStop("stand_still_toward");
			}
			else
			{
				mc.gotoAndStop(animation);
			}
		}
		
		public function animateLoopedMc(mc:MovieClip, animation:String, loops:int):void
		{
			var loopCount:int = 0;
			for each (var label:FrameLabel in mc.currentLabels)
			{
				if (label.name == animation)
				{
					var frameNumber:int = label.frame;
				}
			}
			
			mc.addEventListener(Event.ENTER_FRAME, function onMovieClipEnterFrame():void
			{
				if (mc.currentFrame == frameNumber)
				{
					loopCount++;
					if (loopCount >= loops)
					{
						mc.stop();
						mc.removeEventListener(Event.ENTER_FRAME, onMovieClipEnterFrame);
						dispatchLoopCompleteEvent();
					}
				}
			});
			mc.cacheAsBitmap = true;
			mc.gotoAndPlay(animation);
		}
		
		private function dispatchLoopCompleteEvent():void
		{
			var evt:DynamicEvent = new DynamicEvent("loopComplete", true);
			this.dispatchEvent(evt);			
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
		
		public function clearBitmap():void
		{
			var totalChildren:int = this.numChildren.valueOf();
			for (var i:int = totalChildren; i > 0; i--)
			{
				if (this.numChildren > i-1)
				{
					if (this.getChildAt(i-1) == bitmap)
					{
						removeChild(bitmap);
					}
				}
			}
			bitmapData = null;
			bitmap = null;
		}
		
		public function clearMovieClips():void
		{
			if (_displayMovieClips && _displayMovieClips.length > 0)
			{
				_displayMovieClips.removeAll();			
			}
		}
		
		public function killEventListeners():void
		{
			_displayMovieClips.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onDisplayMovieClipsCollectionChange);			
		}
		
		public function cleanUpChildren():void
		{
			var totalChildren:int = this.numChildren.valueOf();
			for (var i:int = totalChildren; i > 0; i--)
			{
				var currentChildren:int = this.numChildren;
				var index:int = currentChildren - 1;
				var currentChild:Object = this.getChildAt(index);
				this.removeChildAt(index);					
				if (currentChild)
				{
					currentChild = null;
				}
			}			
		}
		
		public function removeCurrentChildren():void
		{
			var totalChildren:int = this.numChildren.valueOf();
			var skips:int = 0;
			for (var i:int = totalChildren; i > 0; i--)
			{
				var currentChildren:int = this.numChildren;
				var index:int = currentChildren - 1 - skips;
				if (!(this.getChildAt(index) is BouncyBitmap))
				{
					this.removeChildAt(index);					
				}
				else
				{
					skips++;
				}
			}
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
			if (_creature)
				setMovieClipsForCreature();
		}
		
		public function setMovieClipsForCreature():void
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

		public function setMovieClipsForStructure(toppers:ArrayCollection):void
		{
			_allMovieClips = new ArrayCollection();
			_displayMovieClips = new ArrayCollection();
			_displayMovieClips.addEventListener(CollectionEvent.COLLECTION_CHANGE, onDisplayMovieClipsCollectionChange);
			
			_allMovieClips.addItem(_movieClip);
			_displayMovieClips.addItem(_movieClip);
			for each (var os:OwnedStructure in toppers)
			{
				var mc:MovieClip = EssentialModelReference.getMovieClipCopy(os.structure.mc);
				_allMovieClips.addItem(mc);
				_displayMovieClips.addItem(mc);
				var offset:Point3D = new Point3D(os.x - (this.thinger as OwnedStructure).x, os.y, os.z - (this.thinger as OwnedStructure).z);
				var flatOffset:Point = World.worldToActualCoords(offset);
				mc.x = flatOffset.x;
				mc.y = flatOffset.y;
			}
		}
		
		private function onDisplayMovieClipsCollectionChange(evt:CollectionEvent):void
		{			
			for each (var item:DisplayObject in evt.items)
			{
				if (evt.kind == CollectionEventKind.ADD)
				{
					if (!(this.contains(item)))
					{
						addChild(item);					
					}
				}
				else if (evt.kind == CollectionEventKind.REMOVE)
				{
					if (this.contains(item))
					{
						this.removeChild(item);
					}
				}
			}
			
			if (evt.kind == CollectionEventKind.RESET)
			{
				var totalChildren:int = this.numChildren.valueOf();
				var skips:int = 0;
				for (var i:int = totalChildren; i > 0; i--)
				{
					var currentChildren:int = this.numChildren;
					var index:int = currentChildren - 1 - skips;
					if (this.getChildAt(index) is Sprite && !(this.getChildAt(index) is BouncyBitmap))
					{
						this.removeChildAt(index);					
					}
					else
					{
						skips++;
					}
				}
			}
		}
		
		public function addToppers(structureController:StructureController):void
		{
			var toppers:ArrayCollection = structureController.getStructureToppers(this.thinger as OwnedStructure);
		
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
		
		public function get allMovieClips():ArrayCollection
		{
			return _allMovieClips;
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