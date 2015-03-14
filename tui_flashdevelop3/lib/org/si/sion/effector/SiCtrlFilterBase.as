//----------------------------------------------------------------------------------------------------
// SiOPM filter controlable
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector {
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.utils.SLLint;
    
    
    /** controlable filter base class. */
    public class SiCtrlFilterBase extends SiEffectBase
    {
    // variables
    //------------------------------------------------------------
        protected var _p0r:Number, _p1r:Number, _p0l:Number, _p1l:Number;
        protected var _cutIndex:int, _res:Number, _table:SiOPMTable;
        
        private var _ptrCut:SLLint, _ptrRes:SLLint
        private var _lfoStep:int;
        private var _lfoResidueStep:int;
        
        
        
        
    // constructor
    //------------------------------------------------------------
        /** constructor */
        function SiCtrlFilterBase() {}
        
        
        
        
    // operation
    //------------------------------------------------------------
        /** set parameters
         *  @param cut table index for cutoff(0-255). 255 to set no tables.
         *  @param res table index for resonance(0-255). 255 to set no tables.
         *  @param fps Envelop speed (0.001-1000)[Frame per second].
         */
        public function setParameters(cut:int=255, res:int=255, fps:Number=20) : void {
            _table = SiOPMTable.instance;
            var simml:SiMMLTable = SiMMLTable.instance;
            _ptrCut = (cut>=0 && cut<255 && simml.getEnvelopTable(cut)) ? simml.getEnvelopTable(cut).head : null;
            _ptrRes = (res>=0 && res<255 && simml.getEnvelopTable(res)) ? simml.getEnvelopTable(res).head : null;
            _cutIndex = (_ptrCut) ? _ptrCut.i : 128;
            _res = (_ptrRes) ? (_ptrRes.i*0.007751937984496124) : 0;    // 0.007751937984496124=1/129
            _lfoStep = int(44100/fps);
            if (_lfoStep <= 44) _lfoStep = 44;
            _lfoResidueStep = _lfoStep<<1;
        }
        
        
        /** control cutoff and resonance manualy. 
         *  @param cutoff cutoff(0-1).
         *  @param resonance resonance(0-1).
         */
        public function control(cutoff:Number, resonance:Number) : void {
            _lfoStep = 2048;
            _lfoResidueStep = 4096;
            
            if (cutoff > 1) cutoff=1;
            else if (cutoff<0) cutoff=0;
            _cutIndex = cutoff*128;
            
            if (resonance > 1) resonance=1;
            else if (resonance<0) resonance=0;
            _res = resonance;
        }
        
        
        
        
    // overrided funcitons
    //------------------------------------------------------------
        /** @private */
        override public function initialize() : void
        {
            _lfoResidueStep = 0;
            _p0r = _p1r = _p0l = _p1l = 0;
            setParameters();
        }
        

        /** @private */
        override public function mmlCallback(args:Vector.<Number>) : void
        {
            setParameters((!isNaN(args[0])) ? int(args[0]) : 255,
                          (!isNaN(args[1])) ? int(args[1]) : 255,
                          (!isNaN(args[2])) ? int(args[2]) : 20);
        }
        
        
        /** @private */
        override public function prepareProcess() : int
        {
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
                processLFO(buffer, i, istep);
                if (_ptrCut) { _ptrCut = _ptrCut.next; _cutIndex = (_ptrCut) ? _ptrCut.i : 128; }
                if (_ptrRes) { _ptrRes = _ptrRes.next; _res = (_ptrRes) ? (_ptrRes.i*0.007751937984496124) : 0; }
                i += istep;
                istep = _lfoStep<<1;
            }
            processLFO(buffer, i, imax-i);
            _lfoResidueStep = istep - (imax - i);
            return channels;
        }
        
        
        /** @private */
        protected function processLFO(buffer:Vector.<Number>, startIndex:int, length:int) : void
        {
        }
    }
}

