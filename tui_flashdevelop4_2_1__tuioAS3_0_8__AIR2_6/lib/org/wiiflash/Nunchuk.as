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
	import flash.utils.ByteArray;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import org.wiiflash.events.*;
	import flash.events.Event;
	
	/**
	 * The Nunchuk class represents a Nunchuk.
	 * A Nunchuk object can not be created manually. The only access to a Nunchuk is
	 * by using the <code>nunchuk</code> property of a Wiimote object.
	 * 
	 * @see http://www.wiili.org/index.php/Nunchuk Nunchuk description on wiili.org
	 * @see org.wiiflash.Wiimote org.wiiflash.Wiimote
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 * 
	 * @example
	 * This example shows how to check if the Nunchuk has been plugged to the Wiimote :
	 * <div class="listing">
	 * <pre>
	 * 
	 * var wiimote:Wiimote = new Wiimote();
	 * myWiimote.addEventListener( WiimoteEvent.NUNCHUK_CONNECT, onNunchukConnected );
	 * myWiimote.addEventListener( WiimoteEvent.NUNCHUK_DISCONNECT, onNunchukDisconnected );
	 * </pre>
	 * </div>
	 * 
	 * This example shows how to listen for events from the <em>C</em> button:
	 * <div class="listing">
	 * <pre>
	 * 
	 * myWiimote.nunchuk.addEventListener ( ButtonEvent.C_PRESS, onCPress );
	 * myWiimote.nunchuk.addEventListener ( ButtonEvent.C_RELEASE, onCRelease );
	 * </pre>
	 * </div>
	 */	
	public final class Nunchuk implements IEventDispatcher
	{
		/**
		 * @private
		 * 
		 * Flag that enables Nunchuk initialitzation. Set this to true before
		 * calling the Nunchuk constructor.
		 */
		internal static var initializing:Boolean = false;
		
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		
		private var _stickX:Number;
		private var _stickY:Number;
		
		private var _cButton:Button
		private var _zButton:Button;

		private var _parent:Wiimote;
		private var eventDispatcher:EventDispatcher;
		
		/**
		 * @private
		 * 
		 * Creates a new Nunchuk object.
		 * 
		 * A Nunchuk object may only be created by the Wiimote class.
		 * 
		 * @throws Error Thrown when constructor is called manually.
		 */		
		public function Nunchuk()
		{
			if ( !Nunchuk.initializing )
				throw new Error( 'Can not create Nunchuk instance manually.\nAccess is only available using a Wiimote object.' );
			Nunchuk.initializing = false;
			
			eventDispatcher = new EventDispatcher(this);
			
			_cButton = new Button( ButtonType.C );
			_zButton = new Button( ButtonType.Z );
			
			_x = _y = _z = _stickX = _stickY = 0;
		}
		
		/**
		 * @private
		 * 
		 * The parent of the Nunchuk.
		 */		
		internal function set parent( newValue:Wiimote ):void
		{
			_parent = newValue;
		}
		
		//-----------------------------------------------------------------------------------
		// Buttons
		//-----------------------------------------------------------------------------------
		
		/**
		 * Indicates if button <em>C</em> is pressed.
		 */
		public function get c():Boolean
		{
			return _cButton.state;
		}
		
		/**
		 * Indicates if button <em>Z</em> is pressed.
		 */
		public function get z():Boolean
		{
			return _zButton.state;
		}
		
		//-----------------------------------------------------------------------------------
		// Sensors
		//-----------------------------------------------------------------------------------
		
		/**
		 * Value of the <em>x</em> acceleration sensor.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get sensorX():Number
		{
			return _x;
		}
		
		/**
		 * Value of the <em>y</em> acceleration sensor.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get sensorY():Number
		{
			return _y;
		}
		
		/**
		 * Value of the <em>z</em> acceleration sensor.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get sensorZ():Number
		{
			return _z;
		}
		
		/**
		 * Value of the <em>x</em> stick-axis.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get stickX():Number
		{
			return _stickX;
		}
		
		/**
		 * Value of the <em>y</em> stick-axis.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get stickY():Number
		{
			return _stickY;
		}		
		
		/**
		 * Pitch angle of the Wiimote in radians.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */		
		public function get pitch():Number
		{
			return Wiimote.calcAngle( sensorY );
		}
		
		/**
		 * Roll angle of the Wiimote in radians.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */		
		public function get roll():Number
		{
			return Wiimote.calcAngle( sensorX );
		}
		
		/**
		 * Yaw angle of the Nunchuk in radians.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */		
		public function get yaw():Number
		{
			return Wiimote.calcAngle( sensorZ );
		}
		
		//-----------------------------------------------------------------------------------
		// Parsing
		//-----------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * Updates Nunchuk data.
		 */		
		internal function update( pack:ByteArray ):void
		{
			
			var buttonState:int = pack.readUnsignedByte();
			
			_cButton.update( buttonState );
			_zButton.update( buttonState );
			
			_stickX = pack.readFloat();
			_stickY = pack.readFloat();
			
			_x = pack.readFloat();
			_y = pack.readFloat();
			_z = pack.readFloat();
			
			if ( _cButton.state && !_cButton.lastState )
			{
				eventDispatcher.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( _cButton.type, true ), true ) );
			}
			else if ( !_cButton.state && _cButton.lastState )
			{
				eventDispatcher.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( _cButton.type, false ), false ) );
			}
			
			if ( _zButton.state && !_zButton.lastState )
			{
				eventDispatcher.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( _zButton.type, true ), true ) );
			}
			else if ( !_zButton.state && _zButton.lastState )
			{
				eventDispatcher.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( _zButton.type, false ), false ) );
			}
		}
		
		/**
		 * Returns the string representation of the specified object.
		 * 
		 * @return A string representation of the object.  
		 */	
		public function toString():String
		{
			return '[Nunchuk parent:' + _parent + ']';
		}
		
		//-----------------------------------------------------------------------------------
		// IEventDispatcher
		//-----------------------------------------------------------------------------------
		 
		/**
		 * Registers an event listener object with a Nunchuk object so that the listener receives notification of an event.
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
		 * Checks whether the Nunchuk object has any listeners registered for a specific type of event.
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
		 * Removes a listener from the Nunchuk object.
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
		 * Checks whether an event listener is registered with this Nunchuk object or any of its ancestors for the specified event type.
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