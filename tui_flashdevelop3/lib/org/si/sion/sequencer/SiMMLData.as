//----------------------------------------------------------------------------------------------------
// SiMML data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer {
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.sequencer.base.MMLData;
    import org.si.utils.SLLint;
    import org.si.sion.namespaces._sion_internal;
    
    
    
    /** SiMML data class. */
    public class SiMMLData extends MMLData
    {
    // valiables
    //----------------------------------------
        /** envelop tables */
        public var envelops:Vector.<SiMMLEnvelopTable>;
        /** voice data */
        public var voices:Vector.<SiMMLVoice>;
        
        
        
        
    // constructor
    //----------------------------------------
        /** constructor. */
        function SiMMLData()
        {
            envelops = new Vector.<SiMMLEnvelopTable>(SiMMLTable.ENV_TABLE_MAX);
            voices   = new Vector.<SiMMLVoice>(SiMMLTable.VOICE_MAX);
        }
        
        
        
        
    // operations
    //----------------------------------------
        /** Clear all parameters and free all sequence groups. */
        override public function clear() : void
        {
            super.clear();
            var i:int, imax:int;
            imax = envelops.length;
            for (i=0; i<imax; i++) envelops[i] = null;
            imax = voices.length;
            for (i=0; i<imax; i++) voices[i] = null;
        }
        
        
        /** Set envelop table data refered by &#64;&#64;,na,np,nt,nf,_&#64;&#64;,_na,_np,_nt and _nf.
         *  @param index envelop table number.
         *  @param envelop envelop table.
         */
        public function setEnvelopTable(index:int, envelop:SiMMLEnvelopTable) : void
        {
            if (index >= 0 && index < SiMMLTable.ENV_TABLE_MAX) envelops[index] = envelop;
        }
        
        
        /** Set wave table data refered by %6.
         *  @param index wave table number.
         *  @param voice voice to register.
         */
        public function setVoice(index:int, voice:SiMMLVoice) : void
        {
            if (index >= 0 && index < SiMMLTable.VOICE_MAX) {
                if (!voice._sion_internal::_isSuitableForFMVoice) throw errorNotGoodFMVoice();
                 voices[index] = voice;
            }
        }
        
        
        
        
    // internal function
    //--------------------------------------------------
        /** @private [internal] Set envelop table data */
        internal function _setEnvelopTable(index:int, head:SLLint, tail:SLLint) : void
        {
            var t:SiMMLEnvelopTable = new SiMMLEnvelopTable();
            t._sion_internal::_initialize(head, tail);
            envelops[index] = t;
        }
        
        
        /** @private [internal] Get channel parameter */
        internal function _getSiOPMChannelParam(index:int) : SiOPMChannelParam
        {
            var v:SiMMLVoice = new SiMMLVoice();
            v.channelParam = new SiOPMChannelParam();
            voices[index] = v;
            return v.channelParam;
        }
        
        
        /** @private [internal] register all tables. called from SiMMLTrack._prepareBuffer(). */
        internal function _registerAllTables() : void
        {
            SiOPMTable.instance._sion_internal::_stencilCustomWaveTables = waveTables;
            SiOPMTable.instance._sion_internal::_stencilPCMData          = pcmData;
            SiOPMTable.instance._sion_internal::_stencilSamplerData      = samplerData;
            SiMMLTable.instance._stencilEnvelops = envelops;
            SiMMLTable.instance._stencilVoices   = voices;
        }
        
        
        
        
    // error
    //----------------------------------------
        private function errorNotGoodFMVoice() : Error {
            return new Error("SiONDriver error; Cannot register the voice.");
        }
    }
}

