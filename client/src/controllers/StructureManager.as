package controllers
{
	import flash.events.IEventDispatcher;
	
	import models.OwnedStructure;
	import models.Structure;
	
	import mx.collections.ArrayCollection;

	public class StructureManager extends Manager
	{
		[Bindable] public var structures:ArrayCollection;
		[Bindable] public var owned_structures:ArrayCollection;
		
		public function StructureManager(essentialModelManager:EssentialModelManager, target:IEventDispatcher=null)
		{
			super(essentialModelManager, target);
			structures = essentialModelManager.structures;
			owned_structures = essentialModelManager.owned_structures;
		}
		
		public function getStructuresByType(type:String):ArrayCollection
		{
			var matchingStructures:ArrayCollection = new ArrayCollection();
			for each (var os:OwnedStructure in owned_structures)
			{
				if (os.structure.structure_type == type)
				{
					matchingStructures.addItem(os);
				}
			}
			return matchingStructures;
		}
		
		public function add(structure:Structure):void
		{
			structures.addItem(structure);
		}
		
		public function remove(structure:Structure):void
		{
			var i:int = structures.getItemIndex(structure);
			structures.removeItemAt(i);
		}		
		
	}
}