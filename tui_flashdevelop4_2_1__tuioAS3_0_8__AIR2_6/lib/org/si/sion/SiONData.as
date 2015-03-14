//----------------------------------------------------------------------------------------------------
// SiON data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion {
    import flash.media.Sound;
    import org.si.sion.sequencer.SiMMLData;
    import org.si.sion.utils.SiONUtil;
    import org.si.sion.module.SiOPMPCMData;
    import org.si.sion.module.SiOPMSamplerData;

    
    /** SiON data class.
     */
    public class SiONData extends SiMMLData
    {
    // valiables
    //----------------------------------------
        
        
        
        
    // constructor
    //----------------------------------------
        function SiONData()
        {
        }
        
        
        
        
    // setter
    //----------------------------------------
        /** Set PCM sound rederd from %7.
         *  @param index PCM data number.
         *  @param sound Sound instance to set.
         *  @param samplingOctave Sampling frequency. The value of 5 means that "o5a" is original frequency.
         *  @param sampleMax The maximum sample count to extract. The length of returning vector is limited by this value.
         *  @return created instance
         */
        public function setPCMSound(index:int, sound:Sound, samplingOctave:int=5, sampleMax:int=1048576) : SiOPMPCMData
        {
            var pcm:Vector.<int> = SiONUtil.logTrans(sound, null, sampleMax);
            pcmData[index] = SiOPMPCMData.alloc(pcm, samplingOctave);
            return pcmData[index];
        }
        
        
        /** Set sampler sound refered by %10.
         *  @param index note number. 0-127 for bank0, 128-255 for bank1.
         *  @param sound Sound instance to set.
         *  @param isOneShot True to set "one shot" sound. The "one shot" sound ignores note off.
         *  @param channelCount 1 for monoral, 2 for stereo.
         *  @param sampleMax The maximum sample count to extract. The length of returning vector is limited by this value.
         *  @return created instance
         */
        public function setSamplerSound(index:int, sound:Sound, isOneShot:Boolean=true, channelCount:int=2, sampleMax:int=1048576) : SiOPMSamplerData
        {
            var data:Vector.<Number> = SiONUtil.extract(sound, null, channelCount, sampleMax);
            return setSamplerData(index, data, isOneShot, channelCount);
        }
    }
}

