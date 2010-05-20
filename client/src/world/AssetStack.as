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
		
		private function onMovieClipStackClicked(evt:MouseEvent):void
		{
			trace(evt.target.name, flash.utils.getQualifiedClassName(evt.target));		
		}
		
		public function stand(frameNumber:int, animationType:String):void
		{
			var movieClipChildren:int = _movieClipStack.numChildren.valueOf();
			doAnimation(animationType, frameNumber);
//			for (var i:int = 0; i < movieClipChildren; i++)
//			{
//				var mc:MovieClip = _movieClipStack.getChildAt(i) as MovieClip;
//				mc.gotoAndPlay(frameNumber);
//				mc.stop();									
//			}			
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