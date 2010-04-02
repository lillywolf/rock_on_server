package controllers
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import models.Layerable;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;

	public class LayerableManager extends Manager
	{
		public var _layerables:ArrayCollection;
		public var _owned_layerables:ArrayCollection;
		
		public static const EYE_SCALE:Number = 1;
		public static const INSTRUMENT_SCALE:Number = 0.4;
		public static const BODY_SCALE:Number = 0.5;
		
		public function LayerableManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
			_layerables = essentialModelManager.layerables;
			_owned_layerables = essentialModelManager.owned_layerables;
		}
		
		public function getMovieClipCopy(layerable:Layerable, formatted:Boolean=false, dimensionX:int=100, dimensionY:int=100):UIComponent
		{
			var className:String = flash.utils.getQualifiedClassName(layerable.mc);
			var klass:Class = essentialModelManager.essentialModelReference.loadedModels[className].klass;
			var copy:MovieClip = new klass() as MovieClip;
			if (formatted)
			{
				var uic:UIComponent = formatMovieClipByDimensions(copy, dimensionX, dimensionY);
			}
			return uic;
		}
		
		public function load(params:Object):void
		{

		}
		
		public function instantiate(params:Object, loadedClass:Class):void
		{
			if (loadedClass)
			{
				var layerable:Layerable = new Layerable(params, loadedClass);
				add(layerable);
			}
		}
		
		public function add(layerable:Layerable):void
		{
			_layerables.addItem(layerable);
		}		
		
		public function remove(layerable:Layerable):void
		{
			var i:int = _layerables.getItemIndex(layerable);
			_layerables.removeItemAt(i);
		}
		
		public function set owned_layerables(val:ArrayCollection):void
		{
			_owned_layerables = val;
		}
		
		public function get owned_layerables():ArrayCollection
		{
			return _owned_layerables;
		}
		
		public function formatMovieClipByDimensions(mc:MovieClip, dimensionX:int, dimensionY:int):UIComponent
		{
			var ratio:Number = mc.width/mc.height;
			var uic:UIComponent = new UIComponent();
			uic.width = dimensionX;
			uic.height = dimensionY;
			mc.stop();
			var rect:Rectangle;
			
			if (mc.width > mc.height)
			{
				mc.width = dimensionX;
				mc.height = dimensionX * 1/ratio;
				rect = mc.getBounds(uic);
			}
			else 
			{
				mc.height = dimensionY;
				mc.width = dimensionY * ratio;
				rect = mc.getBounds(uic);	
			}
			mc.y = -(rect.top) + (dimensionY - mc.height)/2; 							
			mc.x = -(rect.left) + (dimensionX - mc.width)/2;			
			uic.addChild(mc);
			return uic;
		}
		
	}
}