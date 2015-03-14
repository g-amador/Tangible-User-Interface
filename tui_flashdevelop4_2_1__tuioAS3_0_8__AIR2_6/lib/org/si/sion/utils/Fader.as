//----------------------------------------------------------------------------------------------------
// Fader class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.utils {
    /** Fader class. */
    public class Fader
    {
    // valiables
    //--------------------------------------------------
        // end value
        private var _end:Number = 0;
        // increment step
        private var _step:Number = 0;
        // counter
        private var _counter:int = 0;
        // value
        private var _value:Number = 0;
        // callback function
        private var _callback:Function = null;
        
        
        
        
    // properties
    //--------------------------------------------------
        /** is active. */
        public function get isActive() : Boolean { return (_counter>0); }
        /** is incrementation, */
        public function get isIncrement() : Boolean { return (_step > 0); }
        /** controling value. */
        public function get value() : Number { return _value; }
        
        
        
        
    // constructor
    //--------------------------------------------------
        /** constructor.
         *  @param valueFrom The starting value.
         *  @param valueTo The value chaging to.
         *  @param term Changing term.
         */
        function Fader(callback:Function=null, valueFrom:Number=0, valueTo:Number=1, term:int=60)
        {
            if (callback != null) setFade(callback, valueFrom, valueTo, term);
        }
        
        
        
        
    // operations
    //--------------------------------------------------
        /** set fading values 
         *  @param valueFrom The starting value.
         *  @param valueTo The value chaging to.
         *  @param term Changing term.
         *  @return this instance.
         */
        public function setFade(callback:Function, valueFrom:Number=0, valueTo:Number=1, term:int=60) : Fader
        {
            if (term == 0 || callback == null) {
                _counter = 0;
                return this;
            }
            _callback = callback;
            _value = valueFrom;
            _end = valueTo;
            _step = (valueTo - valueFrom) / term;
            _counter = term;
            _callback(_value);
            return this;
        }
        
        
        /** Execute 
         *  @return Activation changing. returns true when the execution is finished.
         */
        public function execute() : Boolean
        {
            if (_counter > 0) {
                _value += _step;
                if (--_counter == 0) {
                    _value = _end;
                    _callback(_end);
                    return true;
                } else {
                    _callback(_value);
                }
            }
            return false;
        }
        
        
        /** Stop fading */
        public function stop() : void
        {
            _counter = 0;
        }
    }
}


