//----------------------------------------------------------------------------------------------------
// SiOPM effect stereo chorus
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector {
    /** Stereo chorus effector. */
    public class SiEffectStereoChorus extends SiEffectBase
    {
    // variables
    //------------------------------------------------------------
        static private const DELAY_BUFFER_BITS:int = 12;
        static private const DELAY_BUFFER_FILTER:int = (1<<DELAY_BUFFER_BITS)-1;
        
        private var _delayBufferL:Vector.<Number>, _delayBufferR:Vector.<Number>;
        private var _pointerRead:int;
        private var _pointerWrite:int;
        private var _feedback:Number;
        private var _depth:Number;
        private var _wet:Number;
        
        private var _lfoPhase:int;
        private var _lfoStep:int;
        private var _lfoResidueStep:int;
        private var _sin:Vector.<Number>;
        
        
        
        
    // constructor
    //------------------------------------------------------------
        /** constructor */
        function SiEffectStereoChorus()
        {
            _delayBufferL = new Vector.<Number>(1<<DELAY_BUFFER_BITS);
            _delayBufferR = new Vector.<Number>(1<<DELAY_BUFFER_BITS);
            _sin = SiEffectTable.instance.sinTable;
        }
        
        
        
        
    // operation
    //------------------------------------------------------------
        /** set parameter
         *  @param delayTime delay time[ms]. maximum value is about 94.
         *  @param feedback feedback ratio(0-1).
         *  @param frequency frequency of chorus[Hz].
         *  @param depth depth of chorus.
         *  @param wet wet mixing level.
         */
        public function setParameters(delayTime:Number=20, feedback:Number=0.2, frequency:Number=4, depth:Number=20, wet:Number=0.5) : void {
            var offset:int = int(delayTime * 44.1);
            if (offset > DELAY_BUFFER_FILTER) offset = DELAY_BUFFER_FILTER;
            _pointerWrite = (_pointerRead + offset) & DELAY_BUFFER_FILTER;
            _feedback = (feedback>=1) ? 0.9990234375 : (feedback<=-1) ? -0.9990234375 : feedback;
            _depth = (depth >= offset-4) ? (offset-4) : depth;
            _lfoStep = int(172.265625/frequency);   //44100/256
            if (_lfoStep <= 4) _lfoStep = 4;
            _lfoResidueStep = _lfoStep<<1;
            _wet = wet;
        }
        
        
        
        
    // overrided funcitons
    //------------------------------------------------------------
        /** @private */
        override public function initialize() : void
        {
            _lfoPhase = 0;
            _lfoResidueStep = 0;
            _pointerRead = 0;
            setParameters();
        }
        

        /** @private */
        override public function mmlCallback(args:Vector.<Number>) : void
        {
            setParameters((!isNaN(args[0])) ? args[0] : 20,
                          (!isNaN(args[1])) ? (args[1]*0.01) : 0.2,
                          (!isNaN(args[2])) ? args[2] : 4,
                          (!isNaN(args[3])) ? args[3] : 20,
                          (!isNaN(args[4])) ? (args[4]*0.01) : 0.5);
        }
        
        
        /** @private */
        override public function prepareProcess() : int
        {
            var i:int, imax:int = 1<<DELAY_BUFFER_BITS;
            for (i=0; i<imax; i++) _delayBufferL[i] = _delayBufferR[i] = 0;
            return 2;
        }
        
        
        /** @private */
        override public function process(channels:int, buffer:Vector.<Number>, startIndex:int, length:int) : int
        {
            startIndex <<= 1;
            length <<= 1;
            
            var i:int, imax:int, istep:int, c:Number, s:Number, l:Number, r:Number;
            istep = _lfoResidueStep;
            imax = startIndex + length;
            for (i=startIndex; i<imax-istep;) {
                _processLFO(buffer, i, istep);
                _lfoPhase = (_lfoPhase + 1) & 255;
                i += istep;
                istep = _lfoStep<<1;
            }
            _processLFO(buffer, i, imax-i);
            _lfoResidueStep = istep - (imax - i);
            return channels;
        }
        
        
        // process inside
        private function _processLFO(buffer:Vector.<Number>, startIndex:int, length:int) : void
        {
            var i:int, n:Number, m:Number, p:int, imax:int = startIndex + length, dly:int=int(_sin[_lfoPhase] * _depth),
                dry:Number = 1-_wet;
            for (i=startIndex; i<imax;) {
                p = (_pointerRead + dly) & DELAY_BUFFER_FILTER;
                n = _delayBufferL[p];
                m = buffer[i] - n * _feedback;
                _delayBufferL[_pointerWrite] = m;
                buffer[i] *= dry;
                buffer[i] += n * _wet; i++;
                n = _delayBufferR[p];
                m = buffer[i] - n * _feedback;
                _delayBufferR[_pointerWrite] = m;
                buffer[i] *= dry;
                buffer[i] += n * _wet; i++;
                _pointerWrite = (_pointerWrite+1) & DELAY_BUFFER_FILTER;
                _pointerRead  = (_pointerRead +1) & DELAY_BUFFER_FILTER;
            }
        }
    }
}

