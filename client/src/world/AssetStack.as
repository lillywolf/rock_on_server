package world
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import helpers.CreatureEvent;
	
	import models.Creature;
	import models.EssentialModelReference;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	public class AssetStack extends ActiveAsset
	{
		[Bindable] public var _movieClips:ArrayCollection;
		[Bindable] public var _savedMovieClips:ArrayCollection;
		public var orientation:Number;
		public var _layerableOrder:Array;
		public var _creature:Creature;
		
		public function AssetStack(movieClips:ArrayCollection=null, layerableOrder:Array=null, source:Array=null)
		{
			super();
			_savedMovieClips = new ArrayCollection();
			
			if (movieClips)
			{
				_movieClips = movieClips;
				addNewChildMovieClips();
				_movieClips.addEventListener(CollectionEvent.COLLECTION_CHANGE, onMovieClipsCollectionChanged);
//				_movieClipStack.addEventListener(MouseEvent.CLICK, onMovieClipStackClicked);
			}
			
			if (layerableOrder)
			{
				_layerableOrder = layerableOrder;
			}	
			
//			_movieClipStack = new MovieClip();
//			_movieClipStack = movieClipStack;
//			_movieClipStack.x = 0;
//			_movieClipStack.y = 0;
//			_movieClipStack.addEventListener(MouseEvent.MOUSE_MOVE, onMovieClipStackHover);
//			this.addChild(_movieClipStack);
			
		}	
				
		public function set movieClips(val:ArrayCollection):void
		{
//			if (_movieClipStack in this)
//			{
//				this.removeChild(_movieClipStack);
			removeOldChildMovieClips();
			_movieClips = val;
			addNewChildMovieClips();
			_movieClips.addEventListener(CollectionEvent.COLLECTION_CHANGE, onMovieClipsCollectionChanged);
//				_movieClipStack.addEventListener(MouseEvent.CLICK, onMovieClipStackClicked);
//				this.addChild(_movieClipStack);
//			}
//			else
//			{
//				_movieClipStack = val;
//				this.addChild(_movieClipStack);
//			}
		}
		
		public function removeAllOldChildMovieClips():void
		{
			for each (var mc:MovieClip in _movieClips)
			{
				var index:int = _movieClips.getItemIndex(mc);
				_movieClips.removeItemAt(index);
				
				if (!_savedMovieClips.contains(mc))
				{
					_savedMovieClips.addItem(mc);				
				}
			}
		}
		
		public function hasSavedMovieClip(className:String):MovieClip
		{
			for each (var mc:MovieClip in _savedMovieClips)
			{
				if (getQualifiedClassName(mc) == className)
				{
					return mc;
				}
			}
			return null;
		}
		
		public function removeOldChildMovieClips():void
		{
			for each (var mc:MovieClip in _movieClips)
			{
				if (this.contains(mc))
				{
					removeChild(mc);
				}
			}			
		}
		 
		public function addNewChildMovieClips():void
		{			
			for each (var mc:MovieClip in _movieClips)
			{
				addChild(mc);
			}
		}
		
		public function onMovieClipsCollectionChanged(evt:CollectionEvent):void
		{
			if (evt.kind == CollectionEventKind.ADD)
			{
				for each (var item:DisplayObject in evt.items)
				{
					if (!this.contains(item))
					{
						addChild(item);								
					}
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
		
		public function swapMovieClipsByOwnedLayerable(ol:OwnedLayerable, animation:String):void
		{
			var newOl:OwnedLayerable = getOwnedLayerableMatch(ol);
			var newMc:MovieClip = EssentialModelReference.getMovieClipCopy(ol.layerable.mc);
			var oldOl:OwnedLayerable = getOwnedLayerableByLayerName(ol.layerable.layer_name, animation);
			var index:int;
			if (oldOl)
			{
				var oldMc:MovieClip = getMovieClipByOwnedLayerable(oldOl);
				index = _movieClips.getItemIndex(oldMc);
				_movieClips.setItemAt(newMc, index);	
				oldOl.in_use = false;			
			}
			else
			{
				index = getLayerableIndex(ol, animation);
				_movieClips.setItemAt(newMc, index);				
			}
			newOl.in_use = true;
			doAnimation(oldMc.scaleX, currentAnimation, currentFrameNumber);	
		}
		
		public function getOwnedLayerableMatch(olMatch:OwnedLayerable):OwnedLayerable
		{
			for each (var ol:OwnedLayerable in creature.owned_layerables)
			{
				if (ol.id == olMatch.id)
				{
					return ol;
				}
			}
			return null;
		}
		
		public function getLayerableIndex(ol:OwnedLayerable, animation:String):int
		{
			var i:int = 0;
			for each (var str:String in layerableOrder[animation])
			{
				if (str == ol.layerable.layer_name)
				{
					var index:int = i; 
					break;
				}
				for each (var tempOl:OwnedLayerable in creature.owned_layerables)
				{
					if (tempOl.layerable.layer_name == str)
					{
						i++;				
					}
				}
			}
			return index;
		}	
		
		public function getOwnedLayerableByLayerName(layerName:String, animation:String):OwnedLayerable
		{
			var totalOwnedLayerables:int = _creature.owned_layerables.length.valueOf();			
			
			for (var i:int = 0; i < totalOwnedLayerables; i++)
			{
				if (layerName == (_creature.owned_layerables.getItemAt(i) as OwnedLayerable).layerable.layer_name && (_creature.owned_layerables.getItemAt(i) as OwnedLayerable).in_use)
				{
					var ol:OwnedLayerable = _creature.owned_layerables.getItemAt(i) as OwnedLayerable;
				}
			}	
			return ol;		
		}	
		
		public function getMovieClipByOwnedLayerable(ol:OwnedLayerable):MovieClip
		{
			var className:String = flash.utils.getQualifiedClassName(ol.layerable.mc);
			for each (var mc:MovieClip in _movieClips)
			{			
				var tempName:String = flash.utils.getQualifiedClassName(mc);
				if (tempName == className)
				{
					return mc;
				}
			}
			return null;			
		}
				
		public function getMovieClipByLayerName(layerName:String, animation:String):MovieClip
		{
			var ol:OwnedLayerable = getOwnedLayerableByLayerName(layerName, animation);
			var mc:MovieClip = getMovieClipByOwnedLayerable(ol);
			return mc;
		}
		
		private function onMovieClipStackClicked(evt:MouseEvent):void
		{
			trace(evt.target.name, flash.utils.getQualifiedClassName(evt.target));	
			var event:CreatureEvent = new CreatureEvent(CreatureEvent.CREATURE_CLICKED, evt.currentTarget.parent as AssetStack, true, true);
			FlexGlobals.topLevelApplication.bottomBarView.dispatchEvent(event);
		}
		
		private function onMovieClipStackHover(evt:MouseEvent):void
		{
			trace("hovered");
			trace(evt.target.name, flash.utils.getQualifiedClassName(evt.target));	
			var event:CreatureEvent = new CreatureEvent(CreatureEvent.CREATURE_HOVER, evt.currentTarget.parent as AssetStack, true, true);
//			var cursorClip:MovieClip = FlexGlobals.topLevelApplication.wbi.checkCreatureHover(this);		
//			FlexGlobals.topLevelApplication.wbi.handleCursorClip(cursorClip);
		}
		
		public function stand(scale:Number, frameNumber:int, animationType:String):void
		{
			doAnimation(scale, animationType, frameNumber);
		}	
		
		public function doFakeAnimation(animationType:String, frameNumber:int=0):void
		{
			currentAnimation = animationType;
			currentFrameNumber = frameNumber;
			if (_layerableOrder[animationType])
			{
//				getNewStack();
			}
		}
		
		public function doAnimation(scale:Number, animationType:String, frameNumber:int=0):void
		{
			currentAnimation = animationType;
			currentFrameNumber = frameNumber;
			
			for each (var mc:MovieClip in _movieClips)
			{
				mc.stop();
			}
			
//			if (_layerableOrder[animationType])
//			{
//				var totalChildren:int = (_layerableOrder[animationType] as Array).length;
//				var totalOwnedLayerables:int = _creature.owned_layerables.length.valueOf();
//				removeAllOldChildMovieClips();
//				for (var i:int = 0; i < totalChildren; i++)
//				{
//					for (var j:int = 0; j < totalOwnedLayerables; j++)
//					{
//						var layerName:String = (_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.layer_name;
//						var className:String = getQualifiedClassName((_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.mc);
//						var newMc:MovieClip = hasSavedMovieClip(className);
//						
//						if (!newMc)
//						{
//							newMc = EssentialModelReference.getMovieClipCopy((_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.mc);						
//						}						
//						newMc.scaleX = scale;
//						newMc.scaleY = Math.abs(scale);
//						if (frameNumber == 0)
//						{
//							newMc.gotoAndPlay(animationType);
//						}
//						else
//						{
//							newMc.gotoAndStop(frameNumber);
//						}
//						_movieClips.addItem(newMc);
//					}
//				}
//						if (layerName == _layerableOrder[animationType][i] && (_creature.owned_layerables.getItemAt(j) as OwnedLayerable).in_use)
//						{
//							newStack.addChild(mc);
//						}
//				var newChildren:int = newStack.numChildren.valueOf();
//				
//				for (var k:int = 0; k < newChildren; k++)
//				{
//					var newMc:MovieClip = newStack.getChildAt(0) as MovieClip;
//				var newStack:MovieClip = new MovieClip();
//				
//				var movieClipChildren:int = _movieClipStack.numChildren.valueOf();
//				var limit:int = movieClipChildren;
//				for (var l:int = 0; l < limit; l++)
//				{
//					var mcChild:MovieClip = _movieClipStack.getChildAt(0) as MovieClip;
//					var mcClass:String = getQualifiedClassName(mcChild);
////					trace(mcClass);
//					_movieClipStack.removeChildAt(0);
//					mcChild = null;
//					movieClipChildren = _movieClipStack.numChildren.valueOf();
////					trace(movieClipChildren.toString());
//				}
//				
//					_movieClipStack.addChildAt(newMc, k);
//					if (frameNumber == 0)
//					{
//						newMc.cacheAsBitmap = true;
//						newMc.gotoAndPlay(animationType);
//					}
//					else
//					{
//						newMc.cacheAsBitmap = true;
//						newMc.gotoAndStop(frameNumber);
//					}
//				}	
//			}
		}
		
		public function scaleMovieClips(scaleX:Number=0, scaleY:Number=0):void
		{
			for each (var mc:MovieClip in _movieClips)
			{
				if (scaleX != 0)
				{
					mc.scaleX = scaleX;				
				}
				if (scaleY != 0)
				{
					mc.scaleY = scaleY;				
				}
			}
		}
		
		public function getMovieClipStackCopy(animation:String, frameNumber:int):ArrayCollection
		{
			var totalChildren:int = (_layerableOrder[animation] as Array).length;
			var totalOwnedLayerables:int = _creature.owned_layerables.length.valueOf();
			var newMovieClips:ArrayCollection = new ArrayCollection();
			
			for each (var mc:MovieClip in _movieClips)
			{
				var newMc:MovieClip = EssentialModelReference.getMovieClipCopy(mc);
				newMovieClips.addItem(newMc);
			}
			
			return newMovieClips;
//			
//			for (var i:int = 0; i < totalChildren; i++)
//			{
//				for (var j:int = 0; j < totalOwnedLayerables; j++)
//				{
//					var layerName:String = (_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.layer_name;
//					var mc:MovieClip = EssentialModelReference.getMovieClipCopy((_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.mc);
//					if (layerName == _layerableOrder[animation][i] && (_creature.owned_layerables.getItemAt(j) as OwnedLayerable).in_use)
//					{
//						newStack.addChild(mc);
//					}
//				}
//			}
//			var updatedStack:MovieClip = animateChildMovieClips(newStack, animation, frameNumber);
//			return updatedStack;					
		}
		
		public function animateChildMovieClips(stack:MovieClip, animation:String, frameNumber:int):MovieClip
		{
			var newStack:MovieClip = new MovieClip();
			var numKids:int = stack.numChildren.valueOf();
			for (var k:int = 0; k < numKids; k++)
			{
				var newMc:MovieClip = stack.getChildAt(0) as MovieClip;
				newStack.addChildAt(newMc, k);
				if (frameNumber == 0)
				{
					newMc.gotoAndPlay(animation);								
				}
				else
				{
//					newMc.gotoAndPlay(animation);
					newMc.gotoAndStop(frameNumber);
				}
			}
			return newStack;
		}
		
		public function set layerableOrder(val:Array):void
		{
			_layerableOrder = val;
		}
		
		public function get layerableOrder():Array
		{
			return _layerableOrder;
		}
		
		public function get movieClips():ArrayCollection
		{
			return _movieClips;
		}
		
		public function set creature(val:Creature):void
		{
			_creature = val;
		}
		
		public function get creature():Creature
		{
			return _creature;
		}
		
	}
}