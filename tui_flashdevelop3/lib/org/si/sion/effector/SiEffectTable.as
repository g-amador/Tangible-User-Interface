//----------------------------------------------------------------------------------------------------
// SiOPM effect table
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector {
    /** @private Tables used in effectors. */
    public class SiEffectTable {
        /** sin table */
        public var sinTable:Vector.<Number>;
        
        
        /** constructor. */
        function SiEffectTable()
        {
            var i:int;
            sinTable = new Vector.<Number>(384, true);
            
            for (i=0; i<384; i++) sinTable[i] = Math.sin(i*0.02454369260617026); //pi/128
        }
        
        
        /** instance */
        static public var instance:SiEffectTable;
        
        
        /** static initializer */
        static public function initialize() : void
        {
            if (instance == null) {
                instance = new SiEffectTable();
            }
        }
    }
}

