//----------------------------------------------------------------------------------------------------
// class for SiOPM samplers wave
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module {
    /** SiOPM samplers wave data */
    public class SiOPMSamplerData
    {
        /** Wave data */
        public var waveData:Vector.<Number>;
        
        // flags
        private var _flags:int;
        
        /** is one shot wave sample. */
        public function get isOneShot() : Boolean { return ((_flags & 1) == 1); }
        /** channel count of this data. */
        public function get channelCount() : int { return (_flags & 2) ? 2 : 1; }
        
        
        /** constructor */
        function SiOPMSamplerData(waveData:Vector.<Number>=null, isOneShot:Boolean=true, channelCount:int=2) 
        {
            this.waveData = waveData;
            _flags  = (isOneShot) ?         1 : 0;
            _flags |= (channelCount == 2) ? 2 : 0;
        }
        
        
        public function free() : void
        {
            _freeList.push(this);
        }
        
        
        static private var _freeList:Vector.<SiOPMSamplerData> = new Vector.<SiOPMSamplerData>();
        
        static public function alloc(waveData:Vector.<Number>, isOneShot:Boolean, channelCount:int) : SiOPMSamplerData
        {
            var newInstance:SiOPMSamplerData = _freeList.pop() || new SiOPMSamplerData();
            newInstance.waveData = waveData;
            newInstance._flags  = (isOneShot) ?         1 : 0;
            newInstance._flags |= (channelCount == 2) ? 2 : 0;
            return newInstance;
        }
    }
}

