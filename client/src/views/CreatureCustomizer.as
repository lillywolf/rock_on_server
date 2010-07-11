package views
{
	import controllers.CreatureController;
	import controllers.LayerableController;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import models.Creature;
	import models.EssentialModelReference;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Button;
	import mx.core.UIComponent;
	
	import rock_on.SpecialButton;
	
	import world.AssetStack;

	public class CreatureCustomizer extends UIComponent
	{
		public var _creatureController:CreatureController;
		public var _creature:Creature;
		
		public var constructedCreature:AssetStack;
		public var currentLayerables:ArrayCollection;
		public var availableLayerables:Dictionary;
		
		public var displayedLayerableListContainer:ContainerUIC;
		public var creaturePreview:UICanvas;
		public var displayedLayerableList:ContainerUIC;
		public var currentAnimation:String;
		public var currentFrame:int;
		
		public static const VIEWER_X:Number = 200;
		public static const PREVIEW_WIDTH:Number = 100;
		public static const VIEWER_WIDTH:Number = 400;
		public static const VIEWER_HEIGHT:Number = 400;
		public static const BUTTONS_HEIGHT:int = 100;
		public static const ITEM_WIDTH:int = 80;
		public static const ITEM_HEIGHT:int = 80;
		public static const ITEM_PADDING:int = 10;
		public static const ITEMS_PER_ROW:int = 4;
		
		public function CreatureCustomizer(creature:Creature, creatureController:CreatureController)
		{
			super();
			_creature = creature;
			_creatureController = creatureController;
			
			currentAnimation = "walk_toward";
			currentFrame = 39;
			
			createAvailableLayerableList(currentAnimation);
			generateCreaturePreview(currentAnimation);
			addButtons();
		}
		
		public function addButtons():void
		{
			addSaveButton();
			addCloseButton();
			addLayerButtons();
		}
		
		public function addSaveButton():void
		{
			var btn:Button = new Button();
			btn.x = 100;
			btn.y = 100;
			btn.width = 30;
			btn.height = 30;
			btn.addEventListener(MouseEvent.CLICK, onSaveButtonClicked);
			addChild(btn);
		}
		
		public function addLayerButtons():void
		{
			var btn:SpecialButton;
			var i:int = 0;
			for each (var str:String in _creature.layerableOrder[currentAnimation])
			{
				btn = new SpecialButton();
				btn.setStyles(PREVIEW_WIDTH + i * 40, 0, 30, 30);
				btn.layerName = str;
				btn.addEventListener(MouseEvent.CLICK, onLayerSelected);
				creaturePreview.addChild(btn);
				i++;
			}
		}
		
		private function onLayerSelected(evt:MouseEvent):void
		{
			var btn:SpecialButton = evt.target as SpecialButton;
			var layerName:String = btn.layerName;
			showAvailableLayerablesForCreatureAndLayer(layerName);
		}
		
		public function addCloseButton():void
		{
			var btn:Button = new Button();
			btn.x = 150;
			btn.y = 100;
			btn.width = 30;
			btn.height = 30;
			btn.addEventListener(MouseEvent.CLICK, onCloseButtonClicked);
			addChild(btn);
		}
		
		private function onSaveButtonClicked(evt:MouseEvent):void
		{
			var discardedLayerables:ArrayCollection = new ArrayCollection();
			for each (var ol:OwnedLayerable in _creature.owned_layerables)
			{
				if (!currentLayerables.contains(ol) && ol.in_use)
				{
					discardedLayerables.addItem(ol);
				}
			}
			creatureController.saveCustomLayers(_creature, currentLayerables, discardedLayerables);
		}
		
		private function onCloseButtonClicked(evt:MouseEvent):void
		{
//			parentApplication.currentState = "worldView";
			var parentUI:UICanvas = this.parent as UICanvas;
			parentUI.removeChild(this);
		}
		
		public function generateCreaturePreview(animation:String):void
		{
			currentLayerables = new ArrayCollection();
			populateCurrentLayerables();	
								
			createCreaturePreview();

			var layerableOrder:Array = creatureController.getLayerableOrderByCreatureType(_creature.type);
			constructedCreature = _creature.getConstructedCreature(layerableOrder, animation, 1, 1);
			constructedCreature.doAnimation(constructedCreature.orientation, animation, currentFrame);
			constructedCreature.x = creaturePreview.width / 2;
			var uic:ContainerUIC = new ContainerUIC();
			uic.y = constructedCreature.height;
			uic.thinger = constructedCreature;
			uic.addChild(constructedCreature);
			creaturePreview.addChild(uic);
			addChild(creaturePreview);
		}
		
		public function createCreaturePreview():void
		{
			creaturePreview = new UICanvas();
			creaturePreview.setStyles(0xffffff, 0x333333, 14, VIEWER_WIDTH, VIEWER_HEIGHT);
//			creaturePreview.y = 0;			
		}
		
		public function populateCurrentLayerables():void
		{
			for each (var ol:OwnedLayerable in _creature.owned_layerables)
			{
				if (ol.in_use)
				{
					currentLayerables.addItem(ol);
				}
			}			
		}
		
		public function showLayersForCreature(animation:String):void
		{
			for each (var layerName:String in _creature.layerableOrder[animation])
			{
				showAvailableLayerablesForCreatureAndLayer(layerName);
			}
		}
		
		private function clearDisplayedLayerableList():void
		{
			if (displayedLayerableListContainer)
			{
				removeChild(displayedLayerableListContainer);
			}		
			displayedLayerableListContainer = new ContainerUIC();			
		}
		
		private function createAvailableLayerableList(currentAnimation:String):void
		{
			availableLayerables = new Dictionary();
			
			for each (var layerName:String in _creature.layerableOrder[currentAnimation])
			{
				populateAvailableLayerableList(layerName);
			}
		}
		
		private function populateAvailableLayerableList(layerName:String):void
		{
			var availableLayerablesForLayer:ArrayCollection = new ArrayCollection();
			var creatureLayerables:ArrayCollection = _creature.owned_layerables;
			
			for each (var ol:OwnedLayerable in creatureLayerables)
			{
				if (ol.layerable.layer_name == layerName && !ol.in_use)
				{
					var mc:MovieClip = copyMovieClipForLayerableList(ol.layerable.mc, layerName);
					availableLayerablesForLayer.addItem(ol);
				}
			}
			availableLayerables[layerName] = availableLayerablesForLayer;			
		}
		
		private function showAvailableLayerableList(layerName:String):void
		{
			displayedLayerableList = new ContainerUIC();
			var i:int = 0;
			for each (var ol:OwnedLayerable in availableLayerables[layerName])
			{
				var uic:ContainerUIC = createLayerableOption(ol);
				uic.setStyles(i * ITEM_WIDTH, Math.floor(i/ITEMS_PER_ROW) * ITEM_HEIGHT + ITEM_PADDING, ITEM_WIDTH, ITEM_HEIGHT);							
				displayedLayerableList.addChild(uic);
				i++;			
			}
			displayedLayerableListContainer.addChild(displayedLayerableList);			
		}
		
		public function createLayerableOption(ol:OwnedLayerable):ContainerUIC
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(ol.layerable.mc);
			var uic:ContainerUIC = LayerableController.formatMovieClipByDimensions(mc, ITEM_WIDTH, ITEM_HEIGHT, ITEM_PADDING, ITEM_PADDING);
			uic.thinger = ol;
			uic.addEventListener(MouseEvent.CLICK, onLayerableClicked);
			return uic;	
		}
		
		public function showAvailableLayerablesForCreatureAndLayer(layerName:String):void
		{
			clearDisplayedLayerableList();
			
			showAvailableLayerableList(layerName);
			
			displayedLayerableListContainer.height = VIEWER_HEIGHT;
//			displayedLayerableListContainer.width = VIEWER_WIDTH;
			displayedLayerableListContainer.x = VIEWER_WIDTH - PREVIEW_WIDTH;
			displayedLayerableListContainer.y = BUTTONS_HEIGHT;
			displayedLayerableListContainer.addEventListener(MouseEvent.CLICK, onLayerableClicked);
			addChild(displayedLayerableListContainer);
		}
		
		private function alterAppearanceByLayerName(klass:Class, layerName:String):MovieClip
		{
			var mc:MovieClip = new klass();
			switch (layerName)
			{
				case "instrument":
					mc.scaleX = 0.5;
					mc.scaleY = 0.5;
					break;
				case "eyes":
					break;	
			}
			mc.stop();
			return mc;
		}
		
		private function onLayerableClicked(evt:MouseEvent):void
		{
			if (evt.currentTarget is ContainerUIC)
			{
				var uic:ContainerUIC = evt.currentTarget as ContainerUIC;
				if (uic.thinger is OwnedLayerable)
				{
					var ol:OwnedLayerable = uic.thinger as OwnedLayerable;
					var layerName:String = ol.layerable.layer_name;
					
					var olMatch:OwnedLayerable = getMatchingLayerable(uic.thinger as OwnedLayerable);
					if (olMatch)
					{
						removeOldLayerable(olMatch);
						addLayerableToPreview(ol, olMatch);					
						addLayerableToOptionsList(olMatch, uic);				
					}
					else
					{
						var index:int = getLayerableIndex(ol, currentAnimation);
						addLayerableToPreview(ol, olMatch, index);
					}
					removeLayerableFromOptionsList(uic, layerName, uic.thinger as OwnedLayerable);
				}
			}
		}
		
		private function getLayerableIndex(ol:OwnedLayerable, animation:String):int
		{
			var i:int = 0;
			for each (var str:String in constructedCreature.layerableOrder[animation])
			{
				if (str == ol.layerable.layer_name)
				{
					var index:int = i; 
					break;
				}
				for each (var tempOl:OwnedLayerable in currentLayerables)
				{
					if (tempOl.layerable.layer_name == str)
					{
						i++;				
					}
				}
			}
			return index;
		}
		
		private function addLayerableToPreview(ol:OwnedLayerable, olMatch:OwnedLayerable, index:int=0):void
		{
			currentLayerables.addItem(ol);
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(ol.layerable.mc);
			mc.gotoAndPlay(currentFrame);
			mc.stop();
			if (olMatch)
			{
				var mcMatch:MovieClip = getMovieClipByLayerable(olMatch, "walk_toward");	
//				var index:int = constructedCreature.movieClips.getItemIndex(mcMatch);
				constructedCreature.movieClips.setItemAt(mc, index);							
			}
			else
			{
				constructedCreature.movieClips.setItemAt(mc, index);
			}
		}
		
		private function removeLayerableFromOptionsList(uic:ContainerUIC, layerName:String, ol:OwnedLayerable):int
		{
			displayedLayerableList.removeChild(uic);					
			var index:int = (availableLayerables[layerName] as ArrayCollection).getItemIndex(ol);
			(availableLayerables[layerName] as ArrayCollection).removeItemAt(index);
			return index;
		}
		
		private function copyMovieClipForLayerableList(mc:MovieClip, layerName:String):MovieClip
		{
//			var className:String = flash.utils.getQualifiedClassName(mc);
//			var klass:Class = _creatureController.essentialModelController.essentialModelReference.loadedModels[className].klass;
			var copiedMovieClip:MovieClip = EssentialModelReference.getMovieClipCopy(mc);
//			var copiedMovieClip:MovieClip = alterAppearanceByLayerName(klass, layerName);	
			copiedMovieClip.stop();
			return copiedMovieClip;		
		}
		
		private function addLayerableToOptionsList(ol:OwnedLayerable, uic:ContainerUIC):void
		{
			var mc:MovieClip = EssentialModelReference.getMovieClipCopy(ol.layerable.mc);
			(availableLayerables[ol.layerable.layer_name] as ArrayCollection).addItem(ol);
			var index:int = displayedLayerableList.getChildIndex(uic);		
			var newUic:ContainerUIC = createLayerableOption(ol);
			newUic.setStyles(index * ITEM_WIDTH, Math.floor(index/ITEMS_PER_ROW) * ITEM_HEIGHT + ITEM_PADDING, ITEM_WIDTH, ITEM_HEIGHT);										
			displayedLayerableList.addChildAt(newUic, index);
		}
		
		private function getMatchingLayerable(olCopy:OwnedLayerable):OwnedLayerable
		{
			var layerName:String = olCopy.layerable.layer_name;	
			var olMatch:OwnedLayerable;		
			for each (var ol:OwnedLayerable in currentLayerables)
			{
				if (ol.layerable.layer_name == layerName)
				{
					olMatch = ol;
					break;
				}
			}
			return olMatch;				
		}
		
		private function removeOldLayerable(ol:OwnedLayerable):void
		{
//			var mc:MovieClip = getMovieClipByLayerable(ol, "walk_toward");
//			var mcIndex:int = constructedCreature.movieClipStack.getChildIndex(mc);
//			constructedCreature.movieClipStack.removeChild(mc);	
			var index:int = currentLayerables.getItemIndex(ol);
			currentLayerables.removeItemAt(index);
//			return mcIndex;			
		}
		
		public function getMovieClipByLayerable(ol:OwnedLayerable, animation:String):MovieClip
		{
			var className:String = flash.utils.getQualifiedClassName(ol.layerable.mc);
			
			for each (var mc:MovieClip in constructedCreature.movieClips)
			{			
				var tempName:String = flash.utils.getQualifiedClassName(mc);
				if (tempName == className)
				{
					return mc;
				}
			}
			return null;
		}		
		
		public function set creatureController(val:CreatureController):void
		{
			_creatureController = val;
		}
		
		public function get creatureController():CreatureController
		{
			return _creatureController;
		}
		
		public function set creature(val:Creature):void
		{
			_creature = val;
		}
		
		public function get creature():Creature
		{
			return _creature;
		}
	}
}