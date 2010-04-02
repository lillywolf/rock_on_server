package models
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	
	import mx.core.UIComponent;

	public class Thinger extends EssentialModel
	{
		public var _mc:MovieClip;
		public var _swf_url:String;
		public var _symbol_name:String;
		public var _name:String;
		public var _id:int;
		public var _thinger_type:String;
		
		public function Thinger(params:Object, loadedClass:Class=null, target:IEventDispatcher=null)
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
			_name = params['name'];
			_thinger_type = params['thinger_type'];
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
		
		public function set thinger_type(val:String):void
		{
			_thinger_type = val;
		}
		
		public function get thinger_type():String
		{
			return _thinger_type;
		}
		
		public function setMovieClipFromClass(val:Class):void
		{
			var displayObject:DisplayObject = new val();			
			if (displayObject is MovieClip)
			{
				_mc = displayObject as MovieClip;
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
		
		public function set name(val:String):void
		{
			_name = val;
		}
		
		public function get name():String
		{
			return _name;
		}
				
	}
}