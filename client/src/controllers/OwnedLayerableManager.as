package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.Layerable;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;

	public class OwnedLayerableManager extends Manager
	{
		public var owned_layerables:ArrayCollection;
		public function OwnedLayerableManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
			essentialModelManager.addEventListener(EssentialEvent.INSTANCE_LOADED, onInstanceLoaded);
			owned_layerables = new ArrayCollection();
		}
		
		public function instantiate(params:Object):void
		{
			var ownedLayerable:OwnedLayerable = new OwnedLayerable(params['layerable_id']);
			add(ownedLayerable);
		}
		
		public function onInstanceLoaded(evt:EssentialEvent):void
		{
			if (evt.instance is Layerable)
			{
//				setLayerableForOwnedLayerable(evt.instance as Layerable);						
			}
		}
		
//		public function setLayerableForOwnedLayerable(layerable:Layerable):void
//		{
//			for each (var ownedLayerable:OwnedLayerable in _essentialModelManager.owned_layerables)
//			{
//				if (ownedLayerable.layerable_id == layerable.id)
//				{
//					ownedLayerable.layerable = layerable;
//				}
//			}
//		}
		
		public function add(ownedLayerable:OwnedLayerable):void
		{
			owned_layerables.addItem(ownedLayerable);
		}
		
	}
}