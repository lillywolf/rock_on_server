package controllers
{
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import models.EssentialModelReference;
	import models.OwnedStructure;
	import models.Thinger;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	
	import server.ServerController;
	
	import world.ActiveAsset;
	import world.Point3D;

	public class ThingerController extends Controller
	{
		public var thingers:ArrayCollection;
		public var _serverController:ServerController;
		
		public function ThingerController(essentialModelController:EssentialModelController, target:IEventDispatcher=null)
		{
			super(essentialModelController, target);
			thingers = new ArrayCollection();
		}
		
		public function getMovieClipCopy(thinger:Object, formatted:Boolean=false, dimensionX:int=100, dimensionY:int=100, containerWidth:int=100, containerHeight:int=100):UIComponent
		{
			var copy:MovieClip = EssentialModelReference.getMovieClipCopy(thinger.mc);
			var uic:UIComponent = new UIComponent();
			if (formatted)
			{
				uic = formatMovieClipByDimensions(copy, dimensionX, dimensionY, containerWidth, containerHeight);
			}
			else 
			{
				uic.addChild(copy);
			}
			return uic;
		}		
		
		public function formatMovieClipByDimensions(mc:MovieClip, dimensionX:int, dimensionY:int, containerWidth:int, containerHeight:int):UIComponent
		{
			var ratio:Number = mc.width/mc.height;
			var uic:UIComponent = new UIComponent();
			uic.width = containerWidth;
			uic.height = containerHeight;
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
			mc.y = -(rect.top) + (containerHeight - mc.height)/2; 							
			mc.x = -(rect.left) + (containerWidth - mc.width)/2;			
			uic.addChild(mc);
			return uic;
		}		
		
		public function saveStructurePlacement(asset:ActiveAsset, pointToSave:Point3D):void
		{
			var ownedStructure:OwnedStructure = asset.thinger as OwnedStructure;
			_serverController.sendRequest({id: ownedStructure.id, x: pointToSave.x, y: pointToSave.y, z: pointToSave.z}, 'owned_structure', 'save_placement');
		}
		
		public function instantiate(params:Object, loadedClass:Class):void
		{
			var thinger:Thinger = new Thinger(params, loadedClass);
			add(thinger);
		}
		
		public function load(params:Object):void
		{

		}
		
		public function add(thinger:Thinger):void
		{
			thingers.addItem(thinger);
		}
		
		public function remove(thinger:Thinger):void
		{
			var i:int = thingers.getItemIndex(thinger);
			thingers.removeItemAt(i);
		}
		
		public function set serverController(val:ServerController):void
		{
			_serverController = val;
		}		
		
	}
}