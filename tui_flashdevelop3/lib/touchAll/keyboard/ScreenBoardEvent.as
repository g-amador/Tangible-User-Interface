package touchAll.keyboard 
{
	
	import flash.events.Event;

	/*
	 * Original source code available at http://www.indieas.org/2009/11/onscreen-keyboard-with-air/ 
	 */
	
	public class ScreenBoardEvent extends Event {
		
		public static const ADDCHAR:String = "ScreenBoardAdd";
		public static const DELCHAR:String = "ScreenBoardDel";
		
		private var _char:String;
		
		public function ScreenBoardEvent( _char:String, type:String, bubbles:Boolean=false, cancelable:Boolean=false ) {
			super(type, bubbles, cancelable);
			this._char = _char;
		}
		
		public override function clone():Event {
			return new ScreenBoardEvent( _char, type, bubbles, cancelable );
		}
		
		public function get char():String {
			return _char;
		}
	}
}