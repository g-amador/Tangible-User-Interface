//----------------------------------------------------------------------------------------------------
// Sound object
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.base {
    import org.si.sion.SiONDriver;
    
    
    /** The SoundObject class is the base class for all objects that can be played sounds on the SiONDriver. 
     */
    public class SoundObject
    {
    // valiables
    //----------------------------------------
        /** Name. */
        public var name:String;
        
        /** @private [internal uses] parent container */
        internal var _parent:SoundObjectContainer;
        
        /** Base note of this sound */
        protected var _note:int;
        
        /** Sound length uint in 16th beat, 0 sets inifinity length. @default 0. */
        protected var _length:Number;
        /** Sound delay uint in 16th beat. @default 0. */
        protected var _delay:Number;
        /** Synchronizing uint in 16th beat. (0:No synchronization, 1:sync.with 16th, 4:sync.with 4th). @default 0. */
        protected var _quantize:Number;
        
        /** total volume of all ancestors */
        protected var _totalVolume:Number;
        /** volume of this sound object */
        protected var _thisVolume:Number
        /** total panning of all ancestors */
        protected var _totalPan:Number;
        /** panning of this sound object */
        protected var _thisPan:Number
        /** total mute flag of all ancestors */
        protected var _totalMute:Boolean;
        /** mute flag of this sound object */
        protected var _thisMute:Boolean;
        
        /** track id. This value is asigned when its created. */
        protected var _trackID:int;
        
        
        
        
    // properties
    //----------------------------------------
        /** SiONDriver instrance to operate. this returns null when driver is not created. */
        public function get driver() : SiONDriver { 
            return SiONDriver.mutex;
        }
        
        /** Base note of this sound */
        public function get note() : int { return _note; }
        public function set note(n:int) : void {
            _note = n;
        }
        
        /** Sound length, uint in 16th beat, 0 sets inifinity length. @default 0. */
        public function get length() : Number { return _length; }
        public function set length(l:Number) : void {
            _length = l;
        }
        
        /** Synchronizing quantizing, uint in 16th beat. (0:No synchronization, 1:sync.with 16th, 4:sync.with 4th). @default 0. */
        public function get quantize() : Number { return _quantize; }
        public function set quantize(q:Number) : void {
            _quantize = q;
        }
        
        /** Sound delay, uint in 16th beat. @default 0. */
        public function get delay() : Number { return _delay; }
        public function set delay(d:Number) : void {
            _delay = d;
        }
        
        /** Mute. */
        public function get mute() : Boolean { return _thisMute; }
        public function set mute(m:Boolean) : void { 
            _thisMute = m;
            _updateMute();
        }
        
        /** Volume (0:Minimum - 1:Maximum). */
        public function get volume() : Number { return _thisVolume; }
        public function set volume(v:Number) : void {
            _thisVolume = v;
            _updateVolume();
            _limitVolume();
        }
        
        /** Panning (-1:Left - 0:Center - +1:Right). */
        public function get pan() : Number { return _thisPan; }
        public function set pan(p:Number) : void {
            _thisPan = p;
            _updatePan();
            _limitPan();
        }
        
        /** parent container. */
        public function get parent() : SoundObjectContainer { return _parent; }
        
        /** track id */
        public function get trackID() : int { return _trackID; }
        
        /** is playing ? */
        public function get isPlaying() : Boolean { return false; }
        
        // counter to asign unique track id
        static private var _uniqueTrackID:int = 0;
        
        
        
        
    // constructor
    //----------------------------------------
        /** constructor. */
        function SoundObject(name:String = null)
        {
            this.name = name || "";
            _parent = null;
            _note = 60;
            _length = 0;
            _delay = 0;
            _quantize = 1;
            _totalVolume = 0.5;
            _thisVolume = 0.5;
            _totalPan = 0;
            _thisPan = 0;
            _totalMute = false;
            _thisMute = false;
            _trackID = (_uniqueTrackID & 0x7fff) | 0x8000;
            _uniqueTrackID++;
        }
        
        
        
        
    // operations
    //----------------------------------------
        /** Play sound. */
        public function play() : void
        {
        }
        
        
        /** Stop sound. */
        public function stop() : void
        {
        }
        
        
        
        
    // oprate ancestor
    //----------------------------------------
        /** @private [internal use] */
        internal function _setParent(parent:SoundObjectContainer) : void
        {
            if (_parent != null) _parent.removeChild(this);
            _parent = parent;
            _updateMute();
            _updateVolume();
            _limitVolume();
            _updatePan();
            _limitPan();
        }
        
        
        /** @private [internal use] */
        internal function _updateMute() : void
        {
            if (_parent) _totalMute = _parent._totalMute || _thisMute;
            else _totalMute = _thisMute;
        }
        
        
        /** @private [internal use] */
        internal function _updateVolume() : void
        {
            if (_parent) _totalVolume = _parent._totalVolume * _thisVolume;
            else _totalVolume = _thisVolume;
        }
        
        
        /** @private [internal use] */
        internal function _limitVolume() : void
        {
            if (_totalVolume < 0) _totalVolume = 0;
            else if (_totalVolume > 1) _totalVolume = 1;
        }
        
        
        /** @private [internal use] */
        internal function _updatePan() : void
        {
            if (_parent) _totalPan = (_parent._totalPan + _thisPan) * 0.5;
            else _totalPan = _thisPan;
        }
        
        
        /** @private [internal use] */
        internal function _limitPan() : void
        {
            if (_totalPan < -1) _totalPan = -1;
            else if (_totalPan > 1) _totalPan = 1;
        }
    }
}


