package rock_on
{
	import flash.events.IEventDispatcher;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;

	public class Booth extends OwnedStructure
	{
		public var queueCapacity:Number;
		public var currentQueue:Number;
		public var actualQueue:Number;
		public var proxiedQueue:ArrayCollection;
		public var hasCustomerEnRoute:Boolean;
		
		public function Booth(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			currentQueue = 0;	
			actualQueue = 0;
			proxiedQueue = new ArrayCollection();
			
			if (params['structure'])
			{
				this.structure = params.structure;
			}		
		}
		
		public function addToProxiedQueue(cp:CustomerPerson, pathLength:Number):void
		{
			var obj:Object = {cp: cp, pathLength: pathLength};
			proxiedQueue.addItem(obj);
		}
		
		public function removeFromProxedQueue(cp:CustomerPerson):void
		{
			for each (var obj:Object in proxiedQueue)
			{
				if (obj.cp == cp)
				{
					var index:int = proxiedQueue.getItemIndex(obj);
					proxiedQueue.removeItemAt(index);
				}
			}
		}
		
	}
}