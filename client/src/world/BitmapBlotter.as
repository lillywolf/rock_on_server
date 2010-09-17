package world
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	
	import models.EssentialModelReference;
	import models.OwnedDwelling;
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	
	import rock_on.Person;
	
	import views.AssetBitmapData;
	import views.BouncyBitmap;
	import views.ExpandingMovieclip;
	
	public class BitmapBlotter extends EventDispatcher
	{
		public static const FOOT_CONSTANT:int = 9;
		public static const WIDTH_BUFFER:int = 10;
		public static const HEIGHT_BUFFER:int = 20;
		public var _backgroundCanvas:Canvas;
		public var bitmapReferences:ArrayCollection;
		public var incrementX:int;
		public var incrementY:int;
		public var relWidth:int;
		public var relHeight:int;
		public var expectedAssetCount:int;
		public var _myWorld:World;
		
		public function BitmapBlotter(target:IEventDispatcher=null)
		{
			super(target);
			bitmapReferences = new ArrayCollection();
			bitmapReferences.addEventListener(CollectionEvent.COLLECTION_CHANGE, onNewBitmapReference);
		}
		
		public function onNewBitmapReference(evt:CollectionEvent):void
		{
			if (bitmapReferences.length == expectedAssetCount)
			{
				bitmapReferences.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onNewBitmapReference);
//				renderInitialBitmap();
//				renderAssociatedMovieClips();
			}
		}
		
		public function addBitmap(asset:ActiveAsset, animation:String=null, frameNumber:int = 0, reflect:Boolean=false):AssetBitmapData
		{
			var abd:AssetBitmapData = this.getMatchFromBitmapReferences(asset);
			if (abd)
				this.updateAssetBitmapDataLocation(abd, asset);
			else
			{
				abd = createNewAssetBitmapData(asset, animation, frameNumber, reflect);
				bitmapReferences.addItem(abd);
			}
			return abd;
		}
		
		public function addRenderedBitmap(asset:ActiveAsset, animation:String=null, frameNumber:int = 0, reflect:Boolean=false):void
		{
			var abd:AssetBitmapData = addBitmap(asset, animation, frameNumber, reflect);
			this.getBitmapForPerson(abd);
			_backgroundCanvas.rawChildren.addChild(abd.bitmap);
		}
		
		public function addInitialBitmap(abd:AssetBitmapData, animation:String, frameNumber:int=0):void
		{
			updateAssetBitmapData(abd, abd.activeAsset, animation, frameNumber);
			bitmapReferences.addItem(abd);
		}
		
		public function updateAssetBitmapDataLocation(abd:AssetBitmapData, asset:ActiveAsset):void
		{
			abd.activeAsset = asset;
			abd.realCoordX = asset.realCoords.x;
			abd.realCoordY = asset.realCoords.y;		
		}
		
		public function updateAssetBitmapData(abd:AssetBitmapData, asset:ActiveAsset, animation:String, frameNumber:int=0):void
		{
			abd.activeAsset = asset;
			var newMc:MovieClip = getNewMovieClip(abd.activeAsset, animation, frameNumber);
			abd.mc = newMc;
			abd.realCoordX = asset.realCoords.x;
			abd.realCoordY = asset.realCoords.y;
		}
		
		public function createNewAssetBitmapData(asset:ActiveAsset, animation:String=null, frameNumber:int=0, reflect:Boolean=false):AssetBitmapData
		{
			var abd:AssetBitmapData = new AssetBitmapData();
			var newMc:MovieClip = getNewMovieClip(asset, animation, frameNumber);
			abd.mc = newMc;
			abd.reflected = reflect;
			abd.activeAsset = asset;
			abd.realCoordX = asset.realCoords.x;
			abd.realCoordY = asset.realCoords.y;	
			return abd;
		}
		
		public function getMatchingBitmapDataForStructure(os:OwnedStructure):AssetBitmapData
		{
			for each (var abd:AssetBitmapData in this.bitmapReferences)
			{
				if (abd.activeAsset.thinger is OwnedStructure)
				{
					if (abd.activeAsset.thinger.id == os.id)
						return abd;
				}
			}
			return null;
		}
		
		public function removeOwnedStructure(os:OwnedStructure):void
		{
			var abd:AssetBitmapData = this.getMatchingBitmapDataForStructure(os);
			this.removeBitmapFromBlotter(abd);
		}
		
		public function getNewMovieClip(asset:ActiveAsset, animation:String=null, frameNumber:int = 0):MovieClip
		{
			var newMc:MovieClip = new MovieClip();
			if (asset is ActiveAssetStack)
			{
				var newMcs:ArrayCollection = (asset as ActiveAssetStack).getMovieClipStackCopy(animation, frameNumber);	
				for each (var mc:MovieClip in newMcs)
				{
					newMc.addChild(mc);
				}
			}
			else
			{
				newMc = EssentialModelReference.getMovieClipCopy((asset.thinger as OwnedStructure).structure.mc);
				newMc.gotoAndPlay(1);
				newMc.stop();
			}
			return newMc;			
		}
		
		public function addStructureAsBitmap(asset:ActiveAsset):void
		{
			var newMc:MovieClip = EssentialModelReference.getMovieClipCopy(asset.movieClip);
			var abd:AssetBitmapData = new AssetBitmapData();
			abd.activeAsset = asset;
			abd.realCoordX = asset.realCoordX;
			abd.realCoordY = asset.realCoordY;
			abd.mc = newMc;
			bitmapReferences.addItem(abd);	
		}
		
		public function getMatchFromBitmapReferences(asset:ActiveAsset):AssetBitmapData
		{
			for each (var abd:AssetBitmapData in bitmapReferences)
			{
				if (abd.activeAsset == asset)
					return abd;
			}
			return null;
		}
		
		public function getMatchingBitmap(asset:ActiveAsset):Bitmap
		{
			for each (var abd:AssetBitmapData in bitmapReferences)
			{
				if (abd.activeAsset == asset)
					return abd.bitmap;
			}	
			return null;			
		}
		
		public function removeRenderedBitmap(asset:ActiveAsset):void
		{
			var abd:AssetBitmapData = getMatchFromBitmapReferences(asset);
			if (abd)
			{
				if (abd.bitmap)
				{
					if (_backgroundCanvas.rawChildren.contains(abd.bitmap))
						_backgroundCanvas.removeChild(abd.bitmap.parent);	
				}
			}			
		}
		
		public function removeBitmapFromBlotter(abd:AssetBitmapData):void
		{
			if (abd.bitmap)
			{
				if (_backgroundCanvas.rawChildren.contains(abd.bitmap))
				{
					_backgroundCanvas.rawChildren.removeChild(abd.bitmap);
					var index:int = bitmapReferences.getItemIndex(abd);
					bitmapReferences.removeItemAt(index);	
				}
			}
		}
		
		public function removeBitmapFromReferences(asset:ActiveAsset):void
		{
			var abd:AssetBitmapData = getMatchFromBitmapReferences(asset);
			var index:int = bitmapReferences.getItemIndex(abd);
			bitmapReferences.removeItemAt(index);				
		}
		
		public function evaluateBitmap(asset:ActiveAsset):void
		{
			
		}
		
		public function renderInitialBitmap():void
		{
			sortBitmaps();
			renderBitmaps();
			trace("initial bitmap rendered");
		}
		
		public function renderAssociatedMovieClips():void
		{
			var yAdjustment:Number = getYAdjustment();
			for each (var abd:AssetBitmapData in this.bitmapReferences)
			{
				if (abd.moodClip)
				{
					abd.moodClip.x = abd.bitmap.x + (abd.activeAsset.width - abd.moodClip.width)/2;
					abd.moodClip.y = abd.bitmap.y + yAdjustment - abd.moodClip.height + 5;
					_myWorld.addChild(abd.moodClip);
					abd.startMoodClipBounce();
				}
			}		
		}
		
		public function getYAdjustment():Number
		{
			var rect:Rectangle = _backgroundCanvas.getBounds(_myWorld);
			return rect.y;
		}
		
		public function renderReplacedBitmaps():void
		{
			updateBitmapLocations();
			sortBitmaps();
			renderUpdatedBitmaps();
		}
		
		public function renderUpdatedBitmaps():void
		{
			for each (var abd:AssetBitmapData in bitmapReferences)
			{
				if (abd)
					_backgroundCanvas.rawChildren.addChild(abd.bitmap);
			}	
		}
		
		public function updateBitmapLocations():void
		{
			for each (var abd:AssetBitmapData in bitmapReferences)
			{
				if (abd)
					moveRenderedBitmap(abd);
			}
		}
		
		public function clearBitmaps():void
		{
			_backgroundCanvas.removeAllChildren();
		}
		
		public function renderBitmaps():void
		{
			var i:int = 0;
			for each (var abd:AssetBitmapData in bitmapReferences)
			{
				var bp:Bitmap;
				if (abd)
				{
					if (abd.activeAsset is Person)
						bp = getBitmapForPerson(abd);
					else
						bp = getBitmapForStructure(abd);
					var uic:UIComponent = new UIComponent();
					uic.addChild(bp);
					_backgroundCanvas.addChild(uic);
					bp = null;
					i++;
				}
			}
		}
		
		public function getNewBitmap(abd:AssetBitmapData):Bitmap
		{
			var bp:Bitmap;
			if (abd.activeAsset is Person)
			{
				bp = getBitmapForPerson(abd);
			}
			else
			{
				bp = getBitmapForStructure(abd);
			}	
			return bp;
		}
		
		public function moveRenderedBitmap(abd:AssetBitmapData):void
		{
			if (abd.bitmap)
			{
				var bmd:BitmapData = abd.bitmap.bitmapData;
				var bp:Bitmap = new Bitmap();
				bp.bitmapData = bmd;
				bp.opaqueBackground = null;				
				bp.x = abd.realCoordX - abd.mc.width/2;
				bp.y = relHeight/2 + abd.realCoordY - abd.mc.height;			
				//			abd.bitmap.transform.matrix.tx = (abd.realCoordX - abd.mc.width/2) - abd.bitmap.x;
				//			abd.bitmap.transform.matrix.ty = (relHeight/2 + abd.realCoordY - abd.mc.height) - abd.bitmap.y;	
				abd.bitmap = bp;
			}
		}
		
		public function getBitmapForStructure(abd:AssetBitmapData):Bitmap
		{
			var bmd:BitmapData = new BitmapData(abd.mc.width, abd.mc.height, true, 0x00000000);
			var bottomSlice:Number = (abd.mc.transform.pixelBounds.bottom/abd.mc.transform.pixelBounds.height)*abd.mc.height;
			var rect:Rectangle = new Rectangle(0, 0, abd.mc.width + WIDTH_BUFFER, abd.mc.height + bottomSlice);
			var matrix:Matrix = new Matrix();
			matrix.tx = abd.mc.width/2;	
			matrix.ty = abd.mc.height;
			bmd.draw(abd.mc, matrix, new ColorTransform(), null, rect);
			var bp:Bitmap = new Bitmap();
			bp.bitmapData = bmd;
			bp.opaqueBackground = null;				
			bp.x = abd.realCoordX - abd.mc.width/2;
			bp.y = relHeight/2 + abd.realCoordY - abd.mc.height;
			abd.bitmap = bp;
			return bp;
		}
		
		public function clearFilters():void
		{
			for each (var abd:AssetBitmapData in this.bitmapReferences)
			{
				if (!(abd.activeAsset as Person).doNotClearFilters)
				{
					abd.bitmap.filters = null;	
					if (abd.moodClip)
					{
						abd.moodClip.filters = null;					
					}
				}
			}		
		}
		
		public static function getBitmapForMovieClip(mc:MovieClip):Bitmap
		{
			var bmd:BitmapData = new BitmapData(mc.width, mc.height, true, 0x00000000);
			var bottomSlice:Number = (mc.transform.pixelBounds.bottom/mc.transform.pixelBounds.height)*mc.height;
			var rect:Rectangle = new Rectangle(0, 0, mc.width + WIDTH_BUFFER, mc.height + bottomSlice);
			var matrix:Matrix = new Matrix();
			matrix.tx = mc.width/2;	
			matrix.ty = mc.height - bottomSlice;
			bmd.draw(mc, matrix, new ColorTransform(), null, rect);
			var bp:Bitmap = new Bitmap();
			bp.bitmapData = bmd;
			bp.opaqueBackground = null;				
			bp.x = mc.width/2;
			bp.y = -mc.height/2;
			return bp;			
		}
		
		public function getBitmapForPerson(abd:AssetBitmapData):Bitmap
		{
			abd.mc.scaleX = 0.5;
			abd.mc.scaleY = 0.5;
			var bmd:BitmapData = new BitmapData(abd.mc.width + WIDTH_BUFFER, abd.mc.height + FOOT_CONSTANT, true, 0x00000000);
			var rect:Rectangle = new Rectangle(0, 0, abd.mc.width + WIDTH_BUFFER, abd.mc.height + FOOT_CONSTANT);
			var matrix:Matrix = new Matrix();
			if (abd.reflected)
				matrix.scale(-0.5, 0.5);
			else
				matrix.scale(0.5, 0.5);			
			matrix.tx = abd.mc.width/2 + WIDTH_BUFFER/2;
			matrix.ty = abd.mc.height;
			abd.transformedHeight = matrix.ty;
			abd.transformedWidth = matrix.tx;
			bmd.draw(abd.mc, matrix, new ColorTransform(), null, rect);
			var bp:Bitmap = new Bitmap();
			bp.bitmapData = bmd;
			bp.opaqueBackground = null;				
			bp.x = abd.realCoordX - abd.mc.width/2;
			bp.y = relHeight/2 + abd.realCoordY - abd.mc.height;
			abd.bitmap = bp;
			return bp;
		}
		
		public function undrawPreviousBitmaps():void
		{
	
		}
		
		public function addMoodToAssetBitmapData(asset:ActiveAssetStack, mood:Object, moodClip:BouncyBitmap = null):void
		{
			var abd:AssetBitmapData = getMatchFromBitmapReferences(asset);
			abd.mood = mood;
			abd.moodClip = moodClip;
		}
		
		public function removeMoodClipFromBitmap(asset:ActiveAsset):BouncyBitmap
		{
			var abd:AssetBitmapData = getMatchFromBitmapReferences(asset);
			if (_myWorld.contains(abd.moodClip))
				_myWorld.removeChild(abd.moodClip);
			return abd.moodClip;
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			for each (var abd:AssetBitmapData in bitmapReferences)
			{
				if (isUnderMousePoint(abd))
				{
					backgroundCanvas.buttonMode = true;
					break;
				}
				else
				{
					backgroundCanvas.buttonMode = false;
				}
			}
		}
		
		public function isUnderMousePoint(abd:AssetBitmapData):Boolean
		{
			if (backgroundCanvas.contains(abd.bitmap))
			{
				var bounds:Rectangle = new Rectangle(abd.bitmap.x, abd.bitmap.y, abd.mc.width, abd.mc.height);
				if (bounds.contains(backgroundCanvas.mouseX, backgroundCanvas.mouseY))
				{
					return true;
				}				
			}			
			return false;
		}
		
		public function sortBitmaps():void
		{
			var sortField:SortField = new SortField("realCoordY");
			sortField.numeric = true;
			var sort:Sort = new Sort();
			sort.fields = [sortField];
			bitmapReferences.sort = sort;
			bitmapReferences.refresh();					
		}
		
		public function set myWorld(val:World):void
		{
			_myWorld = val;
		}
		
		public function set backgroundCanvas(val:Canvas):void
		{
			_backgroundCanvas = val;
//			_backgroundCanvas.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		public function get backgroundCanvas():Canvas
		{
			return _backgroundCanvas;
		}
	}	
}