//----------------------------------------------------------------------------------------------------
// SiOPM Sampler pad channel.
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module {
    import org.si.utils.SLLNumber;
    import org.si.utils.SLLint;
    
    
    /** Sampler pad channel. */
    public class SiOPMChannelSampler extends SiOPMChannelBase
    {
    // valiables
    //--------------------------------------------------
        /** note on flag */  protected var _isNoteOn:Boolean;
        
        /** bank number */   protected var _bankNumber:int;
        /** wave number */   protected var _waveNumber:int;
        /** one shot flag */ protected var _isOneShot:Boolean;
        
        /** expression */    protected var _expression:Number;
        
        /** sample data */   protected var _sample:Vector.<Number>;
        /** sample length */ protected var _sampleLength:int;
        /** sample index */  protected var _sampleIndex:int;
        /** phase reset */   protected var _sampleStartPhase:int;
        /** channel count */ protected var _sampleChannelCount:int;
        
        
        
        
    // toString
    //--------------------------------------------------
        /** Output parameters. */
        public function toString() : String
        {
            var str:String = "SiOPMChannelSampler : ";
            $2("vol", _volume[0]*_expression,  "pan", _pan-64);
            return str;
            function $2(p:String, i:*, q:String, j:*) : void { str += "  " + p + "=" + String(i) + " / " + q + "=" + String(j) + "\n"; }
        }
        
        
        
        
    // constructor
    //--------------------------------------------------
        /** constructor */
        function SiOPMChannelSampler(chip:SiOPMModule)
        {
            super(chip);
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
        }
        
        
        /** Get SiOPMChannelParam.
         *  @param param SiOPMChannelParam.
         */
        override public function getSiOPMChannelParam(param:SiOPMChannelParam) : void
        {
            var i:int, imax:int = SiOPMModule.STREAM_SIZE_MAX;
            for (i=0; i<imax; i++) param.volumes[i] = _volume[i];
            param.pan = _pan;
        }
        
        
        
        
    // interfaces
    //--------------------------------------------------
        /** Set algorism (&#64;al) 
         *  @param cnt Operator count.
         *  @param alg Algolism number of the operator's connection.
         */
        override public function setAlgorism(cnt:int, alg:int) : void
        {
        }
        
        
        /** pgType & ptType (&#64; call from SiMMLChannelSetting.selectTone()/initializeTone()) */
        override public function setType(pgType:int, ptType:int) : void 
        {
            _bankNumber = pgType & 3;
        }
        
        
        
        
    // interfaces
    //--------------------------------------------------
        /** pitch = (note << 6) | (kf & 63) [0,8191] */
        override public function get pitch() : int { return _waveNumber<<6; }
        override public function set pitch(p:int) : void {
            _waveNumber = p >> 6;
        }
        
        
        
        
    // volume controls
    //--------------------------------------------------
        /** update all tl offsets of final carriors */
        override public function offsetVolume(expression:int, velocity:int) : void {
            _expression = expression * velocity * 0.00006103515625; // 1/16384
        }
        
        /** phase (&#64;ph) */
        override public function set phase(i:int) : void {
            _sampleStartPhase = i;
        }
        
        
        
        
    // operation
    //--------------------------------------------------
        /** Initialize. */
        override public function initialize(prev:SiOPMChannelBase, bufferIndex:int) : void
        {
            _isNoteOn = false;
            _bankNumber = 0;
            _waveNumber = -1;
            _isOneShot = false;
            _sample = null;
            _sampleLength = 0;
            _sampleIndex = 0;
            _sampleStartPhase = 0;
            _sampleChannelCount = 1;
            _expression = 0.5;
            super.initialize(prev, bufferIndex);
        }
        
        
        /** Reset. */
        override public function reset() : void
        {
            _isNoteOn = false;
            _isIdling = true;
            _bankNumber = 0;
            _waveNumber = -1;
            _isOneShot = false;
            _sample = null;
            _sampleLength = 0;
            _sampleIndex = 0;
            _sampleStartPhase = 0;
            _sampleChannelCount = 1;
            _expression = 0.5;
        }
        
        
        /** Note on. */
        override public function noteOn() : void
        {
            if (_waveNumber >= 0) {
                _isNoteOn = true;
                _isIdling = false;
                var idx:int = _waveNumber + (_bankNumber<<7),
                    data:SiOPMSamplerData = _table.getSamplerData(idx);
                if (data) {
                    _sample = data.waveData;
                    _isOneShot = data.isOneShot;
                    _sampleChannelCount = data.channelCount;
                    _sampleLength = _sample.length >> (_sampleChannelCount-1);
                    if (_sampleStartPhase!=255) _sampleIndex = _sampleLength * _sampleStartPhase * 0.00390625; // 1/256
                }
            }
        }
        
        
        /** Note off. */
        override public function noteOff() : void
        {
            if (!_isOneShot) {
                _isNoteOn = false;
                _isIdling = true;
                _sample = null;
                _sampleLength = 0;
            }
        }
        
        
        /** Check note on */
        override public function isNoteOn() : Boolean
        {
            return _isNoteOn;
        }
        
        
        /** Buffering */
        override public function buffer(len:int) : void
        {
            var i:int, imax:int, vol:Number;
            if (_isIdling || _sample == null || _mute) {
                //_nop(len);
            } else {
                var residureLen:int = _sampleLength - _sampleIndex,
                    procLen:int = (len < residureLen) ? len : residureLen;
                if (_hasEffectSend) {
                    imax = _chip.streamBuffer.length;
                    for (i=0; i<imax; i++) {
                        vol = _volume[i] * _expression;
                        if (vol > 0) _chip.streamBuffer[i].writeVectorNumber(_sample, _sampleIndex, _bufferIndex, procLen, vol, _pan, _sampleChannelCount);
                    }
                } else {
                    vol = _volume[0] * _expression;
                    _chip.streamBuffer[0].writeVectorNumber(_sample, _sampleIndex, _bufferIndex, procLen, vol, _pan, _sampleChannelCount);
                }
                if (procLen < len) {
                    _isIdling = true;
                    _sample = null;
                    //_nop(len - procLen);
                }
            }
            
            // update buffer index
            _bufferIndex += len;
            _sampleIndex += len;
        }
        
        
        /** Buffering without processnig */
        override public function nop(len:int) : void
        {
            //_nop(len);
            _bufferIndex += len;
        }
    }
}

