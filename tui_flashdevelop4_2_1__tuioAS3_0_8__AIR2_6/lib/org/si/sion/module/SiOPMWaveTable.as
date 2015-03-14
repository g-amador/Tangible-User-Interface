//----------------------------------------------------------------------------------------------------
// class for SiOPM wave table
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module {
    public class SiOPMWaveTable
    {
        public var wavelet:Vector.<int>;
        public var fixedBits:int;
        public var defaultPTType:int;
        
        
        /** create new SiOPMWaveTable instance. */
        function SiOPMWaveTable()
        {
            this.wavelet = null;
            this.fixedBits = 0;
            this.defaultPTType = 0;
        }
        
        
        /** free. */
        public function free() : void
        {
            _freeList.push(this);
        }
        
        
        static private var _freeList:Vector.<SiOPMWaveTable> = new Vector.<SiOPMWaveTable>();
        
        
        /** allocate. */
        static public function alloc(wavelet:Vector.<int>, defaultPTType:int=0) : SiOPMWaveTable
        {
            var len:int, bits:int=0;
            for (len=wavelet.length>>1; len!=0; len>>=1) bits++;
            
            var newInstance:SiOPMWaveTable = _freeList.pop() || new SiOPMWaveTable();
            newInstance.wavelet = wavelet;
            newInstance.fixedBits = SiOPMTable.PHASE_BITS - bits;
            newInstance.defaultPTType = defaultPTType;
            
            return newInstance;
        }
    }
}

