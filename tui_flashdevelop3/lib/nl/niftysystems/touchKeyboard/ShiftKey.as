package nl.niftysystems.touchKeyboard 
{
	
	/*
	 * Original source code available at http://www.indieas.org/2009/11/onscreen-keyboard-with-air/ 
	 */
	
	public class ShiftKey extends Key {
		
		public function ShiftKey(keyColor:uint = 0xffffff, buttonColor:uint = 0x000000, buttonBorderColor:uint = 0x000000) {
			super("Shift", keyColor, buttonColor, buttonBorderColor);
			
			frameWidth = 36;
			textField.x += (36 - textField.width) / 2;
			
			onUp(null);
		}
		
		public override function get char():String {
			return "";
		}
		
		public override function toUpperCase():void {
		}
		
		public override function toLowerCase():void {
		}
	}
}