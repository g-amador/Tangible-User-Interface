//----------------------------------------------------------------------------------------------------
// FM sound module based on OPM emulator and TSS algorism.
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module {
    import org.si.utils.SLLNumber;
    import org.si.utils.SLLint;
    
    
    /** FM sound module based on OPM emulator and TSS algorism. */
    public class SiOPMModule
    {
    // constants
    //--------------------------------------------------
        /** maximum value of stream buffer size */
        static public const STREAM_SIZE_MAX:int = 8;
        /** pipe size */
        static public const PIPE_SIZE:int = 5;
        
        
        
        
    // valiables
    //--------------------------------------------------
        /** Intial values for operator parameters */
        public var initOperatorParam:SiOPMOperatorParam;
        /** zero buffer */
        public var zeroBuffer:SLLint;
        /** stereo output buffer */
        public var streamBuffer:Vector.<SiOPMStream>;
        
        private var _freeOperators:Vector.<SiOPMOperator>;   // Free list for SiOPMOperator
        private var _bufferLength:int;                       // buffer length
        
        // pipes
        private var _pipeBuffer:Vector.<SLLint>;
        private var _pipeBufferPager:Vector.<Vector.<SLLint>>;
        
        
    // properties
    //--------------------------------------------------
        /** Buffer count */
        public function get output() : Vector.<Number> { return streamBuffer[0].buffer; }
        /** Buffer channel count */
        public function get channelCount() : int { return streamBuffer[0].channels; }
        /** Buffer length */
        public function get bufferLength() : int { return _bufferLength; }
        
        
        /** stream buffer count */
        public function set streamCount(count:int) : void {
            var i:int;
            
            // allocate streams
            if (count > STREAM_SIZE_MAX) count = STREAM_SIZE_MAX;
            if (streamBuffer.length != count) {
                if (streamBuffer.length < count) {
                    i = streamBuffer.length;
                    streamBuffer.length = count;
                    for (; i<count; i++) streamBuffer[i] = SiOPMStream.newStream(2, _bufferLength);
                } else {
                    for (i=count; i<streamBuffer.length; i++) SiOPMStream.deleteStream(streamBuffer[i]);
                    streamBuffer.length = count;
                }
            }
        }
        public function get streamCount() : int {
            return streamBuffer.length;
        }
        
        
        
        
    // constructor
    //--------------------------------------------------
        /** Default constructor
         *  @param busSize Number of mixing buses.
         */
        function SiOPMModule()
        {
            // initialize table once
            SiOPMTable.initialize(3580000, 44100);
            
            // initial values
            initOperatorParam = new SiOPMOperatorParam();
            
            // stream buffer
            streamBuffer = new Vector.<SiOPMStream>();
            streamCount = 1;

            // zero buffer gives always 0
            zeroBuffer = SLLint.allocRing(1);
            
            // others
            _bufferLength = 0;
            _pipeBuffer = new Vector.<SLLint>(PIPE_SIZE, true);
            _pipeBufferPager = new Vector.<Vector.<SLLint>>(PIPE_SIZE, true);
            _freeOperators = new Vector.<SiOPMOperator>();
            
            // call at once
            SiOPMChannelManager.initialize(this, true);
        }
        
        
        
        
    // operation
    //--------------------------------------------------
        /** Initialize module and all tone generators.
         *  @param channelCount ChannelCount
         *  @param bufferLength Maximum buffer size processing at once.
         */
        public function initialize(channelCount:int, bufferLength:int) : void
        {
            var i:int, stream:SiOPMStream, bufferLength2:int = bufferLength<<1;

            // allocate buffer
            if (_bufferLength != bufferLength) {
                _bufferLength = bufferLength;
                for each (stream in streamBuffer) {
                    stream.buffer.length = bufferLength2;
                }
                for (i=0; i<PIPE_SIZE; i++) {
                    SLLint.freeRing(_pipeBuffer[i]);
                    _pipeBuffer[i] = SLLint.allocRing(bufferLength);
                    _pipeBufferPager[i] = SLLint.createRingPager(_pipeBuffer[i], true);
                }
            }

            // set standard outputs channel count
            streamBuffer[0].channels = channelCount;
            
            // initialize all channels
            SiOPMChannelManager.initializeAllChannels();
        }
        
        
        /** Reset. */
        public function reset() : void
        {
            // reset all channels
            SiOPMChannelManager.resetAllChannels();
        }
        
        
        /** Clear all buffer. */
        public function clearAllBuffers() : void
        {
            var idx:int, i:int, imax:int, buf:Vector.<Number>, stream:SiOPMStream;
            for each (stream in streamBuffer) {
                buf = stream.buffer;
                imax = buf.length;
                for (i=0; i<imax; i++) buf[i] = 0;
            }
        }
        
        
        /** Limit output level in the ranged of -1 ~ 1.*/
        public function limitLevel() : void
        {
            var buf:Vector.<Number> = streamBuffer[0].buffer,
                i:int, imax:int = buf.length, n:Number;
            for (i=0; i<imax; i++) {
                n = buf[i];
                if (n < -1) buf[i] = -1;
                else if (n > 1) buf[i] = 1;
            }
        }
        
        
        /** get pipe buffer */
        public function getPipe(pipeNum:int, index:int=0) : SLLint
        {
            return _pipeBufferPager[pipeNum][index];
        }
        
        
        /** @private [internal] Alloc operator instance WITHOUT initializing. Call from SiOPMChannelFM. */
        internal function _allocFMOperator() : SiOPMOperator
        {
            return _freeOperators.pop() || new SiOPMOperator(this);
        }

        
        /** @private [internal] Free operator instance. Call from SiOPMChannelFM. */
        internal function _freeFMOperator(osc:SiOPMOperator) : void
        {
            _freeOperators.push(osc);
        }
    }
}

