package helpers
{
	public class UnprocessedModel
	{
		public var _model:String;
		public var _instanceData:Object;
		public var _relationshipData:Object;
		public var _instance:Object;
		
		public function UnprocessedModel(model:String, relationshipData:Object, instanceData:Object, instance:Object = null)
		{
			_model = model;
			_relationshipData = relationshipData;
			_instanceData = instanceData;
			_instance = instance;
		}
		
		public function set model(val:String):void
		{
			_model = val;
		}
		
		public function get model():String
		{
			return _model;
		}
		
		public function set instanceData(val:Object):void
		{
			_instanceData = val;
		}
		
		public function get instanceData():Object
		{
			return _instanceData;
		}
		
		public function set relationshipData(val:Object):void
		{
			_relationshipData = val;
		}
		
		public function get relationshipData():Object
		{
			return _relationshipData;
		}
		
		public function set instance(val:Object):void
		{
			_instance = val;
		}
		
		public function get instance():Object
		{
			return _instance;
		}

	}
}