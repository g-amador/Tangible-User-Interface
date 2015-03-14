package touchAll.keyboard 
{
	
	/*
	 * Original source code available at http://www.indieas.org/2009/11/onscreen-keyboard-with-air/ 
	 */
	
	public class DeleteKey extends Key {
		
		public function DeleteKey(keyColor:uint = 0xffffff, buttonColor:uint = 0x000000, buttonBorderColor:uint = 0x000000) {
			super("Backspace", keyColor, buttonColor, buttonBorderColor);		
			
			frameWidth = 70;
			textField.x += (70 - textField.width) / 2;
			
			onUp(null);
		}
		
		public override function toUpperCase():void {
		}
		
		public override function toLowerCase():void {
		}
	}
}