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
package org.wiiflash.events
{
	import flash.events.Event;

	/**
	 * WiiFlash dispatches ButtonEvent objects when a user interacts with buttons on a Wiimote.
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 */
	public final class ButtonEvent extends Event
	{
		//-----------------------------------------------------------------------------------
		// Wiimote Buttons
		//-----------------------------------------------------------------------------------
		
		/**
		* Type of the <em>1</em> press event.
		*/
		public static const ONE_PRESS:String = 'onePress';
		
		/**
		* Type of the <em>1</em> release event.
		*/
		public static const ONE_RELEASE:String = 'oneRelease';

		/**
		* Type of the <em>2</em> press event.
		*/
		public static const TWO_PRESS:String = 'twoPress';
		
		/**
		* Type of the <em>2</em> release event.
		*/
		public static const TWO_RELEASE:String = 'twoRelease';
		
		/**
		* Type of the <em>A</em> press event.
		*/
		public static const A_PRESS:String = 'aPress';
		
		/**
		* Type of the <em>A</em> release event.
		*/
		public static const A_RELEASE:String = 'aRelease';
		
		/**
		* Type of the <em>B</em> press event.
		*/
		public static const B_PRESS:String = 'bPress';
		
		/**
		* Type of the <em>B</em> release event.
		*/
		public static const B_RELEASE:String = 'bRelease';
		
		/**
		* Type of the <em>+</em> press event.
		*/
		public static const PLUS_PRESS:String = 'plusPress';
		
		/**
		* Type of the <em>+</em> release event.
		*/
		public static const PLUS_RELEASE:String = 'plusRelease';
		
		/**
		* Type of the <em>-</em> press event.
		*/
		public static const MINUS_PRESS:String = 'minusPress';
		
		/**
		* Type of the <em>-</em> release event.
		*/
		public static const MINUS_RELEASE:String = 'minusRelease';
		
		/**
		* Type of the <em>Home</em> press event.
		*/
		public static const HOME_PRESS:String = 'homePress';
		
		/**
		* Type of the <em>Home</em> release event.
		*/
		public static const HOME_RELEASE:String = 'homeRelease';
		
		/**
		* Type of the <em>Up</em> press event.
		*/
		public static const UP_PRESS:String = 'upPress';
		
		/**
		* Type of the <em>Up</em> release event.
		*/
		public static const UP_RELEASE:String = 'upRelease';
		
		/**
		* Type of the <em>Down</em> press event.
		*/
		public static const DOWN_PRESS:String = 'downPress';
		
		/**
		* Type of the <em>Down</em> release event.
		*/
		public static const DOWN_RELEASE:String = 'downRelease';
		
		/**
		* Type of the <em>Right</em> press event.
		*/
		public static const RIGHT_PRESS:String = 'rightPress';
		
		/**
		* Type of the <em>Right</em> release event.
		*/
		public static const RIGHT_RELEASE:String = 'rightRelease';
		
		/**
		* Type of the <em>Left</em> press event.
		*/
		public static const LEFT_PRESS:String = 'leftPress';
		
		/**
		* Type of the <em>Left</em> release event.
		*/
		public static const LEFT_RELEASE:String = 'leftRelease';
		
		//-----------------------------------------------------------------------------------
		// Nunchuk Buttons
		//-----------------------------------------------------------------------------------
		
		/**
		* Type of the <em>C</em> press event.
		*/
		public static const C_PRESS:String = 'cPress';
		
		/**
		* Type of the <em>C</em> release event.
		*/
		public static const C_RELEASE:String = 'cRelease';
		
		/**
		* Type of the <em>Z</em> press event.
		*/
		public static const Z_PRESS:String = 'zPress';
		
		/**
		* Type of the <em>Z</em> release event.
		*/
		public static const Z_RELEASE:String = 'zRelease';
		
		//-----------------------------------------------------------------------------------
		
		//-----------------------------------------------------------------------------------
		// ClassicController Buttons
		//-----------------------------------------------------------------------------------
		
		/**
		* Type of the <em>X</em> press event.
		*/
		public static const X_PRESS:String = 'xPress';
		
		/**
		* Type of the <em>X</em> release event.
		*/
		public static const X_RELEASE:String = 'xRelease';
		
		/**
		* Type of the <em>Y</em> press event.
		*/
		public static const Y_PRESS:String = 'yPress';
		
		/**
		* Type of the <em>Y</em> release event.
		*/
		public static const Y_RELEASE:String = 'yRelease';
		
				/**
		* Type of the <em>L</em> press event.
		*/
		public static const L_PRESS:String = 'lPress';
		
		/**
		* Type of the <em>L</em> release event.
		*/
		public static const L_RELEASE:String = 'lRelease';
		
		/**
		* Type of the <em>R</em> press event.
		*/
		public static const R_PRESS:String = 'rPress';
		
		/**
		* Type of the <em>R</em> release event.
		*/
		public static const R_RELEASE:String = 'rRelease';
		
		/**
		* Type of the <em>ZL</em> press event.
		*/
		public static const ZL_PRESS:String = 'zlPress';
		
		/**
		* Type of the <em>ZL</em> release event.
		*/
		public static const ZL_RELEASE:String = 'zlRelease';
		/**
		* Type of the <em>ZR</em> press event.
		*/
		public static const ZR_PRESS:String = 'zrPress';
		
		/**
		* Type of the <em>ZR</em> release event.
		*/
		public static const ZR_RELEASE:String = 'zrRelease';
		
		//-----------------------------------------------------------------------------------
		
		private var _state:Boolean;
		
		/**
		 * Creates an event object that contains information about button events.
		 * 
		 * @param type The type of the event. Event listeners can access this information through the inherited <code>type</code> property.
		 * @param state State of the button. <code>true</code> for down; <code>false</code> otherwise.
		 */		
		public function ButtonEvent( type:String, state:Boolean )
		{
			super( type, false, false );
			
			_state = state;
		}
		
		/**
		* State of the button. <code>true</code> for down; <code>false</code> otherwise.
		*/	
		public function get state():Boolean
		{
			return _state;
		}
	}
}