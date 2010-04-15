package rock_on
{
	import flash.events.IEventDispatcher;
	
	import world.Point3D;

	public class ListeningStation extends Booth
	{
		public var numAttractedFans:int;
		public var createdAt:int;
		public var stationType:String;
		public var radius:Point3D;
		
		public function ListeningStation(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			setRadius();
		}
				
		public function setRadius():void
		{
			if (_structure.mc is Ticket_01)
			{
				stationType = "Gramophone";
				radius = new Point3D(1, 0, 1);
			}
			else if (_structure.mc is Booth_01)
			{
				stationType = "RecordPlayer";
				radius = new Point3D(2, 0, 1);
			}
		}	
		
	}
}