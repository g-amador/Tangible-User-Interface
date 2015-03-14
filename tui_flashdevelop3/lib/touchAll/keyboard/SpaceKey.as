package touchAll.keyboard 
{
	/*
	 * Original source code available at http://www.indieas.org/2009/11/onscreen-keyboard-with-air/ 
	 */
	
	public class SpaceKey extends Key {
		
		public function SpaceKey(keyColor:uint = 0xffffff, buttonColor:uint = 0x000000, buttonBorderColor:uint = 0x000000) {
			super("Space", keyColor, buttonColor, buttonBorderColor);
			
			frameWidth = 520;
			
			textField.x += (520 - textField.width) / 2;
			
			onUp(null);
		}
		
		public override function get char():String {
			return " ";
		}
		
		public override function toUpperCase():void {
		}
		
		public override function toLowerCase():void {
		}
	}
}