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
package org.wiiflash.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.wiiflash.events.PeakEvent;
	
	/**
	 * Dispatched when a peak has been detected.
	 * 
 	 * @eventType org.wiiflash.events.PeakEvent.PEAK
  	 */	
	[Event(name='peak', type='org.wiiflash.events.PeakEvent')]
	
	/**
	 * The HistoryPeakDetection class is analyzing a set of values to detect peaks inside.
	 * 
	 * A peak is detected if current value is greater than average value of history values
	 * multiplied by given <code>historyMultiplier</code>.
	 * 
	 * Also the current value can be interpolated using <code>valueCount</code> greater than
	 * one. If this is the case the current value is the average of given values. This average
	 * value will be put into the history afterwards.
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 */	
	public final class HistoryPeakDetection implements IEventDispatcher
	{
		private var historyCount:int;
		private var valueCount:int;
		
		private var values:Array;
		private var history:Array;
		
		private var valueDivide:Number;
		private var historyDivide:Number;
		private var historyMultiplier:Number;
				
		private var eventDispatcher:EventDispatcher;
		
		private var lastPeak:Boolean;
		
		/**
		 * Creates a new HistoryPeakDetection object.
		 * 
		 * @param valueCount Number of values that build current value.
		 * @param historyCount Number of values that are stored in the history.
		 * @param historyMultiplier Multiplier for average value of history.
		 */		
		public function HistoryPeakDetection( valueCount:int = 2, historyCount:int = 32, historyMultiplier:Number = 16 )
		{
			var i:int;
			
			lastPeak = false;
			
			eventDispatcher = new EventDispatcher;
			
			values = new Array( this.valueCount = valueCount );
			history = new Array( this.historyCount = historyCount );
			
			valueDivide = 1 / valueCount;
			historyDivide = 1 / historyCount;
			this.historyMultiplier = historyMultiplier;
						
			for ( i = 0; i < valueCount; i++ )
			{
				values[ i ] = 0;
			}
			
			for ( i = 0; i < historyCount; i++ )
			{
				history[ i ] = 0;
			}
		}
		
		/**
		 * Adds a value to the HistoryPeakDetection object.
		 * Whenever a value is added the check to detect a peak is done.
		 * 
		 * @param value The new value.
		 * @return <code>true</code> if peak has been detected; <code>false</code> otherwise.
		 */		
		public function addValue( value:Number ):Boolean
		{
			var i:int;
			var peak:Boolean;
			
			var meanValue:Number = 0;
			var meanHistory:Number = 0;
			
			values.shift();
			values.push( value );
			
			for ( i = 0; i < valueCount; i++ )
			{
				meanValue += values[ i ] as Number;
			}
			
			for ( i = 0; i < historyCount; i++ )
			{
				meanHistory += history[ i ] as Number;
			}
			
			meanValue *= valueDivide;
			meanHistory *= historyDivide;
			
			history.shift();
			history.push( meanValue );
			
			if ( meanValue > 0 )
				peak = ( meanValue - ( meanHistory * historyMultiplier ) ) > 0;
			else
				peak = ( meanValue + ( meanHistory * historyMultiplier ) ) < 0;
			
			if ( peak && !lastPeak )
			{
				eventDispatcher.dispatchEvent( new PeakEvent );
			}
			
			return lastPeak = peak;
		}
		
		/**
		 * Returns the string representation of the specified object.
		 * 
		 * @return A string representation of the object.  
		 */		
		public function toString():String
		{
			return '[HistoryPeakDetection valueCount:' + valueCount + ', historyCount:' + historyCount + ', historyMultiplier:' + historyMultiplier + ']';
		}
		
		//-----------------------------------------------------------------------------------
		// IEventDispatcher
		//-----------------------------------------------------------------------------------
		
		/**
		 * Registers an event listener object with a HistoryPeakDetection object so that the listener receives notification of an event.
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
		 * Checks whether the HistoryPeakDetection object has any listeners registered for a specific type of event.
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
		 * Removes a listener from the HistoryPeakDetection object.
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
		 * Checks whether an event listener is registered with this HistoryPeakDetection object or any of its ancestors for the specified event type.
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