package world
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	public class WorldGrid extends UIComponent
	{
		private static const GRID_ANGLE:Number = 0.5;
		
		public var _gridWidth:int;
		public var _gridHeight:int;
		public var _blockSize:int;
		
		public var xGridCoord:Number;
		public var yGridCoord:Number;
		public var mc:MovieClip;
		
		public function WorldGrid(gridWidth:int, gridHeight:int, blockSize:int)
		{
			_gridWidth = gridWidth;
			_gridHeight = gridHeight;
			_blockSize = blockSize;
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
			mc.graphics.lineStyle(1,0xB0DEFF);
			
			var xCoord:Number = Math.sqrt( (_gridWidth * _gridWidth) / 2 );
			var yCoord:Number = xCoord * GRID_ANGLE;
			
//			mc.graphics.beginFill(0x92C5E8, 1);
			
			mc.graphics.lineTo(xCoord, yCoord);
			mc.graphics.lineTo(xCoord*2, 0);
			mc.graphics.lineTo(xCoord, -yCoord);
			mc.graphics.lineTo(0, 0);
			mc.graphics.endFill();			
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
	
//			for (i=0; i<totalBlocksHigh; i++)
//			{
//				for (j=1; j<totalBlocksWide+1; j++)
//				{
//					mc.graphics.beginFill(0x000000, 0);
//					mc.graphics.moveTo(xGridCoord*(j-1+i), yGridCoord*(j-1-i));
//					mc.graphics.lineTo(xGridCoord*(j+i)+1, yGridCoord*(j-i));
//					mc.graphics.lineTo(xGridCoord*(j+i+1), yGridCoord*(j-1-i));
//					mc.graphics.lineTo(xGridCoord*(j+i), yGridCoord*(j-2-i));
//					mc.graphics.moveTo(xGridCoord*(j-1+i), yGridCoord*(j-1-i));
//					mc.graphics.endFill();
//				}
//			}		
			
			addChild(mc);	
		}
	}
}