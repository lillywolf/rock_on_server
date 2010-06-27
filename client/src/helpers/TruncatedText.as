package helpers 
{
	
	import mx.controls.Text;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class TruncatedText extends Text {
		
		protected static const TRUNCATION_INDICATOR : String = "...";
		
		public function TruncatedText() {
			super();
			
			truncateToFit = true;
		}
		
		override public function set text(text : String) : void {
			_isHTML = false;
			
			super.text = text;
		}
		
		override public function set htmlText(htmlText : String) : void {
			_isHTML = true;
			
			super.htmlText = htmlText;
		}
		
		protected function get truncationRequired() : Boolean {
			return (textField.height < textField.textHeight + UITextField.TEXT_HEIGHT_PADDING);
		}
		
		override protected function updateDisplayList(w : Number, h : Number) : void {
			super.updateDisplayList(w, h);
			
			if (truncateToFit) {
				if (!_isHTML) {
					var originalText : String = textField.text = super.text;
					if (truncationRequired) {
						var l : int = 0;
						var r : int = textField.text.length;
						while (r - l > 1) {
							var median : Number = Math.floor((l + r) / 2);
							textField.text = originalText.substr(0, median) + TRUNCATION_INDICATOR;
							if (truncationRequired) {
								r = median;
							} else {
								l = median;
							}
						}
						while (truncationRequired && median > 0) {
							median--;
							textField.text = originalText.substr(0, median) + TRUNCATION_INDICATOR;
						}
					}
				}
			}
			
		}
		
		private var _isHTML : Boolean;
		
	}
}