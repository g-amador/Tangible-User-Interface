//----------------------------------------------------------------------------------------------------
// Class for sound object with single track
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.base {
    import org.si.sion.*;
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.sequencer.SiMMLSequencer;
    import org.si.sion.sequencer.base.MMLSequence;
    
    
    /** Sound object with single track */
    public class SingleTrackObject extends SoundObject
    {
    // variables
    //----------------------------------------
        /** voice data. */
        public var voice:SiONVoice;
        /** sequence data. */
        protected var _data:SiONData;

        /** note quantize */
        protected var _noteQuantize:int;
        /** Event trigger ID */
        protected var _eventTriggerID:int;
        /** note on trigger type */
        protected var _noteOnTrigger:int;
        /** note off trigger type */
        protected var _noteOffTrigger:int;
        
        // track to control
        private var _track:SiMMLTrack;
        
        
        
        
    // properties
    //----------------------------------------
        /** note quantize (value of 'q' command) */
        public function get noteQuantize() : int { return _noteQuantize; }
        public function set noteQuantize(q:int) : void {
            _noteQuantize = q;
            if (_noteQuantize < 0) _noteQuantize = 0;
            else if (_noteQuantize > 8) _noteQuantize = 8;
            if (_track) _track.quantRatio = _noteQuantize * 0.125;
        }
        
        
        /** sequence data */
        public function get data() : SiONData { return _data; }
        
        /** track to render */
        public function get track() : SiMMLTrack { 
            if (!driver) return null;
            if (_track == null) {
                _track = driver.newUserControlableTrack(_trackID);
            } else
            if (_track.isFinished) {
                _track.setDisposable();
                _track = driver.newUserControlableTrack(_trackID);
            }
            return _track;
        }
        
        /** @private */
        override public function set mute(m:Boolean) : void { 
            super.mute = m;
            if (_track) _track.channel.masterVolume = (_totalMute) ? 0 : _totalVolume*128;
        }
        
        /** @private */
        override public function set volume(v:Number) : void {
            super.volume = v;
            if (_track) _track.channel.masterVolume = (_totalMute) ? 0 : _totalVolume*128;
        }
        
        /** @private */
        override public function set pan(p:Number) : void {
            super.pan = p;
            if (_track) _track.channel.pan = _totalPan;
        }
        
        /** @private */
        override public function get isPlaying() : Boolean {
            return (_track && !_track.isFinished);
        }
        
        
        
        
    // constructor
    //----------------------------------------
        /** constructor */
        function SingleTrackObject(name:String="") {
            super(name);
            voice = null;
            _data = null;
            _track = null;
            _eventTriggerID = 0;
            _noteOnTrigger = 0;
            _noteOffTrigger = 0;
            _noteQuantize = 6;
        }
        
        
        
        
    // operations
    //----------------------------------------
        /** Set event trigger.
         *  @param id Event trigger ID of this track. This value can be refered from SiONTrackEvent.eventTriggerID.
         *  @param noteOnType Dispatching event type at note on. 0=no events, 1=NOTE_ON_FRAME, 2=NOTE_ON_STREAM, 3=both.
         *  @param noteOffType Dispatching event type at note off. 0=no events, 1=NOTE_OFF_FRAME, 2=NOTE_OFF_STREAM, 3=both.
         *  @see org.si.sion.events.SiONTrackEvent
         */
        public function setEventTrigger(id:int, noteOnType:int=1, noteOffType:int=0) : void
        {
            _eventTriggerID = id;
            _noteOnTrigger = noteOnType;
            _noteOffTrigger = noteOffType;
        }
        
        
        /** call driver.noteOn() */
        protected function noteOn() : SiMMLTrack
        {
            if (!driver) return null;
            var trk:SiMMLTrack = track, sequencer:SiMMLSequencer = driver.sequencer;
            var delay:int  = sequencer.calcSampleDelay(0, _delay, _quantize),
                length:int = sequencer.calcSampleLength(_length);
            voice.setTrackVoice(trk);
            trk.keyOnInterrupt(_note, length, delay);
            trk.setEventTrigger(_eventTriggerID, _noteOnTrigger, _noteOffTrigger);
            trk.channel.pan = _totalPan;
            trk.channel.masterVolume = (_totalMute) ? 0 : _totalVolume*128;
            trk.quantRatio = _noteQuantize * 0.125;
            return trk;
        }
        
        
        /** call driver.noteOff() */
        protected function noteOff() : SiMMLTrack
        {
            if (!driver) return null;
            if (_track) _track.setDisposable();
            driver.noteOff(_note, _trackID, 0, 1);
            return _track;
        }
        
        
        /** call driver.sequenceOn(_data) */
        protected function sequenceOn() : SiMMLTrack
        {
            if (!_data || !driver) return null;
            
            var seq:MMLSequence = _data.getSequence(0);
            if (!seq) return null;
            
            var trk:SiMMLTrack = track, sequencer:SiMMLSequencer = driver.sequencer;
            var delay:int  = sequencer.calcSampleDelay(0, _delay, _quantize),
                length:int = sequencer.calcSampleLength(_length);
            voice.setTrackVoice(trk);
            trk.sequenceOn(seq, length, delay);
            trk.setEventTrigger(_eventTriggerID, _noteOnTrigger, _noteOffTrigger);
            trk.channel.pan = _totalPan;
            trk.channel.masterVolume = (_totalMute) ? 0 : _totalVolume*128;
            trk.quantRatio = _noteQuantize * 0.125;
            return trk;
        }
        
        
        /** call driver.sequenceOff() */
        protected function sequenceOff() : SiMMLTrack
        {
            if (!driver) return null;
            if (_track) {
                _track.setDisposable();
                _track.sequenceOff(driver.sequencer.calcSampleDelay(0, 0, 1));
            }
            return _track;
        }
        
        
        /** Play sound. */
        override public function play() : void { noteOn(); }
        
        
        /** Stop sound. */
        override public function stop() : void { noteOff(); }
    }
}

