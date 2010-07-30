package views
{	
	import flash.filters.GlowFilter;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	import world.ActiveAssetStack;
	
	public class CreatureInfoComponent extends UIComponent
	{
		public var backingComponent:ExpandingCanvas;
		public var nameComponent:Label;
		public var avatarComponent:ActiveAssetStack;
		public var infoComponent:Canvas;
		
		public function CreatureInfoComponent()
		{
			super();
			createBackCanvas();
		}
		
		public function expandComponent():void
		{
			var pushComponents:ArrayCollection = new ArrayCollection();
			pushComponents.addItem(nameComponent);
			backingComponent.expand("up", 200, pushComponents);
		}		
		
		private function createBackCanvas():void
		{
			backingComponent = new ExpandingCanvas();
			backingComponent.width = 252;
			backingComponent.height = 105;
			backingComponent.alpha = 0.6;
			backingComponent.setStyle("backgroundColor", 0xffffff);
			backingComponent.setStyle("cornerRadius", 12);
			backingComponent.setStyle("borderStyle", "solid");
			backingComponent.setStyle("borderColor", 0xffffff);
			backingComponent.clipContent = false;		
			this.addChild(backingComponent);
		}		
		
		public function setDisplayedCreature(creature:Creature, dimension:Number):void
		{
			avatarComponent = new ActiveAssetStack(creature, null, creature.layerableOrder, dimension);
			avatarComponent.doAnimation("walk_toward", false, 39);
		}	
		
		public function showInitialCreature(asset:ActiveAssetStack):void
		{
			setDisplayedCreature(asset.creature, 0.55);
			setAvatarDimensions();
			displayCreatureInfo(asset.creature);
			addChild(avatarComponent);					
		}		
		
		public function replaceCreature(creature:Creature):void
		{
			if (avatarComponent)
			{
				removeChild(avatarComponent);
				setDisplayedCreature(creature, 0.55);
				setAvatarDimensions();
				displayCreatureInfo(creature);
				addChild(avatarComponent);
			}
			if (infoComponent)
			{
				removeChild(infoComponent);
			}
		}	
		
		public function setAvatarDimensions():void
		{
			avatarComponent.x = avatarComponent.width/2 - 5;
			avatarComponent.y = avatarComponent.height - 80;
		}	
		
		public function setCreatureName(name:String):void
		{
			nameComponent = new Label();
			nameComponent.text = name;
			nameComponent.filters = [createTextFilter()];
			nameComponent.setStyle("color", 0xffffff);
			nameComponent.setStyle("fontFamily", "Museo-Slab-900");
			nameComponent.setStyle("fontSize", 18);	
			addChild(nameComponent);
		}
		
		public function createTextFilter():GlowFilter
		{
			var filter:GlowFilter = new GlowFilter(0x333333, 1, 1.4, 1.4, 30, 5); 
			return filter;
		}			
		
		public function displayCreatureInfo(creature:Creature):void
		{
			setCreatureName(creature.name);

			infoComponent = new Canvas();
			infoComponent.clipContent = false;
			infoComponent.x = 100;
			infoComponent.y = -30;
			infoComponent.addChild(nameComponent);
			var vbox:VBox = new VBox();
			vbox.setStyle("verticalGap", 4);
			vbox.y = 40;
			var typeLabel:Text = getCreatureType(creature);
			var starCanvas:Canvas = getCreatureStars(creature);
			vbox.addChild(starCanvas);
			typeLabel.y = 40;
			vbox.addChild(typeLabel);
			infoComponent.addChild(vbox);
			addChild(infoComponent);				
		}	
		
		public function getCreatureStars(creature:Creature):Canvas
		{
			var canvas:Canvas = new Canvas();
			var star:Image;
			var overlay:Image;
			var numStars:int = Math.floor(Math.random() * 5);
			
			for (var i:int = 0; i < (numStars + 1); i++)
			{
				star = new Image();
				overlay = new Image();
				switch (numStars)
				{
					case 0:
						star.source = HeartFilledYellowGreen;
						overlay.source = HeartEmpty;
						break;
					case 1:
						star.source = HeartFilledYellow;
						overlay.source = HeartEmpty;
						break;
					case 2:
						star.source = HeartFilledOrange;
						overlay.source = HeartEmpty;
						break;
					case 3:
						star.source = HeartFilledOrangeRed;
						overlay.source = HeartEmpty;
						break;
					case 4:
						star.source = HeartFilledRed;
						overlay.source = HeartEmpty;
						break;
				}
				overlay.x = i * 22;
				overlay.height = 22;
				star.x = i * 22;
				star.height = 18;
				canvas.addChild(star);
				canvas.addChild(overlay);
			}
			if (numStars == 4 && Math.random() > 0.5)
			{
				star = new Image();
				overlay = new Image();
				star.source = HeartFilledGreen;
				overlay.source = HeartEmpty;
				overlay.x = 5 * 22;
				overlay.height = 22;
				star.x = 5 * 22;
				star.height = 18;
				canvas.addChild(star);
				canvas.addChild(overlay);
			}
			return canvas;
		}
		
		public function getCreatureType(creature:Creature):Text
		{
			var canvas:Canvas = new Canvas();
			var text:Text = new Text();
			text.width = 140;
			var textFilter:GlowFilter = createTextFilter();
			if (creature.type == "BandMember")
			{
				text.text = "Band Member";
			}
			else
			{
				text.text = creature.type;
			}
			text.setStyle("color", 0xffffff);
			text.setStyle("fontFamily", "Museo-Slab-900");
			text.setStyle("fontSize", 14);
			text.filters = [textFilter];
			text.y = 70;
			return text;
		}		
		
	}
}