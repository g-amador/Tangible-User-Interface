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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import org.wiiflash.events.*;
	
	/**
	 * The BalanceBoard class represents a Balance Board.
	 * A BalanceBoard object can not be created manually. The only access to a BalanceBoard is
	 * by using the <code>balanceBoard</code> property of a Wiimote object.
	 * 
	 * @see http://www.wiili.org/index.php/Balance_Board Balance Board description on wiili.org
	 * @see org.wiiflash.Wiimote org.wiiflash.BalanceBoard
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 * 
	 * @example
	 * This example shows how to check if the Balance Board has been plugged to the Wiimote :
	 * <div class="listing">
	 * <pre>
	 * 
	 * var wiimote:Wiimote = new Wiimote();
	 * myWiimote.addEventListener( WiimoteEvent.BALANCEBOARD_CONNECT, onBalanceBoardConnected );
	 * myWiimote.addEventListener( WiimoteEvent.BALANCEBOARD_DISCONNECT, onBalanceBoardDisconnected );
	 * </pre>
	 * </div>
	 */	
	public final class BalanceBoard implements IEventDispatcher
	{
		/**
		 * @private
		 * 
		 * Flag that enables BalanceBoard initialization. Set this to true before
		 * calling the BalanceBoard constructor.
		 */
		internal static var initializing:Boolean = false;
		
		private static const BSL:int = 43;
		private static const BSW:int = 24;
		
		private var _topLeftKg:Number;
		private var _topRightKg:Number;
		
		private var _bottomLeftKg:Number;
		private var _bottomRightKg:Number;
		private var _totalKg:Number;
		
		private var kX:Number;
		private var kY:Number;
		private var gX:Number;
		private var gY:Number;


		private var _parent:Wiimote;
		private var eventDispatcher:EventDispatcher;
		
		/**
		 * @private
		 * 
		 * Creates a new Balance Board object.
		 * 
		 * A BalanceBoard object may only be created by the Wiimote class.
		 * 
		 * @throws Error Thrown when constructor is called manually.
		 */		
		public function BalanceBoard()
		{
			if ( !BalanceBoard.initializing )
				throw new Error( 'Can not create BalanceBoard instance manually.\nAccess is only available using a Wiimote object.' );
			BalanceBoard.initializing = false;
			
			eventDispatcher = new EventDispatcher(this);
			
			_topLeftKg = _topRightKg = _bottomLeftKg = _bottomRightKg = _totalKg = 0;
		}
		
		/**
		 * @private
		 * 
		 * The parent of the BalanceBoard.
		 */		
		internal function set parent( newValue:Wiimote ):void
		{
			_parent = newValue;
		}
		
		//-----------------------------------------------------------------------------------
		// Sensors
		//-----------------------------------------------------------------------------------
		
		/**
		 * Total Kg on the balance board
		 * This value is scaled by the calibration data that has been read from the BalanceBoard.
		 */
		public function get totalKg():Number
		{
			return _totalKg;
		}
		
		/**
		 * Value of the top left sensor.
		 * This value is scaled by the calibration data that has been read from the BalanceBoard.
		 */
		public function get topLeftKg():Number
		{
			return _topLeftKg;
		}
		
		/**
		 * Value of the top right sensor.
		 * This value is scaled by the calibration data that has been read from the BalanceBoard.
		 */
		public function get topRightKg():Number
		{
			return _topRightKg;
		}
		
		/**
		 * Value of the bottom left sensor.
		 * This value is scaled by the calibration data that has been read from the BalanceBoard.
		 */
		public function get bottomLeftKg():Number
		{
			return _bottomLeftKg;
		}
		
		/**
		 * Value of the bottom right sensor.
		 * This value is scaled by the calibration data that has been read from the BalanceBoard.
		 */
		public function get bottomRightKg():Number
		{
			return _bottomRightKg;
		}
		
		/**
		 * Current center of gravity on the balance board. Expressed a Point with x and y gravity. 
		 * This value is scaled by the calibration data that has been read from the BalanceBoard.
		 */
		public function get centerOfGravity():Point
		{
		
			kX = (topLeftKg + bottomLeftKg) / (topRightKg + bottomRightKg);
			kY = (topLeftKg + topRightKg) / (bottomRightKg + bottomLeftKg);
			
			gX = (kX-1)/(kX+1)*(-BSL*.5);
			gY = (kY-1)/(kY+1)*(-BSW*.5);
			
			return new Point ( gX, gY );
			
		}
		//-----------------------------------------------------------------------------------
		// Parsing
		//-----------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * Updates Balance Board data.
		 */		
		internal function update( pack:ByteArray ):void
		{

			_bottomLeftKg = pack.readFloat();
			_bottomRightKg = pack.readFloat();
			
			_topLeftKg = pack.readFloat();
			_topRightKg = pack.readFloat();
			
			_totalKg = pack.readFloat();
			
		}
		
		/**
		 * Returns the string representation of the specified object.
		 * 
		 * @return A string representation of the object.  
		 */	
		public function toString():String
		{
			return '[BalanceBoard parent:' + _parent + ']';
		}
		
		//-----------------------------------------------------------------------------------
		// IEventDispatcher
		//-----------------------------------------------------------------------------------
		 
		/**
		 * Registers an event listener object with a BalanceBoard object so that the listener receives notification of an event.
		 * 
		 * @param type The type of event.
		 * @param listener The listener function that processes the event.
		 * @param useCapture Determines whether the listener works in the capture phase or the target and bubbling phases.
		 * @param priority The priority level of the event listener.
		 * @param useWeakReference Determines whether the reference to the listener is strong or weak.
		 * 
		 * @see http://livedocs.adobe.com/flex/2/langref/flash/events/IEventDispatcher.html#addEventListener() flash.events.IEventDispatcher.addEventListener()
		 */		
		public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void 
		{
			eventDispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		/**
		 * Dispatches an event into the event flow.
		 * 
		 * @param event The Event object dispatched into the event flow.
		 * 
		 * @see http://livedocs.adobe.com/flex/2/langref/flash/events/IEventDispatcher.html#dispatchEvent() flash.events.IEventDispatcher.dispatchEvent()
		 */
		public function dispatchEvent( event:Event ):Boolean
		{
			return eventDispatcher.dispatchEvent( event );
		}
		
		/**
		 * Checks whether the BalanceBoard object has any listeners registered for a specific type of event.
		 * 
		 * @param type The type of event.
		 * @return A value of <code>true</code> if a listener of the specified type is registered; <code>false</code> otherwise.
		 * 
		 * @see http://livedocs.adobe.com/flex/2/langref/flash/events/IEventDispatcher.html#hasEventListener() flash.events.IEventDispatcher.hasEventListener()
		 */		
		public function hasEventListener( type:String ):Boolean
		{
			return eventDispatcher.hasEventListener( type );
		}
		
		/**
		 * Removes a listener from the BalanceBoard object.
		 * 
		 * @param type The type of event.
		 * @param listener The listener object to remove.
		 * @param useCapture Specifies whether the listener was registered for the capture phase or the target and bubbling phases.
		 * 
		 * @see http://livedocs.adobe.com/flex/2/langref/flash/events/IEventDispatcher.html#removeEventListener() flash.events.IEventDispatcher.removeEventListener()
		 */		
		public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void
		{
			eventDispatcher.removeEventListener( type, listener, useCapture );
		}
		
		/**
		 * Checks whether an event listener is registered with this BalanceBoard object or any of its ancestors for the specified event type.
		 * 
		 * @param type The type of event.
		 * @return A value of <code>true</code> if a listener of the specified type will be triggered; <code>false</code> otherwise.
		 * 
		 * @see http://livedocs.adobe.com/flex/2/langref/flash/events/IEventDispatcher.html#willTrigger() flash.events.IEventDispatcher.willTrigger()
		 */	
		public function willTrigger( type:String ):Boolean
		{
			return eventDispatcher.willTrigger( type );
		}
		
	}
}