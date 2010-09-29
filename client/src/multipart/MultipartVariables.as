package multipart
{
	import flash.utils.Dictionary;
	
	/**
	 * The MultipartVariables class represents a set of variables to be used for a multipart/form-data HTTP request.
	 * 
	 * @see multipart.MultipartLoader
	 * @author Neer Friedman
	 * 
	 */	
	public class MultipartVariables
	{
		private var _variableNames:Array;
		private var _variables:Dictionary;
		
		/**
		 * Creates a MultipartVariables object.
		 * @return 
		 * 
		 */		
		public function MultipartVariables() {
			this._variableNames = new Array();
			this._variables = new Dictionary();
		}
		
		/**
		 * Adds a new variable to the MultipartVariables object. <br>
		 * @param name The name of the HTTP variable (in html: <INPUT NAME="myName" ...>)
		 * @param value The parameter value, can be String or ByteArray.
		 * 
		 */		
		public function add(name:String,value:Object=''):void {
			if (this._variableNames.indexOf(name) == -1)
				this._variableNames.push(name);
			this._variables[name] = value;
		}
		
		
		public function get variableNames():Array {
			return(this._variableNames);
		}
		
		public function get variables():Dictionary {
			return(_variables);
		}
	}
}