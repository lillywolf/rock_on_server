package views
{
	import controllers.CreatureManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import rock_on.BandMember;
	import rock_on.BandMemberManager;
	import rock_on.ConcertStage;
	import rock_on.Venue;
	
	import world.AssetStack;
	import world.World;

	public class BandManager extends EventDispatcher
	{
		public var bandMembers:ArrayCollection;
		public var bandMemberManager:BandMemberManager;
		public var _creatureManager:CreatureManager;
		public var _booths:ArrayCollection;
		public var _concertStage:ConcertStage;
		public var _myWorld:World;
		public var _venue:Venue;
		
		public function BandManager(creatureManager:CreatureManager, booths:ArrayCollection, concertStage:ConcertStage, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_creatureManager = creatureManager;
			_booths = booths;
			_concertStage = concertStage;	
			_myWorld = myWorld;		
		}
		
		public function setInMotion():void
		{
			bandMemberManager = new BandMemberManager();
			bandMemberManager.myWorld = _myWorld;
			bandMemberManager.concertStage = _concertStage;	
			showBandMembers();		
		}
		
		public function mapVenueStateToBandMemberState():int
		{
			if (_venue.state == Venue.EMPTY_STATE)
			{
				return BandMember.WAIT_STATE;
			}
			else if (_venue.state == Venue.ENCORE_STATE)
			{
				return BandMember.ENTER_STATE;
			}
			else if (_venue.state == Venue.ENCORE_WAIT_STATE)
			{
				return BandMember.WAIT_STATE;
			}
			else if (_venue.state == Venue.SHOW_STATE)
			{
				return BandMember.ENTER_STATE;
			}
			else if (_venue.state == Venue.SHOW_WAIT_STATE)
			{
				return BandMember.WAIT_STATE;
			}
			else
			{
				throw new Error("Not a legitimate state");
			}
		}
		
		private function showBandMembers():void
		{
			var bandMembers:ArrayCollection = _creatureManager.getConstructedCreaturesByType("BandMember", 1, 1);
			
			for each (var assetStack:AssetStack in bandMembers)
			{
				var bandMember:BandMember = new BandMember(assetStack.movieClipStack, assetStack.layerableOrder, assetStack.creature, 0.4);
				bandMember.concertStage = _concertStage;
				bandMember.addExemptStructures();
				bandMember.speed = 0.06;
				bandMemberManager.add(bandMember);
				
				var newState:int = mapVenueStateToBandMemberState();
				bandMember.advanceState(newState);
			}
		}
		
		public function update(lockedDelta:Number):void
		{
			if (bandMemberManager)
			{
				bandMemberManager.update(lockedDelta);							
			}
		}
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}		
		
	}
}