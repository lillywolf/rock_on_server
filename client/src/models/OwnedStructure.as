package models
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.events.DynamicEvent;
	
	import world.Point3D;

	public class OwnedStructure extends EssentialModel
	{
		public var _structure_id:int;
		public var _id:int;
		public var _structure:Structure;
		public var _user_id:int;
		public var _owned_dwelling_id:int;
		public var _x:Number;
		public var _y:Number;
		public var _z:Number;
		public var _created_at:String;
		public var _updated_at:String;
		public var _in_use:Boolean;
		public var _flipped:Boolean;
		public var _rotated:Boolean;
		
		public var _inventory_count:int;
				
		public function OwnedStructure(params:Object=null, target:IEventDispatcher=null)
		{
			super(params, target);
			updateProperties(params);
		}
		
		public function updateProperties(params:Object):void
		{
			_id = params.id;
			_structure_id = params.structure_id;
			_x = params.x;
			_y = params.y;
			_z = params.z;
			_created_at = params.created_at;
			_in_use = params.in_use;
			
			if (params.structure)
			{
				_structure = params.structure;
			}
			
			setOptionalProperties(params);
		}	
		
		public function setOptionalProperties(params:Object):void
		{
			if (params.inventory_count)
			{
				_inventory_count = params.inventory_count;
			}
			if (params.updated_at)
			{
				_updated_at = params.updated_at;
			}
			if (params.owned_dwelling_id)
			{
				_owned_dwelling_id = params.owned_dwelling_id;
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
			
		public function set updated_at(val:String):void
		{
			_updated_at = val;
		}
		
		public function get updated_at():String
		{
			return _updated_at;
		}		
		
		public function set user_id(val:int):void
		{
			_user_id = val;
		}
		
		public function get user_id():int
		{
			return _user_id;
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
		
		public function set inventory_count(val:int):void
		{
			_inventory_count = val;
		}
		
		public function get inventory_count():int
		{
			return _inventory_count;
		}
		
		public function set owned_dwelling_id(val:int):void
		{
			_owned_dwelling_id = val;
		}
		
		public function get owned_dwelling_id():int
		{
			return _owned_dwelling_id;
		}
		
		public function set in_use(val:Boolean):void
		{
			_in_use = val;
		}
		
		public function get in_use():Boolean
		{
			return _in_use;
		}
		
		public function set flipped(val:Boolean):void
		{
			_flipped = val;
			if (_flipped)
			{	
				_structure.width = _structure.normalDepth;
				_structure.depth = _structure.normalWidth;
			}
			else
			{
				_structure.width = _structure.normalWidth;
				_structure.depth = _structure.normalDepth;
			}
		}
		
		public function get flipped():Boolean
		{
			return _flipped;
		}
		
		public function set rotated(val:Boolean):void
		{
			_rotated = val;
		}
		
		public function get rotated():Boolean
		{
			return _rotated;
		}
		
		public function getCornerMatrix():Dictionary
		{
			var cornerMatrix:Dictionary = new Dictionary();
			cornerMatrix["topLeft"] = new Point3D(x - structure.width/2, 0, z - structure.depth/2);
			cornerMatrix["topRight"] = new Point3D(x - structure.width/2, 0, z + structure.depth/2);
			cornerMatrix["bottomLeft"] = new Point3D(x + structure.width/2, 0, z - structure.depth/2);
			cornerMatrix["bottomRight"] = new Point3D(x + structure.width/2, 0, z + structure.depth/2);
			return cornerMatrix;
		}
		
		
	}
}