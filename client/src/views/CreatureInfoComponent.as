package views
{	
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import models.Creature;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.DynamicEvent;
	
	import world.ActiveAssetStack;
	
	public class CreatureInfoComponent extends UIComponent
	{
		public var backingComponent:ExpandingCanvas;
		public var nameComponent:Label;
		public var avatarComponent:ActiveAssetStack;
		public var infoComponent:Canvas;
		public var locked:Boolean;
		public var closeButton:Button;
		
		public function CreatureInfoComponent()
		{
			super();
			createBackCanvas();
		}
		
		public function expandComponent(creature:Creature):void
		{
			if (!locked)
			{				
				replaceCreature(creature);
				locked = true;
				closeButton = new Button();
				closeButton.right = 6;
				closeButton.top = 6;
				closeButton.addEventListener(MouseEvent.CLICK, onCloseButtonClicked);
				backingComponent.addChild(closeButton);
				
//				var pushComponents:ArrayCollection = new ArrayCollection();
//				pushComponents.addItem(nameComponent);
				backingComponent.expand("up", 200);
				
				removeChild(infoComponent);
				removeChild(nameComponent);
			}
		}		
		
		private function onCloseButtonClicked(evt:MouseEvent):void
		{
			backingComponent.addEventListener("shrinkComplete", onShrinkComplete);
			closeButton.removeEventListener(MouseEvent.CLICK, onCloseButtonClicked);
			backingComponent.removeChild(closeButton);
			backingComponent.shrink();
		}
		
		private function onShrinkComplete(evt:DynamicEvent):void
		{
			backingComponent.removeEventListener("shrinkComplete", onShrinkComplete);
			addChild(infoComponent);
			addChild(nameComponent);
			locked = false;
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
			avatarComponent.doAnimation("stand_still_toward", false);
		}	
		
		public function showInitialCreature(asset:ActiveAssetStack):void
		{
			setDisplayedCreature(asset.creature, 0.6);
			setAvatarDimensions();
			displayCreatureInfo(asset.creature);
			addChild(avatarComponent);					
		}		
		
		public function replaceCreature(creature:Creature):void
		{
			if (!locked)
			{
				if (avatarComponent)
				{
					removeChild(avatarComponent);
				}
				if (infoComponent)
				{
					removeChild(infoComponent);
				}
				if (nameComponent)
				{
					removeChild(nameComponent);
				}
				setDisplayedCreature(creature, 0.6);
				setAvatarDimensions();
				addChild(avatarComponent);
				displayCreatureInfo(creature);
			}
		}	
		
		public function setAvatarDimensions():void
		{
			avatarComponent.x += 40;
			avatarComponent.y += 94;
		}	
		
		public function setCreatureName(name:String):void
		{
			nameComponent = new Label();
			nameComponent.text = name;
			nameComponent.filters = [createTextFilter()];
			nameComponent.setStyle("color", 0xffffff);
			nameComponent.setStyle("fontFamily", "Museo-Slab-900");
			nameComponent.setStyle("fontSize", 18);	
			nameComponent.x = 90;
			nameComponent.y = -30;
			nameComponent.height = 30;
//			nameComponent.width = this.width;
			addChild(nameComponent);
			nameComponent.width = 200;
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
			infoComponent.x = 90;
			infoComponent.y = 0;
//			infoComponent.addChild(nameComponent);
			var vbox:VBox = new VBox();
			vbox.setStyle("verticalGap", 4);
			vbox.y = 10;
			var typeLabel:Text = getCreatureType(creature);
			var starCanvas:Canvas = getCreatureStars(creature);
			vbox.addChild(starCanvas);
			typeLabel.y = 10;
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