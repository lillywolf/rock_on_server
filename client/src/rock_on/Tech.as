package rock_on
{
	import flash.display.MovieClip;
	
	import models.Creature;
	
	public class Tech extends Person
	{
		public static const INITIALIZED_STATE:int = 0;
		public static const STANDBY_STATE:int = 1;
		public static const ROAM_STATE:int = 2;
		public static const ROUTE_STATE:int = 3;
		public static const EXIT_OFFSTAGE_STATE:int = 4;
		public static const EXIT_STAGE_STATE:int = 5;
		public static const STOPPED_STATE:int = 6;
		public static const ITEM_PICKUP_STATE:int = 7;	
		public static const GONE_STATE:int = 8;
		
		public var state:int;
		public var _venue:Venue;
		
		public function Tech(creature:Creature, movieClip:MovieClip=null, layerableOrder:Array=null, scale:Number=1)
		{
			updateLayerableOrder();

			super(creature, movieClip, layerableOrder, scale);
		}
		
		private function updateLayerableOrder():void
		{
			layerableOrder = new Array();
			layerableOrder['walk_toward'] = ["body", "bottom", "top", "hair front"];
			layerableOrder['walk_away'] = ["body", "bottom", "top", "hair front"];
			layerableOrder['stand_still_toward'] = ["body", "bottom", "top", "hair front"];
			layerableOrder['stand_still_away'] = ["body", "bottom", "top", "hair front"];			
		}
		
		public function update(deltaTime:Number):Boolean
		{		
			switch (state)
			{
				case INITIALIZED_STATE:
					doInitializedState(deltaTime);
					break;
				case ROAM_STATE:
					doRoamState(deltaTime);
					break;
				case STANDBY_STATE:
					doStandbyState(deltaTime);
					break;	
				case STOPPED_STATE:
					doStoppedState(deltaTime);
					break;
				case ROUTE_STATE:
					doRouteState(deltaTime);
					break;
				case EXIT_OFFSTAGE_STATE:
					doExitOffstageState(deltaTime);	
					break;
				case EXIT_STAGE_STATE:
					doExitStageState(deltaTime);	
					break;
				case ITEM_PICKUP_STATE:
					doItemPickupState(deltaTime);	
					break;
				case GONE_STATE:
					doGoneState(deltaTime);
					return true;	
				default: throw new Error('oh noes!');
			}		
			return false;
		}
		
		public function advanceState(destinationState:int):void
		{
			switch (state)
			{	
				case INITIALIZED_STATE:
					endInitializedState();
					break;
				case ROAM_STATE:
					endRoamState();
					break;
				case STANDBY_STATE:
					endStandbyState();				
					break;	
				case STOPPED_STATE:
					endStoppedState();
					break;
				case ROUTE_STATE:
					endRouteState();
					break;	
				case EXIT_OFFSTAGE_STATE:
					endExitOffstageState();
					break;	
				case EXIT_STAGE_STATE:
					endExitStageState();
					break;	
				case ITEM_PICKUP_STATE:
					endItemPickupState();
					break;	
				case GONE_STATE:
					break;					
				default: throw new Error('no state to advance from!');
			}
			switch (destinationState)
			{
				case ROAM_STATE:
					startRoamState();
					break;
				case STOPPED_STATE:
					startStoppedState();
					break;
				case STANDBY_STATE:
					startStandbyState();
					break;
				case EXIT_OFFSTAGE_STATE:
					startExitOffstageState();
					break;
				case EXIT_STAGE_STATE:
					startExitStageState();
					break;
				case ITEM_PICKUP_STATE:
					startItemPickupState();
					break;														
				case GONE_STATE:
					startGoneState();
					break;	
				default: throw new Error('no state to advance to!');	
			}
		}
		
		public function doInitializedState(deltaTime:Number):void
		{
			
		}
		
		public function startInitializedState():void
		{
			
		}
		
		public function endInitializedState():void
		{
			
		}
		
		public function startRoamState():void
		{
			
		}
		
		public function endRoamState():void
		{
			
		}
		
		public function doRoamState(deltaTime:Number):void
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
		}
		
		public function endStoppedState():void
		{
			
		}
		
		public function doStoppedState(deltaTime:Number):void
		{
			
		}
		
		public function startExitStageState():void
		{
			
		}
		
		public function startExitOffstageState():void
		{
			
		}
		
		public function doExitOffstageState(deltaTime:Number):void
		{
			
		}
		
		public function doExitStageState(deltaTime:Number):void
		{
			
		}
		
		public function endExitStageState():void
		{
			
		}
		
		public function startItemPickupState():void
		{
			
		}
		
		public function endItemPickupState():void
		{
			
		}
		
		public function doItemPickupState(deltaTime:Number):void
		{
			
		}
		
		public function startGoneState():void
		{
			
		}
		
		public function doGoneState(deltaTime:Number):void
		{
			
		}
		
		public function startStandbyState():void
		{
			
		}
		
		public function endStandbyState():void
		{
			
		}
		
		public function doStandbyState(deltaTime:Number):void
		{
			
		}
		
		public function startRouteState():void
		{
			
		}
		
		public function endRouteState():void
		{
			
		}
		
		public function doRouteState(deltaTime:Number):void
		{
			
		}
		
		public function endExitOffstageState():void
		{
			
		}
		
		public function set venue(val:Venue):void
		{
			_venue = val;
		}
		
		public function get venue():Venue
		{
			return _venue;
		}

	}	
}