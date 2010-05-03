package rock_on
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class ContentIndex extends EventDispatcher
	{
		public function ContentIndex(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function setBoothInventoryByName(boothName:String):int
		{
			var boothInventory:int = 0;
			switch (boothName)
			{
				case "Booth 1":
					boothInventory = 50;
					break;
				case "Booth 2":
					boothInventory = 60;
					break;		
			}
			if (boothInventory == 0)
			{
				throw new Error("Booth type not found on index");
			}
			return boothInventory;
		}
		
	}
}