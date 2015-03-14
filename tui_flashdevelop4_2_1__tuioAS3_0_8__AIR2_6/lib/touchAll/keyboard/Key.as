package touchAll.keyboard 
{
	import flash.system.fscommand;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	//import flash.events.TransformGestureEvent;
	import flash.text.*;
	
	import touchAll.keyboard.CustomKeyboard;
	
	import org.tuio.TuioTouchEvent;
	
	/*
	 * Original source code available at http://www.indieas.org/2009/11/onscreen-keyboard-with-air/ 
	 */

	public class Key extends Sprite {
		
		protected var textField:TextField;
		protected var borderVertical:Number = 4;
		protected var borderHorizontal:Number = 15;
		
		protected var frameWidth:Number;
		protected var frameHeight:Number;
		
		private var _buttonColor:uint;
		private var _buttonBorderColor:uint;
		
		public function Key(char:String, keyColor:uint = 0xffffff, buttonColor:uint = 0x000000, buttonBorderColor:uint = 0x000000) {
			super();
			
			_buttonColor = buttonColor;
			_buttonBorderColor = buttonBorderColor;
			
			textField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.wordWrap = false;
			textField.x = borderHorizontal;
			textField.y = borderVertical;
			addChild(textField);
			
			var format:TextFormat = new TextFormat();
			format.font = "Trebuchet MS";
			format.color = keyColor;
			format.size = 19;
						
			textField.defaultTextFormat = format;
			textField.text = char;
			
			frameWidth = 18;
			frameHeight = 28;
			
			mouseChildren = false;
			buttonMode = true;
			useHandCursor = true;
			
			onUp(null);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			addEventListener(MouseEvent.MOUSE_UP, onUp);
			addEventListener(MouseEvent.MOUSE_OUT, onUp);
			
			addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
			addEventListener(TuioTouchEvent.TOUCH_UP, onUp);
			addEventListener(TuioTouchEvent.TOUCH_OUT, onUp);
		}
		
		public function get char():String {
			return textField.text;
		}
		
		public function toUpperCase():void {
			textField.text = textField.text.toUpperCase();
		}
		
		public function toLowerCase():void {
			textField.text = textField.text.toLowerCase();
		}
		
		protected function onDown(me:Event):void {	
			graphics.clear();
			graphics.lineStyle(1, _buttonBorderColor, 0.6);
			graphics.beginFill(0x00ff00, 0.6);
			graphics.drawRect(0, 0, frameWidth + 2 * borderHorizontal, frameHeight + 2 * borderVertical);
			graphics.endFill();
			
			switch (this.char) {
				case "Backspace" :
					CustomKeyboard._textScreen.replaceText(CustomKeyboard._textScreen.text.length - 1, CustomKeyboard._textScreen.text.length, "");
					break;
				case "Enter" :
					CustomKeyboard._textScreen.appendText("\n");
					CustomKeyboard._textScreen.scrollV += 1;
					
					var command:String = CustomKeyboard._textScreen.getLineText(CustomKeyboard._textScreen.numLines - 2).slice( 0, -1 );
					command.toLowerCase();
					
					switch (command) {
						case "quit":
							trace("quit");
							fscommand("quit");
							break;
						case "trapallkeys true":
							trace("trapallkeys true");
							fscommand("trapallkeys", "true");
							break;						
						case "trapallkeys false":
							trace("trapallkeys false");
							fscommand("trapallkeys", "false");
							break;
						case "fullscreen true":
							trace("fullscreen true");
							fscommand("fullscreen", "true");
							break;
						case "fullscreen false":
							trace("fullscreen false");
							fscommand("fullscreen", "false");
							break;
						case "allowscale true":
							trace("allowscale true");
							fscommand("allowscale", "true");
							break;
						case "allowscale false":
							trace("allowscale false");
							fscommand("allowscale", "false");
							break;
						case "showmenu true":
							trace("showmenu true");
							fscommand("showmenu", "true");
							break;						
						case "showmenu false":
							trace("showmenu false");
							fscommand("showmenu", "false");
							break;
						default :
							trace(command + " length " + command.length);
							
							if (command.slice(0, 5) == "exec ") {
								var args:String = command.slice(5, command.length)
								trace("exec " + args);
								fscommand("exec", args);
								break;
							}
					}
					break;
				default :
					CustomKeyboard._textScreen.appendText(this.char);
			}
		}
		
		protected function onUp(me:Event):void {
			graphics.clear();
			graphics.lineStyle(1, _buttonBorderColor, 0.4);
			graphics.beginFill(_buttonColor, 1.0);
			graphics.drawRect(0, 0, frameWidth + 2 * borderHorizontal, frameHeight + 2 * borderVertical);
			graphics.endFill();
		}
	}
}