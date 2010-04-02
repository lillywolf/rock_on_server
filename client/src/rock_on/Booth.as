package rock_on
{
	import models.OwnedStructure;
	import flash.events.IEventDispatcher;

	public class Booth extends OwnedStructure
	{
		public var queueCapacity:Number;
		public var currentQueue:Number;
		public var hasCustomerEnRoute:Boolean;		
		public function Booth(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			currentQueue = 0;	
			if (params['structure'])
			{
				this.structure = params.structure;
			}		
		}
		
	}
}