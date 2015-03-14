//----------------------------------------------------------------------------------------------------
// class for SiMML sequencer setting
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer {
    import org.si.sion.sequencer.base.MMLSequence;
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.SiOPMPCMData;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMChannelBase;
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.SiOPMChannelManager;

    
    /** @private SiOPM channel setting */
    public class SiMMLChannelSetting
    {
    // constants
    //--------------------------------------------------
        static public const SELECT_TONE_NOP   :int = 0;
        static public const SELECT_TONE_NORMAL:int = 1;
        static public const SELECT_TONE_FM    :int = 2;
        static public const SELECT_TONE_PCM   :int = 3;

        
        
        
    // variables
    //--------------------------------------------------
        public   var type:int;
        internal var _selectToneType:int;
        internal var _pgTypeList:Vector.<int>;
        internal var _ptTypeList:Vector.<int>;
        internal var _initIndex:int;
        internal var _channelTone:Vector.<int>;
        internal var _channelType:int;
        
        
        
        
    // constructor
    //--------------------------------------------------
        function SiMMLChannelSetting(type:int, offset:int, length:int, step:int, channelCount:int)
        {
            var i:int, idx:int;
            _pgTypeList = new Vector.<int>(length, true);
            _ptTypeList = new Vector.<int>(length, true);
            for (i=0, idx=offset; i<length; i++, idx+=step) {
                _pgTypeList[i] = idx;
                _ptTypeList[i] = SiOPMTable.instance.getWaveTable(idx).defaultPTType;
            }
            _channelTone = new Vector.<int>(channelCount, true);
            for (i=0; i<channelCount; i++) { _channelTone[i] = i; }
            
            this._initIndex = 0;
            this.type = type;
            _channelType = SiOPMChannelManager.CT_CHANNEL_FM;
            _selectToneType = SELECT_TONE_NORMAL;
        }
        
        
        
        
    // tone setting
    //--------------------------------------------------
        /** initialize tone by channel number. 
         *  call from SiMMLTrack::reset()/setChannelModuleType().
         *  call from "%" MML command
         */
        public function initializeTone(track:SiMMLTrack, chNum:int, bufferIndex:int) : int
        {
            if (track.channel == null) {
                // create new channel
                track.channel = SiOPMChannelManager.newChannel(_channelType, null, bufferIndex);
            } else 
            if (track.channel.channelType != _channelType) {
                // change channel type
                var prev:SiOPMChannelBase = track.channel;
                track.channel = SiOPMChannelManager.newChannel(_channelType, prev, bufferIndex);
                SiOPMChannelManager.deleteChannel(prev);
            }

            // initialize
            // channelTone = chNum except for PSG and APU
            var channelTone:int = _initIndex; 
            if (chNum>=0 && chNum<_channelTone.length) channelTone = _channelTone[chNum];
            track._channelNumber = (chNum<0) ? 0 : chNum;
            track.channel.setAlgorism(1, 0);
            selectTone(track, channelTone);
            return (chNum == -1) ? -1 : channelTone;
        }
        
        
        /** select tone by tone number. 
         *  call from initializeTone(), SiMMLTrack::setChannelModuleType()/_bufferEnvelop()/_keyOn()/_setChannelParameters().
         *  call from "%" and "&#64;" MML command
         */
        public function selectTone(track:SiMMLTrack, voiceIndex:int) : MMLSequence
        {
            if (voiceIndex == -1) return null;
            
            var voice:SiMMLVoice, pcm:SiOPMPCMData;
            
            switch (_selectToneType) {
            case SELECT_TONE_NORMAL:
                if (voiceIndex <0 || voiceIndex >=_pgTypeList.length) voiceIndex = _initIndex;
                track.channel.setType(_pgTypeList[voiceIndex], _ptTypeList[voiceIndex]);
                break;
            case SELECT_TONE_FM: // %6
                if (voiceIndex<0 || voiceIndex>=SiMMLTable.VOICE_MAX) voiceIndex=0;
                voice = SiMMLTable.instance.getSiMMLVoice(voiceIndex);
                if (voice) { // this module changes only channel params, not track params.
                    track.channel.setSiOPMChannelParam(voice.channelParam, false);
                    return (voice.channelParam.initSequence.isEmpty()) ? null : voice.channelParam.initSequence;
                }
                break;
            case SELECT_TONE_PCM: // %7
                if (voiceIndex>=0 && voiceIndex<SiOPMTable.PCM_DATA_MAX) {
                    pcm = SiOPMTable.instance.getPCMData(voiceIndex);
                    if (pcm) track.channel.setPCMData(pcm);
                }
                break;
            default:
                break;
            }
            return null;
        }
    }
}

