package rock_on
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.Creature;
	import models.Layerable;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	import world.Point3D;

	public class Promoter extends Person
	{
		private static const ROAM_TIME:int = Math.random()*2000 + 1000;
		private static const STOP_TIME:int = 8000;
		
		private static const VENUE_BOUNDS_X:int = 14;
		private static const VENUE_BOUNDS_Z:int = 20;
				
		public function Promoter(movieClipStack:MovieClip, layerableOrder:Array=null, creature:Creature=null, personScale:Number=1, source:Array=null)
		{
			super(movieClipStack, layerableOrder, creature, personScale, source);
			startStopState();				
		}
		
		override public function startEnterState():void
		{
			advanceState(Person.STOP_STATE);
		}
		
		override public function endEnterState():void
		{
			
		}
		
		override public function startStopState():void
		{
			if (roamTime && roamTime.hasEventListener(TimerEvent.TIMER))
			{
				roamTime.removeEventListener(TimerEvent.TIMER, stop);
			}
			
			state = STOP_STATE;
			doAnimation("stand_still_toward");
			movieClipStack.scaleX = -(orientation);
//			stopTime = new Timer(STOP_TIME);
//			stopTime.addEventListener(TimerEvent.TIMER, roam);
//			stopTime.start();			
		}
		
		override public function startRoamState():void
		{
			if (stopTime && stopTime.hasEventListener(TimerEvent.TIMER))
			{
				stopTime.removeEventListener(TimerEvent.TIMER, roam);
			}
			
			worldDestination = new Point3D(VENUE_BOUNDS_X + Math.floor(Math.random()*(myWorld.tilesWide - VENUE_BOUNDS_X)), 0, Math.floor(Math.random()*myWorld.tilesDeep));

			_myWorld.moveAssetTo(this, worldDestination);
			
			state = ROAM_STATE;
			setDirection(worldDestination);
			roamTime = new Timer(ROAM_TIME);
			roamTime.addEventListener(TimerEvent.TIMER, stop);
			roamTime.start();				
		}
		
		public function stop(evt:TimerEvent):void
		{
			advanceState(STOP_STATE);
		}
		
		override public function endRoamState():void
		{
			
		}		

		override public function leave(evt:TimerEvent):void
		{

		}
				
		public static function getStyles(creatureId:int):ArrayCollection
		{
			var myStyles:ArrayCollection = new ArrayCollection();
			var bodyLayer:OwnedLayerable = new OwnedLayerable({id: -1, layerable_id: 2, creature_id: creatureId, in_use: true});
			var eyeLayer:OwnedLayerable = new OwnedLayerable({id: -1, layerable_id: 1, creature_id: creatureId, in_use:true});
			for each (var layerable:Layerable in Application.application.gdi.layerableController.layerables)
			{
				if (layerable.symbol_name == "PeachBody")
				{
					bodyLayer.layerable = layerable;
				}
			}
			
			myStyles.addItem(bodyLayer);
			myStyles.addItem(eyeLayer);
			return myStyles;
		}
		
	}
}