package models
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;

	public class Dwelling extends EssentialModel
	{
		public var _mc:MovieClip;
		public var _swf_url:String;
		public var _symbol_name:String;
		public var _name:String;
		public var _id:int;
		public var _dwelling_type:String;
		public var _capacity:int;
		public var _floor_type:String;
		public var _floor_structure_id:int;
		public var _dimension:int;
		public var _sidewalk_dimension:int;
		
		public var _width:Number;
		public var _height:Number;
		public var _depth:Number;		
		
		public function Dwelling(params:Object=null, loadedClass:Class=null, target:IEventDispatcher=null)
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

		public function setProperties(params:Object):void
		{
			_id = params['id'];
			_swf_url = params['swf_url'];
			_symbol_name = params['symbol_name'];
			_name = params['name'];
			_dwelling_type = params['dwelling_type'];
			_floor_type = params["floor_type"];
			_floor_structure_id = params["floor_structure_id"];
			_dimension = params.dimension;
			_sidewalk_dimension = params.sidewalk_dimension;
			
			setExtraProperties(params);
		}
		
		private function setExtraProperties(params:Object):void
		{
			if (params['width'])
				_width = params['width'];
			if (params['height'])
				_height = params['height'];
			if (params['depth'])
				_depth = params['depth'];
			if (params['capacity'])
				_capacity = params.capacity;
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
		
		public function set dimension(val:int):void
		{
			_dimension = val;
		}
		
		public function get dimension():int
		{
			return _dimension;
		}
		
		public function set sidewalk_dimension(val:int):void
		{
			_sidewalk_dimension = val;
		}
		
		public function get sidewalk_dimension():int
		{
			return _sidewalk_dimension;
		}
		
		public function set dwelling_type(val:String):void
		{
			_dwelling_type = val;
		}
		
		public function get dwelling_type():String
		{
			return _dwelling_type;
		}
		
		public function setMovieClipFromClass(val:Class):void
		{
			var displayObject:DisplayObject = new val();			
			if (displayObject is MovieClip)
			{
				_mc = displayObject as MovieClip;
				
				var evt:DynamicEvent = new DynamicEvent('movieClipLoaded', true, true);
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
		
		public function set name(val:String):void
		{
			_name = val;
		}
		
		public function get name():String
		{
			return _name;
		}	
		
		public function set capacity(val:int):void
		{
			_capacity = val;
		}
		
		public function get capacity():int
		{
			return _capacity;
		}	
		
		public function set width(val:Number):void
		{
			_width = val;
		}	
		
		public function get width():Number
		{
			return _width;
		}
		
		public function set height(val:Number):void
		{
			_height = val;
		}	
		
		public function get height():Number
		{
			return _height;
		}
		
		public function set depth(val:Number):void
		{
			_depth = val;
		}	
		
		public function get depth():Number
		{
			return _depth;
		}
		
		public function set floor_structure_id(val:int):void
		{
			_floor_structure_id = val;
		}	
		
		public function get floor_structure_id():int
		{
			return _floor_structure_id;
		}	
		
		public function set floor_type(val:String):void
		{
			_floor_type = val;
		}
		
		public function get floor_type():String
		{
			return _floor_type;
		}
									   
			
	}
}