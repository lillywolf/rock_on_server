package server
{	
	import com.google.analytics.utils.Variables;
	
	import flash.display.Loader;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import helpers.MultipartURLLoader;
	
	import multipart.MultipartLoader;
	import multipart.MultipartVariables;
	
	import mx.controls.Button;
	import mx.controls.ProgressBar;
	import mx.controls.Text;
	import mx.core.FlexGlobals;
	import mx.formatters.NumberFormatter;
	import mx.utils.Base64Encoder;
		
	public class ClientUploader extends EventDispatcher
	{
		private var fileRef:FileReference;
		private var message:Text;
		private var numberFormatter:NumberFormatter;
		private var progressBar:ProgressBar;
		private var _sc:ServerController;
		
		public function ClientUploader(sc:ServerController, target:IEventDispatcher=null)
		{
			super(target);
			_sc = sc;
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, onFileSelected);
			fileRef.addEventListener(ProgressEvent.PROGRESS, onFileProgress);
			fileRef.addEventListener(Event.COMPLETE, onFileComplete);
			numberFormatter = new NumberFormatter();
			progressBar = new ProgressBar();
			formatUploader();
		}
		
		private function formatUploader():void
		{
			message = new Text();
			message.right = 0;
			FlexGlobals.topLevelApplication.topBarView.addChild(message);
			var btn:Button = new Button();
			btn.width = 30;
			btn.height = 30;
			btn.right = 10;
			btn.top = 30;
			var saveBtn:Button = new Button();
			saveBtn.width = 30;
			saveBtn.height = 30;
			saveBtn.right = 50;
			saveBtn.top = 30;
			saveBtn.addEventListener(MouseEvent.CLICK, doUpload);
			btn.addEventListener(MouseEvent.CLICK, browseAndUpload);
			FlexGlobals.topLevelApplication.topBarView.addChild(btn);
			FlexGlobals.topLevelApplication.topBarView.addChild(saveBtn);
			progressBar.visible = false;
			progressBar.indeterminate = true;
			FlexGlobals.topLevelApplication.topBarView.addChild(progressBar);
		}
		
		private function browseAndUpload(evt:MouseEvent):void
		{
			fileRef.browse();
			message.text = "";
		}
		
		private function onFileSelected(evt:Event):void
		{
			try	{
				message.text = "size (bytes): " + numberFormatter.format(fileRef.size);
//				fileRef.upload(new URLRequest(ServerController.BASE_URL));
				fileRef.load();
			} catch (e:Error) {
				message.text = "Error: zero-byte file";
			}
		}
		
		private function onFileProgress(evt:ProgressEvent):void
		{
			progressBar.visible = true;
		}
		
		private function onFileComplete(evt:Event):void
		{
			message.text += " (complete)";
			progressBar.visible = false;
			var loader:Loader = new Loader();
			loader.loadBytes(evt.target.data);
		}
		
		private function doUpload(evt:MouseEvent):void
		{
			var route:String = ServerController.BASE_URL + "song/upload_song";
			var request:URLRequest = new URLRequest(route);
			request.method = URLRequestMethod.POST;
			var b64:Base64Encoder = new Base64Encoder();
			b64.encodeBytes(fileRef.data);
			var variables:URLVariables = new URLVariables();
			variables.bytearray = b64.toString();
			variables.filename = fileRef.name;
			request.data = variables;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.load(request);			
		}
	}
}