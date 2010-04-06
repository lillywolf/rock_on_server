package views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import models.OwnedStructure;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.DynamicEvent;
	
	import world.ActiveAsset;
	import world.Point;
	import world.Point3D;
	import world.World;
	import world.WorldGrid;

	public class EditMode extends UIComponent
	{
		public var _world:World;
		public var currentAsset:ActiveAsset;
		public var activated:Boolean = false;
		public var flexiUIC:FlexibleUIComponent;
		
		public static const INVALID_COLOR:ColorTransform = new ColorTransform(1, 0.25, 0.25);
		public static const NORMAL_COLOR:ColorTransform = new ColorTransform(1, 1, 1);
		
		public function EditMode(world:World)
		{
			super();
			_world = world;
			_world.addEventListener(MouseEvent.CLICK, onWorldClicked);

			enableMouseDetection();

			addEventListener(Event.ADDED, onAdded);
		}
		
		private function onAdded(evt:Event):void
		{
			width = parent.width;
			height = parent.height;	
			x = parent.x;
			y = parent.y;
		}
		
		private function enableMouseDetection():void
		{
			_world.graphics.beginFill(0x000000, 0.2);
			_world.graphics.drawRect(_world.x, -(_world.y), Application.application.width, Application.application.height);
			_world.graphics.endFill();			
		}
		
		private function addFlexibleUIC():void
		{
			flexiUIC = new FlexibleUIComponent();
			addChild(flexiUIC);			
		}
		
		private function updateFlexibleUIC():void
		{
			flexiUIC.x = x;
			flexiUIC.y = y;
			flexiUIC.width = width;
			flexiUIC.height = height;
		}
		
		private function onWorldClicked(evt:MouseEvent):void
		{
			if (evt.target.parent is ActiveAsset)
			{
				if ((evt.target.parent as ActiveAsset).thinger is OwnedStructure && !activated)
				{
					activateMoveableStructure(evt.target.parent as ActiveAsset);
					activated = true;
				}
				else if (activated)
				{
					deactivateMoveableStructure();
					activated = false;
				}
			}
			else if (evt.target.parent is WorldGrid)
			{
				deactivateMoveableStructure();
				activated = false;
			}
		}		
		
		public function activateMoveableStructure(asset:ActiveAsset):void
		{			
			_world.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			currentAsset = asset;
			currentAsset.speed = 1;
		}
		
		public function deactivateMoveableStructure():void
		{
			saveCurrentPlacement();
			if (_world.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				_world.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);			
			}
		}
		
		public function saveCurrentPlacement():void
		{
			var pointToSave:Point3D = new Point3D(Math.round(currentAsset.worldDestination.x), Math.round(currentAsset.worldDestination.y), Math.round(currentAsset.worldDestination.z));
			pointToSave = keepPointInBounds(pointToSave);
			var evt:DynamicEvent = new DynamicEvent('structurePlaced', true, true);
			evt.asset = currentAsset;
			evt.currentPoint = pointToSave;
			dispatchEvent(evt);
		}
		
		private function onMouseMove(evt:Event):void
		{
			var currentPoint:Point = new Point(_world.mouseX, _world.mouseY);
			var worldDestination:Point3D = World.actualToWorldCoords(currentPoint);
			worldDestination.x = Math.round(worldDestination.x);
			worldDestination.z = Math.round(worldDestination.z);
			
//			worldDestination = keepPointInBounds(worldDestination);
			_world.moveAssetTo(currentAsset, worldDestination, false);
			
			if (isFurnitureOutOfBounds() || isFurnitureOnInvalidPoint())
			{
				currentAsset.transform.colorTransform = INVALID_COLOR;
			}
			else
			{
				currentAsset.transform.colorTransform = NORMAL_COLOR;
			}
		}
		
		public function isFurnitureOutOfBounds():Boolean
		{
			if (currentAsset.worldCoords.x > _world.tilesWide || currentAsset.worldCoords.x < 0 || currentAsset.worldCoords.z > _world.tilesDeep || currentAsset.worldCoords.z < 0)
			{
				return true;
			}
			return false;
		}
		
		public function isFurnitureOnInvalidPoint():Boolean
		{
			return false;
		}
		
		public function keepPointInBounds(destination:Point3D):Point3D
		{
			if (destination.x < 0)
			{
				destination.x = 0;
			}
			else if (destination.x > _world.tilesWide)
			{
				destination.x = _world.tilesWide;
			}
			if (destination.z < 0)
			{
				destination.z = 0;
			}
			else if (destination.z > _world.tilesDeep)
			{
				destination.z = _world.tilesDeep;
			}
			return destination;			
		}
		
	}
}