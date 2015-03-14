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
	 * WiiFlash dispatches WiimoteEvent objects when a change releated to a Wiimote object occured.
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 */
	public final class WiimoteEvent extends Event
	{
		/**
		* Type of the update event that is dispatched by a Wiimote object.
		*/		
		public static const UPDATE:String = 'update';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when a Nunchuk has been connected.
		*/		
		public static const NUNCHUK_CONNECT:String = 'nunchukConnect';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when a Nunchuk has been disconnected.
		*/
		public static const NUNCHUK_DISCONNECT:String = 'nunchukDisconnect';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when a Balance Board has been detected.
		*/		
		public static const BALANCEBOARD_CONNECT:String = 'balanceBoardConnect';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when a Balance Board is disconnected.
		*/
		public static const BALANCEBOARD_DISCONNECT:String = 'balanceBoardDisconnect';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when a Classic Controller has been connected.
		*/		
		public static const CONTROLLER_CONNECT:String = 'classicControllerConnect';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when a Classic Controller has been disconnected.
		*/
		public static const CONTROLLER_DISCONNECT:String = 'classicControllerDisconnect';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when IR sensor bar point <em>1</em> has been found.
		*/
		public static const IR1_FOUND:String = 'ir1Found';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when IR sensor bar point <em>2</em> has been found.
		*/
		public static const IR2_FOUND:String = 'ir2Found';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when IR sensor bar point <em>3</em> has been found.
		*/
		public static const IR3_FOUND:String = 'ir3Found';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when IR sensor bar point <em>4</em> has been found.
		*/
		public static const IR4_FOUND:String = 'ir4Found';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when IR sensor bar point <em>1</em> got lost.
		*/
		public static const IR1_LOST:String = 'ir1Lost';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when IR sensor bar point <em>2</em> got lost.
		*/
		public static const IR2_LOST:String = 'ir2Lost';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when IR sensor bar point <em>3</em> got lost.
		*/
		public static const IR3_LOST:String = 'ir3Lost';
		
		/**
		* Type of the event that is dispatched by a Wiimote object when IR sensor bar point <em>4</em> got lost.
		*/
		public static const IR4_LOST:String = 'ir4Lost';
		
		/**
		 * Creates an event object that contains information about Wiimote events.
		 * 
		 * @param type The type of the event. Event listeners can access this information through the inherited <code>type</code> property.
		 */	
		public function WiimoteEvent( type:String )
		{
			super( type, false, false );
		}
	}
}