//----------------------------------------------------------------------------------------------------
// SiOPM FM channel.
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module {
    import org.si.utils.SLLNumber;
    import org.si.utils.SLLint;
    
    
    /** FM sound channel. <p>
     *  The calculation of this class is based on OPM emulation (refer from sources of mame, fmgen and x68sound).
     *  And it has some extension to simulate other sevral fm sound modules (OPNA, OPLL, OPL2, OPL3, OPX, MA3, MA5, MA7, TSS and DX7).
     *  <ul>
     *    <li>steleo output (from TSS,DX7)</li>
     *    <li>key scale level (from OPL3,OPX,MAx)</li>
     *    <li>phase select (from TSS)</li>
     *    <li>fixed frequency (from MAx)</li>
     *    <li>ssgec (from OPNA)</li>
     *    <li>wave shape select (from OPX,MAx,TSS)</li>
     *    <li>custom wave shape (from MAx)</li>
     *    <li>some more algolisms (from OPLx,OPX,MAx,DX7)</li>
     *    <li>decimal multiple (from p-TSS)</li>
     *    <li>feedback from op1-3 (from DX7)</li>
     *    <li>channel independet LFO (from TSS)</li>
     *    <li>low-pass filter envelop (from MAx)</li>
     *    <li>flexible fm connections (from TSS)</li>
     *    <li>ring modulation (from C64?)</li>
     *  </ul>
     *  </p>
     */
    public class SiOPMChannelFM extends SiOPMChannelBase
    {
    // valiables
    //--------------------------------------------------
        // Operators
        /** operators */        public var operator:Vector.<SiOPMOperator>;
        /** active operator */  public var activeOperator:SiOPMOperator;
        
        // Parameters
        /** count */        protected var _operatorCount:int;
        /** algorism */     protected var _algorism:int;
        
        // Processing
        /** process func */ protected var _funcProcessList:Array;
        
        // Pipe
        /** internal pipe0 */ protected var _pipe0:SLLint;
        /** internal pipe1 */ protected var _pipe1:SLLint;
        
        // modulation
        /** am depth */         protected var _am_depth:int;    // = chip.amd<<(ams-1)
        /** am output level */  protected var _am_out:int;
        /** pm depth */         protected var _pm_depth:int;    // = chip.pmd<<(pms-1)
        /** pm output level */  protected var _pm_out:int;
        
        // tone generator setting
        /** ENV_TIMER_INITIAL * freq_ratio */  protected var _eg_timer_initial:int;
        /** LFO_TIMER_INITIAL * freq_ratio */  protected var _lfo_timer_initial:int;
        
        /** note on flag */ protected var _isNoteOn:Boolean;
        
        
        
        
    // toString
    //--------------------------------------------------
        /** Output parameters. */
        public function toString() : String
        {
            var str:String = "SiOPMChannelFM : operatorCount=";
            str += String(_operatorCount) + "\n";
            $("fb ", _inputLevel-6);
            $2("vol", _volume[0],  "pan", _pan-64);
            if (operator[0]) str += String(operator[0]) + "\n";
            if (operator[1]) str += String(operator[1]) + "\n";
            if (operator[2]) str += String(operator[2]) + "\n";
            if (operator[3]) str += String(operator[3]) + "\n";
            return str;
            function $ (p:String, i:*) : void { str += "  " + p + "=" + String(i) + "\n"; }
            function $2(p:String, i:*, q:String, j:*) : void { str += "  " + p + "=" + String(i) + " / " + q + "=" + String(j) + "\n"; }
        }
        
        
        
        
    // constructor
    //--------------------------------------------------
        /** constructor */
        function SiOPMChannelFM(chip:SiOPMModule)
        {
            super(chip);
            
            _funcProcessList = [[_proc1op_loff, _proc2op, _proc3op, _proc4op, _procpcm_loff], 
                                [_proc1op_lon,  _proc2op, _proc3op, _proc4op, _procpcm_lon]];
            operator = new Vector.<SiOPMOperator>(4, true);
            operator[0] = _chip._allocFMOperator();
            operator[1] = null;
            operator[2] = null;
            operator[3] = null;
            activeOperator = operator[0];
            
            _operatorCount = 1;
            _funcProcess = _proc1op_loff;
            
            _pipe0 = SLLint.allocRing(1);
            _pipe1 = SLLint.allocRing(1);
            
            initialize(null, 0);
        }
        
        
        
        
    // Chip settings
    //--------------------------------------------------
        /** set chip "PSEUDO" frequency ratio by [%]. 100 means 3.56MHz. This value effects only for envelop and lfo speed. */
        override public function setFrequencyRatio(ratio:int) : void
        {
            _freq_ratio = ratio;
            var r:Number = (ratio!=0) ? (100/ratio) : 1;
            _eg_timer_initial  = int(SiOPMTable.ENV_TIMER_INITIAL * r);
            _lfo_timer_initial = int(SiOPMTable.LFO_TIMER_INITIAL * r);
        }
        
        
        
        
    // LFO settings
    //--------------------------------------------------
        /** initialize low frequency oscillator. and stop lfo
         *  @param waveform LFO waveform. 0=saw, 1=pulse, 2=triangle, 3=noise.
         */
        override public function initializeLFO(waveform:int) : void
        {
            super.initializeLFO(waveform);
            _lfoSwitch(false);
            _am_depth = 0;
            _pm_depth = 0;
            _am_out = 0;
            _pm_out = 0;
            if (operator[0]) operator[0].detune2 = 0;
            if (operator[1]) operator[1].detune2 = 0;
            if (operator[2]) operator[2].detune2 = 0;
            if (operator[3]) operator[3].detune2 = 0;
        }
        
        
        /** Amplitude modulation.
         *  @param depth depth = (ams) ? (amd << (ams-1)) : 0;
         */
        override public function setAmplitudeModulation(depth:int) : void
        {
            _am_depth = depth<<2;
            _am_out = (_lfo_waveTable[_lfo_phase] * _am_depth) >> 7 << 3;
            _lfoSwitch(_pm_depth > 0 || _am_depth > 0);
        }
        
        
        /** Pitch modulation.
         *  @param depth depth = (pms<6) ? (pmd >> (6-pms)) : (pmd << (pms-5));
         */
        override public function setPitchModulation(depth:int) : void
        {
            _pm_depth = depth;
            _pm_out = (((_lfo_waveTable[_lfo_phase]<<1)-255) * _pm_depth) >> 8;
            _lfoSwitch(_pm_depth > 0 || _am_depth > 0);
            if (_pm_depth == 0) {
                if (operator[0]) operator[0].detune2 = 0;
                if (operator[1]) operator[0].detune2 = 0;
                if (operator[2]) operator[0].detune2 = 0;
                if (operator[3]) operator[0].detune2 = 0;
            }
        }
        
        
        /** @private [protected] lfo on/off */
        protected function _lfoSwitch(sw:Boolean) : void
        {
            var new_lfo_on:int = int(sw);
            if (_lfo_on != new_lfo_on) {
                _lfo_on = new_lfo_on;
                if (operator[0]._pgType >= SiOPMTable.PG_PCM) _funcProcess = _funcProcessList[_lfo_on][4];
                else _funcProcess = _funcProcessList[_lfo_on][_operatorCount-1];
            }
        }
        
        
        
        
    // parameter setting
    //--------------------------------------------------
        /** Set by SiOPMChannelParam. 
         *  @param param SiOPMChannelParam.
         *  @param withVolume Set volume when its true.
         */
        override public function setSiOPMChannelParam(param:SiOPMChannelParam, withVolume:Boolean) : void
        {
            var i:int;
            if (param.opeCount == 0) return;
            
            if (withVolume) {
                var imax:int = SiOPMModule.STREAM_SIZE_MAX;
                for (i=0; i<imax; i++) _volume[i] = param.volumes[i];
                for (_hasEffectSend=false, i=1; i<imax; i++) if (_volume[i] > 0) _hasEffectSend = true;
                _pan = param.pan;
            }
            setFrequencyRatio(param.fratio);
            setAlgorism(param.opeCount, param.alg);
            setFeedBack(param.fb, param.fbc);
            initializeLFO(param.lfoWaveShape);
            _lfo_timer = (param.lfoFreqStep>0) ? 1 : 0;
            _lfo_timer_step = param.lfoFreqStep;
            setAmplitudeModulation(param.amd);
            setPitchModulation(param.pmd);
            setFilterEnvelop(param.far, param.fdr1, param.fdr2, param.frr, param.cutoff, param.fdc1, param.fdc2, param.fsc, param.frc);
            setFilterResonance(param.resonanse);
            activateFilter(param.cutoff<128 || param.resonanse>0 || param.far>0 || param.frr>0);
            for (i=0; i<_operatorCount; i++) {
                operator[i].setSiOPMOperatorParam(param.operatorParam[i]);
            }
        }
        
        
        /** Get SiOPMChannelParam.
         *  @param param SiOPMChannelParam.
         */
        override public function getSiOPMChannelParam(param:SiOPMChannelParam) : void
        {
            var i:int, imax:int = SiOPMModule.STREAM_SIZE_MAX;
            for (i=0; i<imax; i++) param.volumes[i] = _volume[i];
            param.pan = _pan;
            param.fratio = _freq_ratio;
            param.opeCount = _operatorCount;
            param.alg = _algorism;
            param.fb = 0;
            param.fbc = 0;
            for (i=0; i<_operatorCount; i++) {
                if (_inPipe == operator[i]._feedPipe) {
                    param.fb = _inputLevel - 6;
                    param.fbc = i;
                    break;
                }
            }
            param.lfoWaveShape = _lfo_waveShape;
            param.lfoFreqStep  = _lfo_timer_step;
            param.amd = _am_depth;
            param.pmd = _pm_depth;
            for (i=0; i<_operatorCount; i++) {
                operator[i].getSiOPMOperatorParam(param.operatorParam[i]);
            }
        }
        
        
        /** Set sound by 14 basic params. The value of int.MIN_VALUE means not to change.
         *  @param ar Attack rate [0-63].
         *  @param dr Decay rate [0-63].
         *  @param sr Sustain rate [0-63].
         *  @param rr Release rate [0-63].
         *  @param sl Sustain level [0-15].
         *  @param tl Total level [0-127].
         *  @param ksr Key scaling [0-3].
         *  @param ksl key scale level [0-3].
         *  @param mul Multiple [0-15].
         *  @param dt1 Detune 1 [0-7]. 
         *  @param detune Detune.
         *  @param ams Amplitude modulation shift [0-3].
         *  @param phase Phase [0-255].
         *  @param fixNote Fixed note number [0-127].
         */
        public function setSiOPMParameters(ar:int, dr:int, sr:int, rr:int, sl:int, tl:int, ksr:int, ksl:int, mul:int, dt1:int, detune:int, ams:int, phase:int, fixNote:int) : void
        {
            var ope:SiOPMOperator = activeOperator;
            if (ar      != int.MIN_VALUE) ope.ar  = ar;
            if (dr      != int.MIN_VALUE) ope.dr  = dr;
            if (sr      != int.MIN_VALUE) ope.sr  = sr;
            if (rr      != int.MIN_VALUE) ope.rr  = rr;
            if (sl      != int.MIN_VALUE) ope.sl  = sl;
            if (tl      != int.MIN_VALUE) ope.tl  = tl;
            if (ksr     != int.MIN_VALUE) ope.ks  = ksr;
            if (ksl     != int.MIN_VALUE) ope.ksl = ksl;
            if (mul     != int.MIN_VALUE) ope.mul = mul;
            if (dt1     != int.MIN_VALUE) ope.dt1 = dt1;
            if (detune  != int.MIN_VALUE) ope.detune = detune;
            if (ams     != int.MIN_VALUE) ope.ams = ams;
            if (phase   != int.MIN_VALUE) ope.keyOnPhase = phase;
            if (fixNote != int.MIN_VALUE) ope.fixedPitchIndex = fixNote<<6;
        }
        
        
        /** Set PCM data. 
         *  @param pcmData PCM data to set.
         */
        override public function setPCMData(pcmData:SiOPMPCMData) : void
        {
            _updateOperatorCount(1);
            activeOperator.setPCMData(pcmData);
            _funcProcess = _funcProcessList[_lfo_on][4];
        }
        
        
        
        
    // interfaces
    //--------------------------------------------------
        /** Set algorism (&#64;al) 
         *  @param cnt Operator count.
         *  @param alg Algolism number of the operator's connection.
         */
        override public function setAlgorism(cnt:int, alg:int) : void
        {
            _updateOperatorCount(cnt);
        
            _algorism = alg;
            switch (_operatorCount) {
            case 1: _algorism1();  break;
            case 2: _algorism2();  break;
            case 3: _algorism3();  break;
            case 4: _algorism4();  break;
            }
        }
        
        
        /** Set feedback(&#64;fb). This also initializes the input mode(&#64;i). 
         *  @param fb Feedback level. Ussualy in the range of 0-7.
         *  @param fbc Feedback connection. Operator index which feeds back its output.
         */
        override public function setFeedBack(fb:int, fbc:int) : void
        {
            if (fb > 0) {
                // connect feedback pipe
                if (fbc < 0 || fbc >= _operatorCount) fbc = 0;
                _inPipe = operator[fbc]._feedPipe;
                _inPipe.i = 0;
                _inputLevel = fb + 6;
                _inputMode = INPUT_FEEDBACK;
            } else {
                // no feedback
                _inPipe = _chip.zeroBuffer;
                _inputLevel = 0;
                _inputMode = INPUT_ZERO;
            }
            
        }
        
        
        /** Set parameters (&#64; command). */
        override public function setParameters(param:Vector.<int>) : void
        {
            setSiOPMParameters(param[1],  param[2],  param[3],  param[4],  param[5], 
                               param[6],  param[7],  param[8],  param[9],  param[10], 
                               param[11], param[12], param[13], param[14]);
        }
        
        
        /** pgType & ptType (&#64;) */
        override public function setType(pgType:int, ptType:int) : void
        {
            var funcIndex:int = _operatorCount-1;
            if (pgType >= SiOPMTable.PG_PCM) {
                _updateOperatorCount(1);
                funcIndex = 4;
            }
            activeOperator.pgType = pgType;
            activeOperator.ptType = ptType;
            _funcProcess = _funcProcessList[_lfo_on][funcIndex];
        }
        
        
        /** Attack rate */
        override public function setAllAttackRate(ar:int) : void 
        {
            var i:int, ope:SiOPMOperator;
            for (i=0; i<_operatorCount; i++) {
                ope = operator[i];
                if (ope._final) ope.ar = ar;
            }
        }
        
        
        /** Release rate (s) */
        override public function setAllReleaseRate(rr:int) : void 
        {
            var i:int, ope:SiOPMOperator;
            for (i=0; i<_operatorCount; i++) {
                ope = operator[i];
                if (ope._final) ope.rr = rr;
            }
        }
        
        
        
        
    // interfaces
    //--------------------------------------------------
        /** pitch = (note << 6) | (kf & 63) [0,8191] */
        override public function get pitch() : int { return operator[_operatorCount-1].pitchIndex; }
        override public function set pitch(p:int) : void {
            for (var i:int=0; i<_operatorCount; i++) {
                operator[i].pitchIndex = p;
            }
        }
        
        /** active operator index (i) */
        override public function set activeOperatorIndex(i:int) : void {
            var opeIndex:int = (i<0) ? 0 : (i>=_operatorCount) ? (_operatorCount-1) : i;
            activeOperator = operator[opeIndex];
        }
        
        /** release rate (&#64;rr) */
        override public function set rr(i:int) : void { activeOperator.rr = i; }
        
        /** total level (&#64;tl) */
        override public function set tl(i:int) : void { activeOperator.tl = i; }
        
        /** fine multiple (&#64;ml) */
        override public function set fmul(i:int) : void { activeOperator.fmul = i; }
        
        /** phase  (&#64;ph) */
        override public function set phase(i:int) : void { activeOperator.keyOnPhase = i; }
        
        /** detune (&#64;dt) */
        override public function set detune(i:int) : void { activeOperator.detune = i; }
        
        /** fixed pitch (&#64;fx) */
        override public function set fixedPitch(i:int) : void { activeOperator.fixedPitchIndex = i; }
        
        /** ssgec (&#64;se) */
        override public function set ssgec(i:int) : void { activeOperator.ssgec = i; }
        
        /** envelop reset (&#64;er) */
        override public function set erst(b:Boolean) : void { for (var i:int=0; i<_operatorCount; i++) { operator[i].erst = b; } }
        
        
        
    // volume controls
    //--------------------------------------------------
        /** update all tl offsets of final carriors */
        override public function offsetVolume(expression:int, velocity:int) : void
        {
            var i:int, ope:SiOPMOperator,
                tl:int = _table.eg_tlTable[expression] + _table.eg_tlTable[velocity];
            for (i=0; i<_operatorCount; i++) {
                ope = operator[i];
                if (ope._final) ope._tlOffset(tl);
            }
        }
        
        
        
        
    // operation
    //--------------------------------------------------
        /** Initialize. */
        override public function initialize(prev:SiOPMChannelBase, bufferIndex:int) : void
        {
            // initialize operators
            _updateOperatorCount(1);
            operator[0].initialize();
            _isNoteOn = false;
            
            // initialize sound channel
            super.initialize(prev, bufferIndex);
        }
        
        
        /** Reset. */
        override public function reset() : void
        {
            // reset all operators
            for (var i:int=0; i<_operatorCount; i++) {
                operator[i].reset();
            }
            _isNoteOn = false;
            _isIdling = true;
        }
        
        
        /** Note on. */
        override public function noteOn() : void
        {
            // operator note on
            for (var i:int=0; i<_operatorCount; i++) {
                operator[i].noteOn();
            }
            // reset lfo phase
            _lfo_phase = 0;
            // reset filter
            if (_filterOn) {
                resetLPFilterState();
                shiftLPFilterState(EG_ATTACK);
            }
            _isNoteOn = true;
            _isIdling = false;
        }
        
        
        /** Note off. */
        override public function noteOff() : void
        {
            // operator note off
            for (var i:int=0; i<_operatorCount; i++) {
                operator[i].noteOff();
            }
            // shift filters phase
            if (_filterOn) {
                shiftLPFilterState(EG_RELEASE);
            }
            _isNoteOn = false;
        }
        
        
        /** Check note on */
        override public function isNoteOn() : Boolean
        {
            return _isNoteOn;
        }
        
        
        /** Prepare buffering */
        override public function resetChannelBufferStatus() : void
        {
            _bufferIndex = 0;
            
            // check idling flag
            var i:int, ope:SiOPMOperator;
            _isIdling = true;
            for (i=0; i<_operatorCount; i++) {
                ope = operator[i];
                // SiOPMOperator.EG_OFF = 4
                if (ope._final && ope._eg_state != 4) _isIdling = false;
            }
        }
        
        
        
        
    //====================================================================================================
    // Internal uses
    //====================================================================================================
    // processing operator x1
    //--------------------------------------------------
        // without lfo_update()
        private function _proc1op_loff(len:int) : void
        {
            var t:int, l:int, i:int, n:Number;
            var ope:SiOPMOperator = operator[0],
                phase_filter:int = SiOPMTable.PHASE_FILTER;

            // buffering
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
            for (i=0; i<len; i++) {
                // eg_update();
                //----------------------------------------
                ope._eg_timer -= ope._eg_timer_step;
                if (ope._eg_timer < 0) {
                    if (ope._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope._eg_incTable[ope._eg_counter];
                        if (t > 0) {
                            ope._eg_level -= 1 + (ope._eg_level >> t);
                            if (ope._eg_level <= 0) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                        }
                    } else {
                        ope._eg_level += ope._eg_incTable[ope._eg_counter];
                        if (ope._eg_level >= ope._eg_stateShiftLevel) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                    }
                    ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                    ope._eg_counter = (ope._eg_counter+1)&7;
                    ope._eg_timer += _eg_timer_initial;
                }

                // pg_update();
                //----------------------------------------
                ope._phase += ope._phase_step;
                t = ((ope._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope._waveFixedBits;
                l = ope._waveTable[t];
                l += ope._eg_out;
                t = _table.logTable[l];
                ope._feedPipe.i = t;
                
                // output and increment pointers
                //----------------------------------------
                op.i = t + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
            }
            
            // update pointers
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        // with lfo_update()
        private function _proc1op_lon(len:int) : void
        {
            var t:int, l:int, i:int, n:Number;
            var ope:SiOPMOperator = operator[0],
                phase_filter:int = SiOPMTable.PHASE_FILTER;
            
            // buffering
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;

            for (i=0; i<len; i++) {
                // lfo_update();
                //----------------------------------------
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope.detune2 = _pm_out;
                    _lfo_timer += _lfo_timer_initial;
                }
                
                // eg_update();
                //----------------------------------------
                ope._eg_timer -= ope._eg_timer_step;
                if (ope._eg_timer < 0) {
                    if (ope._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope._eg_incTable[ope._eg_counter];
                        if (t > 0) {
                            ope._eg_level -= 1 + (ope._eg_level >> t);
                            if (ope._eg_level <= 0) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                        }
                    } else {
                        ope._eg_level += ope._eg_incTable[ope._eg_counter];
                        if (ope._eg_level >= ope._eg_stateShiftLevel) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                    }
                    ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                    ope._eg_counter = (ope._eg_counter+1)&7;
                    ope._eg_timer += _eg_timer_initial;
                }

                // pg_update();
                //----------------------------------------
                ope._phase += ope._phase_step;
                t = ((ope._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope._waveFixedBits;
                l = ope._waveTable[t];
                l += ope._eg_out + (_am_out>>ope._ams);
                t = _table.logTable[l];
                ope._feedPipe.i = t;
                
                // output and increment pointers
                //----------------------------------------
                op.i = t + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
            }
            
            // update pointers
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    // processing operator x2
    //--------------------------------------------------
        // This inline expansion makes execution faster.
        private function _proc2op(len:int) : void
        {
            var i:int, t:int, l:int, n:Number;
            var phase_filter:int = SiOPMTable.PHASE_FILTER,
                ope0:SiOPMOperator = operator[0],
                ope1:SiOPMOperator = operator[1];
            
            // buffering
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
            for (i=0; i<len; i++) {
                // clear pipes
                //----------------------------------------
                _pipe0.i = 0;

                // lfo
                //----------------------------------------
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope0.detune2 = _pm_out;
                    ope1.detune2 = _pm_out;
                    _lfo_timer += _lfo_timer_initial;
                }
                
                // operator[0]
                //----------------------------------------
                // eg_update();
                ope0._eg_timer -= ope0._eg_timer_step;
                if (ope0._eg_timer < 0) {
                    if (ope0._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope0._eg_incTable[ope0._eg_counter];
                        if (t > 0) {
                            ope0._eg_level -= 1 + (ope0._eg_level >> t);
                            if (ope0._eg_level <= 0) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                        }
                    } else {
                        ope0._eg_level += ope0._eg_incTable[ope0._eg_counter];
                        if (ope0._eg_level >= ope0._eg_stateShiftLevel) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                    }
                    ope0._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope0._eg_total_level)<<3;
                    ope0._eg_counter = (ope0._eg_counter+1)&7;
                    ope0._eg_timer += _eg_timer_initial;
                }
                // pg_update();
                ope0._phase += ope0._phase_step;
                t = ((ope0._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope0._waveFixedBits;
                l = ope0._waveTable[t];
                l += ope0._eg_out + (_am_out>>ope0._ams);
                t = _table.logTable[l];
                ope0._feedPipe.i = t;
                ope0._outPipe.i  = t + ope0._basePipe.i;

                // operator[1]
                //----------------------------------------
                // eg_update();
                ope1._eg_timer -= ope1._eg_timer_step;
                if (ope1._eg_timer < 0) {
                    if (ope1._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope1._eg_incTable[ope1._eg_counter];
                        if (t > 0) {
                            ope1._eg_level -= 1 + (ope1._eg_level >> t);
                            if (ope1._eg_level <= 0) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                        }
                    } else {
                        ope1._eg_level += ope1._eg_incTable[ope1._eg_counter];
                        if (ope1._eg_level >= ope1._eg_stateShiftLevel) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                    }
                    ope1._eg_out = (ope1._eg_levelTable[ope1._eg_level] + ope1._eg_total_level)<<3;
                    ope1._eg_counter = (ope1._eg_counter+1)&7;
                    ope1._eg_timer += _eg_timer_initial;
                }
                // pg_update();
                ope1._phase += ope1._phase_step;
                t = ((ope1._phase + (ope1._inPipe.i<<ope1._fmShift)) & phase_filter) >> ope1._waveFixedBits;
                l = ope1._waveTable[t];
                l += ope1._eg_out + (_am_out>>ope1._ams);
                t = _table.logTable[l];
                ope1._feedPipe.i = t;
                ope1._outPipe.i  = t + ope1._basePipe.i;

                // output and increment pointers
                //----------------------------------------
                op.i = _pipe0.i + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
            }
            
            // update pointers
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
                
        
        
    // processing operator x3
    //--------------------------------------------------
        // This inline expansion makes execution faster.
        private function _proc3op(len:int) : void
        {
            var i:int, t:int, l:int, n:Number;
            var phase_filter:int = SiOPMTable.PHASE_FILTER,
                ope0:SiOPMOperator = operator[0],
                ope1:SiOPMOperator = operator[1],
                ope2:SiOPMOperator = operator[2];
            
            // buffering
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
            for (i=0; i<len; i++) {
                // clear pipes
                //----------------------------------------
                _pipe0.i = 0;
                _pipe1.i = 0;

                // lfo
                //----------------------------------------
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope0.detune2 = _pm_out;
                    ope1.detune2 = _pm_out;
                    ope2.detune2 = _pm_out;
                    _lfo_timer += _lfo_timer_initial;
                }
                
                // operator[0]
                //----------------------------------------
                // eg_update();
                ope0._eg_timer -= ope0._eg_timer_step;
                if (ope0._eg_timer < 0) {
                    if (ope0._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope0._eg_incTable[ope0._eg_counter];
                        if (t > 0) {
                            ope0._eg_level -= 1 + (ope0._eg_level >> t);
                            if (ope0._eg_level <= 0) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                        }
                    } else {
                        ope0._eg_level += ope0._eg_incTable[ope0._eg_counter];
                        if (ope0._eg_level >= ope0._eg_stateShiftLevel) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                    }
                    ope0._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope0._eg_total_level)<<3;
                    ope0._eg_counter = (ope0._eg_counter+1)&7;
                    ope0._eg_timer += _eg_timer_initial;
                }
                // pg_update();
                ope0._phase += ope0._phase_step;
                t = ((ope0._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope0._waveFixedBits;
                l = ope0._waveTable[t];
                l += ope0._eg_out + (_am_out>>ope0._ams);
                t = _table.logTable[l];
                ope0._feedPipe.i = t;
                ope0._outPipe.i  = t + ope0._basePipe.i;

                // operator[1]
                //----------------------------------------
                // eg_update();
                ope1._eg_timer -= ope1._eg_timer_step;
                if (ope1._eg_timer < 0) {
                    if (ope1._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope1._eg_incTable[ope1._eg_counter];
                        if (t > 0) {
                            ope1._eg_level -= 1 + (ope1._eg_level >> t);
                            if (ope1._eg_level <= 0) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                        }
                    } else {
                        ope1._eg_level += ope1._eg_incTable[ope1._eg_counter];
                        if (ope1._eg_level >= ope1._eg_stateShiftLevel) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                    }
                    ope1._eg_out = (ope1._eg_levelTable[ope1._eg_level] + ope1._eg_total_level)<<3;
                    ope1._eg_counter = (ope1._eg_counter+1)&7;
                    ope1._eg_timer += _eg_timer_initial;
                }
                // pg_update();
                ope1._phase += ope1._phase_step;
                t = ((ope1._phase + (ope1._inPipe.i<<ope1._fmShift)) & phase_filter) >> ope1._waveFixedBits;
                l = ope1._waveTable[t];
                l += ope1._eg_out + (_am_out>>ope1._ams);
                t = _table.logTable[l];
                ope1._feedPipe.i = t;
                ope1._outPipe.i  = t + ope1._basePipe.i;

                // operator[2]
                //----------------------------------------
                // eg_update();
                ope2._eg_timer -= ope2._eg_timer_step;
                if (ope2._eg_timer < 0) {
                    if (ope2._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope2._eg_incTable[ope2._eg_counter];
                        if (t > 0) {
                            ope2._eg_level -= 1 + (ope2._eg_level >> t);
                            if (ope2._eg_level <= 0) ope2._eg_shiftState(ope2._eg_nextState[ope2._eg_state]);
                        }
                    } else {
                        ope2._eg_level += ope2._eg_incTable[ope2._eg_counter];
                        if (ope2._eg_level >= ope2._eg_stateShiftLevel) ope2._eg_shiftState(ope2._eg_nextState[ope2._eg_state]);
                    }
                    ope2._eg_out = (ope2._eg_levelTable[ope2._eg_level] + ope2._eg_total_level)<<3;
                    ope2._eg_counter = (ope2._eg_counter+1)&7;
                    ope2._eg_timer += _eg_timer_initial;
                }
                // pg_update();
                ope2._phase += ope2._phase_step;
                t = ((ope2._phase + (ope2._inPipe.i<<ope2._fmShift)) & phase_filter) >> ope2._waveFixedBits;
                l = ope2._waveTable[t];
                l += ope2._eg_out + (_am_out>>ope2._ams);
                t = _table.logTable[l];
                ope2._feedPipe.i = t;
                ope2._outPipe.i  = t + ope2._basePipe.i;

                // output and increment pointers
                //----------------------------------------
                op.i = _pipe0.i + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
            }
            
            // update pointers
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    // processing operator x4
    //--------------------------------------------------
        // This inline expansion makes execution faster.
        private function _proc4op(len:int) : void
        {
            var i:int, t:int, l:int, n:Number;
            var phase_filter:int = SiOPMTable.PHASE_FILTER,
                ope0:SiOPMOperator = operator[0],
                ope1:SiOPMOperator = operator[1],
                ope2:SiOPMOperator = operator[2],
                ope3:SiOPMOperator = operator[3];
            
            // buffering
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
            for (i=0; i<len; i++) {
                // clear pipes
                //----------------------------------------
                _pipe0.i = 0;
                _pipe1.i = 0;

                // lfo
                //----------------------------------------
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope0.detune2 = _pm_out;
                    ope1.detune2 = _pm_out;
                    ope2.detune2 = _pm_out;
                    ope3.detune2 = _pm_out;
                    _lfo_timer += _lfo_timer_initial;
                }
                
                // operator[0]
                //----------------------------------------
                // eg_update();
                ope0._eg_timer -= ope0._eg_timer_step;
                if (ope0._eg_timer < 0) {
                    if (ope0._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope0._eg_incTable[ope0._eg_counter];
                        if (t > 0) {
                            ope0._eg_level -= 1 + (ope0._eg_level >> t);
                            if (ope0._eg_level <= 0) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                        }
                    } else {
                        ope0._eg_level += ope0._eg_incTable[ope0._eg_counter];
                        if (ope0._eg_level >= ope0._eg_stateShiftLevel) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                    }
                    ope0._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope0._eg_total_level)<<3;
                    ope0._eg_counter = (ope0._eg_counter+1)&7;
                    ope0._eg_timer += _eg_timer_initial;
                }
                // pg_update();
                ope0._phase += ope0._phase_step;
                t = ((ope0._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope0._waveFixedBits;
                l = ope0._waveTable[t];
                l += ope0._eg_out + (_am_out>>ope0._ams);
                t = _table.logTable[l];
                ope0._feedPipe.i = t;
                ope0._outPipe.i  = t + ope0._basePipe.i;

                // operator[1]
                //----------------------------------------
                // eg_update();
                ope1._eg_timer -= ope1._eg_timer_step;
                if (ope1._eg_timer < 0) {
                    if (ope1._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope1._eg_incTable[ope1._eg_counter];
                        if (t > 0) {
                            ope1._eg_level -= 1 + (ope1._eg_level >> t);
                            if (ope1._eg_level <= 0) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                        }
                    } else {
                        ope1._eg_level += ope1._eg_incTable[ope1._eg_counter];
                        if (ope1._eg_level >= ope1._eg_stateShiftLevel) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                    }
                    ope1._eg_out = (ope1._eg_levelTable[ope1._eg_level] + ope1._eg_total_level)<<3;
                    ope1._eg_counter = (ope1._eg_counter+1)&7;
                    ope1._eg_timer += _eg_timer_initial;
                }
                // pg_update();
                ope1._phase += ope1._phase_step;
                t = ((ope1._phase + (ope1._inPipe.i<<ope1._fmShift)) & phase_filter) >> ope1._waveFixedBits;
                l = ope1._waveTable[t];
                l += ope1._eg_out + (_am_out>>ope1._ams);
                t = _table.logTable[l];
                ope1._feedPipe.i = t;
                ope1._outPipe.i  = t + ope1._basePipe.i;

                // operator[2]
                //----------------------------------------
                // eg_update();
                ope2._eg_timer -= ope2._eg_timer_step;
                if (ope2._eg_timer < 0) {
                    if (ope2._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope2._eg_incTable[ope2._eg_counter];
                        if (t > 0) {
                            ope2._eg_level -= 1 + (ope2._eg_level >> t);
                            if (ope2._eg_level <= 0) ope2._eg_shiftState(ope2._eg_nextState[ope2._eg_state]);
                        }
                    } else {
                        ope2._eg_level += ope2._eg_incTable[ope2._eg_counter];
                        if (ope2._eg_level >= ope2._eg_stateShiftLevel) ope2._eg_shiftState(ope2._eg_nextState[ope2._eg_state]);
                    }
                    ope2._eg_out = (ope2._eg_levelTable[ope2._eg_level] + ope2._eg_total_level)<<3;
                    ope2._eg_counter = (ope2._eg_counter+1)&7;
                    ope2._eg_timer += _eg_timer_initial;
                }
                // pg_update();
                ope2._phase += ope2._phase_step;
                t = ((ope2._phase + (ope2._inPipe.i<<ope2._fmShift)) & phase_filter) >> ope2._waveFixedBits;
                l = ope2._waveTable[t];
                l += ope2._eg_out + (_am_out>>ope2._ams);
                t = _table.logTable[l];
                ope2._feedPipe.i = t;
                ope2._outPipe.i  = t + ope2._basePipe.i;
                
                // operator[3]
                //----------------------------------------
                // eg_update();
                ope3._eg_timer -= ope3._eg_timer_step;
                if (ope3._eg_timer < 0) {
                    if (ope3._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope3._eg_incTable[ope3._eg_counter];
                        if (t > 0) {
                            ope3._eg_level -= 1 + (ope3._eg_level >> t);
                            if (ope3._eg_level <= 0) ope3._eg_shiftState(ope3._eg_nextState[ope3._eg_state]);
                        }
                    } else {
                        ope3._eg_level += ope3._eg_incTable[ope3._eg_counter];
                        if (ope3._eg_level >= ope3._eg_stateShiftLevel) ope3._eg_shiftState(ope3._eg_nextState[ope3._eg_state]);
                    }
                    ope3._eg_out = (ope3._eg_levelTable[ope3._eg_level] + ope3._eg_total_level)<<3;
                    ope3._eg_counter = (ope3._eg_counter+1)&7;
                    ope3._eg_timer += _eg_timer_initial;
                }
                // pg_update();
                ope3._phase += ope3._phase_step;
                t = ((ope3._phase + (ope3._inPipe.i<<ope3._fmShift)) & phase_filter) >> ope3._waveFixedBits;
                l = ope3._waveTable[t];
                l += ope3._eg_out + (_am_out>>ope3._ams);
                t = _table.logTable[l];
                ope3._feedPipe.i = t;
                ope3._outPipe.i  = t + ope3._basePipe.i;

                // output and increment pointers
                //----------------------------------------
                op.i = _pipe0.i + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
            }
            
            // update pointers
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    // processing PCM
    //--------------------------------------------------
        private function _procpcm_loff(len:int) : void
        {
            var t:int, l:int, i:int, n:Number;
            var ope:SiOPMOperator = operator[0],
                phase_filter:int = SiOPMTable.PHASE_FILTER;
            
            
            // buffering
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
            for (i=0; i<len; i++) {
                // eg_update();
                //----------------------------------------
                ope._eg_timer -= ope._eg_timer_step;
                if (ope._eg_timer < 0) {
                    if (ope._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope._eg_incTable[ope._eg_counter];
                        if (t > 0) {
                            ope._eg_level -= 1 + (ope._eg_level >> t);
                            if (ope._eg_level <= 0) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                        }
                    } else {
                        ope._eg_level += ope._eg_incTable[ope._eg_counter];
                        if (ope._eg_level >= ope._eg_stateShiftLevel) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                    }
                    ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                    ope._eg_counter = (ope._eg_counter+1)&7;
                    ope._eg_timer += _eg_timer_initial;
                }

                // pg_update();
                //----------------------------------------
                ope._phase += ope._phase_step;
                t = (ope._phase + (ip.i<<_inputLevel)) >>> ope._waveFixedBits;
                if (t >= ope._pcm_endPoint) {
                    if (ope._pcm_loopPoint == -1) {
                        ope._eg_shiftState(SiOPMOperator.EG_OFF);
                        ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                        for (;i<len; i++) {
                            op.i = bp.i;
                            ip = ip.next;
                            bp = bp.next;
                            op = op.next;
                        }
                        break;
                    } else {
                        t -=  ope._pcm_endPoint - ope._pcm_loopPoint;
                        ope._phase -= (ope._pcm_endPoint - ope._pcm_loopPoint) << ope._waveFixedBits;
                    }
                }
                l = ope._waveTable[t];
                l += ope._eg_out;
                t = _table.logTable[l];
                ope._feedPipe.i = t;
                
                // output and increment pointers
                //----------------------------------------
                op.i = t + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
            }
            
            // update pointers
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        private function _procpcm_lon(len:int) : void
        {
            var t:int, l:int, i:int, n:Number;
            var ope:SiOPMOperator = operator[0],
                phase_filter:int = SiOPMTable.PHASE_FILTER;
            
            // buffering
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;

            for (i=0; i<len; i++) {
                // lfo_update();
                //----------------------------------------
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope.detune2 = _pm_out;
                    _lfo_timer += _lfo_timer_initial;
                }
                
                // eg_update();
                //----------------------------------------
                ope._eg_timer -= ope._eg_timer_step;
                if (ope._eg_timer < 0) {
                    if (ope._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope._eg_incTable[ope._eg_counter];
                        if (t > 0) {
                            ope._eg_level -= 1 + (ope._eg_level >> t);
                            if (ope._eg_level <= 0) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                        }
                    } else {
                        ope._eg_level += ope._eg_incTable[ope._eg_counter];
                        if (ope._eg_level >= ope._eg_stateShiftLevel) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                    }
                    ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                    ope._eg_counter = (ope._eg_counter+1)&7;
                    ope._eg_timer += _eg_timer_initial;
                }

                // pg_update();
                //----------------------------------------
                ope._phase += ope._phase_step;
                t = (ope._phase + (ip.i<<_inputLevel)) >>> ope._waveFixedBits;
                if (t >= ope._pcm_endPoint) {
                    if (ope._pcm_loopPoint == -1) {
                        ope._eg_shiftState(SiOPMOperator.EG_OFF);
                        ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                        for (;i<len; i++) {
                            op.i = bp.i;
                            ip = ip.next;
                            bp = bp.next;
                            op = op.next;
                        }
                        break;
                    } else {
                        t -=  ope._pcm_endPoint - ope._pcm_loopPoint;
                        ope._phase -= (ope._pcm_endPoint - ope._pcm_loopPoint) << ope._waveFixedBits;
                    }
                }
                l = ope._waveTable[t];
                l += ope._eg_out + (_am_out>>ope._ams);
                t = _table.logTable[l];
                ope._feedPipe.i = t;
                
                // output and increment pointers
                //----------------------------------------
                op.i = t + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
            }
            
            // update pointers
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    // internal operations
    //--------------------------------------------------
        /** Update LFO. This code is only for testing. */
        internal function lfo_update() : void
        {
            _lfo_timer -= _lfo_timer_step;
            if (_lfo_timer < 0) {
                _lfo_phase = (_lfo_phase+1) & 255;
                _am_out = (_lfo_waveTable[_lfo_phase] * _am_depth) >> 7 << 3;
                _pm_out = (((_lfo_waveTable[_lfo_phase]<<1)-255) * _pm_depth) >> 8;
                if (operator[0]) operator[0].detune2 = _pm_out;
                if (operator[1]) operator[1].detune2 = _pm_out;
                if (operator[2]) operator[2].detune2 = _pm_out;
                if (operator[3]) operator[3].detune2 = _pm_out;
                _lfo_timer += _lfo_timer_initial;
            }
        }
        
        
        // update operator count.
        private function _updateOperatorCount(cnt:int) : void
        {
            var i:int;
            
            // limit operator count
            cnt = (cnt<4) ? ((cnt>0) ? cnt : 1) : 4;

            // change operator instances
            if (_operatorCount < cnt) {
                // allocate and initialize new operators
                for (i=_operatorCount; i<cnt; i++) {
                    operator[i] = _chip._allocFMOperator();
                    operator[i].initialize();
                }
            } else 
            if (_operatorCount > cnt) {
                // free old operators
                for (i=cnt; i<_operatorCount; i++) {
                    _chip._freeFMOperator(operator[i]);
                    operator[i] = null;
                }
            } 
            
            // update count
            _operatorCount = cnt;
            // select processing function
            _funcProcess = _funcProcessList[_lfo_on][_operatorCount-1];
            
            // default active operator is the last one.
            activeOperator = operator[_operatorCount-1];

            // reset feed back
            if (_inputMode == INPUT_FEEDBACK) {
                setFeedBack(0, 0);
            }
        }
        
        
        // alg operator=1
        private function _algorism1() : void
        {
            operator[0]._setPipes(_pipe0, null, true);
        }
        
        
        // alg operator=2
        private function _algorism2() : void
        {
            switch(_algorism) {
            case 0: // OPL3/MA3:con=0, OPX:con=0, 1(fbc=1)
                // o1(o0)
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                break;
            case 1: // OPL3/MA3:con=1, OPX:con=2
                // o0+o1
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                break;
            case 2: // OPX:con=3
                // o0+o1(o0)
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[1]._basePipe = _pipe0;
                break;
            default:
                // o0+o1
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                break;
            }
        }
        
        
        // alg operator=3
        private function _algorism3() : void
        {
            switch(_algorism) {
            case 0: // OPX:con=0, 1(fbc=1)
                // o2(o1(o0))
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0);
                operator[2]._setPipes(_pipe0, _pipe0, true);
                break;
            case 1: // OPX:con=2
                // o2(o0+o1)
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0);
                operator[2]._setPipes(_pipe0, _pipe0, true);
                break;
            case 2: // OPX:con=3
                // o0+o2(o1)
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe0, _pipe1, true);
                break;
            case 3: // OPX:con=4, 5(fbc=1)
                // o1(o0)+o2
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[2]._setPipes(_pipe0, null,   true);
                break;
            case 4:
                // o1(o0)+o2(o0)
                operator[0]._setPipes(_pipe1);
                operator[1]._setPipes(_pipe0, _pipe1, true);
                operator[2]._setPipes(_pipe0, _pipe1, true);
                break;
            case 5: // OPX:con=6
                // o0+o1+o2
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                operator[2]._setPipes(_pipe0, null, true);
                break;
            case 6: // OPX:con=7
                // o0+o1(o0)+o2
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[1]._basePipe = _pipe0;
                operator[2]._setPipes(_pipe0, null,   true);
                break;
            default:
                // o0+o1+o2
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                operator[2]._setPipes(_pipe0, null, true);
                break;
            }
        }
        
        
        // alg operator=4
        private function _algorism4() : void
        {
            switch(_algorism) {
            case 0: // OPL3:con=0, MA3:con=4, OPX:con=0, 1(fbc=1)
                // o3(o2(o1(o0)))
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0);
                operator[2]._setPipes(_pipe0, _pipe0);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                break;
            case 1: // OPX:con=2
                // o3(o2(o0+o1))
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0);
                operator[2]._setPipes(_pipe0, _pipe0);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                break;
            case 2: // MA3:con=3, OPX:con=3
                // o3(o0+o2(o1))
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe0, _pipe1);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                break;
            case 3: // OPX:con=4, 5(fbc=1)
                // o3(o1(o0)+o2)
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0);
                operator[2]._setPipes(_pipe0);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                break;
            case 4: // OPL3:con=1, MA3:con=5, OPX:con=6, 7(fbc=1)
                // o1(o0)+o3(o2)
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[2]._setPipes(_pipe1);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                break;
            case 5: // OPX:con=12
                // o1(o0)+o2(o0)+o3(o0)
                operator[0]._setPipes(_pipe1);
                operator[1]._setPipes(_pipe0, _pipe1, true);
                operator[2]._setPipes(_pipe0, _pipe1, true);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                break;
            case 6: // OPX:con=10, 11(fbc=1)
                // o1(o0)+o2+o3
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[2]._setPipes(_pipe0, null,   true);
                operator[3]._setPipes(_pipe0, null,   true);
                break;
            case 7: // MA3:con=2, OPX:con=15
                // o0+o1+o2+o3
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                operator[2]._setPipes(_pipe0, null, true);
                operator[3]._setPipes(_pipe0, null, true);
                break;
            case 8: // OPL3:con=2, MA3:con=6, OPX:con=8
                // o0+o3(o2(o1))
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe1, _pipe1);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                break;
            case 9: // OPL3:con=3, MA3:con=7, OPX:con=13
                // o0+o2(o1)+o3
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe0, _pipe1, true);
                operator[3]._setPipes(_pipe0, null,   true);
                break;
            case 10: // for DX7 emulation
                // o3(o0+o1+o2)
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0);
                operator[2]._setPipes(_pipe0);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                break;
            case 11: // OPX:con=9
                // o0+o3(o1+o2)
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe1);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                break;
            case 12: // OPX:con=14
                // o0+o1(o0)+o3(o2)
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[1]._basePipe = _pipe0;
                operator[2]._setPipes(_pipe1);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                break;
            default:
                // o0+o1+o2+o3
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                operator[2]._setPipes(_pipe0, null, true);
                operator[3]._setPipes(_pipe0, null, true);
                break;
            }
        }
    }
}

