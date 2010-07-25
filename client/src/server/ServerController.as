package server
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import game.GameDataInterface;
	
	import mx.controls.Alert;
	import mx.events.DynamicEvent;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	
	public class ServerController extends EventDispatcher
	{
		
//		public static const BASE_URL:String = "http://vivid-samurai-39.heroku.com/";
		public static const BASE_URL:String = "http://localhost:3000/";
		
		public var _gdi:GameDataInterface;
		public var httpService:HTTPService;
		public var httpServiceRequests:Dictionary;
		public var modelToManagerMap:Dictionary;
		
		public static var NETWORK_ERROR:String = 'network_error';
		
		public function ServerController(gdi:GameDataInterface)
		{
			_gdi = gdi;
			httpService = new HTTPService();
			httpServiceRequests = new Dictionary();
			generateModelToManagerMap();
			setupHttpService();
		}
		
		public function generateModelToManagerMap():void
		{
			modelToManagerMap = new Dictionary();
			modelToManagerMap['layerable'] = 'layerableController';
			modelToManagerMap['owned_layerable'] = 'ownedlayerableController';
			modelToManagerMap['thinger'] = 'thingerController';
			modelToManagerMap['owned_thinger'] = 'thingerController';
			modelToManagerMap['creature'] = 'creatureController';
			modelToManagerMap['dwelling'] = 'dwellingController';
		}
		
		public function sendRequest(params:Object, controller:String, action:String, method:String = 'GET'):void
		{
			setHttpServiceMethod(method);
			var route:String = calculateRoute(controller, action);
			setHttpServiceUrl(route);
			var token:AsyncToken = httpService.send(params);
			httpServiceRequests[token] = {controller: controller, received: false};
//			Alert.show("sent " + controller.toString());
		}
		
		private function calculateRoute(controller:String, action:String):String
		{
			var route:String = controller + '/' + action;
			return route;
		}

		private function setupHttpService():void
		{
			httpService.resultFormat = "text";
			httpService.addEventListener("result", onServerResponse);
			httpService.addEventListener("fault", onHttpServiceFault);
		}
		
		private function onServerResponse(evt:ResultEvent):void
		{	
			var params:Object = getParams( evt );						
			var requestKey:String = httpServiceRequests[evt.token].controller;
			httpServiceRequests[evt.token].received = true;
//			Alert.show("received " + requestKey.toString());
//			requestCache.cacheRequest( params.hashkey, params );
//			params = requestCache.retrieveRequest( params.hashkey );
			
			if (params.auth_failed)
			{
				mx.controls.Alert.show("Problems with your connection! Yikes!");
			}
			else
			{
				handleParams(params, requestKey);
			}
		}
		
		public function allOutoingRequestsReceived(controllerName:String):Boolean
		{
			for each (var obj:Object in httpServiceRequests)
			{
				if (obj.received == false && obj.controller == controllerName)
				{
					return false;
				}
			}
			return true;
		}
		
		private function getParams(evt:ResultEvent):Object
		{
			try
			{
				return JSON.decode(String(evt.result));
			}
			catch( e:Error )
			{
				throw new Error("The server returned something that did not look like JSON.");
			}			
			return {};
		}
		
		private function handleParams(params:Object, requestKey:String):void
		{
			var managerName:String = modelToManagerMap[requestKey];
			handleParamsForModel(managerName, requestKey, params);
		}	
		
		public function handleParamsForModel(managerName:String, requestKey:String, params:Object):void
		{
			_gdi.objectLoaded(params, requestKey);	
		}		
		
		private function onHttpServiceFault(evt:FaultEvent):void
		{				
			var dEvt:DynamicEvent = new DynamicEvent( NETWORK_ERROR );
			dEvt.message = evt.message;
			dispatchEvent( dEvt );
		}	
		
		private function setHttpServiceMethod(method:String = 'GET'):void
		{
			if( method != 'GET' && method != 'POST' )
			{
				throw new Error("Method must be 'GET' or 'POST'");
			}
						
			httpService.method = method;
		}	
		
		private function setHttpServiceUrl(route:String):void
		{
			// This is not secure
			
			httpService.url = ServerController.BASE_URL + route;
			
			if (httpService.url.length > 2000)
			{
				throw new Error("Your HTTPService URL was more than 2000 characters! This breaks in IE."); 
			}			
		}	
	}
}