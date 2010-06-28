package models
{
	import controllers.Controller;
	
	import flash.display.*;
	import flash.errors.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	
	/**
	 * @private
	 **/ 
	public class ClassLoader extends Loader
	{
		public static var CLASS_LOADED:String = "classLoaded";
		public static var LOAD_ERROR:String ="loadError";
		
		private var fileURL:String;
		private var applicationDomain:ApplicationDomain;
		
		public function ClassLoader(fileURL:String)
		{
			this.fileURL = fileURL;
			super();
			contentLoaderInfo.addEventListener(Event.COMPLETE,classesLoaded);
			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadFailed);
		}
		
		public function loadClasses():void
		{
			var request:URLRequest = new URLRequest(fileURL);
			load(request);
		}
		
		private function classesLoaded(evt:Event):void
		{
			applicationDomain = evt.currentTarget.applicationDomain
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		public function getClass( className:String ):Class
		{
			if(!applicationDomain)
			{
				throw new Error('Classes have not yet been loaded!');
				return;
			}
			return applicationDomain.getDefinition(className) as Class;
		}
		
		public function getInstance( className:String ):*
		{
			var TheClass:Class = getClass( className );
			return new TheClass();
		}
		
		public function loadFailed(evt:IOErrorEvent):void
		{
			throw new Error(evt.text);	
		}
	}
}