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
	import org.wiiflash.events.ButtonEvent;
	
	/**
	 * The ButtonType class is an enumeration of constant values that indicate which type a Button object is.
	 * Each button of the Wiimote and extensions like the Nunchuk is asociated with one of these constants.
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 */	
	public final class ButtonType
	{
		//-----------------------------------------------------------------------------------
		// Wiimote
		//-----------------------------------------------------------------------------------
		
		/**
		* The <em>1</em> button of the Wiimote.
		*/
		public static const ONE:int = 0x00;
		
		/**
		* The <em>2</em> button of the Wiimote.
		*/
		public static const TWO:int = 0x01;
		
		/**
		* The <em>A</em> button of the Wiimote.
		*/
		public static const A:int = 0x02;
		
		/**
		* The <em>B</em> button of the Wiimote.
		*/
		public static const B:int = 0x03;
		
		/**
		* The <em>+</em> button of the Wiimote.
		*/
		public static const PLUS:int = 0x04;
		
		/**
		* The <em>-</em> button of the Wiimote.
		*/
		public static const MINUS:int = 0x05;
		
		/**
		* The <em>Home</em> button of the Wiimote.
		*/
		public static const HOME:int = 0x06;
		
		/**
		* The <em>Up</em> button of the Wiimote.
		*/
		public static const UP:int = 0x07;
		
		/**
		* The <em>Down</em> button of the Wiimote.
		*/
		public static const DOWN:int = 0x08;
		
		/**
		* The <em>Right</em> button of the Wiimote.
		*/
		public static const RIGHT:int = 0x09;
		
		/**
		* The <em>Left</em> button of the Wiimote.
		*/
		public static const LEFT:int = 0x0a;
		
		//-----------------------------------------------------------------------------------
		// Nunchuk
		//-----------------------------------------------------------------------------------
		
		/**
		* The <em>C</em> button of the Nunchuk.
		*/
		public static const C:int = 0x0b;
		
		/**
		* The <em>Z</em> button of the Nunchuk.
		*/
		public static const Z:int = 0x0c;
		
		//-----------------------------------------------------------------------------------
		// Classic controller
		//-----------------------------------------------------------------------------------
		/*
		
		/**
		* The <em>X</em> button of the Classic Controller.
		*/
		public static const X:int = 0x0d;
		
		/**
		* The <em>Y</em> button of the Classic Controller.
		*/
		public static const Y:int = 0x0e;
		
		/**
		* The <em>L</em> button of the Classic Controller.
		*/
		public static const L:int = 0x0f;
		
		/**
		* The <em>R</em> button of the Classic Controller.
		*/
		public static const R:int = 0x10;
		
		/**
		* The <em>ZL</em> button of the Classic Controller.
		*/
		public static const ZL:int = 0x11;
		
		/**
		* The <em>ZR</em> button of the Classic Controller.
		*/
		public static const ZR:int = 0x12;
	
		/**
		 * @private
		 */
		internal static function getShiftFromType( type:int ):int
		{
			if ( type < 0x0b )
			{
				return ( 0x0f - type );
			}
			else if ( type == 0x0b )
				return 1;
			else if ( type == 0x0c )
				return 0;
			else if ( type == 0x0d )
				return 15;
			else if ( type == 0x0e )
				return 14;
			else if ( type == 0x0f )
				return 4;
			else if ( type == 0x10 )
				return 3;
			else if ( type == 0x11 )
				return 2;
			else if ( type == 0x12 )
				return 1;
			
			return 0;
		}
		
		/**
		 * @private
		 */		
		internal static function getEventFromType( type:int, state:Boolean ):String
		{
			if ( state )
			{
				if ( type == 0x00 )
					return ButtonEvent.ONE_PRESS;
				else if ( type == 0x01 )
					return ButtonEvent.TWO_PRESS;
				else if ( type == 0x02 )
					return ButtonEvent.A_PRESS;
				else if ( type == 0x03 )
					return ButtonEvent.B_PRESS;
				else if ( type == 0x04 )
					return ButtonEvent.PLUS_PRESS;
				else if ( type == 0x05 )
					return ButtonEvent.MINUS_PRESS;
				else if ( type == 0x06 )
					return ButtonEvent.HOME_PRESS;
				else if ( type == 0x07 )
					return ButtonEvent.UP_PRESS;
				else if ( type == 0x08 )
					return ButtonEvent.DOWN_PRESS;
				else if ( type == 0x09 )
					return ButtonEvent.RIGHT_PRESS;
				else if ( type == 0x0a )
					return ButtonEvent.LEFT_PRESS;
				else if ( type == 0x0b )
					return ButtonEvent.C_PRESS;
				else if ( type == 0x0c )
					return ButtonEvent.Z_PRESS;
				else if ( type == 0x0d )
					return ButtonEvent.X_PRESS;
				else if ( type == 0x0e )
					return ButtonEvent.Y_PRESS;
				else if ( type == 0x0f )
					return ButtonEvent.L_PRESS;
				else if ( type == 0x10 )
					return ButtonEvent.R_PRESS;
				else if ( type == 0x11 )
					return ButtonEvent.ZL_PRESS;
				else if( type == 0x12 )
					return ButtonEvent.ZR_PRESS;
				
			}
			else
			{
				if ( type == 0x00 )
					return ButtonEvent.ONE_RELEASE;
				else if ( type == 0x01 )
					return ButtonEvent.TWO_RELEASE;
				else if ( type == 0x02 )
					return ButtonEvent.A_RELEASE;
				else if ( type == 0x03 )
					return ButtonEvent.B_RELEASE;
				else if ( type == 0x04 )
					return ButtonEvent.PLUS_RELEASE;
				else if ( type == 0x05 )
					return ButtonEvent.MINUS_RELEASE;
				else if ( type == 0x06 )
					return ButtonEvent.HOME_RELEASE;
				else if ( type == 0x07 )
					return ButtonEvent.UP_RELEASE;
				else if ( type == 0x08 )
					return ButtonEvent.DOWN_RELEASE;
				else if ( type == 0x09 )
					return ButtonEvent.RIGHT_RELEASE;
				else if ( type == 0x0a )
					return ButtonEvent.LEFT_RELEASE;
				else if ( type == 0x0b )
					return ButtonEvent.C_RELEASE;
				else if ( type == 0x0c )
					return ButtonEvent.Z_RELEASE;
				else if ( type == 0x0d )
					return ButtonEvent.X_RELEASE
				else if ( type == 0x0e )
					return ButtonEvent.Y_RELEASE
				else if ( type == 0x0f )
					return ButtonEvent.L_RELEASE;
				else if ( type == 0x10 )
					return ButtonEvent.R_RELEASE;
				else if ( type == 0x11 )
					return ButtonEvent.ZL_RELEASE;
				else if( type == 0x12 )
					return ButtonEvent.ZR_RELEASE;
			}
			
			return '';
		}
	}
}