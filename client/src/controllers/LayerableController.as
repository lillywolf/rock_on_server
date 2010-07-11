package controllers
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import models.EssentialModelReference;
	import models.Layerable;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.DynamicEvent;
	
	import views.ContainerUIC;

	public class LayerableController extends Controller
	{
		public var _layerables:ArrayCollection;
		public var _owned_layerables:ArrayCollection;
		public var ownedLayerableMovieClipsLoaded:int;
		public var layerableMovieClipsLoaded:int;
		public var ownedLayerableReferencesUpdated:int;
		public var ownedLayerablesLoaded:int;
		public var layerablesLoaded:int;
		public var fullyLoaded:Boolean;
		
		public static const EYE_SCALE:Number = 1;
		public static const INSTRUMENT_SCALE:Number = 0.5;
		public static const BODY_SCALE:Number = 0.5;
		
		public function LayerableController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			_layerables = essentialModelController.layerables;
			_owned_layerables = essentialModelController.owned_layerables;
			_layerables.addEventListener(CollectionEvent.COLLECTION_CHANGE, onLayerablesCollectionChange);
			_owned_layerables.addEventListener(CollectionEvent.COLLECTION_CHANGE, onOwnedLayerablesCollectionChange);
			essentialModelController.addEventListener(EssentialEvent.INSTANCE_LOADED, onInstanceLoaded);
			essentialModelController.addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);			
			
			ownedLayerableMovieClipsLoaded = 0;
			ownedLayerablesLoaded = 0;
			layerablesLoaded = 0;
		}
		
		private function onOwnedLayerablesCollectionChange(evt:CollectionEvent):void
		{
//			(evt.items[0] as OwnedLayerable).addEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
			if ((evt.items[0] as OwnedLayerable).layerable == null)
			{
				(evt.items[0] as OwnedLayerable).addEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);						
			}
			else
			{
				ownedLayerableReferencesUpdated++;
				checkForLoadingComplete();
			}
		}

		private function onLayerablesCollectionChange(evt:CollectionEvent):void
		{
			if ((evt.items[0] as Layerable).mc == null)
			{
				(evt.items[0] as Layerable).addEventListener('movieClipLoaded', onLayerableMovieClipAssigned);			
			}
			else
			{
				layerableMovieClipsLoaded++;
				checkForLoadingComplete();
			}
		}
		
		private function onParentAssigned(evt:EssentialEvent):void
		{
			var ol:OwnedLayerable = evt.currentTarget as OwnedLayerable;
			ol.removeEventListener(EssentialEvent.PARENT_ASSIGNED, onParentAssigned);
			ownedLayerableReferencesUpdated++;
			
			if (ol.layerable.mc)
			{
				ownedLayerableMovieClipsLoaded++;
			}	
			
			checkForLoadingComplete();		
		}
		
		private function checkForLoadingComplete():void
		{
			if (_layerables.length == EssentialModelReference.numInstancesToLoad["layerable"] && _owned_layerables.length == EssentialModelReference.numInstancesToLoad["owned_layerable"])
			{
				for each (var l:Layerable in _layerables)
				{
					if (!l.mc)
					{
						return;
					}
				}
				for each (var ol:OwnedLayerable in _owned_layerables)
				{
					if (!ol.layerable)
					{
						return;
					}
				}
				essentialModelController.checkIfLoadingAndInstantiationComplete();	
			}			
		}
		
		private function onParentMovieClipAssigned(evt:DynamicEvent):void
		{
			(evt.target as OwnedLayerable).removeEventListener('parentMovieClipAssigned', onParentMovieClipAssigned);
			ownedLayerableMovieClipsLoaded++;
			
			checkForLoadingComplete();		
		}
		
		private function onLayerableMovieClipAssigned(evt:DynamicEvent):void
		{
			(evt.target as Layerable).removeEventListener("movieClipLoaded", onLayerableMovieClipAssigned);
			layerableMovieClipsLoaded++;
			checkForLoadingComplete();
		}
		
		private function onInstanceLoaded(evt:EssentialEvent):void
		{
			if (evt.instance is Layerable)
			{
				layerablesLoaded++;
			}
			else if (evt.instance is OwnedLayerable)
			{
				ownedLayerablesLoaded++;
			}
			essentialModelController.checkIfLoadingAndInstantiationComplete();
		}		
		
		public function getMovieClipCopy(layerable:Layerable, formatted:Boolean=false, dimensionX:int=100, dimensionY:int=100):UIComponent
		{
			var copy:MovieClip = EssentialModelReference.getMovieClipCopy(layerable.mc);
			if (formatted)
			{
				var uic:UIComponent = formatMovieClipByDimensions(copy, dimensionX, dimensionY, 0, 0);
			}
			return uic;
		}
		
		public function updateOwnedLayerableOnServerResponse(olCopy:OwnedLayerable, method:String):void
		{
			var olReference:OwnedLayerable;
			for each (var ol:OwnedLayerable in owned_layerables)
			{
				if (ol.id == olCopy.id)
				{
					olReference = ol;
				}
			}	
			olReference.updateProperties(olCopy);
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
		
		public function set layerables(val:ArrayCollection):void
		{
			_layerables = val;
		}
		
		public function get layerables():ArrayCollection
		{
			return _layerables;
		}
		
		public function set owned_layerables(val:ArrayCollection):void
		{
			_owned_layerables = val;
		}
		
		public function get owned_layerables():ArrayCollection
		{
			return _owned_layerables;
		}
		
		public static function formatMovieClipByDimensions(mc:MovieClip, dimensionX:int, dimensionY:int, itemPaddingX:int, itemPaddingY:int):ContainerUIC
		{
			var ratio:Number = mc.width/mc.height;
			var uic:ContainerUIC = new ContainerUIC();
			uic.width = dimensionX;
			uic.height = dimensionY;
			mc.stop();
			var toScale:Number;
			var rect:Rectangle;
			
			if (mc.width > mc.height)
			{
				toScale = dimensionX / mc.width;
			}
			else 
			{
				toScale = dimensionY / mc.height;
			}
			
			mc.scaleX = toScale;
			mc.scaleY = toScale;
			rect = mc.getBounds(uic);
			
			mc.y = -(rect.top) + (dimensionY - mc.height)/2; 							
			mc.x = -(rect.left) + (dimensionX - mc.width)/2;			
			uic.x = itemPaddingX;
			uic.y = itemPaddingY;
			uic.addChild(mc);
			return uic;
		}
		
	}
}