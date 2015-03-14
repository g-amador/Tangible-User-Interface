//----------------------------------------------------------------------------------------------------
// SiOPM effect Compressor
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector {
    import org.si.utils.SLLNumber;
    
    
    /** Compressor. */
    public class SiEffectCompressor extends SiEffectBase
    {
    // variables
    //------------------------------------------------------------
        private var _windowRMSList:SLLNumber = null;
        private var _windowSamples:int;
        private var _windowRMSTotal:Number;
        private var _windwoRMSAveraging:Number;
        private var _thres:Number;  // threshold
        private var _slope:Number;  // slope angle
        private var _attRate:Number;    // attack rate  (per sample decay)
        private var _relRate:Number;    // release rate (per sample decay)
        
        
        
        
    // constructor
    //------------------------------------------------------------
        /** constructor */
        function SiEffectCompressor() {}
        
        
        
        
    // operation
    //------------------------------------------------------------
        /** set parameters.
         *  @param thres threshold(0-1).
         *  @param slope slope(0-1).
         *  @param wndTime window to calculate gain[ms].
         *  @param attTime attack [ms].
         *  @param relTime release [ms].
         */
        public function setParameters(thres:Number=0.5, slope:Number=0.5, wndTime:Number=50, attTime:Number=20, relTime:Number=20) : void {
            _thres = thres;
            _slope = slope;
            _windowSamples = int(wndTime * 44.1);
            _windwoRMSAveraging = 1/_windowSamples;
            _attRate = (attTime == 0) ? 0 : Math.exp(-1.0 / (attTime * 44.1));
            _relRate = (relTime == 0) ? 0 : Math.exp(-1.0 / (relTime * 44.1));
        }
        
        
        
        
    // overrided funcitons
    //------------------------------------------------------------
        /** @private */
        override public function initialize() : void
        {
            setParameters();
        }
        

        /** @private */
        override public function mmlCallback(args:Vector.<Number>) : void
        {
            setParameters((!isNaN(args[0])) ? args[0]*0.01 : 0.5,
                          (!isNaN(args[0])) ? args[0]*0.01 : 0.5,
                          (!isNaN(args[0])) ? args[0] : 50,
                          (!isNaN(args[0])) ? args[0] : 20,
                          (!isNaN(args[0])) ? args[0] : 20);
        }
        
        
        /** @private */
        override public function prepareProcess() : int
        {
            if (_windowRMSList) SLLNumber.freeRing(_windowRMSList);
            _windowRMSList = SLLNumber.allocRing(_windowSamples);
            _windowRMSTotal = 0;
            return 2;
        }
        
        
        /** @private */
        override public function process(channels:int, buffer:Vector.<Number>, startIndex:int, length:int) : int
        {
            startIndex <<= 1;
            length <<= 1;
            
            var i:int, imax:int = startIndex + length;
            var l:Number, r:Number, rms:Number, dt:Number, gain:Number, env:Number;
            env = 0;
            gain = 1;
            for (i=startIndex; i<imax; i+=2) {
                l = buffer[i];
                r = buffer[i+1];
                _windowRMSList = _windowRMSList.next;
                _windowRMSTotal  -= _windowRMSList.n;
                _windowRMSList.n = l * l + r * r;
                _windowRMSTotal  += _windowRMSList.n;
                rms = Math.sqrt(_windowRMSTotal * _windwoRMSAveraging);

                dt = (rms > env) ? _attRate : _relRate;
                env = (1 - dt) * rms + dt * env;

                if (env > _thres) gain = gain - (env - _thres) * _slope;

                l *= gain;
                r *= gain;
                l = (l>1) ? 1 : (l<-1) ? -1 : l;
                r = (r>1) ? 1 : (r<-1) ? -1 : r;
                buffer[i]   = l;
                buffer[i+1] = r;
            }
            return channels;
        }
    }
}

