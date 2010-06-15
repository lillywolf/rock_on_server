package world
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Image;

	public class ActiveAsset extends Sprite
	{
		public var _movieClip:MovieClip;
		public var _world:World;
		public var _worldCoords:Point3D;
		public var _worldDestination:Point3D;
		public var _lastWorldPoint:Point3D;
		public var _speed:Number = -1;
		
		[Bindable] public var _realCoords:Point;
		public var _realDestination:Point;
		public var _lastRealPoint:Point;
		public var _walkProgress:Number;
		public var _isMoving:Boolean;
		public var _fourDirectional:Boolean;
		public var imageEnabled:Boolean;
		public var enabledImage:Canvas;
		
		public var realCoordY:Number;
		public var realCoordX:Number;
		
		public var _currentPath:ArrayCollection;
		public var _pathStep:int;
		public var _directionality:Point3D;
		
		public var _thinger:Object;
		public var currentAnimation:String;
		public var currentFrameNumber:int;
		
		public static const MOVE_DELAY_TIME:int = 200;
		
		public function ActiveAsset(movieClip:MovieClip)
		{
			super();
			_movieClip = movieClip;
			_directionality = new Point3D(0, 0, 0);
//			addEventListener(Event.ADDED, onAdded);
			if (_movieClip)
			{
				addChild(_movieClip);			
				_movieClip.addEventListener(MouseEvent.CLICK, onMouseClicked);
			}
		}
		
		private function onMouseClicked(evt:MouseEvent):void
		{
			trace(evt.target.name, flash.utils.getQualifiedClassName(evt.target));					
		}
		
		public function onAdded(evt:Event):void
		{
			this.removeEventListener(Event.ADDED, onAdded);
			addChild(_movieClip);
		}
		
		public function set world(val:World):void
		{
			_world = val;
		}
		
		public function get world():World
		{
			return _world;
		}
		
		public function set movieClip(val:MovieClip):void
		{
			if (_world)
			{
				_movieClip = val;					
			}
		}
		
		public function get movieClip():MovieClip
		{
			return _movieClip;
		} 
		
		public function set speed(val:Number):void
		{
			_speed = val;					
		}
		
		public function get speed():Number
		{
			return _speed;
		} 
		
		public function set walkProgress(val:Number):void
		{
			_walkProgress = val;					
		}
		
		public function get walkProgress():Number
		{
			return _walkProgress;
		} 

		public function set realDestination(val:Point):void
		{
			_realDestination = val;					
		}
		
		public function get worldDestination():Point3D
		{
			return _worldDestination;
		} 
		
		public function set worldDestination(val:Point3D):void
		{
			_worldDestination = val;					
		}
		
		public function get worldCoords():Point3D
		{
			return _worldCoords;
		} 
		
		public function set worldCoords(val:Point3D):void
		{
			_worldCoords = val;					
		}
		
		public function get lastWorldPoint():Point3D
		{
			return _lastWorldPoint;
		} 
		
		public function set lastWorldPoint(val:Point3D):void
		{
			_lastWorldPoint = val;					
		}
		
		public function get realDestination():Point
		{
			return _realDestination;
		} 
		
		public function set realCoords(val:Point):void
		{
			_realCoords = val;
			realCoordX = _realCoords.x;
			realCoordY = _realCoords.y;					
		}
		
		public function get realCoords():Point
		{
			return _realCoords;
		} 
				
		public function set lastRealPoint(val:Point):void
		{
			_lastRealPoint = val;					
		}
		
		public function get lastRealPoint():Point
		{
			return _lastRealPoint;
		} 	
			
		public function set isMoving(val:Boolean):void
		{
			_isMoving = val;					
		}
		
		public function get isMoving():Boolean
		{
			return _isMoving;
		} 	
		
		public function set currentPath(val:ArrayCollection):void
		{
			_currentPath = val;
		}	
		
		public function get currentPath():ArrayCollection
		{
			return _currentPath;
		}
		
		public function set pathStep(val:int):void
		{
			_pathStep = val;
		}
		
		public function get pathStep():int
		{
			return _pathStep;
		}
		
		public function set thinger(val:Object):void
		{
			_thinger = val;
		}
		
		public function get thinger():Object
		{
			return _thinger;
		}
		
		public function set directionality(val:Point3D):void
		{
			_directionality = val;
		}
		
		public function get directionality():Point3D
		{
			return _directionality;
		}
		
		public function set fourDirectional(val:Boolean):void
		{
			_fourDirectional = val;
		}
		
		public function get fourDirectional():Boolean
		{
			return _fourDirectional;
		}
		
	}
}