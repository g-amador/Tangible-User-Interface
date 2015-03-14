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
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	/**
	 * The WiiSocket class recieves Wiimote data from the WiiFlash server and dispatches an event
	 * on a full package that has been read.
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 */
	internal final class WiiSocket implements IEventDispatcher
	{
		/**
		* Maximum number of Wiimotes that are supported by the WiiFlash server.
		*/		
		public static const MAX_WIIMOTES:int = 4;
		
		private static const I0:int = 0;
		private static const I80:int = 80;
		
		private static var initializing:Boolean = false;
		private static var instance:WiiSocket;
		
		private var socket:Socket;
		private var buffer:ByteArray;
		
		[ArrayElementType('class')]
		private var wiimotes:Array;
		
		private var rawPackage:ByteArray;
		
		private var _rumble:Array;
		private var _leds:Array;
		private var _mousecontrol:Array;
		
		private var timeOut:Array;
		private var timer:Array;

		public static function getInstance():WiiSocket
		{
			if ( instance == null )
			{
				initializing = true;
				instance = new WiiSocket();
				initializing = false;
			}
			
			return instance;
		}
		
		public static function register( wiimote:Wiimote ):void
		{
			getInstance().wiimotes[ wiimote._id ] = wiimote;
		}
		
		public function WiiSocket()
		{
			if ( !initializing )
				throw new Error( 'This is a singleton. Use WiiSocket.getInstance().' );
			
			wiimotes = new Array( MAX_WIIMOTES );
			
			socket = new Socket;
			
			buffer = new ByteArray;
			
			rawPackage = new ByteArray;
			
			_rumble = new Array;
			_leds = new Array;
			_mousecontrol = new Array;
			timer = new Array;
			timeOut = new Array;
			
			for ( var i:int = I0; i < MAX_WIIMOTES; i++ )
			{
				var rumbleTimer:Timer = new Timer( I0, 1 );
				
				_rumble.push( false );
				_leds.push( I0 );
				
				timer.push( rumbleTimer );
				timeOut.push( I0 );
				
				rumbleTimer.addEventListener( TimerEvent.TIMER, onRumbleTimeout );
			}
			
			socket.addEventListener( ProgressEvent.SOCKET_DATA, onSocketData );
		}
		
		public function connect( host:String = 'localhost', port:uint = 0x4a54 ):void
		{
			if ( !socket.connected )
				socket.connect( host, port );
			else
				dispatchEvent( new Event( Event.CONNECT ) );
		}
		
		public function get connected():Boolean
		{
			return socket.connected;
		}
		
		public function close():void
		{
			for ( var i:int = I0; i < MAX_WIIMOTES; i++ )
			{
				setRumble( i, false );
				setLEDs( i, I0 );
			}
			
			socket.close();
		}
		
		private function onSocketData( event:ProgressEvent ):void
		{
			while ( socket.bytesAvailable > I0 )
			{
				buffer.writeByte( socket.readByte() );
				
				if ( buffer.position == I80 )
				{
					var index:int = buffer[ I0 ];
					
					rawPackage.position = I0;
					rawPackage.writeBytes( buffer, 1 );
			     
					buffer.position = rawPackage.position = I0;
					
			     	try
			     	{
				     	( wiimotes[ index ] as Wiimote ).update( rawPackage );
				    }
				    catch ( error:Error ) {}
				}
			}
		}
		
		//--
		//-- Wii rumble
		//--
		public function setRumbleTimeout( index:int, newValue:uint ):void
		{
			if ( timeOut[ index ] != newValue )
			{ 
				timeOut[ index ] = newValue;
				
				if ( timeOut[ index ] == I0 )
				{
					setRumble( index, false );
					return;
				}
				
				setRumble( index, true );
						
				( timer[ index ] as Timer ).delay = timeOut[ index ];
				( timer[ index ] as Timer ).start();
			}
		}
		
		public function getRumbleTimeout( index:int ):int
		{
			return timeOut[ index ];
		}
		
		public function setRumble( index:int, newValue:Boolean ):void
		{
			if ( _rumble[ index ] != newValue )
			{
				_rumble[ index ] = newValue;
				
				socket.writeByte( index );
				socket.writeByte( 0x72 );
				socket.writeByte( _rumble[ index ] ? 0x31 :0x30 );
				socket.writeByte( 0x0a );
				
				socket.flush();
			}
		}
		
		public function getRumble( index:int ):Boolean
		{
			return _rumble[ index ];
		}
		
		public function getMouseControl ( index:int ):Boolean 
		{
			
			return _mousecontrol[index];
			
		}
		
		public function setMouseControl ( index:int, newValue:Boolean ):void
		{
			
			_mousecontrol[ index ] = newValue;
				
			socket.writeByte( index );
			socket.writeByte( 0x76 );
			socket.writeByte( _mousecontrol [ index ] ? 0x31 :0x30 );
			socket.writeByte( 0x0a );
				
			socket.flush();
			
		}
		
		private function onRumbleTimeout( event:TimerEvent ):void
		{
			var index:int = timer.indexOf( event.target as Timer );
			
			timeOut[ index ] = I0;
			
			setRumble( index, false );
		}
		
		//--
		//-- Wii leds
		//--
		public function setLEDs( index:int, newValue:int ):void
		{
			if ( ( newValue & 0xf ) != newValue )
			{
				throw new ArgumentError( 'led value may be between 0 and 15' );
			}
			
			if ( _leds[ index ] != newValue )
			{
				_leds[ index ] = newValue;
				
				socket.writeByte( index );
				socket.writeByte( 0x6c );
				socket.writeByte( _leds[ index ] );
				socket.writeByte( 0x0a );
				socket.flush();
			}
		}
		
		public function getLEDs( index:int ):int
		{
			return _leds[ index ];
		}
		
		//--
		//-- IEventDispatcher
		//--
		
		public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void 
		{
			socket.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		public function dispatchEvent( event:Event ):Boolean
		{
			return socket.dispatchEvent( event );
		}
		
		public function hasEventListener( type:String ):Boolean
		{
			return socket.hasEventListener( type );
		}
		
		public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void
		{
			socket.removeEventListener( type, listener, useCapture );
		}
		
		public function willTrigger( type:String ):Boolean
		{
			return socket.willTrigger( type );
		}
	}
}