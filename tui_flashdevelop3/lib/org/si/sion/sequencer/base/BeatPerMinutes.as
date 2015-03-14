//----------------------------------------------------------------------------------------------------
// Beat per minutes data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.base {
    /** Beat per minutes class, Calculates BPM-releated numbers automatically. */
    public class BeatPerMinutes
    {
        /** 16th beat par sample */
        public var beat16ParSample:Number;
        /** sample par 16th beat */
        public var sampleParBeat16:Number;
        /** @private [internal] sample per tick in FIXED unit. */
        internal var _samplePerTick:Number;
        // beat per minutes
        private var _bpm:Number = 0;
        // sample rate
        private var _sampleRate:int = 0;
        // tick resolution
        private var _resolution:int;
        
        
        /** beat per minute. */
        public function get bpm() : Number { return _bpm; }
        
        /** sampling rate */
        public function get sampleRate() : int { return _sampleRate; }
        

        /** constructor. */
        function BeatPerMinutes(bpm:Number, sampleRate:int, resolution:int=1920) {
            _resolution = resolution;
            update(bpm, sampleRate);
        }
        

        /** update */
        public function update(beatPerMinutes:Number, sampleRate:int) : Boolean {
            if (beatPerMinutes<1) beatPerMinutes=1;
            else if (beatPerMinutes>511) beatPerMinutes=511;
            if (beatPerMinutes != _bpm || sampleRate != _sampleRate) {
                _bpm = beatPerMinutes
                _sampleRate = sampleRate;
                _samplePerTick = int(_sampleRate * 240 / (_resolution * _bpm) * (1<<MMLSequencer.FIXED_BITS));
                beat16ParSample = _bpm / (_sampleRate * 15); // 60/4
                sampleParBeat16 = 1 / beat16ParSample;
                return true;
            }
            return false;
        }
    }
}


