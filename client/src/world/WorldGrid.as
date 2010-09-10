package world
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import models.EssentialModelReference;
	import models.Structure;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	public class WorldGrid extends UIComponent
	{
		private static const GRID_ANGLE:Number = 0.5;
		
		public var _gridWidth:int;
		public var _gridHeight:int;
		public var _blockSize:int;
		public var _tile:Structure;
		public var _floorStyle:String;
		
		public var xGridCoord:Number;
		public var yGridCoord:Number;
		public var mc:MovieClip;
		
		public function WorldGrid(gridWidth:int, gridHeight:int, blockSize:int, tile:Structure, floorStyle:String)
		{
			_gridWidth = gridWidth;
			_gridHeight = gridHeight;
			_blockSize = blockSize;
			_tile = tile;
			_floorStyle = floorStyle;
			mc = new MovieClip();
			
			drawGridOutline();
			drawGridBlocks();
		}
		
		public function drawGridOutline():void
		{
//			var bisector:int = Math.sqrt( _gridWidth * _gridWidth + _gridHeight * _gridHeight );
//			var increment:int = ( _gridWidth * bisector ) / ( _gridWidth + _gridHeight );
//			var yCoord:int = bisector / ( _gridHeight + _gridWidth );
//			var xCoord:int = Math.sqrt( (_gridWidth * _gridWidth) / 2);

			mc.graphics.clear();
			mc.graphics.lineStyle(1, 0xB0DEFF, 0);
			
			var xCoord:Number = Math.sqrt( (_gridWidth * _gridWidth) / 2 );
			var yCoord:Number = xCoord * GRID_ANGLE;
			
//			mc.graphics.beginFill(0x92C5E8, 1);
			
//			Draws the outline of the space
			
			mc.graphics.lineTo(xCoord, yCoord);
			mc.graphics.lineTo(xCoord*2, 0);
			mc.graphics.lineTo(xCoord, -yCoord);
			mc.graphics.lineTo(0, 0);
//			mc.graphics.endFill();			
		}

		public function drawGridBlocks():void
		{
			xGridCoord = Math.sqrt( (_blockSize * _blockSize) / 2 );
			yGridCoord = xGridCoord * GRID_ANGLE;
			FlexGlobals.topLevelApplication.xGridCoord = xGridCoord;
			FlexGlobals.topLevelApplication.yGridCoord = yGridCoord;
			var totalBlocksWide:int = _gridWidth / _blockSize;
			var totalBlocksHigh:int = _gridHeight / _blockSize;
			var i:int;
			var j:int;
			
			mc.graphics.moveTo(0, 0);

			if (_floorStyle == "tile")
			{
				for (i=0; i<totalBlocksHigh; i++)
				{
					for (j=1; j<totalBlocksWide+1; j++)
					{
//						addTile(i, j);						
	//					mc.graphics.beginFill(0x000000, 0);
	//					mc.graphics.moveTo(xGridCoord*(j-1+i), yGridCoord*(j-1-i));
	//					mc.graphics.lineTo(xGridCoord*(j+i)+1, yGridCoord*(j-i));
	//					mc.graphics.lineTo(xGridCoord*(j+i+1), yGridCoord*(j-1-i));
	//					mc.graphics.lineTo(xGridCoord*(j+i), yGridCoord*(j-2-i));
	//					mc.graphics.moveTo(xGridCoord*(j-1+i), yGridCoord*(j-1-i));
	//					mc.graphics.endFill();
					}
				}		
			}			
			addChild(mc);	
		}
		
		public function updateDimensions():void
		{
			x = (parent.width)/2 - (mc.width/2);
			y = (parent.height)/2;
		}
		
		public function drawFloor():void
		{
			xGridCoord = Math.sqrt( (_blockSize * _blockSize) / 2 );
			yGridCoord = xGridCoord * GRID_ANGLE;
			FlexGlobals.topLevelApplication.xGridCoord = xGridCoord;
			FlexGlobals.topLevelApplication.yGridCoord = yGridCoord;
			var totalBlocksWide:int = _gridWidth / _blockSize;
			var totalBlocksHigh:int = _gridHeight / _blockSize;
			var i:int;
			var j:int;			
			
			for (i=0; i<totalBlocksHigh; i++)
			{
				for (j=1; j<totalBlocksWide+1; j++)
				{
					addTile(i, j);		
				}
			}	
		}
		
		private function addTile(i:int, j:int):void
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(_tile.mc);
			mc.x = xGridCoord*(j-1+i); 
			mc.y = yGridCoord*(j-1-i) - yGridCoord;
			mc.scaleX = 2;
			mc.scaleY = 2;
			addChild(mc);
		}
		
		public function set tile(val:Structure):void
		{
			_tile = val;
		}
		
		public function set floorStyle(val:String):void
		{
			_floorStyle = val;
		}
	}
}