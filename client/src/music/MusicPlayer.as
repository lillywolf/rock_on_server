package music
{
	import controllers.SongController;
	
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import helpers.TruncatedText;
	
	import models.OwnedSong;
	import models.Song;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	import rock_on.SpecialButton;
	
	import views.UICanvas;
		
	public class MusicPlayer extends UIComponent
	{
		public var _songController:SongController;
		public var musicButton:SpecialButton;
		public var musicRollout:Canvas;
		public var boxHeight:int;
		public var songVBox:VBox;
		[Bindable] public var songsText:Label;
		[Bindable] public var numSongs:int;
		
		[Embed(source="../libs/Museo_Slab_900.otf",
                    fontFamily="Museo_Slab_900",
                    mimeType="application/x-font",
                    embedAsCFF="true")]
		public const Museo_Slab_900_Font:Class;	
		[Embed(source="../libs/icons/arrow_right_small.png")]
		public var arrowScrollerRight:Class;
		[Embed(source="../libs/icons/arrow_left_small.png")]
		public var arrowScrollerLeft:Class;		
		[Embed(source="../libs/icons/close_btn.png")]
		public var closeButton:Class;		
		[Embed(source="../libs/icons/play_button.png")]
		public var playButtonClass:Class;		
		[Embed(source="../libs/icons/add_button.png")]
		public var addButtonClass:Class;		
		[Embed(source="../libs/icons/play_button_big.png")]
		public var playButtonBigClass:Class;		
		[Embed(source="../libs/icons/add_button_big.png")]
		public var addButtonBigClass:Class;		
		[Embed(source="../libs/icons/stars.png")]
		public var starsIcon:Class;		
		
		public static const DISTANCE_FROM_TOP:int = 220;
		public static const DISTANCE_FROM_LEFT:int = 20;
		public static const SONG_HEIGHT:int = 26;
		public static const SONG_INTERNAL_PADDING:int = 4;
		public static const SONG_EXTERNAL_PADDING:int = 0;
		public static const TOP_PADDING:int = 14;
		public static const MAX_SONGS:int = 5;
		public static const BOX_WIDTH:int = 430;
		
		public function MusicPlayer(songController:SongController)
		{
			super();
			_songController = songController;
			createMusicRollout();
			addSongsInfo();
			addMusicButton();
		}
		
		public function addSongsInfo():void
		{
			songsText = new Label();
			songsText.width = BOX_WIDTH;
			songsText.height = 22;
			numSongs = _songController.owned_songs.length;
			songsText.text = numSongs.toString() + " Songs";
			MusicPlayer.setTextStyle(songsText, 16, 0xffffff, true);
			songsText.x = DISTANCE_FROM_LEFT;
			songsText.y = DISTANCE_FROM_TOP - 38;
			addChild(songsText);
		}
		
		public function styleMusicRollout():void			
		{
			var backCanvas:Canvas = new Canvas();
			backCanvas.setStyle("backgroundColor", 0x9EDFFF);
			backCanvas.setStyle("cornerRadius", 12);
			backCanvas.setStyle("borderStyle", "solid");
			backCanvas.width = BOX_WIDTH;
			var shownSongs:Number = Math.min(_songController.owned_songs.length, MAX_SONGS);
			boxHeight = shownSongs * (SONG_HEIGHT) + (shownSongs - 1) * SONG_EXTERNAL_PADDING + 2 * TOP_PADDING;
			backCanvas.height = boxHeight;
			musicRollout.addChild(backCanvas);
			var topCanvas:Canvas = new Canvas();
			topCanvas.height = TOP_PADDING;
			topCanvas.width = BOX_WIDTH;
			topCanvas.setStyle("backgroundColor", 0xC9F0FF);
//			musicRollout.addChild(topCanvas);
			musicRollout.clipContent = false;
			musicRollout.width = BOX_WIDTH
			musicRollout.height = boxHeight;
			var uic:UIComponent = new UIComponent();
			var cfb:ColorFrameBlue = new ColorFrameBlue();
			cfb.width = BOX_WIDTH;
			cfb.height = boxHeight;
			uic.addChild(cfb);
			musicRollout.addChild(uic);
//			musicRollout.setStyle("backgroundColor", 0xDEF9FF);
		}
		
		public function createMusicRollout():void
		{
			musicRollout = new Canvas();
			musicRollout.nestLevel = 1;
			styleMusicRollout();
			musicRollout.y = DISTANCE_FROM_TOP;
			musicRollout.x = DISTANCE_FROM_LEFT; 
			songVBox = new VBox();
			setVBoxStyles(songVBox);
			var index:int = 0;
			for each (var os:OwnedSong in _songController.owned_songs)
			{
				var c:Canvas = initializeSong(os, index);
				songVBox.addChild(c);
				index++;
			}
			musicRollout.addChild(songVBox);
			musicRollout.validateDisplayList();
			addCloseButton(musicRollout);
			addScrollers();			
		}
		
		public function setVBoxStyles(vbox:VBox):void
		{
//			vbox.width = musicRollout.width - (TOP_PADDING * 2);
			vbox.width = musicRollout.width - 14;
			vbox.clipContent = false;
			vbox.setStyle("verticalGap", SONG_EXTERNAL_PADDING);
			vbox.x = 7;
			vbox.setStyle("borderStyle", "solid");
			vbox.setStyle("borderColor", 0x9EE8FF);
			vbox.y = TOP_PADDING;			
		}
		
		public function addScrollers():void
		{
			var imageRight:Image = new Image();
			imageRight.source = arrowScrollerRight;
			imageRight.rotation = -90;
			var imageLeft:Image = new Image();
			imageLeft.source = arrowScrollerLeft;
			imageLeft.rotation = -90;
			imageRight.x = BOX_WIDTH - 17;
			imageLeft.x = BOX_WIDTH - 17;
			imageRight.y = 30;
			imageLeft.y = boxHeight + 10;
			musicRollout.addChild(imageRight);
			musicRollout.addChild(imageLeft);
		}
		
		public function addCloseButton(component:UIComponent):void
		{
			var btn:Button = new Button();
			btn.setStyle("skin", closeButton);
			btn.top = -20;
			btn.right = 21;
			var playBtn:Button = new Button();
			playBtn.setStyle("skin", playButtonBigClass);
			playBtn.top = -20;
			playBtn.right = 89;
			var addBtn:Button = new Button();
			addBtn.setStyle("skin", addButtonBigClass);
			addBtn.top = -20;
			addBtn.right = 55;
			btn.addEventListener(MouseEvent.CLICK, function onCloseButtonClicked():void
			{
				removeChild(component);
			});
			component.addChild(btn);
			component.addChild(playBtn);
			component.addChild(addBtn);
		}
		
		public function initializeSong(os:OwnedSong, index:int):Canvas
		{
			var c:Canvas = new Canvas();
			setSongCanvasStyle(c, index);
			var playButton:Button = new Button();
			playButton.setStyle("skin", playButtonClass);
			playButton.x = 6;
			playButton.y = 4;
			var addButton:Button = new Button();
			addButton.setStyle("skin", addButtonClass);
			addButton.x = 37;
			addButton.y = 4;
			var songName:Label = new Label();
			songName.text = os.song.title;
			songName.height = SONG_HEIGHT;
			songName.x = 60;
			MusicPlayer.formatLongText(songName, 130);
			var artistName:Label = new Label();
			artistName.text = os.song.artist_name;
			artistName.height = SONG_HEIGHT;
			artistName.x = 200;
			MusicPlayer.formatLongText(artistName, 130);
			var pointsImage:Image = new Image();
			pointsImage.source = starsIcon;
			pointsImage.x = 337;
			pointsImage.y = 3;
			var songPoints:Label = new Label();
			songPoints.text = os.song.points.toString();
			songPoints.x = 360;
			songPoints.height = SONG_HEIGHT;
			MusicPlayer.formatLongText(songPoints, 50);
			MusicPlayer.setTextStyle(songName, 12, 0x000000);
			MusicPlayer.setTextStyle(artistName, 12, 0x000000);
			MusicPlayer.setTextStyle(songPoints, 12, 0x000000);
			c.addChild(playButton);
			c.addChild(addButton);
			c.addChild(songName);
			c.addChild(artistName);
			c.addChild(songPoints);
			c.addChild(pointsImage);
			return c;
		}
		
		public function setSongCanvasStyle(c:Canvas, index:int):void
		{
			c.width = songVBox.width;			
			if (index%2 == 0)
			{
				c.setStyle("backgroundColor", 0xC6E5F5);
			}
			else
			{
				c.setStyle("backgroundColor", 0x9EDFFF); 
			}
//			c.setStyle("cornerRadius", 6);
			
			if (index != 0)
			{
				c.setStyle("borderStyle", "solid");
				c.setStyle("borderColor", 0x66CCFF);
				c.setStyle("borderSides", "top");
			}
			c.height = SONG_HEIGHT;
			c.clipContent = false;
		}
		
		public static function formatLongText(text:Label, size:int):void
		{
			text.truncateToFit = true;
			text.width = size;
			text.validateNow();
			text.setStyle("paddingTop", SONG_INTERNAL_PADDING);
			text.setStyle("paddingBottom", SONG_INTERNAL_PADDING);
			text.setStyle("paddingLeft", 5);
			text.setStyle("paddingRight", 5);			
		}
		
		public static function setTextStyle(text:Label, size:int, color:Object, useFilter:Boolean=false):void
		{
			var filter:GlowFilter = new GlowFilter(0x333333, 1, 1.4, 1.4, 30, 4); 
			text.setStyle("color", color);
			text.setStyle("fontFamily", "Museo-Slab-900");
			text.setStyle("fontSize", size);
			if (useFilter)
			{
				text.filters = [filter];			
			}
		}
		
		public function addMusicButton():void
		{
			musicButton = new SpecialButton();
			musicButton.width = 40;
			musicButton.height = 40;
			musicButton.y = DISTANCE_FROM_TOP - 10;
			musicButton.x = DISTANCE_FROM_LEFT;
			musicButton.addEventListener(MouseEvent.CLICK, function onMusicButtonClicked():void
			{
				removeChild(musicButton);

				// Change the state of the music button
				
				addChild(musicRollout);
				addChild(musicButton);
			});
			addChild(musicButton);
		}

	}
}