package game
{
	import flash.events.IEventDispatcher;
	
	import models.Creature;
	
	import world.Point3D;

	public class ImposterCreature extends Creature
	{
		public function ImposterCreature(params:Object, target:IEventDispatcher=null)
		{
			super(params, target);
		}
		
		override public function setPropertiesFromParams(params:Object):void
		{
			if (params.id)
			{
				_id = params.id;			
			}
			if (params.creature_type)
			{
				_type = params.creature_type;
			}		
			if (params.additional_info)
			{
				_additional_info = params.additional_info;				
			}	
			if (params.x != null)
			{
				location = new Point3D(params.x, 0, 0);
			}
			if (params.y != null)
			{
				location.y = params.y;
			}
			if (params.z != null)
			{
				location.z = params.z;
			}		
		}
		
	}
}