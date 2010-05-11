package rock_on
{
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import game.Counter;
	import game.CounterEvent;
	import game.GameClock;
	
	import models.OwnedDwelling;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Button;
	import mx.core.Application;
	
	import views.VenueManager;
	
	import world.Point3D;
	import world.World;

	public class Venue extends OwnedDwelling
	{	
		public static const UNINITIALIZED_STATE:int = 0;	
		public static const SHOW_STATE:int = 1;
		public static const ENCORE_STATE:int = 2;
		public static const CROWDED_STATE:int = 3;
		public static const EMPTY_STATE:int = 4;
		public static const ENCORE_WAIT_STATE:int = 5;
		public static const SHOW_WAIT_STATE:int = 6;
		
		public static const SHOW_TIME:int = 3600000;
		public static const ENCORE_TIME:int = 360000;
		public static const ENCORE_WAIT_TIME:int = 1800000;
		public static const VENUE_FILL_FRACTION:Number = 0.5;
		
		public var state:int;
		public var startShowButton:Button;
		public var mainEntrance:Point3D;
		public var entryPoints:ArrayCollection;
		public var _venueManager:VenueManager;
		
		public var _myWorld:World;
		
		public function Venue(venueManager:VenueManager, myWorld:World, params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			
			_myWorld = myWorld;
			_venueManager = venueManager;
			entryPoints = new ArrayCollection();
			setEntrance(params);
			setAdditionalProperties(params);
			
			updateState();		
		}
		
		public function setAdditionalProperties(params:Object):void
		{
			if (params['dwelling'])
			{
				dwelling = params.dwelling;
			}				
		}
		
		public function updateState():void
		{
			updateStateOnServer(false);
		}
		
		public function updateStateOnServer(showButtonClicked:Boolean):void
		{
			var timeElapsed:int = getUpdatedTimeElapsed();
			_venueManager.dwellingManager.serverController.sendRequest({id: id, time_elapsed_client: timeElapsed, show_button_clicked: showButtonClicked}, "owned_dwelling", "update_state");
		}
		
		public function getUpdatedTimeElapsed():int
		{
			var currentDate:Date = new Date();
			var timeSinceStateChanged:int = currentDate.getTime()/1000 + (currentDate.timezoneOffset * 60) - GameClock.convertStringTimeToUnixTime(_state_updated_at);
			return timeSinceStateChanged;
		}
		
		public function stateTranslateString():int
		{
			switch (_last_state)
			{
				case "empty_state":
					return EMPTY_STATE;
				case "show_state":
					return SHOW_STATE;
				case "encore_state":
					return ENCORE_STATE;
				case "show_wait_state":
					return SHOW_WAIT_STATE;
				case "encore_wait_state":
					return ENCORE_WAIT_STATE;
				default: throw new Error("Unrecognized state name");					
			}
		}		
		
		public function advanceState(destinationState:int):void
		{
			switch (state)
			{
				case UNINITIALIZED_STATE:
					break;
				case SHOW_STATE:
					endShowState();
					break;				
				case ENCORE_STATE:
					endEncoreState();				
					break;	
				case CROWDED_STATE:
					endCrowdedState();
					break;						
				case EMPTY_STATE:
					endEmptyState();
					break;						
				case ENCORE_WAIT_STATE:
					endEncoreWaitState();
					break;						
				case SHOW_WAIT_STATE:
					endShowWaitState();
					break;						
				default: throw new Error('no state to advance from!');
			}
			switch (destinationState)
			{
				case SHOW_STATE:
					startShowState();
					break;
				case ENCORE_STATE:
					startEncoreState();
					break;
				case CROWDED_STATE:
					startCrowdedState();
					break;
				case EMPTY_STATE:
					startEmptyState();
					break;
				case ENCORE_WAIT_STATE:
					startEncoreWaitState();
					break;
				case SHOW_WAIT_STATE:
					startShowWaitState();
					break;
				default: throw new Error('no state to advance to!');	
			}
		}	
		
		public function startShowState():void
		{
			state = SHOW_STATE;
			updateStateTimer(SHOW_TIME);
		}		
		
		public function updateStateTimer(stateTime:int):void
		{
			var millisecondsElapsed:int = getUpdatedTimeElapsed() * 1000;
			var millisecondsRemaining:int = (stateTime - millisecondsElapsed);
			
			var counter:Counter = new Counter(millisecondsRemaining);
			counter.addEventListener(CounterEvent.COUNTER_COMPLETE, onCounterComplete);
			counter.displayCounter();
			counter.counterCanvas.x = 400;
			counter.counterCanvas.y = 0;
			counter.counterCanvas.setStyle("fontSize", "20");
			counter.counterCanvas.setStyle("fontFamily", "Museo-Slab-900");
			counter.counterCanvas.setStyle("color", 0xffffff);
			Application.application.addChild(counter.counterCanvas);
		}
		
		private function onCounterComplete():void
		{
			updateState();
		}
		
		public function checkForMinimumFancount():Boolean
		{
			if (state == EMPTY_STATE && fancount > dwelling.capacity * VENUE_FILL_FRACTION)
			{
				advanceState(SHOW_WAIT_STATE);
				return true;
			}			
			return false;
		}
		
		public function endShowState():void
		{
			
		}
		
		public function startEncoreState():void
		{
			state = ENCORE_STATE;
			updateStateTimer(ENCORE_TIME);			
		}
		
		public function endEncoreState():void
		{
			
		}
		
		public function startCrowdedState():void
		{
			state = CROWDED_STATE;
		}
		
		public function endCrowdedState():void
		{
			
		}
		
		public function checkForVenueTurnover():void
		{
			if (state == ENCORE_STATE || state == ENCORE_WAIT_STATE)
			{
				_venueManager.dwellingManager.serverController.sendRequest({id: id, level: _venueManager.levelManager.level}, "owned_dwelling", "change_venue");
			}
		}
		
		public function startEmptyState():void
		{
			checkForVenueTurnover();
			state = EMPTY_STATE;
		}
		
		public function endEmptyState():void
		{
			
		}
		
		private function setEntrance(params:Object=null):void
		{
			mainEntrance = new Point3D(14, 0, 10);
		}
		
		public function updateFanCount(fansToAdd:int, venue:Venue, station:ListeningStation):void
		{
			_venueManager.dwellingManager.serverController.sendRequest({id: venue.id, to_add: fansToAdd, owned_structure_id: station.id}, "owned_dwelling", "update_fancount");
		}
		
		public function startEncoreWaitState():void
		{
			state = ENCORE_WAIT_STATE;
		}
		
		public function endEncoreWaitState():void
		{
			
		}
		
		public function startShowWaitState():void
		{
			state = SHOW_WAIT_STATE;
			displayStartShowButton();
		}
		
		public function displayStartShowButton():void
		{
			startShowButton = new Button();
			startShowButton.width = 50;
			startShowButton.height = 50;
			startShowButton.x = 400;
			startShowButton.y = 0;
			startShowButton.addEventListener(MouseEvent.CLICK, onStartShowButtonClicked);
			Application.application.addChild(startShowButton);
		}
		
		private function onStartShowButtonClicked(evt:MouseEvent):void
		{
			updateStateOnServer(true);
		}
		
		public function endShowWaitState():void
		{
			removeShowButton();
		}
		
		public function removeShowButton():void
		{
			if (Application.application.contains(startShowButton))
			{
				Application.application.removeChild(startShowButton);
			}
			if (startShowButton)
			{
				startShowButton = null;
			}			
		}
		
		public function get myWorld():World
		{
			return _myWorld;
		}
		
	}
}