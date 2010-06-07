package views
{
	import controllers.LevelManager;
	
	import models.Level;
	import models.User;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.core.UIComponent;

	public class UserInfoRenderer extends UIComponent
	{
		public var _myUser:User;
		public function UserInfoRenderer(myUser:User)
		{
			super();
			_myUser = myUser;
		}
		
		public static function createLevelBox(myUser:User, boxWidth:int, boxHeight:int, boxY:int, boxX:int, fontSize:int, filters:Array=null):Canvas
		{
			var levelBox:Canvas = new Canvas();
			levelBox.height = boxHeight;
			levelBox.setStyle("backgroundColor", 0x2DA2FC);
			levelBox.setStyle("borderStyle", "solid");
			levelBox.setStyle("borderColor", 0x091063);
			levelBox.setStyle("cornerRadius", 8);
			levelBox.x = boxX;
			levelBox.y = boxY;
			var levelText:Label = new Label();
			levelText.filters = filters;
			levelText.text = myUser.level.rank.toString();
			levelText.setStyle("color", 0xffffff);
			levelText.setStyle("textAlign", "center");
			levelText.y = (boxHeight - fontSize - 8)/2;
			levelText.x = -1;
//			levelText.setStyle("fontFamily", "Museo-Slab-900");
			levelText.setStyle("fontSize", fontSize);
			levelBox.addChild(levelText);
			return levelBox;
		}	
		
		public static function getLevelText(myUser:User, levelManager:LevelManager, fontSize:int, filters:Array):Label
		{
			var levelText:Label = new Label();
			levelText.filters = filters;
			levelText.text = myUser.level.rank.toString();
			levelText.setStyle("color", 0xffffff);
			levelText.setStyle("textAlign", "center");
			levelText.y = 0;
			levelText.x = 0;
//			levelText.setStyle("fontFamily", "Museo-Slab-900");
			levelText.setStyle("fontSize", fontSize);
			return levelText;			
		}
		
		public static function createLevelProgressBar(myUser:User, levelManager:LevelManager, barWidth:int, barHeight:int, backgroundColor:Object, borderColor:Object, progressColor:Object):Canvas
		{
			var canvas:Canvas = new Canvas();
			canvas.height = barHeight;
			canvas.width = barWidth;
			canvas.clipContent = false;
			var backing:Canvas = new Canvas();
			backing.setStyle("backgroundColor", backgroundColor);
			backing.setStyle("cornerRadius", 8);
			backing.setStyle("borderColor", borderColor);
			backing.setStyle("borderStyle", "solid");
			backing.width = barWidth + 2;
			backing.height = barHeight;
			var progress:Canvas = new Canvas();
			var xpFraction:Number = levelManager.getLevelProgressPercentage(myUser.level, myUser.xp);
			progress.width = barWidth * xpFraction;
			progress.height = barHeight;
			progress.setStyle("backgroundColor", progressColor);
			progress.setStyle("borderStyle", "solid");
			progress.setStyle("borderColor", borderColor);
			progress.x = 4;
			backing.x = 4;
			progress.y = 2;
			backing.y = 2;
			var cfg:ColorFrameGreen = new ColorFrameGreen();
			cfg.width = barWidth + 8; 
			cfg.height = barHeight + 6;
			var uic:UIComponent = new UIComponent();
			uic.addChild(cfg);
			var mask:Canvas = new Canvas();
			mask.width = barWidth;
			mask.height = barHeight;
			mask.setStyle("cornerRadius", 8);
			mask.setStyle("borderStyle", "solid");
			progress.mask = mask;
			backing.mask = mask;
			canvas.addChild(backing);
			canvas.addChild(mask);
			canvas.addChild(progress);
			canvas.addChild(uic);
			return canvas;
		}	
		
	}
}