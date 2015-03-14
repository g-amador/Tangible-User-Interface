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
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import org.wiiflash.events.*;
	
	/**
 	 * Dispatched when a Wiimote object has successfully connected to the WiiFlash server.
 	 * 
 	 * @eventType flash.events.Event.CONNECT
 	 */
	[Event(name='connect', type='flash.events.Event')]
	
	/**
	 * Dispatched when a Wiimote object could not establish a connection.
	 * 
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name='ioError', type='flash.events.IOErrorEvent')]
	
	/**
	 * Dispatched when Wiimote data has been updated.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.UPDATE
 	 */	
	[Event(name='update', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when Nunchuk has been connected to Wiimote.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.NUNCHUK_CONNECT
 	 */
	[Event(name='nunchukConnect', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when Nunchuk has been disconnected from Wiimote.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.NUNCHUK_DISCONNECT
 	 */
	[Event(name='nunchukDisconnect', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when the Classic Controller has been connected to Wiimote.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.CONTROLLER_CONNECT
 	 */
	[Event(name='classicControllerConnect', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when the Classic Controller has been disconnected from Wiimote.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.CONTROLLER_DISCONNECT
 	 */
	[Event(name='classicControllerDisconnect', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when the Balance Board has been connected to Wiimote.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.BALANCEBOARD_CONNECT
 	 */
	[Event(name='balanceBoardConnect', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when the Classic Controller has been disconnected from Wiimote.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.BALANCEBOARD_DISCONNECT
 	 */
	[Event(name='balanceBoardDisconnect', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when Point <em>1</em> of the IR sensor bar has been found.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.IR1_FOUND
 	 */
	[Event(name='ir1Found', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when Point <em>2</em> of the IR sensor bar has been found.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.IR2_FOUND
 	 */
	[Event(name='ir2Found', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when Point <em>1</em> of the IR sensor bar has been lost.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.IR1_LOST
 	 */
	[Event(name='ir1Lost', type='org.wiiflash.events.WiimoteEvent')]
	
	/**
	 * Dispatched when Point <em>2</em> of the IR sensor bar has been lost.
	 * 
	 * @eventType org.wiiflash.events.WiimoteEvent.IR2_LOST
 	 */
	[Event(name='ir2Lost', type='org.wiiflash.events.WiimoteEvent')]
	
	//-----------------------------------------------------------------------------------
	// Press events
	//-----------------------------------------------------------------------------------
	
	/**
	 * Dispatched when button <em>1</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.ONE_PRESS
 	 */	
	[Event(name='onePress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>2</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.TWO_PRESS
 	 */	
	[Event(name='twoPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>A</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.A_PRESS
 	 */	
	[Event(name='aPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>B</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.B_PRESS
 	 */	
	[Event(name='bPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>+</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.PLUS_PRESS
 	 */	
	[Event(name='plusPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>-</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.MINUS_PRESS
 	 */	
	[Event(name='minusPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Home</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.HOME_PRESS
 	 */	
	[Event(name='homePress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Up</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.UP_PRESS
 	 */	
	[Event(name='upPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Down</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.DOWN_PRESS
 	 */	
	[Event(name='downPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Left</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.LEFT_PRESS
 	 */	
	[Event(name='leftPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Right</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.RIGHT_PRESS
 	 */	
	[Event(name='rightPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when Nunchuk button <em>C</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.C_PRESS
 	 */	
	[Event(name='cPress', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when Nunchuk button <em>Z</em> has been pressed.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.Z_PRESS
 	 */	
	[Event(name='zPress', type='org.wiiflash.events.ButtonEvent')]
	
	//-----------------------------------------------------------------------------------
	// Release events
	//-----------------------------------------------------------------------------------
	
	/**
	 * Dispatched when button <em>1</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.ONE_RELEASE
 	 */	
	[Event(name='oneRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>2</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.TWO_RELEASE
 	 */	
	[Event(name='twoRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>A</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.A_RELEASE
 	 */	
	[Event(name='aRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>B</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.B_RELEASE
 	 */	
	[Event(name='bRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>+</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.PLUS_RELEASE
 	 */	
	[Event(name='plusRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>-</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.MINUS_RELEASE
 	 */	
	[Event(name='minusRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Home</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.HOME_RELEASE
 	 */	
	[Event(name='homeRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Up</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.UP_RELEASE
 	 */	
	[Event(name='upRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Down</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.DOWN_RELEASE
 	 */	
	[Event(name='downRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Left</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.LEFT_RELEASE
 	 */	
	[Event(name='leftRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when button <em>Right</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.RIGHT_RELEASE
 	 */	
	[Event(name='rightRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when Nunchuk button <em>C</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.C_RELEASE
 	 */	
	[Event(name='cRelease', type='org.wiiflash.events.ButtonEvent')]
	
	/**
	 * Dispatched when Nunchuk button <em>Z</em> has been released.
	 * 
	 * @eventType org.wiiflash.events.ButtonEvent.Z_RELEASE
 	 */	
	[Event(name='zRelease', type='org.wiiflash.events.ButtonEvent')]
	//-----------------------------------------------------------------------------------
	
	/**
	 * The Wiimote class represents a Wiimote.
	 * 
	 * A Wiimote object has to be connected to the WiiFlash server. The WiiFlash server
	 * gathers available information from a Wiimote through Bluetooth and sends it back.
	 * 
	 * <p>It is important to remember the following information regarding the motion sensors:
	 * <ul><li>Sensor data is automatically calibrated.</li>
	 * <li>Sensor data is not interpolated in any way.</li>
	 * </ul></p>
	 * 
	 * Multiple Wiimotes can be handled as well. It is possible to create up to four Wiimote objects.
	 * If more than four Wiimote objects have been created an error will be thrown. After one Wiimote
	 * object made a successful connection to the WiiFlash Server all the other Wiimote objects will
	 * fire the connect event immediately.
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 * 
	 * @see http://www.wiili.org/index.php/Wiimote Wiimote description on wiili.org
	 * 
	 * @example
	 * This example shows how to create a Wiimote and connect it to the Basic WiiFlash server:
	 * <div class="listing">
	 * <pre>
	 * 
	 * var wiimote:Wiimote = new Wiimote();
	 * wiimote.addEventListener( Event.CONNECT, onWiimoteConnect );
	 * wiimote.connect();
	 * </pre>
	 * </div>
	 * 
	 * This example shows how to listen for events from the <em>A</em> button:
	 * <div class="listing">
	 * <pre>
	 * 
	 * wiimote.addEventListener( ButtonEvent.A_PRESS, onWiimoteAPress );
	 * wiimote.addEventListener( ButtonEvent.A_RELEASE, onWiimoteARelease );
	 * </pre>
	 * </div>
	 */	
	public final class Wiimote implements IEventDispatcher
	{
		private static var id:int = 0;
		
		/**
		* The first LED.
		*/		
		public static const LED1:int = 1;
		
		/**
		* The second LED.
		*/		
		public static const LED2:int = 2;
		
		/**
		* The third LED.
		*/		
		public static const LED3:int = 4;
		
		/**
		* The fourth LED.
		*/		
		public static const LED4:int = 8;
		
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
		
		private var wiiSocket:WiiSocket;
		private var eventDispatcher:EventDispatcher;
	
		/**
		* @private
		*/	
		internal var _id:int;
		
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		
		private var _ir:IR;
		
		private var _hadNunchuk:Boolean;
		private var _hasNunchuk:Boolean;
		private var _hasBalanceBoard:Boolean;
		private var _hadBalanceBoard:Boolean;
		private var _hadClassicController:Boolean;
		private var _hasClassicController:Boolean;
		private var _nunchuk:Nunchuk;
		private var _classicController:ClassicController;
		private var _balanceBoard:BalanceBoard;
		private var _extensionType:int;
		private var _batteryLevel:Number;
		
		[ArrayElementType('class')]
		private var buttons:Array;
		
		/**
		 * Creates a new Wiimote object.
		 * 
		 * @throws Error Thrown if more than four Wiimote objects have been created.
		 */		
		public function Wiimote()
		{
			_id = Wiimote.id++;
			
			if ( _id >= WiiSocket.MAX_WIIMOTES )
				throw new Error( 'Can not handle more than four Wiimote objects.' );
					
			eventDispatcher = new EventDispatcher(this);
			
			wiiSocket = WiiSocket.getInstance();
			
			wiiSocket.addEventListener( Event.CONNECT, onConnect );
			wiiSocket.addEventListener( IOErrorEvent.IO_ERROR, onError );

			WiiSocket.register( this );
						
			{ Nunchuk.initializing = true;
			
				_nunchuk = new Nunchuk();
				_nunchuk.parent = this;
				
			}
			
			{ ClassicController.initializing = true;
			
				_classicController = new ClassicController();
				_classicController.parent = this;
				
			}
			
			{ BalanceBoard.initializing = true;
			
				_balanceBoard = new BalanceBoard();
				_balanceBoard.parent = this;
				
			}
			
			{ IR.initializing = true;
			
				_ir = new IR();
				_ir.parent = this;
				
			}
			
			buttons = [
				new Button( ButtonType.ONE ),
				new Button( ButtonType.TWO ),
				new Button( ButtonType.A ),
				new Button( ButtonType.B ),
				new Button( ButtonType.PLUS ),
				new Button( ButtonType.MINUS ),
				new Button( ButtonType.HOME ),
				new Button( ButtonType.UP ),
				new Button( ButtonType.DOWN ),
				new Button( ButtonType.RIGHT ),
				new Button( ButtonType.LEFT )
			];
		}
		
		/**
		 * Connects the Wiimote to the specified host and port.
		 * 
		 * @param host The name of the host to connect to.
		 * @param port The port number to connect to.
		 * 
		 * @see http://livedocs.adobe.com/flex/2/langref/flash/net/Socket.html#connect() flash.net.Socket.connect()
		 */		
		public function connect( host:String = 'localhost', port:int = 0x4a54 ):void
		{
			wiiSocket.connect( host, port );
		}
		
		/**
		 * Closes the connection between this Wiimote object and the WiiFlash server.
		 */		
		public function close():void
		{
			wiiSocket.close();
		}
		
		/**
		 * Indicates whether this Wiimote object is currently connected to the WiiFlash server.
		 */		
		public function get connected():Boolean
		{
			return wiiSocket.connected;
		}
		
		/**
		 * Indicates Wiimote ID, for multiple wiimotes handling
		 */		
		public function get id():uint
		{
			return _id;
		}
		
		/**
		 * Returns the string representation of the specified object.
		 * 
		 * @return A string representation of the object.  
		 */	
		public function toString():String
		{
			return	'[Wiimote '
				+ 	'index:' + _id + ', '
				+	'sensorX:' + sensorX + ', '
				+	'sensorY:' + sensorY + ', '
				+	'sensorZ:' + sensorZ + ', '
				+	'roll:' + roll + ', '
				+	'pitch:' + pitch + ', '
				+	'hasClassicController:' + hasClassicController + ', '
				+	'hasBalanceBoard:' + hasBalanceBoard + ', '
				+	'hasNunchuk:' + hasNunchuk + ']';
		}
		
		//-----------------------------------------------------------------------------------
		// Nunchuk
		//-----------------------------------------------------------------------------------
		
		/**
		 * Indicates if a Nunchuk is attached to this Wiimote object.
		 */		
		public function get hasNunchuk():Boolean
		{
			return _hasNunchuk;
		}
		
		/**
		 * The Nunchuk that is attached to this Wiimote object.
		 */		
		public function get nunchuk():Nunchuk
		{
			return _nunchuk;
		}
		
		/**
		 * Indicates if a Classic Controller is attached to this Wiimote object.
		 */		
		public function get hasClassicController():Boolean
		{
			return _hasClassicController;
		}
		
		/**
		 * The ClassicController that is attached to this Wiimote object.
		 */		
		public function get classicController():ClassicController
		{
			return _classicController;
		}
		
		/**
		 * Indicates if a Balance Board is attached to this Wiimote object.
		 */		
		public function get hasBalanceBoard():Boolean
		{
			return _hasBalanceBoard;
		}
		
		/**
		 * The Balance Board that is attached to this Wiimote object.
		 */		
		public function get balanceBoard():BalanceBoard
		{
			return _balanceBoard;
		}
		
		/**
		 * The IR data that this Wiimote object recieves.
		 */
		 public function get ir():IR
		 {
		 	return _ir;
		 }
		
		//-----------------------------------------------------------------------------------
		// Buttons
		//-----------------------------------------------------------------------------------
		
		/**
		 * Indicates if button <em>1</em> is pressed.
		 */
		public function get one():Boolean
		{
			return ( buttons[ I0 ] as Button ).state;
		}
		
		/**
		 * Indicates if button <em>2</em> is pressed.
		 */
		public function get two():Boolean
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
		
		//-----------------------------------------------------------------------------------
		// Sensors
		//-----------------------------------------------------------------------------------
		
		/**
		 * Value of the <em>x</em> acceleration sensor.
		 * This value is scaled by the calibration data that has been read from the Wiimote.
		 */
		public function get sensorX():Number
		{
			return _x;
		}
		
		/**
		 * Value of the <em>y</em> acceleration sensor.
		 * This value is scaled by the calibration data that has been read from the Wiimote.
		 */
		public function get sensorY():Number
		{
			return _y;
		}
		
		/**
		 * Value of the <em>z</em> acceleration sensor.
		 * This value is scaled by the calibration data that has been read from the Wiimote.
		 */
		public function get sensorZ():Number
		{
			return _z;
		}

		/**
		 * Flag of the Wiimote's rumble state.
		 * 
		 * @example
		 * This example shows how to enable the rumble feature:
		 * <div class="listing"><pre>wiimote.rumble = true;</pre></div>
		 * 
		 * This example shows how to disable the rumble feature:
		 * <div class="listing"><pre>wiimote.rumble = false;</pre></div>
		 */
		public function get rumble():Boolean
		{
			return wiiSocket.getRumble( _id );
		}
		
		public function set rumble( newValue:Boolean ):void
		{
			wiiSocket.setRumble( _id, newValue );
		}
		
		/**
		 * Flag of the Wiimote's mouse control.
		 * 
		 * @example
		 * This example shows how to enable the mouse control feature:
		 * <div class="listing"><pre>wiimote.mouseControl = true;</pre></div>
		 * 
		 * This example shows how to disable the mouse control feature:
		 * <div class="listing"><pre>wiimote.mouseControl = false;</pre></div>
		 */
		public function get mouseControl ():Boolean
		{
			return wiiSocket.getMouseControl( _id );
		}
		
		public function set mouseControl( newValue:Boolean ):void
		{
			wiiSocket.setMouseControl( _id, newValue );
		}
		
		/**
		 * Flag for a rumble that stops after given amount of milliseconds.
		 * 
		 * @example
		 * This example shows how to enable the rumble feature for one second:
		 * <div class="listing"><pre>wiimote.rumbleTimeout = 1000;</pre></div>
		 */		
		public function get rumbleTimeout():uint
		{
			return wiiSocket.getRumbleTimeout( _id );
		}
		
		public function set rumbleTimeout( newValue:uint ):void
		{
			wiiSocket.setRumbleTimeout( _id, newValue );
		}
		
		/**
		 * Wiimote battery level from 0 to 1 (full batteries).
		 * 
		 * @example
		 * This example shows how to retrieve the battery level :
		 * <div class="listing"><pre>var battery:Number = wiimote.batteryLevel;</pre></div>
		 */		
		public function get batteryLevel():Number
		{
			return _batteryLevel;
		}
		
		/**
		 * Bitmask of the Wiimote's LEDs.
		 *
		 * @example
		 * This example shows how to turn the left and right LED on:
		 * <div class="listing"><pre>wiimote.leds = Wiimote.LED1 | Wiimote.LED4;</pre></div>
		 */		
		public function get leds():int
		{
			return wiiSocket.getLEDs( _id );
		}

		public function set leds( newValue:int ):void
		{
			wiiSocket.setLEDs( _id, newValue );
		}
		
		/**
		 * Pitch angle of the Wiimote in radians.
		 * This value is scaled by the calibration data that has been read from the Wiimote.
		 */		
		public function get pitch():Number
		{
			return calcAngle( sensorY );
		}
		
		/**
		 * Roll angle of the Wiimote in radians.
		 * This value is scaled by the calibration data that has been read from the Wiimote.
		 */		
		public function get roll():Number
		{
			return calcAngle( sensorX );
		}
		
		/**
		 * Yaw angle of the Wiimote in radians.
		 * This value is scaled by the calibration data that has been read from the Wiimote.
		 * 
		 * <p>A sensor measures only acceleration. The default acceleration a sensor can measure
		 * is the gravity vector that is pointing downwards. This has no affect to the yaw angle
		 * and is the reason whil there wont be much changes in value. Using an IR sensor bar
		 * can solve this issue.</p>
		 */		
		public function get yaw():Number
		{
			return calcAngle( sensorZ );
		}
		
		/**
		 * @private
		 */		
		internal static function calcAngle( value:Number ):Number
		{
			var clamp:Number = value;
			
			if ( clamp >  1 ) clamp =  1;
			if ( clamp < -1 ) clamp = -1;
			
			return Math.asin( clamp );
		}
		
		//-----------------------------------------------------------------------------------
		// Parsing
		//-----------------------------------------------------------------------------------
		
		internal function update( pack:ByteArray ):void
		{
			
			_batteryLevel = pack.readUnsignedByte() / 0xC8;
			
			var buttonState:int = pack.readUnsignedShort();
			var button:Button;
			
			for ( var i:int = 0; i < I11; i++ )
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

			_x = pack.readFloat();
			_y = pack.readFloat();
			_z = pack.readFloat();

			_extensionType = pack.readUnsignedByte();
			
			_hasNunchuk = _extensionType == 1;
			_hasClassicController = _extensionType == 2;
			_hasBalanceBoard = _extensionType == 3;
			
			if ( _hasClassicController && !_hadClassicController )
			{
				eventDispatcher.dispatchEvent( new WiimoteEvent( WiimoteEvent.CONTROLLER_CONNECT ) );
				
			} else if ( !_hasClassicController && _hadClassicController )
			
			{
				eventDispatcher.dispatchEvent( new WiimoteEvent( WiimoteEvent.CONTROLLER_DISCONNECT ) );
			}
			
			if ( _hasNunchuk && !_hadNunchuk )
			{
				eventDispatcher.dispatchEvent( new WiimoteEvent( WiimoteEvent.NUNCHUK_CONNECT ) );
			}
			else if ( !_hasNunchuk && _hadNunchuk )
			{
				eventDispatcher.dispatchEvent( new WiimoteEvent( WiimoteEvent.NUNCHUK_DISCONNECT ) );
			}
			
			if ( _hasBalanceBoard && !_hadBalanceBoard )
			{
				eventDispatcher.dispatchEvent( new WiimoteEvent( WiimoteEvent.BALANCEBOARD_CONNECT ) );
			}
			else if ( !_hasBalanceBoard && _hadBalanceBoard )
			{
				eventDispatcher.dispatchEvent( new WiimoteEvent( WiimoteEvent.BALANCEBOARD_DISCONNECT ) );
			}
			
			_hadNunchuk = _hasNunchuk;
			_hadClassicController = _hasClassicController;
			_hadBalanceBoard = _hasBalanceBoard;
				
			if ( _hasNunchuk )
			{
				_nunchuk.update( pack );
			}
			else if ( _hasClassicController )
			{
				_classicController.update( pack );
				
			} else if ( _hasBalanceBoard )
			{
				_balanceBoard.update ( pack );
				
			} else pack.position = 37;
			
			ir.update( pack );
			
			eventDispatcher.dispatchEvent( new WiimoteEvent( WiimoteEvent.UPDATE ) );
		}
		
	    /**
		 * Dispatched when the Wiimote is successfully connected to the WiiFlash Server.
		 * 
		 * @eventType flash.events.Event.CONNECT
	 	 */	
		private function onConnect( event:Event ):void
		{
			eventDispatcher.dispatchEvent( event );
		}
		
		/**
		 * Dispatched when the Wiimote is disconnected from to the WiiFlash Server.
		 * 
		 * @eventType flash.events.Event.CLOSE
	 	 */	
		private function onError( event:Event ):void
		{
			eventDispatcher.dispatchEvent( event );
		}

		//-----------------------------------------------------------------------------------
		// IEventDispatcher
		//-----------------------------------------------------------------------------------
		 
		/**
		 * Registers an event listener object with a Wiimote object so that the listener receives notification of an event.
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
		 * Checks whether the Wiimote object has any listeners registered for a specific type of event.
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
		 * Removes a listener from the Wiimote object.
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
		 * Checks whether an event listener is registered with this Wiimote object or any of its ancestors for the specified event type.
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