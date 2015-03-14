//----------------------------------------------------------------------------------------------------
// SiON Effect Module
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector {
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.SiOPMStream;
    import org.si.sion.namespaces._sion_internal;
    
    
    /** Effect Module. */
    public class SiEffectModule
    {
    // valiables
    //--------------------------------------------------------------------------------
        private var _module:SiOPMModule;
        private var _effectConnectors:Vector.<SiEffectConnector>;
        private var _slotCount:int;
        static private var _effectorInstances:* = {};
        
        
        
        
    // constructor
    //--------------------------------------------------------------------------------
        /** Constructor. */
        function SiEffectModule(module:SiOPMModule) 
        {
            _module = module;
            _effectConnectors = new Vector.<SiEffectConnector>(SiOPMModule.STREAM_SIZE_MAX);
            for (var i:int=0; i<SiOPMModule.STREAM_SIZE_MAX; i++) {
                _effectConnectors[i] = new SiEffectConnector();
            }
            _slotCount = 1;

            // initialize table
            SiEffectTable.initialize();
            
            // register default effectors
            register("ws",      SiEffectWaveShaper);
            register("eq",      SiEffectEqualiser);
            register("delay",   SiEffectStereoDelay);
            register("reverb",  SiEffectStereoReverb);
            register("chorus",  SiEffectStereoChorus);
            register("autopan", SiEffectAutoPan);
            register("ds",      SiEffectDownSampler);
            register("speaker", SiEffectSpeakerSimulator);
            register("comp",    SiEffectCompressor); // bugful!!
            
            register("lf", SiFilterLowPass);
            register("hf", SiFilterHighPass);
            register("bf", SiFilterBandPass);
            register("nf", SiFilterNotch);
            register("pf", SiFilterPeak);
            register("af", SiFilterAllPass);
            
            register("nlf", SiCtrlFilterLowPass);
            register("nhf", SiCtrlFilterHighPass);
        }
        
        
        
        
    // operations
    //--------------------------------------------------------------------------------
        /** Initialize all effectors. This function is called from SiONDriver.play() with the 2nd argment true. 
         *  When you want to connect effectors by code, you have to call this first, then call connect() and SiONDriver.play() with the 2nd argment false.
         */
        public function initialize() : void
        {
            for (var slot:int=0; slot<SiOPMModule.STREAM_SIZE_MAX; slot++) {
                _effectConnectors[slot].clear();
            }
        }
        
        
        /** @private [sion internal] prepare for processing. */
        _sion_internal function _prepareProcess() : void
        {
            var i:int, slot:int;
            
            // preparetion for all effectors
            _slotCount = 1;
            for (slot=0; slot<SiOPMModule.STREAM_SIZE_MAX; slot++) {
                if (_effectConnectors[slot].prepareProcess() > 0) _slotCount = slot+1;
            }
            
            // set modules number of streams and channels
            _module.streamCount = _slotCount;
            for (slot=1; slot<_slotCount; slot++) {
                _module.streamBuffer[slot].channels = _effectConnectors[slot].requestChannels;
            }
        }
        
        
        /** @private [sion internal] processing. */
        _sion_internal function _process() : void
        {
            var i:int, slot:int, buffer:Vector.<Number>, ec:SiEffectConnector,
                bufferLength:int = _module.bufferLength,
                output:Vector.<Number> = _module.output,
                imax:int = output.length;
            // effect
            for (slot=1; slot<_slotCount; slot++) {
                ec = _effectConnectors[slot];
                if (ec.isActive) {
                    buffer = _module.streamBuffer[slot].buffer;
                    ec.process(_module.streamBuffer[slot].channels, buffer, 0, bufferLength);
                    for (i=0; i<imax; i++) output[i] += buffer[i];
                }
            }
            // master effect
            ec = _effectConnectors[0];
            if (ec.isActive) ec.process(_module.channelCount, output, 0, bufferLength);
        }
        
        
        
        
    // effector instance manager
    //--------------------------------------------------------------------------------
        /** Register effector class
         *  @param name Effector name.
         *  @param cls SiEffectBase based class.
         */
        static public function register(name:String, cls:Class) : void
        {
            _effectorInstances[name] = new EffectorInstances(cls);
        }
        
        
        /** Get effector instance by name 
         *  @param name Effector name in mml.
         */
        static public function getInstance(name:String) : SiEffectBase
        {
            if (!(name in _effectorInstances)) return null;
            
            var effect:SiEffectBase, 
                factory:EffectorInstances = _effectorInstances[name];
            for each (effect in factory._instances) {
                if (effect._isFree) {
                    effect._isFree = false;
                    effect.initialize();
                    return effect;
                }
            }
            effect = new factory._classInstance();
            factory._instances.push(effect);
            
            effect._isFree = false;
            effect.initialize();
            return effect;
        }
        
        
        
        
    // effector connection
    //--------------------------------------------------------------------------------
        /** Clear effector slot. 
         *  @param slot Effector slot number.
         */
        public function clear(slot:int) : void
        {
            _effectConnectors[slot].clear();
        }
        
        
        /** Connect effector to the slot.
         *  @param slot Effector slot number.
         *  @param effector Effector instance.
         */
        public function connect(slot:int, effector:SiEffectBase) : void
        {
            _effectConnectors[slot].connect(effector);
        }
        
        
        /** Parse MML for effector 
         *  @param slot Effector slot number.
         *  @param mml MML string.
         *  @param postfix Postfix string.
         */
        public function parseMML(slot:int, mml:String, postfix:String) : void
        {
            _effectConnectors[slot].parseMML(mml, postfix);
        }
        

        /** Get connected effector
         *  @param slot Effector slot number.
         *  @param index The index of connected effector.
         *  @return Effector instance.
         */
        public function getEffector(slot:int, index:int) : SiEffectBase 
        {
            return _effectConnectors[slot].getEffector(index);
        }
    }
}




import org.si.sion.effector.SiEffectBase;
// effector instance manager
class EffectorInstances
{
    public var _instances:Array = [];
    public var _classInstance:Class;
    
    function EffectorInstances(cls:Class)
    {
        _classInstance = cls;
    }
}


