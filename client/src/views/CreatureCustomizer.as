package views
{
	import controllers.CreatureManager;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import models.Creature;
	import models.OwnedLayerable;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Button;
	import mx.core.UIComponent;
	
	import world.AssetStack;

	public class CreatureCustomizer extends UIComponent
	{
		public var _creatureManager:CreatureManager;
		public var _creature:Creature;
		
		public var constructedCreature:AssetStack;
		public var currentLayerables:ArrayCollection;
		public var availableLayerables:Dictionary;
		
		public var displayedLayerableListContainer:UIComponent;
		public var creaturePreview:UIComponent;
		public var displayedLayerableList:UIComponent;
		public var currentAnimation:String;
		public var currentFrame:int;
		
		public static const VIEWER_X:Number = 200;
		public static const VIEWER_WIDTH:Number = 400;
		public static const VIEWER_HEIGHT:Number = 400;
		
		public function CreatureCustomizer(creature:Creature, creatureManager:CreatureManager)
		{
			super();
			_creature = creature;
			_creatureManager = creatureManager;
			
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
			var btn:Button;
			var i:int = 0;
			for each (var str:String in _creature.layerableOrder[currentAnimation])
			{
				btn = new Button();
				btn.x = 100 + i * 40;
				btn.y = 0;
				btn.width = 30;
				btn.height = 30;
				btn.id = str;
				btn.addEventListener(MouseEvent.CLICK, onLayerSelected);
				creaturePreview.addChild(btn);
				i++;
			}
		}
		
		private function onLayerSelected(evt:MouseEvent):void
		{
			var btn:Button = evt.target as Button;
			var selectedLayer:String = btn.id;
			showAvailableLayerablesForCreatureAndLayer(selectedLayer);
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
				if (!currentLayerables.contains(ol))
				{
					discardedLayerables.addItem(ol);
				}
			}
			creatureManager.saveCustomLayers(_creature, currentLayerables, discardedLayerables);
		}
		
		private function onCloseButtonClicked(evt:MouseEvent):void
		{
			parentApplication.currentState = 'worldView';
		}
		
		public function generateCreaturePreview(animation:String):void
		{
			currentLayerables = new ArrayCollection();
			populateCurrentLayerables();	
								
			createCreaturePreview();

			constructedCreature = _creature.getConstructedCreature(animation, 1, 1);
			constructedCreature.doAnimation(animation, currentFrame);
			constructedCreature.x = creaturePreview.width / 2;
			creaturePreview.addChild(constructedCreature.movieClipStack);
			addChild(creaturePreview);
		}
		
		public function createCreaturePreview():void
		{
			creaturePreview = new UIComponent();
			creaturePreview.width = VIEWER_WIDTH;
			creaturePreview.height = VIEWER_HEIGHT;
			creaturePreview.x = VIEWER_X;
			creaturePreview.y = 0;			
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
			displayedLayerableListContainer = new UIComponent();			
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
					availableLayerablesForLayer.addItem(mc);
				}
			}
			availableLayerables[layerName] = availableLayerablesForLayer;			
		}
		
		private function showAvailableLayerableList(layerName:String):void
		{
			displayedLayerableList = new UIComponent();
			for each (var mc:MovieClip in availableLayerables[layerName])
			{
				displayedLayerableList.addChild(mc);				
			}
			displayedLayerableListContainer.addChild(displayedLayerableList);			
		}
		
		public function showAvailableLayerablesForCreatureAndLayer(layerName:String):void
		{
			clearDisplayedLayerableList();
			
			showAvailableLayerableList(layerName);
			
			displayedLayerableListContainer.x = VIEWER_X + VIEWER_WIDTH;
			displayedLayerableListContainer.height = VIEWER_HEIGHT;
			displayedLayerableListContainer.addEventListener(MouseEvent.CLICK, onLayerableClicked);
			addChild(displayedLayerableListContainer);
		}
		
		private function alterAppearanceByLayerName(klass:Class, layerName:String):MovieClip
		{
			var mc:MovieClip = new klass();
			switch (layerName)
			{
				case "instrument":
					mc.scaleX = 0.4;
					mc.scaleY = 0.4;
					break;
				case "eyes":
					break;	
			}
			mc.stop();
			return mc;
		}
		
		private function onLayerableClicked(evt:MouseEvent):void
		{
			if (evt.target is MovieClip)
			{
				var obj:Object = evt.target;
				var className:String = flash.utils.getQualifiedClassName(obj);
				var klass:Class = creatureManager.essentialModelManager.essentialModelReference.loadedModels[className].klass;
				for each (var ol:OwnedLayerable in creature.owned_layerables)
				{
					if (ol.layerable.mc is klass)
					{
						var layerName:String = ol.layerable.layer_name;
						
						removeMatchingLayerableFromPreview(layerName);
						removeLayerableFromOptionsList(ol.layerable.mc, layerName);
						
						currentLayerables.addItem(ol);
						constructedCreature.movieClipStack.addChild(ol.layerable.mc);
					}
				}
			}
		}
		
		private function removeLayerableFromOptionsList(mc:MovieClip, layerName:String):void
		{
			var className:String = flash.utils.getQualifiedClassName(mc);
			var klass:Class = creatureManager.essentialModelManager.essentialModelReference.loadedModels[className].klass;
			for each (var obj:Object in availableLayerables[layerName])
			{
				if (obj is klass)
				{
					displayedLayerableList.removeChild(obj as MovieClip);
					var index:int = (availableLayerables[layerName] as ArrayCollection).getItemIndex(obj);
					(availableLayerables[layerName] as ArrayCollection).removeItemAt(index);
				}
			}
		}
		
		private function copyMovieClipForLayerableList(mc:MovieClip, layerName:String):MovieClip
		{
			var className:String = flash.utils.getQualifiedClassName(mc);
			var klass:Class = _creatureManager.essentialModelManager.essentialModelReference.loadedModels[className].klass;
			var copiedMovieClip:MovieClip = alterAppearanceByLayerName(klass, layerName);	
			return copiedMovieClip;		
		}
		
		private function addLayerableToOptionsList(mc:MovieClip, layerName:String):void
		{
			var copiedMovieClip:MovieClip = copyMovieClipForLayerableList(mc, layerName);
			(availableLayerables[layerName] as ArrayCollection).addItem(copiedMovieClip);		
			displayedLayerableList.addChild(copiedMovieClip);
		}
		
		private function removeMatchingLayerableFromPreview(layerName:String):void
		{
			for each (var ol:OwnedLayerable in creature.owned_layerables)
			{
				if (constructedCreature.movieClipStack.contains(ol.layerable.mc) && ol.layerable.layer_name == layerName)
				{
					var layerableIndex:int = currentLayerables.getItemIndex(ol);
					currentLayerables.removeItemAt(layerableIndex);
					addLayerableToOptionsList(ol.layerable.mc, layerName);
					constructedCreature.movieClipStack.removeChild(ol.layerable.mc);
				}
			}
		}
		
		public function set creatureManager(val:CreatureManager):void
		{
			_creatureManager = val;
		}
		
		public function get creatureManager():CreatureManager
		{
			return _creatureManager;
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