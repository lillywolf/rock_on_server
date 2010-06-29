package world
{
	import flash.display.Bitmap;
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

	public class AssetStack extends ActiveAsset
	{
		[Bindable] public var _movieClipStack:MovieClip;
		public var _layerableOrder:Array;
		public var _creature:Creature;
		
		public function AssetStack(movieClipStack:MovieClip, layerableOrder:Array=null, source:Array=null)
		{
			super(movieClipStack);
			_movieClipStack = new MovieClip();
			_movieClipStack = movieClipStack;
			_movieClipStack.x = 0;
			_movieClipStack.y = 0;
			_movieClipStack.addEventListener(MouseEvent.CLICK, onMovieClipStackClicked);
			_movieClipStack.addEventListener(MouseEvent.MOUSE_MOVE, onMovieClipStackHover);
//			this.addChild(_movieClipStack);
			
			if (layerableOrder)
			{
				_layerableOrder = layerableOrder;
			}	
		}	
		
		public function set movieClipStack(val:MovieClip):void
		{
			if (_movieClipStack in this)
			{
//				this.removeChild(_movieClipStack);
				_movieClipStack = val;
				_movieClipStack.addEventListener(MouseEvent.CLICK, onMovieClipStackClicked);
//				this.addChild(_movieClipStack);
			}
			else
			{
				_movieClipStack = val;
//				this.addChild(_movieClipStack);
			}
		}
		
		public function swapMovieClipsByOwnedLayerable(ol:OwnedLayerable, animation:String):void
		{
			var newOl:OwnedLayerable = getOwnedLayerableMatch(ol);
			var newMc:MovieClip = EssentialModelReference.getMovieClipCopy(ol.layerable.mc);
			var oldOl:OwnedLayerable = getOwnedLayerableByLayerName(ol.layerable.layer_name, animation);
			if (oldOl)
			{
				var oldMc:MovieClip = getMovieClipByOwnedLayerable(oldOl);
				movieClipStack.addChild(newMc);			
				movieClipStack.swapChildren(oldMc, newMc);		
				movieClipStack.removeChild(oldMc);
				oldOl.in_use = false;			
			}
			else
			{
				var index:int = getLayerableIndex(ol, animation);
				movieClipStack.addChildAt(newMc, index);				
			}
			newOl.in_use = true;
			doAnimation(currentAnimation, currentFrameNumber);	
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
			var movieClipChildren:int = _movieClipStack.numChildren.valueOf();
			for (var j:int = 0; j < movieClipChildren; j++)
			{			
				var tempName:String = flash.utils.getQualifiedClassName(_movieClipStack.getChildAt(j));
				if (tempName == className)
				{
					return _movieClipStack.getChildAt(j) as MovieClip;
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
			trace(evt.target.name, flash.utils.getQualifiedClassName(evt.target));	
			var event:CreatureEvent = new CreatureEvent(CreatureEvent.CREATURE_HOVER, evt.currentTarget.parent as AssetStack, true, true);
//			var cursorClip:MovieClip = FlexGlobals.topLevelApplication.wbi.checkCreatureHover(this);		
//			FlexGlobals.topLevelApplication.wbi.handleCursorClip(cursorClip);
		}
		
		public function stand(frameNumber:int, animationType:String):void
		{
			var movieClipChildren:int = _movieClipStack.numChildren.valueOf();
			doAnimation(animationType, frameNumber);
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
		
		public function doAnimation(animationType:String, frameNumber:int=0):void
		{
			currentAnimation = animationType;
			currentFrameNumber = frameNumber;
			if (_layerableOrder[animationType])
			{
				var totalChildren:int = (_layerableOrder[animationType] as Array).length;
				var totalOwnedLayerables:int = _creature.owned_layerables.length.valueOf();
				var newStack:MovieClip = new MovieClip();
				
				var movieClipChildren:int = _movieClipStack.numChildren.valueOf();
				var limit:int = movieClipChildren;
				for (var l:int = 0; l < limit; l++)
				{
					var mcChild:MovieClip = _movieClipStack.getChildAt(0) as MovieClip;
					var mcClass:String = getQualifiedClassName(mcChild);
//					trace(mcClass);
					_movieClipStack.removeChildAt(0);
					mcChild = null;
					movieClipChildren = _movieClipStack.numChildren.valueOf();
//					trace(movieClipChildren.toString());
				}
				
				for (var i:int = 0; i < totalChildren; i++)
				{
					for (var j:int = 0; j < totalOwnedLayerables; j++)
					{
						var layerName:String = (_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.layer_name;
						var mc:MovieClip = EssentialModelReference.getMovieClipCopy((_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.mc);
						if (layerName == _layerableOrder[animationType][i] && (_creature.owned_layerables.getItemAt(j) as OwnedLayerable).in_use)
						{
							newStack.addChild(mc);
						}
					}
				}
				var newChildren:int = newStack.numChildren.valueOf();
				
				for (var k:int = 0; k < newChildren; k++)
				{
					var newMc:MovieClip = newStack.getChildAt(0) as MovieClip;
					_movieClipStack.addChildAt(newMc, k);
					if (frameNumber == 0)
					{
						newMc.cacheAsBitmap = false;
						newMc.gotoAndPlay(animationType);
					}
					else
					{
						newMc.cacheAsBitmap = true;
						newMc.gotoAndStop(frameNumber);
					}
				}				
			}
		}
		
		public function getMovieClipStackCopy(animation:String, frameNumber:int):MovieClip
		{
			var totalChildren:int = (_layerableOrder[animation] as Array).length;
			var totalOwnedLayerables:int = _creature.owned_layerables.length.valueOf();
			var newStack:MovieClip = new MovieClip();			
			var movieClipChildren:int = _movieClipStack.numChildren;
			
			for (var l:int = 0; l < movieClipChildren; l++)
			{
				var mcChild:MovieClip = _movieClipStack.getChildAt(0) as MovieClip;
				var mcClass:String = getQualifiedClassName(mcChild);
				movieClipChildren = _movieClipStack.numChildren;
			}
			
			for (var i:int = 0; i < totalChildren; i++)
			{
				for (var j:int = 0; j < totalOwnedLayerables; j++)
				{
					var layerName:String = (_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.layer_name;
					var mc:MovieClip = EssentialModelReference.getMovieClipCopy((_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.mc);
					if (layerName == _layerableOrder[animation][i] && (_creature.owned_layerables.getItemAt(j) as OwnedLayerable).in_use)
					{
						newStack.addChild(mc);
					}
				}
			}
			var updatedStack:MovieClip = animateChildMovieClips(newStack, animation, frameNumber);
			return updatedStack;					
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
					newMc.gotoAndPlay(animation);
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
		
		public function get movieClipStack():MovieClip
		{
			return _movieClipStack;
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