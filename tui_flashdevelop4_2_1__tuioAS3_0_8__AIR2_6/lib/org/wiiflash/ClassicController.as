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
	import flash.events.Event;
	
	import org.wiiflash.events.*;
	
	/**
	 * The ClassicController class represents a Classic Controller.
	 * A ClassicController object can not be created manually. The only access to a ClassicController is
	 * by using the <code>classicController</code> property of a Wiimote object.
	 * 
	 * @see http://www.wiili.org/index.php/Classic_Controller Classic Controller description on wiili.org
	 * @see org.wiiflash.Wiimote org.wiiflash.ClassicController
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 * 
	 * @example
	 * This example shows how to check if the Classic Controller has been plugged to the Wiimote :
	 * <div class="listing">
	 * <pre>
	 * 
	 * var wiimote:Wiimote = new Wiimote();
	 * myWiimote.addEventListener( WiimoteEvent.CONTROLLER_CONNECT, onClassicControllerConnected );
	 * myWiimote.addEventListener( WiimoteEvent.CONTROLLER_DISCONNECT, onClassicControllerDisconnected );
	 * </pre>
	 * </div>
	 * 
	 * This example shows how to listen for events from the <em>HOME</em> button:
	 * <div class="listing">
	 * <pre>
	 * 
	 * myWiimote.classicController.addEventListener( ButtonEvent.HOME_PRESS, onHomePress );
	 * myWiimote.classicController.addEventListener( ButtonEvent.HOME_RELEASE, onHomeRelease );
	 * </pre>
	 * </div>
	 */	
	public final class ClassicController implements IEventDispatcher
	{
		/**
		 * @private
		 * 
		 * Flag that enables ClassicController initialitzation. Set this to true before
		 * calling the ClassicController constructor.
		 */
		internal static var initializing:Boolean = false;
		
		//-- Typesafe numbers for fast array access
		private static const I0:int = 0;
		private static const I1:int = 1;
		private static const I2:int = 2;
		private static const I3:int = 3;
		private static const I4:int = 4;
		private static const I5:int = 5;
		private static const I6:int = 6;
		private static const I7:int = 7;
		private static const I8:int = 8;
		private static const I9:int = 9;
		private static const I10:int = 10;
		private static const I11:int = 11;
		private static const I12:int = 12;
		private static const I13:int = 13;
		private static const I14:int = 14;
		private static const I15:int = 15;
		
		private var _stickXLeft:Number;
		private var _stickYLeft:Number;
		
		private var _stickXRight:Number;
		private var _stickYRight:Number;
		
		[ArrayElementType('class')]
		private var buttons:Array;

		private var _parent:Wiimote;
		private var eventDispatcher:EventDispatcher;
		
		/**
		 * @private
		 * 
		 * Creates a new Classic Controller object.
		 * 
		 * A ClassicController object may only be created by the Wiimote class.
		 * 
		 * @throws Error Thrown when constructor is called manually.
		 */		
		public function ClassicController()
		{
			if ( !ClassicController.initializing )
				throw new Error( 'Can not create ClassicController instance manually.\nAccess is only available using a Wiimote object.' );
			ClassicController.initializing = false;
			
			eventDispatcher = new EventDispatcher(this);
			
			buttons = [
				new Button( ButtonType.X ),
				new Button( ButtonType.Y ),
				new Button( ButtonType.A ),
				new Button( ButtonType.B ),
				new Button( ButtonType.PLUS ),
				new Button( ButtonType.MINUS ),
				new Button( ButtonType.HOME ),
				new Button( ButtonType.UP ),
				new Button( ButtonType.DOWN ),
				new Button( ButtonType.RIGHT ),
				new Button( ButtonType.LEFT ),
				new Button( ButtonType.L ),
				new Button( ButtonType.R ),
				new Button( ButtonType.ZL ),
				new Button( ButtonType.ZR )
			];
			
			_stickXLeft = _stickYLeft = _stickXRight = _stickYRight = 0;
		}
		
		/**
		 * @private
		 * 
		 * The parent of the ClassicController.
		 */		
		internal function set parent( newValue:Wiimote ):void
		{
			_parent = newValue;
		}
		
		//-----------------------------------------------------------------------------------
		// Buttons
		//-----------------------------------------------------------------------------------
		
		/**
		 * Indicates if button <em>X</em> is pressed.
		 */
		public function get x():Boolean
		{
			return ( buttons[ I0 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>Y</em> is pressed.
		 */
		public function get y():Boolean
		{
			return ( buttons[ I1 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>A</em> is pressed.
		 */
		public function get a():Boolean
		{
			return ( buttons[ I2 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>B</em> is pressed.
		 */
		public function get b():Boolean
		{
			return ( buttons[ I3 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>+</em> is pressed.
		 */
		public function get plus():Boolean
		{
			return ( buttons[ I4 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>-</em> is pressed.
		 */
		public function get minus():Boolean
		{
			return ( buttons[ I5 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>Home</em> is pressed.
		 */
		public function get home():Boolean
		{
			return ( buttons[ I6 ] as Button ).state;
		
		}
		
		/**
		 * Indicates if button <em>Up</em> is pressed.
		 */
		public function get up():Boolean
		{
			return ( buttons[ I7 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>Down</em> is pressed.
		 */
		public function get down():Boolean
		{
			return ( buttons[ I8 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>Right</em> is pressed.
		 */
		public function get right():Boolean
		{
			return ( buttons[ I9 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>Left</em> is pressed.
		 */
		public function get left():Boolean
		{
			return ( buttons[ I10 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>L</em> is pressed.
		 */
		public function get l():Boolean
		{
			return ( buttons[ I11 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>R</em> is pressed.
		 */
		public function get r():Boolean
		{
			return ( buttons[ I12 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>zL</em> is pressed.
		 */
		public function get zL():Boolean
		{
			return ( buttons[ I13 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>zR</em> is pressed.
		 */
		public function get zR():Boolean
		{
			return ( buttons[ I14 ] as Button ).state;
		}
		
		//-----------------------------------------------------------------------------------
		// Sensors
		//-----------------------------------------------------------------------------------
		
		/**
		 * Value of the <em>x</em>left stick-axis.
		 * This value is scaled by the calibration data that has been read from the ClassicController.
		 */
		public function get stickXLeft():Number
		{
			return _stickXLeft;
		}
		
		/**
		 * Value of the <em>y</em>left stick-axis.
		 * This value is scaled by the calibration data that has been read from the ClassicController.
		 */
		public function get stickYLeft():Number
		{
			return _stickYLeft;
		}
		
		/**
		 * Value of the <em>x</em> right stick-axis.
		 * This value is scaled by the calibration data that has been read from the ClassicController.
		 */
		public function get stickXRight():Number
		{
			return _stickXRight;
		}
		
		/**
		 * Value of the <em>y</em>right stick-axis.
		 * This value is scaled by the calibration data that has been read from the ClassicController.
		 */
		public function get stickYRight():Number
		{
			return _stickYRight;
		}
		
		//-----------------------------------------------------------------------------------
		// Parsing
		//-----------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * Updates Classic Controller data.
		 */		
		internal function update( pack:ByteArray ):void
		{
			
			var buttonState:int = pack.readUnsignedShort();
			var button:Button;
			
			for ( var i:int = 0; i < I15; i++ )
			{
				button = buttons[ i ];
				
				button.update( buttonState );
				
				if ( button.state && !button.lastState )
				{
					eventDispatcher.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( button.type, true ), true ) );
				}
				else if ( !button.state && button.lastState )
				{
					eventDispatcher.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( button.type, false ), false ) );
				}
			}

			_stickXLeft = pack.readFloat();
			_stickYLeft = pack.readFloat();
			
			_stickXRight = pack.readFloat();
			_stickYRight = pack.readFloat();
			
		}
		
		/**
		 * Returns the string representation of the specified object.
		 * 
		 * @return A string representation of the object.  
		 */	
		public function toString():String
		{
			return '[ClassicController parent:' + _parent + ']';
		}
		
		//-----------------------------------------------------------------------------------
		// IEventDispatcher
		//-----------------------------------------------------------------------------------
		 
		/**
		 * Registers an event listener object with a ClassicController object so that the listener receives notification of an event.
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
		 * Checks whether the ClassicController object has any listeners registered for a specific type of event.
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
		 * Removes a listener from the ClassicController object.
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
		 * Checks whether an event listener is registered with this ClassicController object or any of its ancestors for the specified event type.
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