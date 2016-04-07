/*
 * Tangible User Interfacer (former TouchAll) misc code.
 *
 * Copyright 2016 Gonçalo Amador <g.n.p.amador@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
﻿package touchAll.keyboard
{
	
	/*
	 * Original source code available at http://www.actionscript.org/resources/articles/711/1/AS3-On-Screen-Keyboard/Page1.html
	 * TO ADD:
	 * 1 - Support mouse touch move multi keys selection
	 * 2 - ...
	 */
	
	import flash.display.*;
	import flash.text.*;
	//import flash.events.TransformGestureEvent;
	
	import touchAll.keyboard.ScreenBoard;
	
	import org.tuio.TuioTouchEvent;

	[SWF(width="720", height="440", frameRate="60", backgroundColor="#ffffff")]
	public class CustomKeyboard extends MovieClip {
		static public var _textScreen:TextField = new TextField;
		static public var _keyboard:ScreenBoard = new ScreenBoard(0, 0);;
		static public var _shift:Boolean = false;
		static public var _caps:Boolean = false;
		
		private var _keyColor:uint;
		private var _buttonColor:uint;
		private var _borderColor:uint;
				
		public function CustomKeyboard(TextScreenX:uint = 0, TextScreenY:uint = 0, TextScreenWidth:uint = 718, TextScreenHeight:uint = 200, screenBoardX:uint = 0, screenBoardY:uint = 220, keyColor:uint = 0xffffff, buttonColor:uint = 0x000000, borderColor:uint = 0x000000) {
			_keyColor = keyColor;
			_buttonColor = buttonColor;
			_borderColor = borderColor;
			
			buildTextScreen(TextScreenX, TextScreenY, TextScreenWidth, TextScreenHeight);
			buidOnScreenKeyboard(screenBoardX, screenBoardY);
		}
		
		public function update(TextScreenX:uint = 0, TextScreenY:uint = 0, screenBoardX:uint = 0, screenBoardY:uint = 220):void {
			_textScreen.x = TextScreenX;
			_textScreen.y = TextScreenY;
			_keyboard.x = screenBoardX;
			_keyboard.y = screenBoardY;
		}
		
		private function buildTextScreen(TextScreenX:uint, TextScreenY:uint, TextScreenWidth:uint, TextScreenHeight:uint):void {
			_textScreen.x = TextScreenX;
			_textScreen.y = TextScreenY;
			_textScreen.width = TextScreenWidth;
			_textScreen.height = TextScreenHeight;
			_textScreen.text = "";
			_textScreen.wordWrap = true;
			_textScreen.selectable = false;
			_textScreen.border = true;
			_textScreen.textColor = _borderColor;
			_textScreen.borderColor = _borderColor;
			addChild(_textScreen);
		}
		
		private function buidOnScreenKeyboard(screenBoardX:uint, screenBoardY:uint):void {
			_keyboard = new ScreenBoard(screenBoardX, screenBoardY, _keyColor, _buttonColor, _borderColor);
			addChild(_keyboard);
		}
	}
}
