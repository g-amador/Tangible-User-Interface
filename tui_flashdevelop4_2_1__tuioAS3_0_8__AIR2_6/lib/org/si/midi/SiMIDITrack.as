//----------------------------------------------------------------------------------------------------
// MIDI track
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.midi {
    import org.si.sion.*;
    import org.si.sion.module.SiOPMModule;

    
    /** MIDI track (still in concept) */
    public class SiMIDITrack
    {
    // valiables
    //--------------------------------------------------
        /** track number */
        public var trackNumber:int;
        
        /** program number */
        public var programNumber:int;
        
        /** stream volumes */
        public var volumes:Vector.<Number>;
        
        /** pan */
        public var pan:int;
        
        // MIDI module
        private var _module:SiMIDIModule;
        
        /** event trigger id. @default 0 */
        public var eventTriggerID:int;
        /** note on trigger type. @default 0 */
        public var noteOnTrigger:int;
        /** note off trigger type. @default 0 */
        public var noteOffTrigger:int;
        
        
        
    // constructor
    //--------------------------------------------------
        /** @private create new SiMIDITrack. This is created only by SiMIDIModule. */
        function SiMIDITrack(module:SiMIDIModule, trackNumber:int)
        {
            var i:int;
            _module = module;
            this.trackNumber = trackNumber;
            this.programNumber = 0;
            volumes = new Vector.<Number>(SiOPMModule.STREAM_SIZE_MAX);
            for (i=1; i<SiOPMModule.STREAM_SIZE_MAX; i++) volumes[i] = 0;
            volumes[0] = 0.5;
            pan = 0;
            eventTriggerID = 0;
            noteOnTrigger = 0;
            noteOffTrigger = 0;
        }
    }
}


