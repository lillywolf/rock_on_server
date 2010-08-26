package world
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import models.EssentialModelReference;
	
	import mx.collections.ArrayCollection;
	
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
		public var _actualBounds:Rectangle;
		
		public var realCoordY:Number;
		public var realCoordX:Number;
		
		public var _currentPath:ArrayCollection;
		public var _pathStep:int;
		public var _directionality:Point3D;
		
		public var _thinger:Object;
		public var currentAnimation:String;
		public var currentFrameNumber:int;
		
		public var bitmapData:BitmapData;
		public var bitmap:Bitmap;
		public var doNotClearFilters:Boolean;
		public var unclearableFilters:Array;				
		public var reflected:Boolean;
		public var _scale:Number;
		public var toppers:ArrayCollection;
		public var rotated:Boolean;
		public var flipped:Boolean;
		public var rotationDegree:int;
		
		public static const X_BITMAP_BUFFER:int = 40;
		public static const Y_BITMAP_BUFFER:int = 12;
		public static const MOVE_DELAY_TIME:int = 200;
		
		public function ActiveAsset(movieClip:MovieClip=null, scale:Number=1)
		{
			super();
			_directionality = new Point3D(0, 0, 0);
			
			if (scale)
			{
				_scale = scale;
			}
			if (movieClip)
			{
				_movieClip = movieClip;
				switchToBitmap();				
//				addChild(_movieClip);			
				_movieClip.addEventListener(MouseEvent.CLICK, onMouseClicked);
			}
			unclearableFilters = new Array();	
		}
		
		public function getNextPointAlongPath():Point3D
		{
			if (currentPath.length > pathStep)
			{			
				var nextPoint:Point3D = currentPath.getItemAt(pathStep) as Point3D;
			}
			return nextPoint;
		}			
		
		private function onMouseClicked(evt:MouseEvent):void
		{
			trace(evt.target.name, flash.utils.getQualifiedClassName(evt.target));					
		}
		
		public function switchToBitmap():void
		{
			var mc:Sprite = createMovieClipForBitmap();
			var mcBounds:Rectangle = mc.getBounds(_world);
			var heightDiff:Number = Math.abs(mcBounds.top - this.y);
			var widthDiff:Number = getWidthDifferential(mcBounds);			
			scaleMovieClip(mc);
			bitmapData = new BitmapData(mc.width, mc.height, true, 0x000000);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, widthDiff/2, heightDiff);
			var rect:Rectangle = new Rectangle(0, 0, mc.width, mc.height + Y_BITMAP_BUFFER);
			scaleMatrix(matrix, mc.width);
			bitmapData.draw(mc, matrix, new ColorTransform(), null, rect);
			bitmap = new Bitmap(bitmapData);
			bitmap.x = -mc.width/2;
			bitmap.y = -heightDiff * _scale;
			bitmap.opaqueBackground = null;
			addChild(bitmap);	
		}
		
		public function getHeightDifferential(mcBounds:Rectangle):Number
		{
			var heightDiff:Number;
			heightDiff = Math.abs(mcBounds.top);
			return heightDiff;
		}		
		
		public function getWidthDifferential(mcBounds:Rectangle):Number
		{
			var widthDiff:Number = Math.abs(mcBounds.width);
			return widthDiff;
		}	
		
		public function placeBitmap(bitmap:Bitmap, mc:Sprite, heightDiff:Number, tx:Number = 0):void
		{
			bitmap.y = -heightDiff * _scale;				
			bitmap.x = -mc.width/2 - X_BITMAP_BUFFER;
		}
		
		public function scaleMatrix(matrix:Matrix, tx:Number = 0):void
		{
			if (reflected && _scale)
			{
				matrix.scale(-(_scale), _scale);
				matrix.tx += tx;
			}
			else if (_scale)
			{
				matrix.scale(_scale, _scale);			
			}
		}		
		
		public function scaleMovieClip(mc:Sprite):void
		{
			if (_scale)
			{
				if (reflected)
				{
					mc.scaleX = -(_scale);
				}
				else
				{
					mc.scaleX = _scale;
				}
				mc.scaleY = _scale;
			}
		}			
		
		public function createMovieClipForBitmap():Sprite
		{
			var newClip:MovieClip = EssentialModelReference.getMovieClipCopy(_movieClip);
			if (!newClip)
			{
				newClip = EssentialModelReference.getMovieClipCopyFromSystem(_movieClip);
			}
			newClip.scaleY = 1;
			if (rotated && newClip.framesLoaded > 1)
				newClip.gotoAndStop(2);
			else
				newClip.gotoAndStop(1);
			if (flipped)
				newClip.scaleX = -1;
			else
				newClip.scaleX = 1;
			return newClip;
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
			_movieClip = val;					
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
		
		public function set actualBounds(val:Rectangle):void
		{
			_actualBounds = val;
		}
		
		public function get actualBounds():Rectangle
		{
			return _actualBounds;
		}	
		
		public function set scale(val:Number):void
		{
			_scale = val;
			
			if (movieClip)
			{
				movieClip.scaleX = _scale;
				movieClip.scaleY = _scale;
			}
		}
	}
}		