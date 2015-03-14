package nl.niftysystems.touchKeyboard 
{
	import flash.system.fscommand;
	import flash.display.*;
	//import flash.events.TransformGestureEvent;
	import flash.text.*;
	
	import org.tuio.TouchEvent;
	
	import nl.niftysystems.audio.NiftySynth;
	
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
			
			addEventListener(TouchEvent.TOUCH_DOWN, onDown);
			addEventListener(TouchEvent.TOUCH_UP, onUp);
			addEventListener(TouchEvent.TOUCH_OUT, onUp);
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
		
		protected function onDown(me:TouchEvent):void {
			graphics.clear();
			graphics.lineStyle(1, _buttonBorderColor, 0.6);
			graphics.beginFill(0xff0000, 0.6);
			graphics.drawRect(0, 0, frameWidth + 2 * borderHorizontal, frameHeight + 2 * borderVertical);
			graphics.endFill();
			switch (this.char) {
				case " ":
					stage.displayState = StageDisplayState.FULL_SCREEN;
					//stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					break;
				case String.fromCharCode(8592):
					NiftySynth._ns.updateVoice(NiftySynth.voiceIndex-1);
					break;
				case String.fromCharCode(8593):
					NiftySynth._ns.updateCategory(NiftySynth.categoryIndex+1);
					break;
				case String.fromCharCode(8594):
					NiftySynth._ns.updateVoice(NiftySynth.voiceIndex+1);
					break;
				case String.fromCharCode(8595):
					NiftySynth._ns.updateCategory(NiftySynth.categoryIndex-1);
					break;
				case "C":
					NiftySynth._ns.setScale("C#mp");
					break;
				case "c":
					NiftySynth._ns.setScale("Cmp");
					break;
				case "D":
					NiftySynth._ns.setScale("D#mp");
					break;
				case "d":
					NiftySynth._ns.setScale("Dmp");
					break;
				case "E":
					NiftySynth._ns.setScale("Emp");
					break;
				case "e":
					NiftySynth._ns.setScale("Emp");
					break;					
				case "F":
					NiftySynth._ns.setScale("F#mp");
					break;
				case "f":
					NiftySynth._ns.setScale("Fmp");
					break;	
				case "G":
					NiftySynth._ns.setScale("G#mp");
					break;
				case "g":
					NiftySynth._ns.setScale("Gmp");
					break;	
				case "A":
					NiftySynth._ns.setScale("A#mp");
					break;
				case "a":
					NiftySynth._ns.setScale("Amp");
					break;	
				case "B":
					NiftySynth._ns.setScale("Bmp");
					break;
				case "b":
					NiftySynth._ns.setScale("Bmp");
					break;	
			}
		}
		
		protected function onUp(me:TouchEvent):void {
			graphics.clear();
			graphics.lineStyle(1, _buttonBorderColor, 0.4);
			graphics.beginFill(_buttonColor, 1.0);
			graphics.drawRect(0, 0, frameWidth + 2 * borderHorizontal, frameHeight + 2 * borderVertical);
			graphics.endFill();
		}
	}
}