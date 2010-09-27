package rock_on
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	
	import world.Point3D;
	import world.World;
	import world.WorldEvent;
	
	public class Friend extends Person
	{
		public static const ROUTE_STATE:int = 0;
		public static const STOPPED_STATE:int = 1;
		
		public static const STOP_TIME_MULTIPLIER:int = 20000;
		public static const STOP_TIME_MIN:int = 10000;

		public var _venue:Venue;
		public var state:int;
		public var stoppedTimer:Timer;
		public var currentDestination:Point3D;		
		
		public function Friend(venue:Venue, creature:Creature, movieClip:MovieClip=null, layerableOrder:Array=null, scale:Number=1)
		{
			super(creature, movieClip, layerableOrder, scale);
			_venue = venue;			
			setRectanglesToAvoid();
			updateLayerableOrder();
			
			addEventListener(WorldEvent.PATHFINDING_FAILED, onPathfindingFailed);
		}
		
		private function onPathfindingFailed(evt:WorldEvent):void
		{
			advanceState(Friend.STOPPED_STATE);
		}
		
		public function setRectanglesToAvoid():void
		{
			rectanglesToAvoid = new ArrayCollection();
			rectanglesToAvoid.addItem(_venue.unwalkableRect);
			rectanglesToAvoid.addItem(_venue.outsideRect);
		}		
		
		private function updateLayerableOrder():void
		{
			layerableOrder = new Array();
			layerableOrder['walk_toward'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];
			layerableOrder['walk_away'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];
			layerableOrder['stand_still_toward'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];
			layerableOrder['stand_still_away'] = ["body", "shoes", "bottom", "bottom custom", "top", "top custom", "hair front", "hair band"];			
		}		
		
		public function addGlowFilter():void
		{
			var gf:GlowFilter = new GlowFilter(0x86FF24, 1, 16, 16, 1.5);
			unclearableFilters.push(gf);
			this.filters = [gf];
		}
		
		public function advanceState(destinationState:int):void
		{
			switch (state)
			{	
				case ROUTE_STATE:
					endRouteState();
					break;
				case STOPPED_STATE:
					endStoppedState();
					break;					
				default: throw new Error('no state to advance from!');
			}
			switch (destinationState)
			{
				case ROUTE_STATE:
					startRouteState();
					break;
				case STOPPED_STATE:
					startStoppedState();
					break;
				default: throw new Error('no state to advance to!');	
			}
		}	
		
		public function startRouteState():void
		{
			state = ROUTE_STATE;
			movePerson(this.currentDestination, true, true, false, null, 0, rectanglesToAvoid);
		}
		
		public function endRouteState():void
		{
			
		}
		
		public function startStoppedState():void
		{
			state = STOPPED_STATE;
			
			var relationships:Array = getDirectionalRelationshipsArray();
			var relationship:Array = new Array();
			relationship["horizontalRelationship"] = relationships["horizontalRelationship"][Math.floor(Math.random() * (relationships["horizontalRelationship"] as Array).length)];
			relationship["verticalRelationship"] = relationships["verticalRelationship"][Math.floor(Math.random() * (relationships["verticalRelationship"] as Array).length)];
			
			frameNumber = evaluateHorizontalAndVerticalRelationship(relationship);						
			var reflection:Boolean = getReflection(relationship);	
			var standAnimation:String = getStandAnimation(frameNumber);
			stand(standAnimation, frameNumber);				
			
			startStoppedTimer();
		}
		
		public function startStoppedTimer():void
		{
			stoppedTimer = new Timer(Hater.STOP_TIME_MIN + Math.random() * Hater.STOP_TIME_MULTIPLIER);
			stoppedTimer.addEventListener(TimerEvent.TIMER, onStoppedTimeComplete);
			stoppedTimer.start();
		}
		
		private function onStoppedTimeComplete(evt:TimerEvent):void
		{
			this.currentDestination = pickNewRandomDestination();
			advanceState(Friend.ROUTE_STATE);
		}
		
		public function pickNewRandomDestination():Point3D
		{
			var destination:Point3D = _venue.pickRandomAvailablePointWithinRect(_venue.boothsRect, _myWorld, 0, _venue.crowdBufferRect, true, true);
			return destination;
		}
		
		public function endStoppedState():void
		{
			if (stoppedTimer)
			{
				stoppedTimer.stop();
				stoppedTimer.removeEventListener(TimerEvent.TIMER, onStoppedTimeComplete);
				stoppedTimer = null;
			}
		}
		
		override public function set myWorld(val:World):void
		{
			_myWorld = val;
			_myWorld.addEventListener(WorldEvent.FINAL_DESTINATION_REACHED, onFinalDestinationReached);		
			_myWorld.addEventListener(WorldEvent.DIRECTION_CHANGED, onDirectionChanged);
		}
		
		private function onFinalDestinationReached(evt:WorldEvent):void
		{
			if (evt.activeAsset == this)
			{
				advanceState(Friend.STOPPED_STATE);
			}
		}
		
		public function reInitialize():void
		{
			advanceState(Friend.STOPPED_STATE);
		}			
	}
}