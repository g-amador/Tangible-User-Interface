package nl.niftysystems.touchKeyboard 
{
	
	/*
	 * Original source code available at http://www.indieas.org/2009/11/onscreen-keyboard-with-air/ 
	 */
	
	public class ToggleKey extends Key {
		
		private var lower:String;
		private var upper:String;
		
		public function ToggleKey(lowerChar:String, upperChar:String, keyColor:uint = 0xffffff, buttonColor:uint = 0x000000, buttonBorderColor:uint = 0x000000) {
			super(" ", keyColor, buttonColor, buttonBorderColor);
			
			lower = lowerChar;
			upper = upperChar;
			
			toLowerCase();
		}
		
		public override function toUpperCase():void {
			textField.text = upper;
		}
		
		public override function toLowerCase():void {
			textField.text = lower;
		}
	}
}