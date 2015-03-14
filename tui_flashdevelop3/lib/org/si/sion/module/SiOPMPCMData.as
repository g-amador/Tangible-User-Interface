//----------------------------------------------------------------------------------------------------
// class for SiOPM PCM data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module {
    /** PCM data class */
    public class SiOPMPCMData
    {
    // valiables
    //----------------------------------------
        /** wave data */
        public var wavelet:Vector.<int>;
        
        /** bits for fixed decimal */
        public var pseudoFixedBits:int;
        
        /** wave starting position. */
        public var startPoint:int;
        
        /** wave end position. */
        public var endPoint:int;
        
        /** wave looping position. -1 means no repeat. */
        public var loopPoint:int;
        
        
        
        
    // oprations
    //----------------------------------------
        /** Constructor */
        function SiOPMPCMData(wavelet:Vector.<int>=null, samplingOctave:int=5, startPoint:int=0, endPoint:int=-1, loopPoint:int=-1)
        {
            this.wavelet = wavelet;
            this.pseudoFixedBits = 11 + (samplingOctave-5);
            if (wavelet != null) {
                slice(startPoint, endPoint, loopPoint);
            } else {
                this.loopPoint = -1;
                this.startPoint = 0;
                this.endPoint   = 0;
            }
        }
        
        
        /** Free instance. Through this into free list. */
        public function free() : void
        {
            _freeList.push(this);
        }
        

        /** Slicer setting. You can cut samples and set repeating.
         *  @param startPoint slicing point to start data.
         *  @param endPoint slicing point to end data. The negative value calculates from the end.
         *  @param loopPoint slicing point to repeat data. -1 means no repeat
         */
        public function slice(startPoint:int=0, endPoint:int=-1, loopPoint:int=-1) : void 
        {
            if (endPoint < 0) endPoint = wavelet.length + endPoint;
            if (wavelet.length < endPoint) endPoint = endPoint;
            if (endPoint < loopPoint)  loopPoint = -1;
            if (endPoint < startPoint) endPoint = endPoint;
            this.startPoint = startPoint;
            this.endPoint   = endPoint;
            this.loopPoint  = loopPoint;
        }
        
        
        // free list
        static private var _freeList:Vector.<SiOPMPCMData> = new Vector.<SiOPMPCMData>();
        
        
        /** @private */
        static public function alloc(wavelet:Vector.<int>, samplingOctave:int=5) : SiOPMPCMData
        {
            var newInstance:SiOPMPCMData = _freeList.pop() || new SiOPMPCMData();
            newInstance.wavelet = wavelet;
            newInstance.pseudoFixedBits = 11 + (samplingOctave-5);
            newInstance.loopPoint = -1;
            newInstance.startPoint = 0;
            newInstance.endPoint   = wavelet.length;
            return newInstance;
        }
    }
}

