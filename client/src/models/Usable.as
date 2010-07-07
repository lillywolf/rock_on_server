package models
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;

	public class Usable extends EssentialModel
	{
		public var _id:int;
		public var _name:String;
		public var _swf_url:String;
		public var _symbol_name:String;
		public var _usable_type:String;
		public var _mc:MovieClip;
		
		public function Usable(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			_id = params["id"];
			_swf_url = params["swf_url"];
			_symbol_name = params["symbol_name"];
			_name = params["name"];
			_usable_type = params["usable_type"];			
		}
		
		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}		
		
		public function set name(val:String):void
		{
			_name = val;
		}
		
		public function get name():String
		{
			return _name;
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
		
		public function set usable_type(val:String):void
		{
			_usable_type = val;
		}
		
		public function get usable_type():String
		{
			return _usable_type;
		}
		
		public function setMovieClipFromClass(val:Class):void
		{
			var displayObject:DisplayObject = new val();			
			if (displayObject is MovieClip)
			{
				_mc = displayObject as MovieClip;
				
				var evt:DynamicEvent = new DynamicEvent("movieClipLoaded", true, true);
				evt.thinger = this;
				dispatchEvent(evt);					
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
		
	}
}