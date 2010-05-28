package world
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import models.Creature;
	import models.EssentialModelReference;
	import models.OwnedLayerable;

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
			var newMc:MovieClip = EssentialModelReference.getMovieClipCopy(ol.layerable.mc);
			var oldMc:MovieClip = getMovieClipByLayerName(ol.layerable.layer_name, animation);
			if (oldMc)
			{
				movieClipStack.addChild(newMc);			
				movieClipStack.swapChildren(oldMc, newMc);		
				movieClipStack.removeChild(oldMc);				
			}
			else
			{
				var index:int = getLayerableIndex(ol, animation);
				movieClipStack.addChildAt(newMc, index);				
			}
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
				
		public function getMovieClipByLayerName(layerName:String, animation:String):MovieClip
		{
			var totalOwnedLayerables:int = _creature.owned_layerables.length.valueOf();			
			var movieClipChildren:int = _movieClipStack.numChildren.valueOf();
			var className:String = null;
			
			for (var i:int = 0; i < totalOwnedLayerables; i++)
			{
				if (layerName == (_creature.owned_layerables.getItemAt(i) as OwnedLayerable).layerable.layer_name && (_creature.owned_layerables.getItemAt(i) as OwnedLayerable).in_use)
				{
					var ol:OwnedLayerable = _creature.owned_layerables.getItemAt(i) as OwnedLayerable;
					className = flash.utils.getQualifiedClassName(ol.layerable.mc);
				}
			}
			
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
		
		private function onMovieClipStackClicked(evt:MouseEvent):void
		{
			trace(evt.target.name, flash.utils.getQualifiedClassName(evt.target));		
		}
		
		public function stand(frameNumber:int, animationType:String):void
		{
			var movieClipChildren:int = _movieClipStack.numChildren.valueOf();
			doAnimation(animationType, frameNumber);		
		}
		
		public function doAnimation(animationType:String, frameNumber:int=0):void
		{
			if (_layerableOrder[animationType])
			{
				var totalChildren:int = (_layerableOrder[animationType] as Array).length;
				var totalOwnedLayerables:int = _creature.owned_layerables.length.valueOf();
				var newStack:MovieClip = new MovieClip();
				
				var movieClipChildren:int = _movieClipStack.numChildren.valueOf();
				for (var l:int = 0; l < movieClipChildren; l++)
				{
					_movieClipStack.removeChildAt(0);									
				}
				
				for (var i:int = 0; i < totalChildren; i++)
				{
					for (var j:int = 0; j < totalOwnedLayerables; j++)
					{
						var layerName:String = (_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.layer_name;
						var className:String = flash.utils.getQualifiedClassName((_creature.owned_layerables.getItemAt(j) as OwnedLayerable).layerable.mc);		
						var klass:Class = EssentialModelReference.getClassCopy(className);
						var mc:MovieClip = new klass() as MovieClip;
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
						newMc.gotoAndPlay(animationType);								
					}
					else
					{
						newMc.gotoAndPlay(frameNumber);
						newMc.stop();
					}
				}
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