package touchAll.keyboard 
{
	
	/**
	 * @author Gonçalo Amador
	 */
	
	public class EnterKey extends Key {
		
		public function EnterKey(keyColor:uint = 0xffffff, buttonColor:uint = 0x000000, buttonBorderColor:uint = 0x000000) {
			super("Enter", keyColor, buttonColor, buttonBorderColor);		
			
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