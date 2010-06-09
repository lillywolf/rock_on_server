package world
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import models.OwnedStructure;
	
	import mx.collections.ArrayCollection;
	
	import rock_on.BandMember;
	import rock_on.Passerby;
	import rock_on.Person;
	
	import views.AssetBitmapData;
	
	public class AssetGenius extends EventDispatcher
	{
		public var _assetRenderer:AssetRenderer;
		public var _bitmapBlotter:BitmapBlotter;
		public var _myWorld:World;
		
		public var masterAssetList:ArrayCollection;

		public function AssetGenius(assetRenderer:AssetRenderer, bitmapBlotter:BitmapBlotter, myWorld:World, target:IEventDispatcher=null)
		{
			super(target);
			_assetRenderer = assetRenderer;
			_bitmapBlotter = bitmapBlotter;
			_myWorld = myWorld;
			
			masterAssetList = new ArrayCollection();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);			
		}
		
		private function onEnterFrame(evt:Event):void
		{
			var abd:AssetBitmapData;
			var overlaps:ArrayCollection = new ArrayCollection();
			for each (abd in masterAssetList)
			{
				if (abd.moving)
				{
					var assetOverlaps:ArrayCollection = getNewOverlappingAssets(abd);
					for each (var overlapper:AssetBitmapData in assetOverlaps)
					{
						if (!(overlaps.contains(overlapper)))
						{
							overlaps.addItem(overlapper);						
						}
					}
				}
			}
			for each (abd in masterAssetList)
			{
				if (abd.rendered && !(overlaps.contains(abd)))
				{
					copyFromRendererToBlotter(abd);
				}
			}
			for each (abd in overlaps)
			{
				if (!(isInAssetRenderer(abd.activeAsset)) && isInBitmapBlotter(abd.activeAsset))
				{
					_bitmapBlotter.removeBitmapFromBlotter(abd.activeAsset);
					_assetRenderer.unsortedAssets.addItem(abd.activeAsset);
					abd.rendered = true;
				}
				else if (isInAssetRenderer(abd.activeAsset) && isInBitmapBlotter(abd.activeAsset))
				{
					throw new Error("What in the sam hill?");
				}
			}
		}	
		
		public function getNewOverlappingAssets(abd:AssetBitmapData):ArrayCollection
		{
			var overlaps:ArrayCollection = new ArrayCollection();
			
			for each (var bitmappedABD:AssetBitmapData in _bitmapBlotter.bitmapReferences)
			{
				if (_bitmapBlotter.doesBitmapOverlapWithAsset(abd, bitmappedABD.bitmap))
				{
					overlaps.addItem(bitmappedABD);
				}
			}
			
			return overlaps;
		}
		
		public function evaluateMoveActivity(asset:ActiveAsset, bitmapBlottingEnabled:Boolean, destination:Point3D=null, avoidStructures:Boolean=true, avoidPeople:Boolean=false):void
		{
			updateMasterAssetList(asset);
			
			if (asset is Passerby || asset is BandMember)
			{
				bitmapBlottingEnabled = false;
			}
			
			if (bitmapBlottingEnabled)
			{
				evaluateMoveActivityForBlotting(asset, destination, avoidStructures, avoidPeople);
			}
			else
			{
				(asset as Person).moveCustomerLater(destination, avoidStructures, avoidPeople);
			}
		}
		
		public function evaluateStandActivity(asset:ActiveAsset, bitmapBlottingEnabled:Boolean, animation:String, frameNumber:int=0):void
		{
			updateMasterAssetList(asset);

			if (bitmapBlottingEnabled)
			{
				evaluateStandActivityForBlotting(asset, animation, frameNumber);
			}
		}
		
		public function getMatchingABD(asset:ActiveAsset):AssetBitmapData
		{
			for each (var abd:AssetBitmapData in masterAssetList)
			{
				if (abd.activeAsset == asset)
				{
					return abd;
				}
			}
			return null;
		}
		
		public function evaluateMoveActivityForBlotting(asset:ActiveAsset, destination:Point3D=null, avoidStructures:Boolean=true, avoidPeople:Boolean=false):void
		{
			var abd:AssetBitmapData = getMatchingABD(asset);
			if (_bitmapBlotter.bitmapReferences.contains(abd))
			{
				if (_assetRenderer.unsortedAssets.contains(asset))
				{
					throw new Error("Assets are in both blotter and renderer");
				}
				else
				{
					moveFromBlotterToRenderer(abd, destination, avoidStructures, avoidPeople);
				}
			}
		}
		
		public function evaluateStandActivityForBlotting(asset:ActiveAsset, animation:String, frameNumber:int=0):void
		{
			var abd:AssetBitmapData = getMatchingABD(asset);
			if (_assetRenderer.unsortedAssets.contains(asset))
			{
				if (_bitmapBlotter.bitmapReferences.contains(abd))
				{
					throw new Error("Assets are in both blotter and renderer");
				}
				else
				{
					standFromRendererToBlotter(abd, animation, frameNumber);
				}
			}
			else
			{
				if (!(_bitmapBlotter.bitmapReferences.contains(abd)))
				{
					standToBlotter(abd, animation, frameNumber);
				}
			}
		}
		
		public function updateMasterAssetList(asset:ActiveAsset):void
		{
			for each (var abd:AssetBitmapData in masterAssetList)
			{
				if (abd.activeAsset == asset)
				{
					updateABD(abd, asset);
					break;
				}
			}
			createNewABD(asset);
		}
		
		public function moveFromBlotterToRenderer(abd:AssetBitmapData, destination:Point3D=null, avoidStructures:Boolean=true, avoidPeople:Boolean=true):void
		{
			abd.activeAsset.addEventListener(WorldEvent.MOVE_DELAY_COMPLETE, onMoveDelayComplete);
			abd.activeAsset.startMoveDelayTimer();
			abd.moving = true;
			abd.standing = false;
			abd.rendered = true;
			if (abd.activeAsset is Person)
			{
				(abd.activeAsset as Person).moveCustomerLater(destination, avoidStructures, avoidPeople);
			}
		}
		
		public function standFromRendererToBlotter(abd:AssetBitmapData, animation:String, frameNumber:int=0):void
		{
			removeAssetFromRenderer(abd);
			abd.standing = true;
			abd.moving = false;
			abd.rendered = false;
			_bitmapBlotter.reIntroduceBitmap(abd, animation, frameNumber);
		}
		
		public function standToBlotter(abd:AssetBitmapData, animation:String, frameNumber:int=0):void
		{
			abd.standing = true;
			abd.moving = false;
			abd.rendered = false;
			_bitmapBlotter.addInitialBitmap(abd, animation, frameNumber);
		}
		
		public function copyFromRendererToBlotter(abd:AssetBitmapData):void
		{
			removeAssetFromRenderer(abd);
			abd.standing = true;
			abd.moving = false;
			abd.rendered = false;
			_bitmapBlotter.reIntroduceBitmap(abd);			
		}
		
		public function removeAssetFromRenderer(abd:AssetBitmapData):void
		{
			var index:int = _assetRenderer.unsortedAssets.getItemIndex(abd.activeAsset);
			_assetRenderer.unsortedAssets.removeItemAt(index);
			abd.rendered = false;
		}
		
		public function updateABD(abd:AssetBitmapData, asset:ActiveAsset):void
		{
			
		}
		
		public function createNewABD(asset:ActiveAsset):void
		{
			var abd:AssetBitmapData = new AssetBitmapData();
			abd.activeAsset = asset;
			abd.realCoordX = asset.realCoords.x;
			abd.realCoordY = asset.realCoords.y;
			masterAssetList.addItem(abd);
		}
		
		public function getAllRenderedStructures():ArrayCollection
		{
			var renderedStructureList:ArrayCollection = new ArrayCollection();
			for each (var abd:AssetBitmapData in masterAssetList)
			{
				if (abd.reference is OwnedStructure)
				{
					renderedStructureList.addItem(abd);
				}
			}
			return renderedStructureList;
		}
		
		public function getAllRenderedCreatures():ArrayCollection
		{
			var renderedPersonList:ArrayCollection = new ArrayCollection();
			for each (var abd:AssetBitmapData in masterAssetList)
			{
				if (abd.reference is Person)
				{
					renderedPersonList.addItem(abd);
				}
			}
			return renderedPersonList;			
		}
		
		private function onMoveDelayComplete(evt:WorldEvent):void
		{
			var asset:ActiveAsset = evt.activeAsset;
			if (asset is Person)
			{
				removeAssetFromBlotter(asset);
			}
			else
			{
				throw new Error("Attempting to move a non-person");
			}
		}		
		
		public function removeAssetFromBlotter(asset:ActiveAsset):void
		{
			_bitmapBlotter.removeBitmapFromBlotter(asset);
		}		
		
		public function isInAssetRenderer(asset:ActiveAsset):Boolean
		{
			if (_assetRenderer.unsortedAssets.contains(asset))
			{
				return true;
			}
			return false;
		}
		
		public function isInBitmapBlotter(asset:ActiveAsset):Boolean
		{
			if (_bitmapBlotter.getMatchFromBitmapReferences(asset))
			{
				return true;
			}
			return false;
		}

	}
}