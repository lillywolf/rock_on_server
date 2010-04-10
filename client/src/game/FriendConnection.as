package game
{
	import controllers.CreatureManager;
	import controllers.EssentialModelManager;
	import controllers.LayerableManager;
	import controllers.StructureManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class FriendConnection extends EventDispatcher
	{
		public function FriendConnection(gameContent:Dictionary, em:EssentialModelManager=null, target:IEventDispatcher=null)
		{
			super(target);
			createManagers(gameContent, em);
		}
		
		public function createManagers(gameContent:Dictionary, em:EssentialModelManager):void
		{
			var structureManager:StructureManager = new StructureManager(em);
			var layerableManager:LayerableManager = new LayerableManager(em);
			var creatureManager:CreatureManager = new CreatureManager(em);
			
			structureManager.structures = gameContent['structures'];
			layerableManager.layerables = gameContent['layerables'];
		}
		
	}
}