//----------------------------------------------------------------------------------------------------
// Events for SiON Track
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.events {
    import flash.events.Event;
    import flash.media.Sound;
    import flash.utils.ByteArray;
    import org.si.sion.SiONDriver;
    import org.si.sion.SiONData;
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.namespaces._sion_internal;
    
    
    /** SiON Track Event class. */
    public class SiONTrackEvent extends SiONEvent 
    {
    // constants
    //----------------------------------------
        /** Dispatch when the note on appears in the sequence with "%t" command.
         * <p>The properties of the event object have the following values:</p>
         * <table class=innertable>
         * <tr><th>Property</th><th>Value</th></tr>
         * <tr><td>cancelable</td><td>true; mute the note</td></tr>
         * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
         * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
         * <tr><td>streamBuffer</td><td>null</td></tr>
         * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
         * <tr><td>eventTriggerID</td><td>Trigger ID specifyed in "%t" commands 1st argument.</td></tr>
         * <tr><td>note</td><td>Note number.</td></tr>
         * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
         * </table>
         * @eventType soundTrigger
         */
        public static const NOTE_ON_STREAM:String = 'noteOnStream';
        
        
        /** Dispatch when the note off appears in the sequence with "%t" command.
         * <p>The properties of the event object have the following values:</p>
         * <table class=innertable>
         * <tr><th>Property</th><th>Value</th></tr>
         * <tr><td>cancelable</td><td>true; mute the note</td></tr>
         * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
         * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
         * <tr><td>streamBuffer</td><td>null</td></tr>
         * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
         * <tr><td>eventTriggerID</td><td>Trigger ID specifyed in "%t" commands 1st argument.</td></tr>
         * <tr><td>note</td><td>Note number.</td></tr>
         * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
         * </table>
         * @eventType soundTrigger
         */
        public static const NOTE_OFF_STREAM:String = 'noteOffStream';

        
        /** Dispatch when the sound starts.
         * <p>The properties of the event object have the following values:</p>
         * <table class=innertable>
         * <tr><th>Property</th><th>Value</th></tr>
         * <tr><td>cancelable</td><td>false</td></tr>
         * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
         * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
         * <tr><td>streamBuffer</td><td>null</td></tr>
         * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
         * <tr><td>eventTriggerID</td><td>Trigger ID specifyed in "%t" commands 1st argument.</td></tr>
         * <tr><td>note</td><td>Note number.</td></tr>
         * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
         * </table>
         * @eventType frameTrigger
         */
        public static const NOTE_ON_FRAME:String = 'noteOnFrame';

        
        /** Dispatch when the sound ends.
         * <p>The properties of the event object have the following values:</p>
         * <table class=innertable>
         * <tr><th>Property</th><th>Value</th></tr>
         * <tr><td>cancelable</td><td>false</td></tr>
         * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
         * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
         * <tr><td>streamBuffer</td><td>null</td></tr>
         * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
         * <tr><td>eventTriggerID</td><td>Trigger ID specifyed in "%t" commands 1st argument.</td></tr>
         * <tr><td>note</td><td>Note number.</td></tr>
         * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
         * </table>
         * @eventType frameTrigger
         */
        public static const NOTE_OFF_FRAME:String = 'noteOffFrame';
        
        
        /** Dispatch on beat while streaming. This event is called in each beat timing on frame. When you want to listen this event, you have to set addEventListener() before SiONDriver.play().
         * <p>The properties of the event object have the following values:</p>
         * <table class=innertable>
         * <tr><th>Property</th><th>Value</th></tr>
         * <tr><td>cancelable</td><td>false</td></tr>
         * <tr><td>driver</td><td>SiONDriver instance playing now.</td></tr>
         * <tr><td>data</td><td>SiONData instance playing now. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
         * <tr><td>streamBuffer</td><td>null.</td></tr>
         * <tr><td>track</td><td>null</td></tr>
         * <tr><td>eventTriggerID</td><td>Counter in 16th beat.</td></tr>
         * <tr><td>note</td><td>0</td></tr>
         * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
         * </table>
         * @eventType stream
         */
        public static const BEAT:String = 'beat';

        
        /** Dispatch when the bpm changes.
         * <p>The properties of the event object have the following values:</p>
         * <table class=innertable>
         * <tr><th>Property</th><th>Value</th></tr>
         * <tr><td>cancelable</td><td>false</td></tr>
         * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
         * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
         * <tr><td>streamBuffer</td><td>null</td></tr>
         * <tr><td>track</td><td>null</td></tr>
         * <tr><td>eventTriggerID</td><td>null</td></tr>
         * <tr><td>note</td><td>0</td></tr>
         * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
         * </table>
         * @eventType changeBPM
         */
        public static const CHANGE_BPM:String = 'changeBPM';        
        
        
        
        
        
        
        
    // valiables
    //----------------------------------------
        // current track
        private var _track:SiMMLTrack;
        
        // trigger event id
        private var _eventTriggerID:int
        
        // note number
        private var _note:int;
        
        // buffering index
        private var _bufferIndex:int;
        
        // frame trigger delay 
        private var _frameTriggerDelay:Number;
        
        // Delay frame timer.
        private var _frameTriggerTimer:int;
        
        
        
        
    // properties
    //----------------------------------------
        /** Sequencer track instance. */
        public function get track() : SiMMLTrack { return _track; }
        
        /** Trigger ID. */
        public function get eventTriggerID() : int { return _eventTriggerID; }
        
        /** Note number. */
        public function get note() : int { return _note; }
        
        /** Buffering index. */
        public function get bufferIndex() : int { return _bufferIndex; }
        
        /** Delay time to dispatch frame trigger event [ms]. */
        public function get frameTriggerDelay() : Number { return _frameTriggerDelay; }
        
        
        
        
    // functions
    //----------------------------------------
        /** This event can be created only in the callback function inside. @private */
        public function SiONTrackEvent(type:String, driver:SiONDriver, track:SiMMLTrack, bufferIndex:int=0, note:int=0, id:int=0)
        {
            super(type, driver, null, true);
            _track = track;
            if (track) {
                _note = track.note;
                _eventTriggerID = track.eventTriggerID;
                _bufferIndex = track.channel.bufferIndex;
                _frameTriggerDelay = track.channel.bufferIndex / driver.sequencer.sampleRate + driver.latency;
                _frameTriggerTimer = _frameTriggerDelay;
            } else {
                _note = note;
                _eventTriggerID = id;
                _bufferIndex = bufferIndex;
                _frameTriggerDelay = bufferIndex / driver.sequencer.sampleRate + driver.latency;
                _frameTriggerTimer = _frameTriggerDelay;
            }
        }
        
        
        /** clone. */
        override public function clone() : Event
        { 
            var event:SiONTrackEvent = new SiONTrackEvent(type, _driver, _track);
            event._eventTriggerID = _eventTriggerID;
            event._note = _note;
            event._bufferIndex = _bufferIndex;
            event._frameTriggerDelay = _frameTriggerDelay;
            event._frameTriggerTimer = _frameTriggerTimer;
            return event;
        }
        
        
        /** @private [sion internal] */
        _sion_internal function _decrementTimer(frameRate:int) : Boolean
        {
            _frameTriggerTimer -= frameRate;
            return (_frameTriggerTimer <= 0);
        }
    }
}

