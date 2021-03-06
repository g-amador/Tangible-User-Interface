package nl.niftysystems.touchKeyboard 
{
	
	import flash.display.*;
	//import flash.events.TransformGestureEvent;
	
	import org.tuio.TuioTouchEvent;
	
	/*
	 * Original source code available at http://www.indieas.org/2009/11/onscreen-keyboard-with-air/ 
	 */
	
	[SWF(width = "720", height = "240")]
	public class ScreenBoard extends Sprite {
		
		private var keys:Array;
		private var shift:Boolean;
		private var gap:Number = 2.5;
		
		private var _keyColor:uint;
		private var _buttonColor:uint;
		private var _buttonBorderColor:uint;
		
		public function ScreenBoard(screenBoardX:uint = 0, screenBoardY:uint = 0, keyColor:uint = 0xffffff, buttonColor:uint = 0x000000, buttonBorderColor:uint = 0x000000) {
			super();
			
			shift = false;
			
			_keyColor = keyColor;
			_buttonColor = buttonColor;
			_buttonBorderColor = buttonBorderColor;
			
			initRows();
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			this.x = screenBoardX;
			this.y = screenBoardY;
		}
		
		private function initRows():void {
			var row1:Array = createKeys(String.fromCharCode(8593));
			row1.push(new ToggleKey("b", "b", _keyColor, _buttonColor, _buttonBorderColor));
			row1.reverse();
			row1.push(new ToggleKey("e", "e", _keyColor, _buttonColor, _buttonBorderColor));
			var row2:Array = createKeys(String.fromCharCode(8592) + String.fromCharCode(8595) + String.fromCharCode(8594));
			var row3:Array = createKeys("acdfg");
			var row4:Array = [new ShiftKey(_keyColor, _buttonColor, _buttonBorderColor), new SpaceKey(_keyColor, _buttonColor, _buttonBorderColor)];
			
			var rows:Array = [row1, row2, row3, row4];
			
			var dy:Number = 0;
			var lines:Array = new Array();
			keys = new Array();
			
			for each(var row:Array in rows) {
				var line:Sprite = new Sprite();
				var dx:Number = 0;
				for each(var key:Key in row) {
					key.addEventListener(TuioTouchEvent.TOUCH_DOWN, onKey);
					key.x = dx;
					keys.push(key);
					dx += key.width + gap;
					line.addChild(key);
				}
				line.y = dy;
				dy += line.height + gap;
				addChild(line);
				lines.push(line);
			}
			
			var maxWidth:Number = 0;
			for each(line in lines) maxWidth = Math.max(maxWidth, line.width);
			for each(line in lines) line.x = (maxWidth - line.width) / 2;
		}
		
		private function onKey(me:TuioTouchEvent):void {
			
			var key:Key = me.currentTarget as Key;
			
			if(key is ShiftKey) {
				shift = !shift;
				applyShift();
			} else {
				dispatchEvent(new ScreenBoardEvent(key.char, ScreenBoardEvent.ADDCHAR));
			}
		}
		
		private function createKeys(chars:String):Array {
			var array:Array = new Array();
			for (var i:Number = 0; i < chars.length; i++) {
				array.push(new Key(chars.charAt(i), _keyColor, _buttonColor, _buttonBorderColor));
			}
			return array;
		}
		
		private function applyShift():void {
			for each(var key:Key in keys) {
				if(shift) {
					key.toUpperCase();
				} else {
					key.toLowerCase();
				}
			}
		}
	}
}