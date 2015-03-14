//----------------------------------------------------------------------------------------------------
// SiON Effect connector
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector {
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.SiOPMStream;
    
    
    /** Effect connector. */
    public class SiEffectConnector
    {
    // valiables
    //--------------------------------------------------------------------------------
        private var _requestChannels:int = 0;
        private var _chain:Vector.<SiEffectBase> = new Vector.<SiEffectBase>();
        
        /** Is active ? */
	    public function get isActive() : Boolean { return (_chain.length > 0); }
        
        
        
        
    // properties
    //----------------------------------------
        /** Request channel count. */
        public function get requestChannels() : int { return _requestChannels; }
        
        
        
    // constructor
    //--------------------------------------------------------------------------------
        /** Constructor. */
        function SiEffectConnector() 
        {
        }
        
        
        
        
    // operations
    //--------------------------------------------------------------------------------
        /** @parivate [internal use] prepare for processing. returns requestChannels. */
        internal function prepareProcess() : int
        {
            _requestChannels = 0;
            if (_chain.length == 0) return 0;
            _requestChannels = _chain[0].prepareProcess();
            for (var i:int=1; i<_chain.length; i++) _chain[i].prepareProcess();
            return _requestChannels;
        }
        
        
        /** processing. */
        public function process(channels:int, buffer:Vector.<Number>, startIndex:int, length:int) : void
        {
            for each (var e:SiEffectBase in _chain) {
                channels = e.process(channels, buffer, startIndex, length);
            }
        }
        
        
        
        
    // effector connection
    //--------------------------------------------------------------------------------
        /** Clear effector chain. */
        public function clear() : void
        {
            for each (var e:SiEffectBase in _chain) e._isFree = true;
            _chain.length = 0;
        }
        
        
        /** Connect effector at tail.
         *  @param effector Effector instance.
         */
        public function connect(effector:SiEffectBase) : void
        {
            _chain.push(effector);
        }
        
        
        /** Parse MML for effector 
         *  @param mml MML string.
         *  @param postfix Postfix string.
         */
        public function parseMML(mml:String, postfix:String) : void
        {
            var res:*, rex:RegExp = /([a-zA-Z_]+|,)\s*([.\-\d]+)?/g, i:int,
                cmd:String = "", argc:int = 0, args:Vector.<Number> = new Vector.<Number>(16, true);
            
            // clear
            clear();
            _clearArgs();
            
            // parse mml
            res = rex.exec(mml);
            while (res) {
                if (res[1] == ",") {
                    args[argc++] = Number(res[2]);
                } else {
                    _connectEffect();
                    cmd = res[1];
                    _clearArgs();
                    args[0] = Number(res[2]);
                    argc = 1;
                }
                res = rex.exec(mml);
            }
            _connectEffect();
            
            // connect new effector
            function _connectEffect() : void {
                if (argc == 0) return;
                var e:SiEffectBase = SiEffectModule.getInstance(cmd);
                if (e) {
                    e.mmlCallback(args);
                    connect(e);
                }
            }
            
            // clear arguments
            function _clearArgs() : void {
                for (var i:int=0; i<16; i++) args[i]=Number.NaN;
            }
        }
        

        /** Get connected effector
         *  @param slot Effector slot number.
         *  @param index The index of connected effector.
         *  @return Effector instance.
         */
        public function getEffector(index:int) : SiEffectBase 
        {
            return (index < _chain.length) ? _chain[index] : null;
        }
    }
}

