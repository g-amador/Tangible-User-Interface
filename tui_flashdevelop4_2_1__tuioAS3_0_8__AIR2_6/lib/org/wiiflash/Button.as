/*
Copyright (c) 2007 Joa Ebert and Thibault Imbert

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package org.wiiflash
{	
	/**
	 * The Button class represents one button on any device. This could be for instance the <em>A</em> button
	 * of the Wiimote or the <em>Z</em> button of the Nunchuk.
	 * 
	 * All posible types are defined in the ButtonType class.
	 * 
	 * @see org.wiiflash.ButtonType org.wiiflash.ButtonType
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 */	
	internal final class Button
	{
		private var _state:Boolean;
		private var _lastState:Boolean;

		private var mask:int;
		
		private var _type:int;
				
		/**
		 * @private
		 * 
		 * Creates a new Button object.
		 * 
		 * A Button object may only be created by the Wiimote class.
		 * 
		 * @param buttonType The type of the button. May be any value from ButtonType.
		 * 
		 * @throws Error Thrown when constructor is called manually.
		 * @throws ArgumentError Thrown when type is unknown.
		 */	
		public function Button( buttonType:int )
		{			
			
			_state = _lastState = false;
			
			mask = 1 << ButtonType.getShiftFromType( buttonType );
			
			_type = buttonType;
			
		}
		
		/**
		 * Flag that indicates if the state of the button.
		 */		
		public function get state():Boolean
		{
			return _state;
		}
		
		/**
		 * Flag that indicates the last state of the button.
		 */
		 public function get lastState():Boolean
		 {
		 	return _lastState;
		 }

		/**
		 * The type of the Button object.
		 * Possible types can be found in the ButtonTypes class.
		 * 
		 * @see org.wiiflash.ButtonType org.wiiflash.ButtonType
		 */		
		public function get type():int
		{
			return _type;
		}
		
		/**
		 * Returns the string representation of the specified object.
		 * 
		 * @return A string representation of the object.  
		 */	
		public function toString():String
		{
			return '[Button state:' + _state + ', lastState:' + _lastState + ']';
		}
		
		/**
		 * @private
		 */
		internal function update( stateValue:int ):void
		{
			_lastState = _state;
			_state = ( stateValue & mask ) != 0x00;
			
		}
	}
}