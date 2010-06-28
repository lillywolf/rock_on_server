package game
{
	import controllers.CreatureController;
	import controllers.EssentialModelController;
	import controllers.LayerableController;
	import controllers.StructureController;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class FriendConnection extends EventDispatcher
	{
		public function FriendConnection(gameContent:Dictionary, em:EssentialModelController=null, target:IEventDispatcher=null)
		{
			super(target);
			createManagers(gameContent, em);
		}
		
		public function createManagers(gameContent:Dictionary, em:EssentialModelController):void
		{
			var structureController:StructureController = new StructureController(em);
			var layerableController:LayerableController = new LayerableController(em);
			var creatureController:CreatureController = new CreatureController(em);
			
			structureController.structures = gameContent['structures'];
			layerableController.layerables = gameContent['layerables'];
		}
		
	}
}