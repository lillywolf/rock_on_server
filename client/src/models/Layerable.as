package models
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.filters.ColorMatrixFilter;
	
	import helpers.ColorAdapter;
	
	import mx.events.DynamicEvent;

	public class Layerable extends EssentialModel
	{
		public var _id:int;		
		public var _swf_url:String;
		public var _symbol_name:String;
		public var _layer_name:String;
		public var _mc:MovieClip;
		public var _name:String;
		public var _editable_color:Boolean;
		
		public var cmf:ColorMatrixFilter;
		
		public function Layerable(params:Object, loadedClass:Class=null, target:IEventDispatcher=null)
		{
			super(params, target);
			if (loadedClass)
			{
				var displayObject:DisplayObject = new loadedClass();			
				if (displayObject is MovieClip)
				{
					_mc = displayObject as MovieClip;
				}
			}
			setProperties(params);
		}
		
		private function setProperties(params:Object):void
		{
			_id = params['id'];
			_swf_url = params['swf_url'];
			_symbol_name = params['symbol_name'];
			_layer_name = params['layer_name'];
			_name = params['name'];
			setOptionalProperties(params);
		}
		
		public function setOptionalProperties(params:Object):void
		{
			if (params.editable_color)
			{
				_editable_color = params.editable_color;
				if (_editable_color)
				{

					
				}
			}
		}
		
		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set swf_url(val:String):void
		{
			_swf_url = val;
		}
		
		public function get swf_url():String
		{
			return _swf_url;
		}
		
		public function set symbol_name(val:String):void
		{
			_symbol_name = val;
		}
		
		public function get symbol_name():String
		{
			return _symbol_name;
		}
		
		public function set layer_name(val:String):void
		{
			_layer_name = val;
		}
		
		public function get layer_name():String
		{
			return _layer_name;
		}
		
		public function set name(val:String):void
		{
			_name = val;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function setMovieClipFromClass(val:Class):void
		{
			var displayObject:DisplayObject = new val();			
			if (displayObject is MovieClip)
			{
				_mc = displayObject as MovieClip;
				
				var evt:DynamicEvent = new DynamicEvent('movieClipLoaded', true, true);
				evt.thinger = this;
				this.dispatchEvent(evt);				
			}
		}
		
		public function set mc(val:MovieClip):void
		{
			_mc = val;
		}
		
		public function get mc():MovieClip
		{
			return _mc;
		}
		
		public function set editable_color(val:Boolean):void
		{
			_editable_color = val;
		}
		
		public function get editable_color():Boolean
		{
			return _editable_color;
		}
	}
}