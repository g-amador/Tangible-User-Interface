//----------------------------------------------------------------------------------------------------
// MIDI module
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.midi {
    import org.si.sion.*;
    import org.si.sion.sequencer.SiMMLSequencer;
    import org.si.sion.sequencer.SiMMLTrack;

    
    /** MIDI module (still in concept) */
    public class SiMIDIModule
    {
    // constants
    //--------------------------------------------------
        /** Voice size. 1024 = 128tones x 8banks. */
        static public const VOICE_SIZE:int = 1024;
        /** Track size. 16tracks x 4banks. */
        static public const TRACK_SIZE:int = 64;
        
        
        
        
    // valiables
    //--------------------------------------------------
        /** MIDI tracks */
        public var tracks:Vector.<SiMIDITrack>;
        
        // voices
        private var _voices:Vector.<SiONVoice>;
        
        // sequencer instance
        private var _sequencer:SiMMLSequencer;
        
        
        
        
    // constructor
    //--------------------------------------------------
        /** Create new MIDI module. */
        function SiMIDIModule(sequencer:SiMMLSequencer)
        {
            var i:int;
            
            _sequencer = sequencer;
            
            _voices = new Vector.<SiONVoice>(VOICE_SIZE);
            for (i=0; i<VOICE_SIZE; i++) _voices[i] = null;
            tracks = new Vector.<SiMIDITrack>(TRACK_SIZE);
            for (i=0; i<TRACK_SIZE; i++) tracks[i] = new SiMIDITrack(this, i);
        }
        
        
        /** register tone setting. */
        public function registerToneSetting(toneNumber:int, toneSetting:SiONVoice) : void
        {
            if (toneNumber<0 || toneNumber>=VOICE_SIZE) return;
            _voices[toneNumber] = toneSetting;
        }
        
        
        /** Note on. This function only is available after play().
         *  @param trackNumber track number [0-63].
         *  @param note note number [0-127].
         *  @return The SiMMLTrack switched key on. Returns null when tracks are overflowed.
         */
        public function noteOn(trackNumber:int, note:int) : SiMMLTrack
        {
            var trackID:int = (trackNumber & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.MIDI_TRACK_ID_OFFSET,
                midiTrack:SiMIDITrack = tracks[trackNumber],
                seqTrack:SiMMLTrack = _sequencer.getFreeControlableTrack(trackID) || _sequencer.newControlableTrack(trackID);
            if (seqTrack) {
                var setting:SiONVoice = _voices[midiTrack.programNumber];
                if (setting) setting.setTrackVoice(seqTrack);
                seqTrack.setEventTrigger(midiTrack.eventTriggerID, midiTrack.noteOnTrigger, midiTrack.noteOffTrigger);
                seqTrack.keyOn(note);
            }
            return seqTrack;
        }
        
        
        /** Note off. This function only is available after play(). 
         *  @param trackNumber track number [0-63].
         *  @param note note number [0-127].
         *  @return The SiMMLTrack switched key off. Returns null when tracks are overflowed.
         */
        public function noteOff(trackNumber:int, note:int) : SiMMLTrack
        {
            var trackID:int = (trackNumber & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.MIDI_TRACK_ID_OFFSET;
            for each (var mmlTrack:SiMMLTrack in _sequencer.tracks) {
                if (mmlTrack.trackID == trackID) {
                    if (note == -1 || (note == mmlTrack.note && mmlTrack.channel.isNoteOn())) {
                        mmlTrack.keyOff(0);
                        return mmlTrack;
                    }
                }
            }
            return null;
        }
        
        
        /** program change.
         *  @param trackNumber track number [0-63].
         *  @param programNumber program number [0-127].
         *  @return MIDI Track instance.
         */
        public function programChenge(trackNumber:int, programNumber:int) : SiMIDITrack
        {
            var midiTrack:SiMIDITrack = tracks[trackNumber];
            midiTrack.programNumber = programNumber;
            return midiTrack;
        }
        
        
        /** volume.
         *  @param trackNumber track number [0-63].
         *  @param volume volume [0-128].
         *  @return MIDI Track instance.
         */
        public function volume(trackNumber:int, volume:int) : SiMIDITrack
        {
            var midiTrack:SiMIDITrack = tracks[trackNumber];
            midiTrack.volumes[0] = volume * 0.0078125;
            return midiTrack;
        }
    }
}


