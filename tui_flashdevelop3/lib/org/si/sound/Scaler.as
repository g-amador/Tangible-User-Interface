//----------------------------------------------------------------------------------------------------
// Note scaler 
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound {
    import org.si.sion.*;
    import org.si.sion.utils.Scale;
    import org.si.sound.base.SingleTrackObject;
    
    
    /** Note scaler */
    public class Scaler extends SingleTrackObject
    {
    // variables
    //----------------------------------------
        /** Table of notes on scale */
        public var scale:Scale;
        
        /** scale index */
        protected var _scaleIndex:int;
        
        
        
        
    // properties
    //----------------------------------------
        /** @private */
        override public function set note(n:int) : void {
            _note = scale.shift(n);
            _scaleIndex = scale.getScaleIndex(_note);
        }
        
        
        /** index on scale */
        public function get scaleIndex() : int { return _scaleIndex; }
        public function set scaleIndex(i:int) : void {
            _scaleIndex = i;
            _note = scale.getNote(i);
        }
        
        
        
        
    // constructor
    //----------------------------------------
        /** constructor.
         *  @param scale Scale
         *  @see org.si.sion.utils.Scale
         */
        function Scaler(scale:Scale) {
            super(scale.scaleName);
            this.scale = scale;
            _scaleIndex = 0;
        }
    }
}

