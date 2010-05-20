package helpers
{
	import flash.filters.ColorMatrixFilter;
	
	public class ColorAdapter
	{
		public function ColorAdapter()
		{
			
		}

		public static function rgb255Transform( r:int, g:int, b:int ):ColorMatrixFilter
		{
			return ColorAdapter.rgbTransform( r/255.0, g/255.0, b/255.0 );
		}

		
		public static function rgbTransform( r:Number= 1.0, g:Number=1.0, b:Number=1.0):ColorMatrixFilter
        {
			var nM:Array =
				 [	r, 0, 0, 0, 0,
				 	0, g, 0, 0, 0,
				 	0, 0, b, 0, 0,
				 	0, 0, 0, 1, 0	] 
			
			return new ColorMatrixFilter( nM );
						
        }

	}
}