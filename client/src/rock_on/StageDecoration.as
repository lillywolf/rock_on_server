package rock_on
{
	import flash.events.IEventDispatcher;
	
	import models.OwnedStructure;
	
	public class StageDecoration extends OwnedStructure
	{
		public var _concertStage:ConcertStage;
		
		public function StageDecoration(concertStage:ConcertStage, params:Object=null, target:IEventDispatcher=null)
		{
			_concertStage = concertStage;
			
			super(params, target);			
		}
	}
}