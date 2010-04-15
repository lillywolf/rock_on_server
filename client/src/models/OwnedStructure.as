package models
{
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;

	public class OwnedStructure extends EssentialModel
	{
		public var _structure_id:int;
		public var _id:int;
		public var _structure:Structure;
		public var _user_id:int;
		public var _x:Number;
		public var _y:Number;
		public var _z:Number;
		public var _created_at:String;
				
		public function OwnedStructure(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			_id = params.id;
			updateProperties(params);
		}
		
		public function updateProperties(params:Object):void
		{
			_structure_id = params.structure_id;
			_x = params.x;
			_y = params.y;
			_z = params.z;
			_created_at = params.created_at;
		}		

		public function set id(val:int):void
		{
			_id = val;
		}
		
		public function get id():int
		{
			return _id;
		}

		public function set structure(val:Structure):void
		{
			_structure = val;
			var evt:DynamicEvent = new DynamicEvent('parentLoaded', true, true);
			evt.thinger = val;
			dispatchEvent(evt);
			
			if (_structure['mc'] != null)
			{
				var event:DynamicEvent = new DynamicEvent('parentMovieClipAssigned', true, true);
				dispatchEvent(event);
			}
			else
			{
				_structure.addEventListener('movieClipLoaded', onStructureMovieClipAssigned);	
			}
		}
		
		private function onStructureMovieClipAssigned(evt:DynamicEvent):void
		{
			_structure.removeEventListener('movieClipLoaded', onStructureMovieClipAssigned);
			var evt:DynamicEvent = new DynamicEvent('parentMovieClipAssigned', true, true);
			dispatchEvent(evt);
		}
		
		public function get structure():Structure
		{
			return _structure;
		}
		
		public function set structure_id(val:int):void
		{
			_structure_id = val;
		}
		
		public function get structure_id():int
		{
			return _structure_id;
		}	
			
		public function set created_at(val:String):void
		{
			_created_at = val;
		}
		
		public function get created_at():String
		{
			return _created_at;
		}		
		
		public function set user_id(val:int):void
		{
			_user_id = val;
		}
		
		public function set x(val:Number):void
		{
			_x = val;
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set y(val:Number):void
		{
			_y = val;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set z(val:Number):void
		{
			_z = val;
		}
		
		public function get z():Number
		{
			return _z;
		}
		
		
		
	}
}