//----------------------------------------------------------------------------------------------------
// SiMMLTrack Envelop table
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer {
    import org.si.utils.SLLint;
    import org.si.sion.namespaces._sion_internal;
    
    
    /** Tabel evnelope data. */
    public class SiMMLEnvelopTable
    {
        /** Head element of single linked list. */
        public var head:SLLint;
        /** Tail element of single linked list. */
        public var tail:SLLint;
        
        /** constructor. 
         *  @param src Source table coping from.
         */
        function SiMMLEnvelopTable(src:SiMMLEnvelopTable=null)
        {
            head = null;
            tail = null;
            if (src) copyFrom(src);
        }
        
        /** free */
        public function free() : void
        {
            if (head) {
                tail.next = null;
                SLLint.freeList(head);
                head = null;
                tail = null;
            }
        }
        
        /** copy */
        public function copyFrom(src:SiMMLEnvelopTable) : SiMMLEnvelopTable
        {
            free();
            if (src.head) {
                for (var pSrc:SLLint = src.head, pDst:SLLint = null; pSrc != src.tail; pSrc = pSrc.next) {
                    var p:SLLint = SLLint.alloc(pSrc.i);
                    if (pDst) {
                        pDst.next = p;
                        pDst = p;
                    } else {
                        head = p;
                        pDst = head;
                    }
                }
            }
            return this;
        }
        
        /** @private [sion internal] initializer. */
        _sion_internal function _initialize(head_:SLLint, tail_:SLLint) : void
        {
            head = head_;
            tail = tail_;
            // looping last data
            if (tail.next == null) tail.next = tail;
        }
    }
}

