package rock_on
{
	import models.OwnedDwelling;
	import flash.events.IEventDispatcher;

	public class Venue extends OwnedDwelling
	{
		public var lastShowTime:int;
		
		public function Venue(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			if (params['dwelling'])
			{
				dwelling = params.dwelling;
			}			
		}
		
	}
}