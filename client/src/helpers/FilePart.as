package helpers
{
	import flash.utils.ByteArray;

	public class FilePart
	{
		public var fileContent:flash.utils.ByteArray;
		public var fileName:String;
		public var dataField:String;
		public var contentType:String;
			
		public function FilePart(fileContent:flash.utils.ByteArray, fileName:String, dataField:String = 'Filedata', contentType:String = 'application/octet-stream')
		{
			this.fileContent = fileContent;
			this.fileName = fileName;
			this.dataField = dataField;
			this.contentType = contentType;
		}
		
		public function dispose():void
		{
			fileContent = null;
			fileName = null;
			dataField = null;
			contentType = null;
		}			
	}
}