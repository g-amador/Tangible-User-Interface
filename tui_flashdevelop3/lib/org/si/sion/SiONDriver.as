//----------------------------------------------------------------------------------------------------
// SiON driver
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion {
    import flash.errors.*;
    import flash.events.*;
    import flash.media.*;
    import flash.display.Sprite;
    import flash.utils.getTimer;
    import flash.utils.ByteArray;
    import org.si.utils.SLLint;
    import org.si.utils.SLLNumber;
    import org.si.sion.events.*;
    import org.si.sion.sequencer.base.MMLSequence;
    import org.si.sion.sequencer.base.MMLEvent;
    import org.si.sion.sequencer.SiMMLSequencer;
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.sequencer.SiMMLEnvelopTable;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.SiOPMWaveTable;
    import org.si.sion.module.SiOPMPCMData;
    import org.si.sion.module.SiOPMSamplerData;
    import org.si.sion.effector.SiEffectModule;
    import org.si.sion.utils.SiONUtil;
    import org.si.sion.utils.Fader;
    import org.si.sion.namespaces._sion_internal;
    
    
    /** SiON driver class.<br/>
     * @see SiONData
     * @see SiONVoice
     * @see org.si.sion.events.SiONEvent
     * @see org.si.sion.events.SiONTrackEvent
     * @see org.si.sion.module.SiOPMModule
     * @see org.si.sion.sequencer.SiMMLSequencer
     * @see org.si.sion.effector.SiEffectModule
@example 1) The simplest sample. Create new instance and call play with MML string.<br/>
<listing version="3.0">
// create driver instance.
var driver:SiONDriver = new SiONDriver();
// call play() with mml string whenever you want to play sound.
driver.play("t100 l8 [ ccggaag4 ffeeddc4 | [ggffeed4]2 ]2");
</listing>
     */
    public class SiONDriver extends Sprite
    {
    // namespace
    //----------------------------------------
        use namespace _sion_internal;
        
        
        
        
    // constants
    //----------------------------------------
        /** version number */
        static public const VERSION:String = "0.5.8";
        
        
        /** note-on exception mode "ignore", No exception. */
        static public const NEM_IGNORE:int = 0;
        /** note-on exception mode "reject", Reject new note. */
        static public const NEM_REJECT:int = 1;
        /** note-on exception mode "overwrite", Overwrite current note. */
        static public const NEM_OVERWRITE:int = 2;
        /** note-on exception mode "shift", Shift sound timing. */
        static public const NEM_SHIFT:int = 3;
        
        static private const NEM_MAX:int = 4;
        
        
        // event listener type
        private const NO_LISTEN:int = 0;
        private const LISTEN_QUEUE:int = 1;
        private const LISTEN_PROCESS:int = 2;
        
        // time avaraging sample count
        private const TIME_AVARAGING_COUNT:int = 8;
        
        
        
        
    // valiables
    //----------------------------------------
        /** SiOPM sound module. */
        public var module:SiOPMModule;
        
        /** effector module. */
        public var effector:SiEffectModule;
        
        /** mml sequencer module. */
        public var sequencer:SiMMLSequencer;
        
        
        // private:
        //----- general
        private var _data:SiONData;         // data to compile or process
        private var _tempData:SiONData;     // temporary data
        private var _mmlString:String;      // mml string of previous compiling
        //----- sound related
        private var _sound:Sound;                   // sound stream instance
        private var _soundChannel:SoundChannel;     // sound channel instance
        private var _soundTransform:SoundTransform; // sound transform
        private var _fader:Fader;                   // sound fader
        //----- SiOPM module related
        private var _channelCount:int;          // module output channels (1 or 2)
        private var _sampleRate:int;            // module output frequency ratio (44100 or 22050)
        private var _bitRate:int;               // module output bitrate (0 or 8 or 16)
        private var _bufferLength:int;          // module and streaming buffer size (8192, 4096 or 2048)
        private var _debugMode:Boolean;         // true; throw Error, false; throw ErrorEvent
        private var _dispatchStreamEvent:Boolean; // dispatch steam event
        private var _dispatchFadingEvent:Boolean; // dispatch fading event
        private var _inStreaming:Boolean;         // in streaming
        private var _preserveStop:Boolean;        // preserve stop after streaming
        private var _isFinishSeqDispatched:Boolean; // FINISH_SEQUENCE event already dispacthed
        //----- operation related
        private var _autoStop:Boolean;          // auto stop when the sequence finished
        private var _noteOnExceptionMode:int;   // track id exception mode
        private var _isPaused:Boolean;          // flag to pause
        private var _position:Number;           // start position [ms]
        private var _masterVolume:Number;       // master volume
        private var _faderVolume:Number;        // fader volume
        //----- background sound
        private var _backgroundSound:Sound;      // background Sound
        private var _backgroundLevel:Number;     // background Sound mixing level
        private var _backgroundBuffer:ByteArray; // buffer for background Sound
        //----- queue
        private var _queueInterval:int;         // interupting interval to execute queued jobs
        private var _queueLength:int;           // queue length to execute
        private var _jobProgress:Number;        // progression of current job
        private var _currentJob:int;            // current job 0=no job, 1=compile, 2=render
        private var _jobQueue:Vector.<SiONDriverJob> = null;   // compiling/rendering jobs queue
        private var _trackEventQueue:Vector.<SiONTrackEvent>;  // SiONTrackEvents queue
        //----- timer interruption
        private var _timerSequence:MMLSequence;     // global sequence
        private var _timerIntervalEvent:MMLEvent;   // MMLEvent.WAIT event
        private var _timerCallback:Function;        // callback function
        //----- rendering
        private var _renderBuffer:Vector.<Number>;  // rendering buffer
        private var _renderBufferChannelCount:int;  // rendering buffer channel count
        private var _renderBufferIndex:int;         // rendering buffer writing index
        private var _renderBufferSizeMax:int;       // maximum value of rendering buffer size
        //----- timers
        private var _timeCompile:int;           // previous compiling time.
        private var _timeRender:int;            // previous rendering time.
        private var _timeProcess:int;           // averge processing time in 1sec.
        private var _timeProcessTotal:int;      // total processing time in last 8 bufferings.
        private var _timeProcessData:SLLint;    // processing time data of last 8 bufferings.
        private var _timeProcessAveRatio:Number;// number to averaging _timeProcessTotal
        private var _timePrevStream:int;        // previous streaming time.
        private var _latency:Number;            // streaming latency [ms]
        private var _prevFrameTime:int;         // previous frame time
        private var _frameRate:int;             // frame rate
        //----- listeners management
        private var _eventListenerPrior:int;    // event listeners priority
        private var _listenEvent:int;           // current lintening event
        
        // mutex instance
        static private var _mutex:SiONDriver = null;     // unique instance
        
        
        
        
    // properties
    //----------------------------------------
        /** Instance of unique SiONDriver. null when new SiONDriver is not created yet. */
        static public function get mutex() : SiONDriver { return _mutex; }
        
        
        // data
        /** MML string (this property is only available during compiling ). */
        public function get mmlString() : String { return _mmlString; }
        
        /** Data to compile, render and process. */
        public function get data() : SiONData { return _data; }
        
        /** Sound instance to stream. */
        public function get sound() : Sound { return _sound; }
        
        /** Sound channel (this property is only available during streaming). */
        public function get soundChannel() : SoundChannel { return _soundChannel; }

        /** Fader to control fade-in/out. You can check activity by "fader.isActive". */
        public function get fader() : Fader { return _fader; }
        
        
        // paramteters
        /** Track count (this property is only available during streaming). */
        public function get trackCount() : int { return sequencer.tracks.length; }
        
        /** Streaming buffer length. */
        public function get bufferLength() : int { return _bufferLength; }
        
        /** Sound volume. */
        public function get volume() : Number { return _masterVolume; }
        public function set volume(v:Number) : void {
            _masterVolume = v;
            _soundTransform.volume = _masterVolume * _faderVolume;
            if (_soundChannel) _soundChannel.soundTransform = _soundTransform;
        }
        
        /** Sound panning. */
        public function get pan() : Number { return _soundTransform.pan; }
        public function set pan(p:Number) : void {
            _soundTransform.pan = p;
            if (_soundChannel) _soundChannel.soundTransform = _soundTransform;
        }
        
        
        // measured times
        /** previous compiling time [ms]. */
        public function get compileTime() : int { return _timeCompile; }
        
        /** previous rendering time [ms]. */
        public function get renderTime() : int { return _timeRender; }
        
        /** average processing time in 1sec [ms]. */
        public function get processTime() : int { return _timeProcess; }
        
        /** progression of current compiling/rendering (0=start -> 1=finish). */
        public function get jobProgress() : Number { return _jobProgress; }
        
        /** progression of all queued jobs (0=start -> 1=finish). */
        public function get jobQueueProgress() : Number {
            if (_queueLength == 0) return 1;
            return (_queueLength - _jobQueue.length - 1 + _jobProgress) / _queueLength;
        }
        
        /** compiling/rendering jobs queue length. */
        public function get jobQueueLength() : int { return _jobQueue.length; }
        
        /** streaming latency [ms]. */
        public function get latency() : Number { return _latency; }
        
        
        // flags
        /** Is job executing ? */
        public function get isJobExecuting() : Boolean { return (_jobProgress>0 && _jobProgress<1); }
        
        /** Is streaming ? */
        public function get isPlaying() : Boolean { return (_soundChannel != null); }
        
        /** Is paused ? */
        public function get isPaused() : Boolean { return _isPaused; }
        
        
        // operation
        /** Playing position[ms] on mml data. @default 0 */
        public function get position() : Number {
            return sequencer.processedSampleCount * 1000 / _sampleRate;
        }
        public function set position(pos:Number) : void {
            _position = pos;
            if (sequencer.isReadyToProcess) {
                sequencer.resetAllTracks();
                sequencer.dummyProcess(_position * _sampleRate * 0.001);
            }
        }
        
        /** Beat par minute. @default 120 */
        public function get bpm() : Number {
            return (sequencer.isReadyToProcess) ? sequencer.bpm : sequencer.setting.defaultBPM;
        }
        public function set bpm(t:Number) : void {
            sequencer.setting.defaultBPM = t;
            if (sequencer.isReadyToProcess) {
                if (!sequencer.isEnableChangeBPM) throw errorCannotChangeBPM();
                sequencer.bpm = t;
            }
        }
        
        /** Auto stop when the sequence finished or fade-outed. @default false */
        public function get autoStop() : Boolean { return _autoStop; }
        public function set autoStop(mode:Boolean) : void { _autoStop = mode; }
        
        /** Debug mode, true; throw Error / false; throw ErrorEvent when error appears. @default false */
        public function get debugMode() : Boolean { return _debugMode; }
        public function set debugMode(mode:Boolean) : void { _debugMode = mode; }
        
        /** Note on exception mode. This value have to be SiONDriver.NEM_*. @default NEM_IGNORE. 
         *  @see #NEM_IGNORE
         *  @see #NEM_REJECT
         *  @see #NEM_OVERWRITE
         *  @see #NEM_SHIFT
         */
        public function get noteOnExceptionMode() : int { return _noteOnExceptionMode; }
        public function set noteOnExceptionMode(mode:int) : void { _noteOnExceptionMode = (0<mode && mode<NEM_MAX) ? mode : 0; }
        
        
        
        
    // constructor
    //----------------------------------------
        /** Create driver to manage the synthesizer, sequencer and effector. Only one SiONDriver instance can be created.
         *  @param bufferLength Buffer size of sound stream. 8192, 4096 or 2048 is available, but no check.
         *  @param channel Channel count. 1(monoral) or 2(stereo) is available.
         *  @param sampleRate Sampling ratio of wave. 22050 or 44100 is available.
         *  @param bitRate Bit ratio of wave. 0, 8 or 16 is available. 0 means float value [-1 to 1].
         */
        function SiONDriver(bufferLength:int=2048, channelCount:int=2, sampleRate:int=44100, bitRate:int=0)
        {
            // check mutex
            if (_mutex != null) throw errorPluralDrivers();
            
            // allocation
            _jobQueue = new Vector.<SiONDriverJob>();
            module = new SiOPMModule();
            effector = new SiEffectModule(module);
            sequencer = new SiMMLSequencer(module, _callbackEventTriggerOn, _callbackEventTriggerOff, _callbackTempoChanged);
            _sound = new Sound();
            _soundTransform = new SoundTransform();
            _fader = new Fader();
            _timerSequence = new MMLSequence();

            // initialize
            _tempData = null;
            _channelCount = channelCount;
            _sampleRate = 44100; // sampleRate; 44100 is only available now.
            _bitRate = bitRate;
            _bufferLength = bufferLength;
            _listenEvent = NO_LISTEN;
            _dispatchStreamEvent = false;
            _dispatchFadingEvent = false;
            _preserveStop = false;
            _inStreaming = false;
            _autoStop = false;
            _noteOnExceptionMode = NEM_IGNORE;
            _debugMode = false;
            _isFinishSeqDispatched = false;
            _timerCallback = null;
            _timerSequence.alloc();
            _timerSequence.appendNewEvent(MMLEvent.REPEAT_ALL, 0);
            _timerSequence.appendNewEvent(MMLEvent.TIMER, 0);
            _timerIntervalEvent = _timerSequence.appendNewEvent(MMLEvent.WAIT, 0, 0);
            
            _backgroundSound = null;
            _backgroundLevel = 1;
            _backgroundBuffer = null;
            
            _position = 0;
            _masterVolume = 1;
            _faderVolume = 1;
            _soundTransform.pan = 0;
            _soundTransform.volume = _masterVolume * _faderVolume;
            
            _eventListenerPrior = 1;
            _trackEventQueue = new Vector.<SiONTrackEvent>();
            
            _queueInterval = 500;
            _jobProgress = 0;
            _currentJob = 0;
            _queueLength = 0;
            
            _timeCompile = 0;
            _timeProcessTotal = 0;
            _timeProcessData = SLLint.allocRing(TIME_AVARAGING_COUNT);
            _timeProcessAveRatio = _sampleRate / (_bufferLength * TIME_AVARAGING_COUNT);
            _timePrevStream = 0;
            _latency = 0;
            _prevFrameTime = 0;
            _frameRate = 1;
            
            _mmlString    = null;
            _data         = null;
            _soundChannel = null;
            
            // register sound streaming function 
            _sound.addEventListener("sampleData", _streaming);
            
            // set mutex
            _mutex = this;
        }
        
        
        
        
    // interfaces for data preparation
    //----------------------------------------
        /** Compile MML string immeriately. 
         *  @param mml MML string to compile.
         *  @param data SiONData to compile. The SiONDriver creates new SiONData instance when this argument is null.
         *  @return Compiled data.
         */
        public function compile(mml:String, data:SiONData=null) : SiONData
        {
            try {
                // stop sound
                stop();
                
                // compile immediately
                var t:int = getTimer();
                _prepareCompile(mml, data);
                _jobProgress = sequencer.compile(0);
                _timeCompile = getTimer() - t;
                _mmlString = null;
            } catch(e:Error) {
                // error
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
            
            return _data;
        }
        
        
        /** Push queue job to compile MML string. Start compiling after calling startQueue.<br/>
         *  @param mml MML string to compile.
         *  @param data SiONData to compile.
         *  @return Queue length.
         *  @see #startQueue()
         */
        public function compileQueue(mml:String, data:SiONData) : int
        {
            if (mml == null || data == null) return _jobQueue.length;
            return _jobQueue.push(new SiONDriverJob(mml, null, data, 2));
        }
        
        
        
        
    // interfaces for sound rendering
    //----------------------------------------
        /** Render sound immeriately.
         *  @param data SiONData or mml String to play.
         *  @param renderBuffer Rendering target. null to create new buffer. The length of renderBuffer limits rendering length except for 0.
         *  @param renderBufferChannelCount Channel count of renderBuffer. 2 for stereo and 1 for monoral.
         *  @param resetEffector reset all effectors before play data.
         *  @return rendered data.
         */
        public function render(data:*, renderBuffer:Vector.<Number>=null, renderBufferChannelCount:int=2, resetEffector:Boolean=true) : Vector.<Number>
        {
            try {
                // stop sound
                stop();
                
                // rendering immediately
                var t:int = getTimer();
                if (resetEffector) effector.initialize();
                _prepareRender(data, renderBuffer, renderBufferChannelCount);
                while(true) { if (_rendering()) break; }
                _timeRender = getTimer() - t;
            } catch (e:Error) {
                // error
                _removeAllEventListners();
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
            
            return _renderBuffer;
        }
        
        
        /** Push queue job to render sound. Start rendering after calling startQueue.<br/>
         *  @param data SiONData or mml String to render.
         *  @param renderBuffer Rendering target. The length of renderBuffer limits rendering length except for 0.
         *  @param renderBufferChannelCount Channel count of renderBuffer. 2 for stereo and 1 for monoral.
         *  @return Queue length.
         *  @see #startQueue()
         */
        public function renderQueue(data:*, renderBuffer:Vector.<Number>, renderBufferChannelCount:int=2) : int
        {
            if (data == null || renderBuffer == null) return _jobQueue.length;
            
            if (data is String) {
                var compiled:SiONData = new SiONData();
                _jobQueue.push(new SiONDriverJob(data as String, null, compiled, 2));
                return _jobQueue.push(new SiONDriverJob(null, renderBuffer, compiled, renderBufferChannelCount));
            } else 
            if (data is SiONData) {
                return _jobQueue.push(new SiONDriverJob(null, renderBuffer, data as SiONData, renderBufferChannelCount));
            }
            
            var e:Error = errorDataIncorrect();
            if (_debugMode) throw e;
            else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            return _jobQueue.length;
        }
        
        
        
        
    // interfaces for jobs queue
    //----------------------------------------
        /** Execute all elements of queue pushed by compileQueue and renderQueue.
         *  After calling this function, the SiONEvent.QUEUE_PROGRESS, SiONEvent.QUEUE_COMPLETE and ErrorEvent.ERROR events will be dispatched.<br/>
         *  The SiONEvent.QUEUE_PROGRESS is dispatched when it's executing queued job.<br/>
         *  The SiONEvent.QUEUE_COMPLETE is dispatched when finish all queued jobs.<br/>
         *  The ErrorEvent.ERROR is dispatched when some error appears during the compile.<br/>
         *  @param interval Interupting interval
         *  @return Queue length.
         *  @see #compileQueue()
         *  @see #renderQueue()
         */
        public function startQueue(interval:int=500) : int
        {
            try {
                stop();
                _queueLength = _jobQueue.length;
                if (_jobQueue.length > 0) {
                    _queueInterval = interval;
                    _executeNextJob();
                    _queue_addAllEventListners();
                }
            } catch (e:Error) {
                // error
                _removeAllEventListners();
                _cancelAllJobs();
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
            return _queueLength;
        }
        
        
        
        
    // interfaces for sound streaming
    //----------------------------------------
        /** Play sound.
         *  @param data SiONData or mml String to play. You can pass null when resume after pause or streaming without any data.
         *  @param resetEffector reset all effectors before play data.
         *  @return SoundChannel instance to play data. This instance is same as soundChannel property.
         *  @see #soundChannel
         */
        public function play(data:*=null, resetEffector:Boolean=true) : SoundChannel
        {
            try {
                if (_isPaused) {
                    _isPaused = false;
                } else {
                    // stop sound
                    stop();
                    
                    // preparation
                    if (resetEffector) effector.initialize();
                    _prepareProcess(data);
                    
                    // dispatch streaming start event
                    var event:SiONEvent = new SiONEvent(SiONEvent.STREAM_START, this, null, true);
                    dispatchEvent(event);
                    if (event.isDefaultPrevented()) return null;   // canceled
                    
                    // set position
                    if (_data && _position > 0) { sequencer.dummyProcess(_position * _sampleRate * 0.001); }
                    
                    // start stream
                    _process_addAllEventListners();
                    _soundChannel = _sound.play();
                    _soundChannel.soundTransform = _soundTransform;
                    
                    // initialize
                    _timeProcessTotal = 0;
                    for (var i:int=0; i<TIME_AVARAGING_COUNT; i++) {
                        _timeProcessData.i = 0;
                        _timeProcessData = _timeProcessData.next;
                    }
                    _isPaused = false;
                    _isFinishSeqDispatched = (data == null);
                }
            } catch(e:Error) {
                // error
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
            
            return _soundChannel;
        }
        
        
        /** Stop sound. */
        public function stop() : void
        {
            if (_soundChannel) {
                if (_inStreaming) {
                    _preserveStop = true;
                } else {
                    _removeAllEventListners();
                    _preserveStop = false;
                    _soundChannel.stop();
                    _soundChannel = null;
                    _latency = 0;
                    _fader.stop();
                    _faderVolume = 1;
                    _soundTransform.volume = _masterVolume;
                    
                    // dispatch streaming stop event
                    dispatchEvent(new SiONEvent(SiONEvent.STREAM_STOP, this));
                }
            }
        }
        
        
        /** Pause sound. You can resume it by play() without any arguments. */
        public function pause() : void
        {
            _isPaused = true;
        }
        
        
        /** Play Sound as a background. This function should be called before play().
         *  @param sound Sound instance to play background.
         *  @param mixLevel Mixing level (0-1).
         */
        public function setBackgroundSound(sound:Sound, mixLevel:Number=1) : void
        {
            _backgroundSound = sound;
            _backgroundLevel = mixLevel;
            if (_backgroundBuffer == null) {
                _backgroundBuffer = new ByteArray();
                _backgroundBuffer.length = _bufferLength * 8;
            }
        }
        
        
        /** Stop background sound. */
        public function stopBackgroundSound() : void
        {
            _backgroundSound = null;
        }
        
        
        /** Fade in.
         *  @param term Fading time [second].
         */
        public function fadeIn(term:Number) : void
        {
            _fader.setFade(_fadeVolume, 0, 1, term * _sampleRate / _bufferLength);
            _dispatchFadingEvent = (hasEventListener(SiONEvent.FADE_PROGRESS));
        }
        
        
        /** Fade out.
         *  @param term Fading time [second].
         */
        public function fadeOut(term:Number) : void
        {
            _fader.setFade(_fadeVolume, 1, 0, term * _sampleRate / _bufferLength);
            _dispatchFadingEvent = (hasEventListener(SiONEvent.FADE_PROGRESS));
        }
        
        
        /** Set timer interruption.
         *  @param length16th Interupting interval in 16th beat.
         *  @param callback Callback function. the Type is function():void.
         */
        public function setTimerInterruption(length16th:Number=1, callback:Function=null) : void
        {
            _timerIntervalEvent.length = length16th * sequencer.setting.resolution * 0.0625;
            _timerCallback = (length16th > 0) ? callback : null;
        }
        
        
        /** Set callback interval of SiONTrackEvent.BEAT.
         *  @param length16th Interval in 16th beat. 2^n is only available(1,2,4,8,16....).
         */
        public function setBeatCallbackInterval(length16th:Number=1) : void
        {
            var filter:int = 1;
            while (length16th > 1.5) {
                filter <<= 1;
                length16th *= 0.5
            }
            sequencer.onBeatCallbackFilter = filter - 1;
        }
        
        
        
        
    // Interface for public data registration
    //----------------------------------------
        /** Set wave table data refered by %4.
         *  @param index wave table number.
         *  @param table wave shape vector ranges in -1 to 1.
         */
        public function setWaveTable(index:int, table:Vector.<Number>) : SiOPMWaveTable
        {
            var len:int, bits:int=-1;
            for (len=table.length; len>0; len>>=1) bits++;
            if (bits<2) return null;
            var waveTable:Vector.<int> = SiONUtil.logTransVector(table, false);
            waveTable.length = 1<<bits;
            return SiOPMTable.registerWaveTable(index, waveTable);
        }
        
        
        /** Set PCM data rederd by %7.
         *  @param index PCM data number.
         *  @param data Vector.<Number> wave data. This type ussualy comes from render().
         *  @param isDataStereo Flag that the wave data is stereo or monoral.
         *  @param samplingOctave Sampling frequency. The value of 5 means that "o5a" is original frequency.
         *  @see #render()
         */
        public function setPCMData(index:int, data:Vector.<Number>, isDataStereo:Boolean=true, samplingOctave:int=5) : SiOPMPCMData
        {
            var pcm:Vector.<int> = SiONUtil.logTransVector(data, isDataStereo);
            return SiOPMTable.registerPCMData(index, pcm, samplingOctave);
        }
        
        
        /** Set PCM sound rederd by %7.
         *  @param index PCM data number.
         *  @param sound Sound instance to set.
         *  @param samplingOctave Sampling frequency. The value of 5 means that "o5a" is original frequency.
         *  @param sampleMax The maximum sample count to extract. The length of returning vector is limited by this value.
         */
        public function setPCMSound(index:int, sound:Sound, samplingOctave:int=5, sampleMax:int=1048576) : SiOPMPCMData
        {
            var data:Vector.<int> = SiONUtil.logTrans(sound, null, sampleMax);
            return SiOPMTable.registerPCMData(index, data, samplingOctave);
        }
        
        
        /** Set sampler data refered by %10.
         *  @param index note number. 0-127 for bank0, 128-255 for bank1.
         *  @param data Vector.<Number> wave data. This type ussualy comes from render().
         *  @param isOneShot True to set "one shot" sound. The "one shot" sound ignores note off.
         *  @param channelCount 1 for monoral, 2 for stereo.
         *  @see #render()
         */
        public function setSamplerData(index:int, data:Vector.<Number>, isOneShot:Boolean=true, channelCount:int=1) : SiOPMSamplerData
        {
            return SiOPMTable.registerSamplerData(index, data, isOneShot, channelCount);
        }
        
        
        /** Set sampler sound refered by %10.
         *  @param index note number. 0-127 for bank0, 128-255 for bank1.
         *  @param sound Sound instance to set.
         *  @param isOneShot True to set "one shot" sound. The "one shot" sound ignores note off.
         *  @param channelCount 1 for monoral, 2 for stereo.
         *  @param sampleMax The maximum sample count to extract. The length of returning vector is limited by this value.
         */
        public function setSamplerSound(index:int, sound:Sound, isOneShot:Boolean=true, channelCount:int=2, sampleMax:int=1048576) : SiOPMSamplerData
        {
            var data:Vector.<Number> = SiONUtil.extract(sound, null, channelCount, sampleMax);
            return SiOPMTable.registerSamplerData(index, data, isOneShot, channelCount);
        }
        
        
        /** Set envelop table data refered by &#64;&#64;,na,np,nt,nf,_&#64;&#64;,_na,_np,_nt and _nf.
         *  @param index envelop table number.
         *  @param table envelop table vector.
         *  @param loopPoint returning point index of looping. -1 sets no loop.
         */
        public function setEnvelopTable(index:int, table:Vector.<int>, loopPoint:int=-1) : void
        {
            var tail:SLLint, head:SLLint, loop:SLLint, i:int, imax:int = table.length;
            head = tail = SLLint.allocList(imax);
            loop = null;
            for (i=0; i<imax-1; i++) {
                if (loopPoint == i) loop = tail;
                tail.i = table[i];
                tail = tail.next;
            }
            tail.i = table[i];
            tail.next = loop;
            var env:SiMMLEnvelopTable = new SiMMLEnvelopTable();
            env._initialize(head, tail);
            SiMMLTable.registerMasterEnvelopTable(index, env);
        }
        
        
        /** Set wave table data refered by %6.
         *  @param index wave table number.
         *  @param voice voice to register.
         */
        public function setVoice(index:int, voice:SiONVoice) : void
        {
            if (!voice._isSuitableForFMVoice) throw errorNotGoodFMVoice();
            SiMMLTable.registerMasterVoice(index, voice);
        }
        
        
        
        
    // Interface for intaractivity
    //----------------------------------------
        /** Play sound registered in sampler table (registered by setSamplerData()), same as noteOn(note, new SiONVoice(10), ...).
         *  @param note note number [0-127].
         *  @param length note length in 16th beat. 0 sets no note off, this means you should call noteOff().
         *  @param delay note on delay units in 16th beat.
         *  @param quant quantize in 16th beat. 0 sets no quantization. 4 sets quantization by 4th beat.
         *  @param trackID new tracks id.
         *  @param eventTriggerID Event trigger id.
         *  @param noteOnTrigger note on trigger type. 0 sets no trigger at note on.
         *  @param noteOffTrigger note off trigger type. 0 sets no trigger at note off.
         *  @param isDisposable use disposable track. The disposable track will free automatically when finished rendering. 
         *         This means you should not keep a dieposable track in your code perpetually. 
         *         If you want to keep track, set this argument false. And after using, SiMMLTrack::setDisposal() to disposed by system.<br/>
         *         [REMARKS] Not disposable track is kept perpetually in the system while streaming, this may causes critical performance loss.
         *  @return SiMMLTrack to play the note. 
         */
        public function playSound(note:int, 
                                  length:Number      = 0, 
                                  delay:Number       = 0, 
                                  quant:Number       = 0, 
                                  trackID:int        = 0, 
                                  eventTriggerID:int = 0, 
                                  noteOnTrigger:int  = 0, 
                                  noteOffTrigger:int = 0,
                                  isDisposable:Boolean = true) : SiMMLTrack
        {
            trackID = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_NOTE_ID_OFFSET;
            var mmlTrack:SiMMLTrack = null, 
                delaySamples:Number = sequencer.calcSampleDelay(0, delay, quant);
            
            // check track id exception
            if (_noteOnExceptionMode != NEM_IGNORE) {
                // find a track sounds at same timing
                mmlTrack = sequencer.findActiveTrack(trackID, delaySamples);
                if (_noteOnExceptionMode == NEM_REJECT && mmlTrack != null) return null; // reject
                else if (_noteOnExceptionMode == NEM_SHIFT) { // shift timing
                    var step:int = sequencer.calcSampleLength(quant);
                    while (mmlTrack) {
                        delaySamples += step;
                        mmlTrack = sequencer.findActiveTrack(trackID, delaySamples);
                    }
                }
            }
            
            mmlTrack = mmlTrack || sequencer.getFreeControlableTrack(trackID, isDisposable) || sequencer.newControlableTrack(trackID, isDisposable);
            if (mmlTrack) {
                mmlTrack.setChannelModuleType(10, 0);
                mmlTrack.setEventTrigger(eventTriggerID, noteOnTrigger, noteOffTrigger);
                mmlTrack.keyOn(note, sequencer.calcSampleLength(length), delaySamples);
            }
            return mmlTrack;
        }
        
        
        /** Note on. This function only is available after play(). The NOTE_ON_STREAM event is dispatched inside.
         *  @param note note number [0-127].
         *  @param voice SiONVoice to play note. You can specify null, but it sets only a default square wave.
         *  @param length note length in 16th beat. 0 sets no note off, this means you should call noteOff().
         *  @param delay note on delay units in 16th beat.
         *  @param quant quantize in 16th beat. 0 sets no quantization. 4 sets quantization by 4th beat.
         *  @param trackID new tracks id.
         *  @param eventTriggerID Event trigger id.
         *  @param noteOnTrigger note on trigger type.
         *  @param noteOffTrigger note off trigger type.
         *  @param isDisposable use disposable track. The disposable track will free automatically when finished rendering. 
         *         This means you should not keep a dieposable track in your code perpetually. 
         *         If you want to keep track, set this argument false. And after using, call SiMMLTrack::setDisposal() to disposed by system.<br/>
         *         [REMARKS] Not disposable track is kept in the system perpetually while streaming, this may causes critical performance loss.
         *  @return SiMMLTrack to play the note.
         */
        public function noteOn(note:int, 
                               voice:SiONVoice    = null, 
                               length:Number      = 0, 
                               delay:Number       = 0, 
                               quant:Number       = 0, 
                               trackID:int        = 0, 
                               eventTriggerID:int = 0, 
                               noteOnTrigger:int  = 0, 
                               noteOffTrigger:int = 0,
                               isDisposable:Boolean = true) : SiMMLTrack
        {
            trackID = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_NOTE_ID_OFFSET;
            var mmlTrack:SiMMLTrack = null, 
                delaySamples:Number = sequencer.calcSampleDelay(0, delay, quant);
            
            // check track id exception
            if (_noteOnExceptionMode != NEM_IGNORE) {
                // find a track sounds at same timing
                mmlTrack = sequencer.findActiveTrack(trackID, delaySamples);
                if (_noteOnExceptionMode == NEM_REJECT && mmlTrack != null) return null; // reject
                else if (_noteOnExceptionMode == NEM_SHIFT) { // shift timing
                    var step:int = sequencer.calcSampleLength(quant);
                    while (mmlTrack) {
                        delaySamples += step;
                        mmlTrack = sequencer.findActiveTrack(trackID, delaySamples);
                    }
                }
            }
            
            mmlTrack = mmlTrack || sequencer.getFreeControlableTrack(trackID, isDisposable) || sequencer.newControlableTrack(trackID, isDisposable);
            if (mmlTrack) {
                if (voice) voice.setTrackVoice(mmlTrack);
                mmlTrack.setEventTrigger(eventTriggerID, noteOnTrigger, noteOffTrigger);
                mmlTrack.keyOn(note, sequencer.calcSampleLength(length), delaySamples);
            }
            return mmlTrack;
        }
        
        
        /** Note off. This function only is available after play(). The NOTE_OFF_STREAM event is dispatched inside.
         *  @param note note number [-1-127]. The value of -1 ignores note number.
         *  @param trackID track id to note off.
         *  @param delay note off delay units in 16th beat.
         *  @param quant quantize in 16th beat. 0 sets no quantization. 4 sets quantization by 4th beat.
         *  @return All SiMMLTracks switched key off.
         */
        public function noteOff(note:int, trackID:int=0, delay:Number=0, quant:Number=0) : Vector.<SiMMLTrack>
        {
            trackID = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_NOTE_ID_OFFSET;
            var delaySamples:int = sequencer.calcSampleDelay(0, delay, quant), 
                tracks:Vector.<SiMMLTrack> = new Vector.<SiMMLTrack>();
            for each (var mmlTrack:SiMMLTrack in sequencer.tracks) {
                if (mmlTrack.trackID == trackID) {
                    if (note == -1 || (note == mmlTrack.note && mmlTrack.channel.isNoteOn())) {
                        mmlTrack.keyOff(delaySamples);
                        tracks.push(mmlTrack);
                    }
                }
            }
            return tracks;
        }
        
        
        /** Play sequences with synchronizing.
         *  @param data The SiONData including sequences. This data is used only for sequences. The system ignores wave, envelop and voice data.
         *  @param voice SiONVoice to play sequence. The voice setting in the sequence has priority.
         *  @param length note length in 16th beat. 0 sets no note off, this means you should call noteOff().
         *  @param delay note on delay units in 16th beat.
         *  @param quant quantize in 16th beat. 0 sets no quantization. 4 sets quantization by 4th beat.
         *  @param trackID new tracks id.
         *  @param isDisposable use disposable track. The disposable track will free automatically when finished rendering. 
         *         This means you should not keep a dieposable track in your code perpetually. 
         *         If you want to keep track, set this argument false. And after using, call SiMMLTrack::setDisposal() to disposed by system.<br/>
         *         [REMARKS] Not disposable track is kept in the system perpetually while streaming, this may causes critical performance loss.
         *  @return list of SiMMLTracks to play sequence.
         */
        public function sequenceOn(data:SiONData, 
                                   voice:SiONVoice  = null, 
                                   length:Number    = 0, 
                                   delay:Number     = 0, 
                                   quant:Number     = 1, 
                                   trackID:int      = 0,
                                   isDisposable:Boolean = true) : Vector.<SiMMLTrack>
        {
            trackID = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_SEQUENCE_ID_OFFSET;
            // create new sequence tracks
            var mmlTrack:SiMMLTrack, tracks:Vector.<SiMMLTrack> = new Vector.<SiMMLTrack>(), 
                seq:MMLSequence = data.sequenceGroup.headSequence, 
                delaySamples:int = sequencer.calcSampleDelay(0, delay, quant),
                lengthSamples:int = sequencer.calcSampleLength(length);
            while (seq) {
                mmlTrack = sequencer.getFreeControlableTrack(trackID, isDisposable) || sequencer.newControlableTrack(trackID, isDisposable);
                mmlTrack.sequenceOn(seq, lengthSamples, delaySamples);
                if (voice) voice.setTrackVoice(mmlTrack);
                tracks.push(mmlTrack);
                seq = seq.nextSequence;
            }
            return tracks;
        }
        
        
        /** Stop the sequences with synchronizing.
         *  @param trackID tracks id to stop.
         *  @param delay sequence off delay units in 16th beat.
         *  @param quant quantize in 16th beat. 0 sets no quantization. 4 sets quantization by 4th beat.
         *  @return list of SiMMLTracks stopped to play sequence.
         */
        public function sequenceOff(trackID:int, delay:Number=0, quant:Number=1) : Vector.<SiMMLTrack>
        {
            trackID = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_SEQUENCE_ID_OFFSET;
            var delaySamples:int = sequencer.calcSampleDelay(0, delay, quant), stoppedTrack:SiMMLTrack = null,
                tracks:Vector.<SiMMLTrack> = new Vector.<SiMMLTrack>();
            for each (var mmlTrack:SiMMLTrack in sequencer.tracks) {
                if (mmlTrack.trackID == trackID) {
                    mmlTrack.sequenceOff(delaySamples);
                    tracks.push(mmlTrack);
                }
            }
            return tracks;
        }
        
        
        /** Create new user controlable track.
         *  @param new user controlable track. This track is NOT disposable.
         */
        public function newUserControlableTrack(trackID:int=0) : SiMMLTrack
        {
            trackID = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.USER_CONTROLLED_ID_OFFSET;
            return sequencer.getFreeControlableTrack(trackID, false) || sequencer.newControlableTrack(trackID, false);
        }
        
        
        
        
    //====================================================================================================
    // Internal uses
    //====================================================================================================
    // callback for event trigger
    //----------------------------------------
        // call back when sound streaming
        private function _callbackEventTriggerOn(track:SiMMLTrack) : Boolean
        {
            return _publishEventTrigger(track, track.eventTriggerTypeOn, SiONTrackEvent.NOTE_ON_FRAME, SiONTrackEvent.NOTE_ON_STREAM);
        }
        
        // call back when sound streaming
        private function _callbackEventTriggerOff(track:SiMMLTrack) : Boolean
        {
            return _publishEventTrigger(track, track.eventTriggerTypeOff, SiONTrackEvent.NOTE_OFF_FRAME, SiONTrackEvent.NOTE_OFF_STREAM);
        }
        
        // publish event trigger
        private function _publishEventTrigger(track:SiMMLTrack, type:int, frameEvent:String, streamEvent:String) : Boolean
        {
            var event:SiONTrackEvent;
            if (type & 1) { // frame event. dispatch later
                event = new SiONTrackEvent(frameEvent, this, track);
                _trackEventQueue.push(event);
            }
            if (type & 2) { // sound event. dispatch immediately
                event = new SiONTrackEvent(streamEvent, this, track);
                dispatchEvent(event);
                return !(event.isDefaultPrevented());
            }
            return true;
        }
        
        // call back when tempo changed
        private function _callbackTempoChanged(bufferIndex:int) : void
        {
            var event:SiONTrackEvent = new SiONTrackEvent(SiONTrackEvent.CHANGE_BPM, this, null, bufferIndex);
            _trackEventQueue.push(event);
        }
        
        // call back on beat
        private function _callbackBeat(bufferIndex:int, beatCounter:int) : void
        {
            var event:SiONTrackEvent = new SiONTrackEvent(SiONTrackEvent.BEAT, this, null, bufferIndex, 0, beatCounter);
            _trackEventQueue.push(event);
        }
        
        
        
        
    // operate event listener
    //----------------------------------------
        // add all event listners
        private function _queue_addAllEventListners() : void
        {
            if (_listenEvent != NO_LISTEN) throw errorDriverBusy(LISTEN_QUEUE);
            addEventListener(Event.ENTER_FRAME, _queue_onEnterFrame, false, _eventListenerPrior);
            _listenEvent = LISTEN_QUEUE;
        }
        
        
        // add all event listners
        private function _process_addAllEventListners() : void
        {
            if (_listenEvent != NO_LISTEN) throw errorDriverBusy(LISTEN_PROCESS);
            addEventListener(Event.ENTER_FRAME, _process_onEnterFrame, false, _eventListenerPrior);
            if (hasEventListener(SiONTrackEvent.BEAT)) sequencer._setBeatCallback(_callbackBeat);
            else sequencer._setBeatCallback(null);
            _dispatchStreamEvent = (hasEventListener(SiONEvent.STREAM));
            _prevFrameTime = getTimer();
            _listenEvent = LISTEN_PROCESS;
        }
        
        
        // remove all event listners
        private function _removeAllEventListners() : void
        {
            switch (_listenEvent) {
            case LISTEN_QUEUE:
                removeEventListener(Event.ENTER_FRAME, _queue_onEnterFrame);
                break;
            case LISTEN_PROCESS:
                removeEventListener(Event.ENTER_FRAME, _process_onEnterFrame);
                sequencer._setBeatCallback(null);
                _dispatchStreamEvent = false;
                break;
            }
            _listenEvent = NO_LISTEN;
        }
        
        
        
        
    // parse
    //----------------------------------------
        // parse system command on SiONDriver
        private function _parseSystemCommand(systemCommands:Array) : Boolean
        {
            var id:int, wcol:uint, effectSet:Boolean = false;
            for each (var cmd:* in systemCommands) {
                switch(cmd.command){
                case "#EFFECT":
                    effectSet = true;
                    effector.parseMML(cmd.number, cmd.content, cmd.postfix);
                    break;
                case "#WAVCOLOR":
                    wcol = parseInt(cmd.content, 16);
                    setWaveTable(cmd.number, SiONUtil.waveColor(wcol));
                    break;
                }
            }
            return effectSet;
        }
        
        
        
        
    // jobs queue
    //----------------------------------------
        // cancel
        private function _cancelAllJobs() : void
        {
            _data = null;
            _mmlString = null;
            _currentJob = 0;
            _jobProgress = 0;
            _jobQueue.length = 0;
            _queueLength = 0;
            _removeAllEventListners();
            dispatchEvent(new SiONEvent(SiONEvent.QUEUE_CANCEL, this, null));
        }
        
        
        // next job
        private function _executeNextJob() : Boolean
        {
            _data = null;
            _mmlString = null;
            _currentJob = 0;
            if (_jobQueue.length == 0) {
                _queueLength = 0;
                _removeAllEventListners();
                dispatchEvent(new SiONEvent(SiONEvent.QUEUE_COMPLETE, this, null));
                return true;
            }
            
            var queue:SiONDriverJob = _jobQueue.shift();
            if (queue.mml) _prepareCompile(queue.mml, queue.data);
            else _prepareRender(queue.data, queue.buffer, queue.channelCount);
            return false;
        }
        
        
        // on enterFrame
        private function _queue_onEnterFrame(e:Event) : void
        {
            try {
                var event:SiONEvent, t:int = getTimer();
                
                switch (_currentJob) {
                case 1: // compile
                    _jobProgress = sequencer.compile(_queueInterval);
                    _timeCompile += getTimer() - t;
                    break;
                case 2: // render
                    _jobProgress += (1 - _jobProgress) * 0.5;
                    while (getTimer() - t <= _queueInterval) { 
                        if (_rendering()) {
                            _jobProgress = 1;
                            break;
                        }
                    }
                    _timeRender += getTimer() - t;
                    break;
                }
                
                // finish job
                if (_jobProgress == 1) {
                    // finish all jobs
                    if (_executeNextJob()) return;
                }
                
                // progress
                event = new SiONEvent(SiONEvent.QUEUE_PROGRESS, this, null, true);
                dispatchEvent(event);
                if (event.isDefaultPrevented()) _cancelAllJobs();   // canceled
            } catch (e:Error) {
                // error
                _removeAllEventListners();
                _cancelAllJobs();
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
        }
        
        
        
        
    // compile
    //----------------------------------------
        // prepare to compile
        private function _prepareCompile(mml:String, data:SiONData) : void
        {
            _data = data || new SiONData();
            _mmlString = mml;
            sequencer.prepareCompile(_data, _mmlString);
            _jobProgress = 0.01;
            _timeCompile = 0; 
            _currentJob = 1;
        }
        
        
        
        
    // render
    //----------------------------------------
        // prepare for rendering
        private function _prepareRender(data:*, renderBuffer:Vector.<Number>, renderBufferChannelCount:int) : void
        {
            _prepareProcess(data);
            _renderBuffer = renderBuffer || new Vector.<Number>();
            _renderBufferChannelCount = (renderBufferChannelCount==2) ? 2 : 1;
            _renderBufferSizeMax = _renderBuffer.length;
            _renderBufferIndex = 0;
            _jobProgress = 0.01;
            _timeRender = 0;
            _currentJob = 2;
        }
        
        
        // rendering @return true when finished rendering.
        private function _rendering() : Boolean
        {
            var i:int, j:int, imax:int, extention:int, 
                output:Vector.<Number> = module.output, 
                finished:Boolean = false;
            
            // processing
            sequencer.process();
            effector._process();
            module.limitLevel();
            
            // limit rendering length
            imax      = _bufferLength<<1;
            extention = _bufferLength<<(_renderBufferChannelCount-1);
            if (_renderBufferSizeMax != 0 && _renderBufferSizeMax < _renderBufferIndex+extention) {
                extention = _renderBufferSizeMax - _renderBufferIndex;
                finished = true;
            }
            
            // extend buffer
            if (_renderBuffer.length < _renderBufferIndex+extention) {
                _renderBuffer.length = _renderBufferIndex+extention;
            }
            
            // copy output
            if (_renderBufferChannelCount==2) {
                for (i=0, j=_renderBufferIndex; i<imax; i++, j++) {
                    _renderBuffer[j] = output[i];
                }
            } else {
                for (i=0, j=_renderBufferIndex; i<imax; i+=2, j++) {
                    _renderBuffer[j] = output[i];
                }
            }
            
            // incerement index
            _renderBufferIndex += extention;
            
            return (finished || (_renderBufferSizeMax==0 && sequencer.isFinished));
        }
        
        
        
        
    // process
    //----------------------------------------
        // prepare for processing
        private function _prepareProcess(data:*) : void
        {
            if (data is String) {
                _tempData = _tempData || new SiONData();
                _data = compile(data as String, _tempData);
            } else {
                if (!(data == null || data is SiONData)) throw errorDataIncorrect();
                _data = data;
            }
            
            // THESE FUNCTIONS ORDER IS VERY IMPORTANT !!
            module.initialize(_channelCount, _bufferLength);
            module.reset();                                                 // reset channels
            sequencer.prepareProcess(_data, _sampleRate, _bufferLength);    // set track channels (this must be called after module.reset()).
            if (_data) _parseSystemCommand(_data.systemCommands);           // parse #EFFECT (initialize effector inside)
            effector._prepareProcess();                                     // set stream number inside
            _trackEventQueue.length = 0;                                    // clear event que
            
            
            if (_timerCallback != null) {
                sequencer.setGlobalSequence(_timerSequence); // set timer interruption
                sequencer._setTimerCallback(_timerCallback);
            }
       }
        
        
        // on enterFrame
        private function _process_onEnterFrame(e:Event) : void
        {
            // frame rate
            var t:int = getTimer();
            _frameRate = t - _prevFrameTime;
            _prevFrameTime = t;
            
            // preserve stop
            if (_preserveStop) stop();
            
            // frame trigger
            if (_trackEventQueue.length > 0) {
                _trackEventQueue = _trackEventQueue.filter(function(e:SiONTrackEvent, i:int, v:Vector.<SiONTrackEvent>) : Boolean {
                    if (e._decrementTimer(_frameRate)) {
                        dispatchEvent(e);
                        return false;
                    }
                    return true;
                });
            }
        }
        
        
        // on sampleData
        private function _streaming(e:SampleDataEvent) : void
        {
            var buffer:ByteArray = e.data, 
                output:Vector.<Number> = module.output, 
                imax:int, i:int;

            // calculate latency (0.022675736961451247 = 1/44.1)
            if (_soundChannel) {
                _latency = e.position * 0.022675736961451247 - _soundChannel.position;
            }
            
            try {
                _inStreaming = true;
                if (_isPaused) {
                    // paused -> zero fill
                    buffer = e.data;
                    imax = _bufferLength;
                    for (i=0; i<imax; i++) {
                        buffer.writeFloat(0);
                        buffer.writeFloat(0);
                    }
                } else {
                    var t:int = getTimer();
                    // processing
                    sequencer.process();
                    effector._process();
                    module.limitLevel();
                    
                    // calculate the average of processing time
                    _timePrevStream = t;
                    _timeProcessTotal -= _timeProcessData.i;
                    _timeProcessData.i = getTimer() - t;
                    _timeProcessTotal += _timeProcessData.i;
                    _timeProcessData   = _timeProcessData.next;
                    _timeProcess = _timeProcessTotal * _timeProcessAveRatio;
                    
                    // write samples
                    imax = output.length;
                    if (_backgroundSound) {
                        // w/ background sound
                        _backgroundSound.extract(_backgroundBuffer, _bufferLength);
                        for (i=0; i<imax; i++) buffer.writeFloat(output[i]+_backgroundBuffer.readFloat()*_backgroundLevel);
                    } else {
                        // w/o background sound
                        for (i=0; i<imax; i++) buffer.writeFloat(output[i]);
                    }
                    
                    // dispatch streaming event
                    if (_dispatchStreamEvent) {
                        var event:SiONEvent = new SiONEvent(SiONEvent.STREAM, this, buffer, true);
                        dispatchEvent(event);
                        if (event.isDefaultPrevented()) stop();   // canceled
                    }
                    
                    // dispatch finishSequence event
                    if (!_isFinishSeqDispatched) {
                        if (sequencer.isSequenceFinished) {
                            dispatchEvent(new SiONEvent(SiONEvent.FINISH_SEQUENCE, this));
                            _isFinishSeqDispatched = true;
                        }
                    }
                    
                    // fading
                    if (_fader.execute()) {
                        var eventType:String = (_fader.isIncrement) ? SiONEvent.FADE_IN_COMPLETE : SiONEvent.FADE_OUT_COMPLETE;
                        dispatchEvent(new SiONEvent(eventType, this, buffer));
                        if (_autoStop && !_fader.isIncrement) stop();
                    } else {
                        // auto stop
                        if (_autoStop && sequencer.isFinished) stop();
                    }
                }
                _inStreaming = false;
            } catch (e:Error) {
                // error
                _removeAllEventListners();
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
        }
        
        
        
    // operations
    //----------------------------------------
        // volume fading
        private function _fadeVolume(v:Number) : void {
            _faderVolume = v;
            _soundTransform.volume = _masterVolume * _faderVolume;
            if (_soundChannel) _soundChannel.soundTransform = _soundTransform;
            if (_dispatchFadingEvent) {
                var event:SiONEvent = new SiONEvent(SiONEvent.FADE_PROGRESS, this, null, true);
                dispatchEvent(event);
                if (event.isDefaultPrevented()) _fader.stop();   // canceled
            }
        }
        
        
        
        
    // errors
    //----------------------------------------
        private function errorPluralDrivers() : Error {
            return new Error("SiONDriver error; Cannot create pulral SiONDrivers.");
        }
        
        
        private function errorDataIncorrect() : Error {
            return new Error("SiONDriver error; data incorrect in play() or render().");
        }
        
        
        private function errorDriverBusy(execID:int) : Error {
            var states:Array = ["???", "compiling", "streaming", "rendering"];
            return new Error("SiONDriver error: Driver busy. Call " + states[execID] + " while " + states[_listenEvent] + ".");
        }
        
        
        private function errorCannotChangeBPM() : Error {
            return new Error("SiONDriver error: Cannot change bpm while rendering (SiONTrackEvent.NOTE_*_STREAM).");
        }
        
        
        private function errorNotGoodFMVoice() : Error {
            return new Error("SiONDriver error; Cannot register the voice.");
        }
    }
}




import org.si.sion.SiONData;

class SiONDriverJob
{
    public var mml:String;
    public var buffer:Vector.<Number>;
    public var data:SiONData;
    public var channelCount:int;
    
    function SiONDriverJob(mml_:String, buffer_:Vector.<Number>, data_:SiONData, channelCount_:int) 
    {
        mml = mml_;
        buffer = buffer_;
        data = data_ || new SiONData();
        channelCount = channelCount_;
    }
}


