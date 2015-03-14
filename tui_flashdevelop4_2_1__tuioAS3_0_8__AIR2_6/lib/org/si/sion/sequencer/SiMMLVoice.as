//----------------------------------------------------------------------------------------------------
// Voice data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer {
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.SiOPMWaveTable;
    import org.si.sion.module.SiOPMPCMData;
    import org.si.sion.namespaces._sion_internal;
    
    
    /** Voice data. This includes SiOPMChannelParam.
     *  @see org.si.sion.module.SiOPMChannelParam
     *  @see org.si.sion.module.SiOPMOperatorParam
     */
    public class SiMMLVoice
    {
    // variables
    //--------------------------------------------------
        /** flag to set volume and panning when the voice is set. @default false; ignore volume settings */
        public var setVolumes:Boolean;
        
        /** module type, 1st argument of '%'. @default 0 */
        public var moduleType:int;
        /** channel number, 2nd argument of '%'. @default 0 */
        public var channelNum:int;
        /** tone number, 1st argument of '&#64;'. -1;do nothing. @default -1 */
        public var toneNum:int;
        
        /** parameters for FM sound channel. */
        public var channelParam:SiOPMChannelParam;
        /** wave data for PCM sound channel. null;not pcm voice. @default null */
        public var pcmData:SiOPMPCMData;
        /** PSM guitar tension @default 8 */
        public var psmTension:int;
        
        /** track pitch shift (same as "k" command). @default 0 */
        public var pitchShift:int;
        /** portament. @default 0 */
        public var portament:int;
        /** release sweep. 2nd argument of '&#64;rr' and 's'. @default 0 */
        public var releaseSweep:int;
        
        
        /** amplitude modulation depth. 1st argument of 'ma'. @default 0 */
        public var amDepth:int;
        /** amplitude modulation depth after changing. 2nd argument of 'ma'. @default 0 */
        public var amDepthEnd:int;
        /** amplitude modulation changing delay. 3rd argument of 'ma'. @default 0 */
        public var amDelay:int;
        /** amplitude modulation changing term. 4th argument of 'ma'. @default 0 */
        public var amTerm:int;
        /** pitch modulation depth. 1st argument of 'mp'. @default 0 */
        public var pmDepth:int;
        /** pitch modulation depth after changing. 2nd argument of 'mp'. @default 0 */
        public var pmDepthEnd:int;
        /** pitch modulation changing delay. 3rd argument of 'mp'. @default 0 */
        public var pmDelay:int;
        /** pitch modulation changing term. 4th argument of 'mp'. @default 0 */
        public var pmTerm:int;
        
        
        /** note on tone envelop table. 1st argument of '&#64;&#64;' @default null */
        public var noteOnToneEnvelop:SiMMLEnvelopTable;
        /** note on amplitude envelop table. 1st argument of 'na' @default null */
        public var noteOnAmplitudeEnvelop:SiMMLEnvelopTable;
        /** note on filter envelop table. 1st argument of 'nf' @default null */
        public var noteOnFilterEnvelop:SiMMLEnvelopTable;
        /** note on pitch envelop table. 1st argument of 'np' @default null */
        public var noteOnPitchEnvelop:SiMMLEnvelopTable;
        /** note on note envelop table. 1st argument of 'nt' @default null */
        public var noteOnNoteEnvelop:SiMMLEnvelopTable;
        /** note off tone envelop table. 1st argument of '_&#64;&#64;' @default null */
        public var noteOffToneEnvelop:SiMMLEnvelopTable;
        /** note off amplitude envelop table. 1st argument of '_na' @default null */
        public var noteOffAmplitudeEnvelop:SiMMLEnvelopTable;
        /** note off filter envelop table. 1st argument of '_nf' @default null */
        public var noteOffFilterEnvelop:SiMMLEnvelopTable;
        /** note off pitch envelop table. 1st argument of '_np' @default null */
        public var noteOffPitchEnvelop:SiMMLEnvelopTable;
        /** note off note envelop table. 1st argument of '_nt' @default null */
        public var noteOffNoteEnvelop:SiMMLEnvelopTable;
        
        
        /** note on tone envelop tablestep. 2nd argument of '&#64;&#64;' @default 1 */
        public var noteOnToneEnvelopStep:int;
        /** note on amplitude envelop tablestep. 2nd argument of 'na' @default 1 */
        public var noteOnAmplitudeEnvelopStep:int;
        /** note on filter envelop tablestep. 2nd argument of 'nf' @default 1 */
        public var noteOnFilterEnvelopStep:int;
        /** note on pitch envelop tablestep. 2nd argument of 'np' @default 1 */
        public var noteOnPitchEnvelopStep:int;
        /** note on note envelop tablestep. 2nd argument of 'nt' @default 1 */
        public var noteOnNoteEnvelopStep:int;
        /** note off tone envelop tablestep. 2nd argument of '_&#64;&#64;' @default 1 */
        public var noteOffToneEnvelopStep:int;
        /** note off amplitude envelop tablestep. 2nd argument of '_na' @default 1 */
        public var noteOffAmplitudeEnvelopStep:int;
        /** note off filter envelop tablestep. 2nd argument of '_nf' @default 1 */
        public var noteOffFilterEnvelopStep:int;
        /** note off pitch envelop tablestep. 2nd argument of '_np' @default 1 */
        public var noteOffPitchEnvelopStep:int;
        /** note off note envelop tablestep. 2nd argument of '_nt' @default 1 */
        public var noteOffNoteEnvelopStep:int;
        
        
        
        
    // properties
    //--------------------------------------------------
        /** FM voice flag */
        public function get isFMVoice() : Boolean {
            return (moduleType == 6);
        }
        
        /** PCM voice flag */
        public function get isPCMVoice() : Boolean {
            return (pcmData != null);
        }
                
        /** @private [sion internal] suitability to register on %6 voice */
        _sion_internal function get _isSuitableForFMVoice() : Boolean {
            return (pcmData == null && moduleType != 6 && moduleType != 7 && moduleType < 10);
        }
        
        
        /** set moduleType, channelNum, toneNum and 0th operator's pgType simultaneously.
         *  @param moduleType Channel module type
         *  @param channelNum Channel number. For %2-11, this value is same as 1st argument of '_&#64;'.
         *  @param toneNum Tone number. Ussualy, this argument is used only in %0;PSG and %1;APU.
         */
        public function setModuleType(moduleType:int, channelNum:int=0, toneNum:int=-1) : void
        {
            this.moduleType = moduleType;
            this.channelNum = channelNum;
            this.toneNum    = toneNum;
            var pgType:int = SiMMLTable.getPGType(moduleType, channelNum, toneNum);
            if (pgType != -1) channelParam.operatorParam[0].setPGType(pgType);
        }
        
        
        
        
    // constrctor
    //--------------------------------------------------
        /** constructor. */
        function SiMMLVoice()
        {
            setVolumes = false;
            
            moduleType = 5;
            channelNum = 0;
            toneNum = -1;
            
            channelParam = new SiOPMChannelParam();
            pcmData = null;
            psmTension = 8;
            
            pitchShift = 0;
            portament = 0;
            releaseSweep = 0;
            
            amDepth = 0;
            amDepthEnd = 0;
            amDelay = 0;
            amTerm = 0;
            pmDepth = 0;
            pmDepthEnd = 0;
            pmDelay = 0;
            pmTerm = 0;

            noteOnToneEnvelop = null;
            noteOnAmplitudeEnvelop = null;
            noteOnFilterEnvelop = null;
            noteOnPitchEnvelop = null;
            noteOnNoteEnvelop = null;
            noteOffToneEnvelop = null;
            noteOffAmplitudeEnvelop = null;
            noteOffFilterEnvelop = null;
            noteOffPitchEnvelop = null;
            noteOffNoteEnvelop = null;
            
            noteOnToneEnvelopStep = 1;
            noteOnAmplitudeEnvelopStep = 1;
            noteOnFilterEnvelopStep = 1;
            noteOnPitchEnvelopStep = 1;
            noteOnNoteEnvelopStep = 1;
            noteOffToneEnvelopStep = 1;
            noteOffAmplitudeEnvelopStep = 1;
            noteOffFilterEnvelopStep = 1;
            noteOffPitchEnvelopStep = 1;
            noteOffNoteEnvelopStep = 1;
        }
        
        
        
        
    // setting
    //--------------------------------------------------
        /** set sequencer track */
        public function setTrackVoice(track:SiMMLTrack) : SiMMLTrack
        {
            switch (moduleType) {
            case 6:  // Registered FM voice (%6)
                track.setChannelModuleType(6, channelNum);
                break;
            case 11: // PMS Guitar (%11)
                track.setChannelModuleType(11, 1);
                track.channel.setSiOPMChannelParam(channelParam, false);
                track.channel.setAllReleaseRate(psmTension);
                break;
            default: // other sound modules
                track.setChannelModuleType(moduleType, channelNum, toneNum);
                track.channel.setSiOPMChannelParam(channelParam, setVolumes);
                break;
            }
            
            // PCM sound module
            if (pcmData) track.channel.setPCMData(pcmData);
            
            // track settings
            track.pitchShift = pitchShift;
            track.setPortament(portament);
            track.setReleaseSweep(releaseSweep);
            track.setModulationEnvelop(false, amDepth, amDepthEnd, amDelay, amTerm);
            track.setModulationEnvelop(true,  pmDepth, pmDepthEnd, pmDelay, pmTerm);
            if (noteOnToneEnvelop != null) track.setToneEnvelop(1, noteOnToneEnvelop, noteOnToneEnvelopStep);
            if (noteOnAmplitudeEnvelop != null) track.setAmplitudeEnvelop(1, noteOnAmplitudeEnvelop, noteOnAmplitudeEnvelopStep);
            if (noteOnFilterEnvelop != null) track.setFilterEnvelop(1, noteOnFilterEnvelop, noteOnFilterEnvelopStep);
            if (noteOnPitchEnvelop != null) track.setPitchEnvelop(1, noteOnPitchEnvelop, noteOnPitchEnvelopStep);
            if (noteOnNoteEnvelop != null) track.setNoteEnvelop(1, noteOnNoteEnvelop, noteOnNoteEnvelopStep);
            if (noteOffToneEnvelop != null) track.setToneEnvelop(0, noteOffToneEnvelop, noteOffToneEnvelopStep);
            if (noteOffAmplitudeEnvelop != null) track.setAmplitudeEnvelop(0, noteOffAmplitudeEnvelop, noteOffAmplitudeEnvelopStep);
            if (noteOffFilterEnvelop != null) track.setFilterEnvelop(0, noteOffFilterEnvelop, noteOffFilterEnvelopStep);
            if (noteOffPitchEnvelop != null) track.setPitchEnvelop(0, noteOffPitchEnvelop, noteOffPitchEnvelopStep);
            if (noteOffNoteEnvelop != null) track.setNoteEnvelop(0, noteOffNoteEnvelop, noteOffNoteEnvelopStep);
            
            return track;
        }

        
        
        
    // operation
    //--------------------------------------------------
        /** copy all parameters */
        public function copyFrom(src:SiMMLVoice) : SiMMLVoice
        {
            moduleType = src.moduleType;
            channelNum = src.channelNum;
            toneNum = src.toneNum;
            channelParam.copyFrom(src.channelParam);
            
            pitchShift = src.pitchShift;
            portament = src.portament;
            releaseSweep = src.releaseSweep;
            
            amDepth = src.amDepth;
            amDepthEnd = src.amDepthEnd;
            amDelay = src.amDelay;
            amTerm = src.amTerm;
            pmDepth = src.pmDepth;
            pmDepthEnd = src.pmDepthEnd;
            pmDelay = src.pmDelay;
            pmTerm = src.pmTerm;
            
            if (src.noteOnToneEnvelop) noteOnToneEnvelop = new SiMMLEnvelopTable(src.noteOnToneEnvelop);
            if (src.noteOnAmplitudeEnvelop) noteOnAmplitudeEnvelop = new SiMMLEnvelopTable(src.noteOnAmplitudeEnvelop);
            if (src.noteOnFilterEnvelop) noteOnFilterEnvelop = new SiMMLEnvelopTable(src.noteOnFilterEnvelop);
            if (src.noteOnPitchEnvelop) noteOnPitchEnvelop = new SiMMLEnvelopTable(src.noteOnPitchEnvelop);
            if (src.noteOnNoteEnvelop) noteOnNoteEnvelop = new SiMMLEnvelopTable(src.noteOnNoteEnvelop);
            if (src.noteOffToneEnvelop) noteOffToneEnvelop = new SiMMLEnvelopTable(src.noteOffToneEnvelop);
            if (src.noteOffAmplitudeEnvelop) noteOffAmplitudeEnvelop = new SiMMLEnvelopTable(src.noteOffAmplitudeEnvelop);
            if (src.noteOffFilterEnvelop) noteOffFilterEnvelop = new SiMMLEnvelopTable(src.noteOffFilterEnvelop);
            if (src.noteOffPitchEnvelop) noteOffPitchEnvelop = new SiMMLEnvelopTable(src.noteOffPitchEnvelop);
            if (src.noteOffNoteEnvelop) noteOffNoteEnvelop = new SiMMLEnvelopTable(src.noteOffNoteEnvelop);
            
            noteOnToneEnvelopStep = src.noteOnToneEnvelopStep;
            noteOnAmplitudeEnvelopStep = src.noteOnAmplitudeEnvelopStep;
            noteOnFilterEnvelopStep = src.noteOnFilterEnvelopStep;
            noteOnPitchEnvelopStep = src.noteOnPitchEnvelopStep;
            noteOnNoteEnvelopStep = src.noteOnNoteEnvelopStep;
            noteOffToneEnvelopStep = src.noteOffToneEnvelopStep;
            noteOffAmplitudeEnvelopStep = src.noteOffAmplitudeEnvelopStep;
            noteOffFilterEnvelopStep = src.noteOffFilterEnvelopStep;
            noteOffPitchEnvelopStep = src.noteOffPitchEnvelopStep;
            noteOffNoteEnvelopStep = src.noteOffNoteEnvelopStep;
            
            return this;
        }
    }
}


