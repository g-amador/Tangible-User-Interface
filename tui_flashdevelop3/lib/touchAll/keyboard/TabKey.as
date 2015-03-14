package touchAll.keyboard 
{
	
	/**
	 * @author Gonçalo Amador
	 */
	
	public class TabKey extends Key {
		
		public function TabKey(keyColor:uint = 0xffffff, buttonColor:uint = 0x000000, buttonBorderColor:uint = 0x000000) {
			super("Tab", keyColor, buttonColor, buttonBorderColor);		
			
			frameWidth = 70;
			textField.x += (70 - textField.width) / 2;
			
			onUp(null);
		}
		
		public override function get char():String {
			return "\t";
		}
		
		public override function toUpperCase():void {
		}
		
		public override function toLowerCase():void {
		}
	}
	
}