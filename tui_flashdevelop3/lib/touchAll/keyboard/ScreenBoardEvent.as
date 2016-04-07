/*
 * Tangible User Interfacer (former TouchAll) code.
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
