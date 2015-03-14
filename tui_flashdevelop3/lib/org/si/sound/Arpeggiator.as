//----------------------------------------------------------------------------------------------------
// Arpeggiator class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound {
    import org.si.sion.*;
    import org.si.sion.utils.Scale;
    import org.si.sion.sequencer.base.MMLEvent;
    import org.si.sion.sequencer.base.MMLSequence;
    import org.si.sion.sequencer.SiMMLTrack;
    
    
    /** Arpeggiator */
    public class Arpeggiator extends Scaler
    {
    // variables
    //----------------------------------------
        /** portament */
        protected var _portament:int;
        /** arepggio pattern */
        protected var _arpeggio:Vector.<int>;
        /** Note events in the sequence with portament */
        protected var _noteEvents:Vector.<MMLEvent>;
        /** Slur events in the sequence with portament */
        protected var _slurEvents:Vector.<MMLEvent>;
        /** Note length */
        protected var _step:int;
        
        
        
        
    // properties
    //----------------------------------------
        /** portament */
        public function get portament() : int { return _portament; }
        public function set portament(p:int) : void {
            _portament = p;
            if (_portament < 0) _portament = 0;
            if (isPlaying) {
                track.setPortament(_portament);
                track.eventMask = (_portament) ? 0 : SiMMLTrack.MASK_SLUR;
            }
        }
        
        /** @private */
        override public function set note(n:int) : void {
            super.note = n;
            _scaleIndexUpdated();
        }
        
        
        /** @private */
        override public function set scaleIndex(index:int) : void {
            super.scaleIndex = index;
            _scaleIndexUpdated();
        }
        

        /** call this after the update of note or scale index */
        protected function _scaleIndexUpdated() : void {
            var i:int, imax:int = _noteEvents.length;
            for (i=0; i<imax; i++) {
                _noteEvents[i].data = scale.getNote(_arpeggio[i] + _scaleIndex);
            }
        }
        
        
        /** note length in 16th beat. */
        public function get noteLength() : Number {
            return _step / 120;
        }
        public function set noteLength(l:Number) : void {
            _step = l * 120;
            var i:int, imax:int = _slurEvents.length;
            for (i=0; i<imax; i++) _slurEvents[i].length = _step;
        }
        
        
        /** Note index array of the arpeggio pattern. If the index is out of range, insert rest instead.*/
        public function set pattern(pat:Array) : void
        {
            if (!isPlaying) {
                _data.clear();
                if (pat) {
                    _arpeggio = Vector.<int>(pat);
                    var i:int, imax:int = pat.length, note:int = 60, 
                        seq:MMLSequence = _data.appendNewSequence();
                    _noteEvents.length = imax;
                    _slurEvents.length = imax;
                    seq.alloc().appendNewEvent(MMLEvent.REPEAT_ALL, 0);
                    for (i=0; i<imax; i++) {
                        var newNote:int = scale.getNote(pat[i]);
                        if (newNote>=0 && newNote<128) note = newNote;
                        _noteEvents[i] = seq.appendNewEvent(MMLEvent.NOTE, note, 0);
                        _slurEvents[i] = seq.appendNewEvent(MMLEvent.SLUR, 0, _step);
                    }
                }
            }
        }
        
        
        
        
    // constructor
    //----------------------------------------
        /** constructor 
         *  @param scale Scale instance.
         *  @param noteLength length for each note
         *  @param pattern arpegio pattern 
         *  @see org.si.sion.utils.Scale
         */
        function Arpeggiator(scale:Scale, noteLength:Number=2, pattern:Array=null) {
            super(scale);
            _data = new SiONData();
            _noteEvents = new Vector.<MMLEvent>();
            _slurEvents = new Vector.<MMLEvent>();
            this.noteLength = noteLength;
            this.pattern = pattern;
            _portament = 0;
        }
        
        
        
        
    // operations
    //----------------------------------------
        /** Play sound. */
        override public function play() : void { 
            var t:SiMMLTrack = sequenceOn();
            if (t) {
                t.setPortament(_portament);
                t.eventMask = (_portament) ? 0 : SiMMLTrack.MASK_SLUR;
            }
        }
        
        
        /** Stop sound. */
        override public function stop() : void {
            var t:SiMMLTrack = sequenceOff();
            if (t && _portament>0) t.keyOff();
        }
    }
}

