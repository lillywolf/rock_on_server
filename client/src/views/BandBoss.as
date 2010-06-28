package views
{
	import com.facebook.commands.events.CreateEvent;
	
	import controllers.CreatureController;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import helpers.CreatureEvent;
	
	import mx.collections.ArrayCollection;
	
	import rock_on.BandMember;
	import rock_on.BandMemberManager;
	import rock_on.ConcertStage;
	import rock_on.Person;
	import rock_on.StageManager;
	import rock_on.Venue;
	
	import world.AssetStack;
	import world.World;

	public class BandBoss extends EventDispatcher
	{
		public var bandMembers:ArrayCollection;
		public var bandMemberManager:BandMemberManager;
		public var friendMirror:Boolean;
		public var _creatureController:CreatureController;
		public var _myWorld:World;
		public var _venueManager:VenueManager;
		
		public function BandBoss(venueManager:VenueManager, creatureController:CreatureController, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_venueManager = venueManager;
			_creatureController = creatureController;
			_myWorld = myWorld;					
		}
		
		public function setInMotion():void
		{
			bandMemberManager = new BandMemberManager(_venueManager.venue);
			bandMemberManager.myWorld = _myWorld;
			bandMemberManager.concertStage = _venueManager.venue.stageManager.concertStage;	
			bandMemberManager.showBandMembers();	
		}
		
		public function update(lockedDelta:Number):void
		{
			if (bandMemberManager)
			{
				bandMemberManager.update(lockedDelta);							
			}
		}
		
	}
}