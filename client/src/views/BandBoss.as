package views
{
	import com.facebook.commands.events.CreateEvent;
	
	import controllers.CreatureController;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import helpers.CreatureEvent;
	
	import models.CreatureGroup;
	
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
		public var bands:ArrayCollection;
		public var friendMirror:Boolean;
		public var _creatureController:CreatureController;
		public var _venueManager:VenueManager;
		
		public function BandBoss(venueManager:VenueManager, creatureController:CreatureController, target:IEventDispatcher=null)
		{
			super(target);
			bands = new ArrayCollection();
			_venueManager = venueManager;
			_creatureController = creatureController;
		}
		
		public function addBands(myWorld:World):void
		{
			for each (var group:CreatureGroup in _creatureController.creature_groups)
			{
				var bmm:BandMemberManager = new BandMemberManager(_venueManager.venue, myWorld);
				bmm.concertStage = _venueManager.venue.stageManager.concertStage;
				_venueManager.venue.bandMemberManager = bmm;
				bands.addItem(bmm);
			}
		}
		
		public function showBandMembers():void
		{
			for each (var bmm:BandMemberManager in bands)
			{
				bmm.showBandMembers();
			}
		}
		
		public function update(lockedDelta:Number):void
		{
			for each (var bmm:BandMemberManager in bands)
			{
				bmm.update(lockedDelta);
			}
		}
		
	}
}