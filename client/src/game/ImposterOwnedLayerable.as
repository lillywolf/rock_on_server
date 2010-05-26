package game
{
	import models.OwnedLayerable;
	import flash.events.IEventDispatcher;

	public class ImposterOwnedLayerable extends OwnedLayerable
	{
		public function ImposterOwnedLayerable(params:Object, target:IEventDispatcher=null)
		{
			super(params, target);
		}
		
		override public function updateProperties(params:Object):void
		{
			if (params.layerable)
			{
				_layerable = params.layerable;
				_layerable_id = params.layerable_id;
			}
			if (params.creature_id)
			{
				_creature_id = params.creature_id;			
			}
			if (params.in_use)
			{
				_in_use = params.in_use;						
			}
		}
		
	}
}