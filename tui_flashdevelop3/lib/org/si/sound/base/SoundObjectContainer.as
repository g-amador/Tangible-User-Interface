//----------------------------------------------------------------------------------------------------
// Sound object container
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.base {
    /** The SoundObjectContainer class is the base class for all objects that can serve as sound object containers on the sound list. 
     */
    public class SoundObjectContainer extends SoundObject
    {
    // valiables
    //----------------------------------------
        /** the list of child sound objects. */
        protected var _soundList:Vector.<SoundObject>;
        
        
        
        
    // properties
    //----------------------------------------
        /** Returns the number of children of this object. */
        public function get numChildren() : int { return _soundList.length; }
        
        
        
        
        
        
    // properties
    //----------------------------------------
        /** Base note of this sound */
        override public function set note(n:int) : void {
            _note = n;
            for each (var sound:SoundObject in _soundList) sound.note = n;
        }
        
        /** Sound length, uint in 16th beat, 0 sets inifinity length. @default 0. */
        override public function set length(l:Number) : void {
            _length = l;
            for each (var sound:SoundObject in _soundList) sound.length = l;
        }
        
        /** Synchronizing quantizing, uint in 16th beat. (0:No synchronization, 1:sync.with 16th, 4:sync.with 4th). @default 0. */
        override public function set quantize(q:Number) : void {
            _quantize = q;
            for each (var sound:SoundObject in _soundList) sound.quantize = q;
        }
        
        /** Sound delay, uint in 16th beat. @default 0. */
        override public function set delay(d:Number) : void {
            _delay = d;
            for each (var sound:SoundObject in _soundList) sound.delay = d;
        }
        
        
        
        
    // constructor
    //----------------------------------------
        /** constructor. */
        function SoundObjectContainer(name:String = "")
        {
            super(name);
            _soundList = new Vector.<SoundObject>();
        }
        
        
        
        
    // operations
    //----------------------------------------
        /** Play sound. */
        override public function play() : void
        {
            for each (var sound:SoundObject in _soundList) sound.play();
        }
        
        
        /** Stop sound. */
        override public function stop() : void
        {
            for each (var sound:SoundObject in _soundList) sound.stop();
        }
        
        
        
        
    // operations for children
    //----------------------------------------
        /** Adds a child SoundObject instance to this SoundObjectContainer instance. 
         *  The child is added to the end of all other children in this SoundObjectContainer instance. (To add a child to a specific index position, use the addChildAt() method.)
         *  If you add a child object that already has a different sound object container as a parent, the object is removed from the child list of the other sound object container. 
         *  @param sound The SoundObject instance to add as a child of this SoundObjectContainer instance.
         *  @return The SoundObject instance that you pass in the sound parameter
         */
        public function addChild(sound:SoundObject) : SoundObject
        {
            sound._setParent(this);
            _soundList.push(sound);
            return sound;
        }
        
        
        /** Adds a child SoundObject instance to this SoundObjectContainer instance. 
         *  The child is added at the index position specified. An index of 0 represents the head of the sound list for this SoundObjectContainer object. 
         *  @param sound The SoundObject instance to add as a child of this SoundObjectContainer instance.
         *  @param index The index position to which the child is added. If you specify a currently occupied index position, the child object that exists at that position and all higher positions are moved up one position in the child list.
         *  @return The child sound object at the specified index position.
         */
        public function addChildAt(sound:SoundObject, index:int) : SoundObject
        {
            sound._setParent(this);
            if (index < _soundList.length) _soundList.splice(index, 0, sound);
            else _soundList.push(sound);
            return sound;
        }
        
        
        /** Removes the specified child SoundObject instance from the child list of the SoundObjectContainer instance.
         *  The parent property of the removed child is set to null, and the object is garbage collected if no other references to the child exist.
         *  The index positions of any sound objects after the child in the SoundObjectContainer are decreased by 1.
         *  @param sound The DisplayObject instance to remove
         *  @return The SoundObject instance that you pass in the sound parameter.
         */
        public function removeChild(sound:SoundObject) : SoundObject
        {
            var index:int = _soundList.indexOf(sound);
            if (index == -1) throw Error("SoundObjectContainer Error; Specifyed children is not in the children list.");
            sound._setParent(null);
            _soundList.splice(index, 1);
            return sound;
        }
        
        
        /** Removes a child SoundObject from the specified index position in the child list of the SoundObjectContainer. 
         *  The parent property of the removed child is set to null, and the object is garbage collected if no other references to the child exist. 
         *  The index positions of any display objects above the child in the DisplayObjectContainer are decreased by 1. 
         *  @param The child index of the SoundObject to remove. 
         *  @return The SoundObject instance that was removed. 
         */
        public function removeChildAt(index:int) : SoundObject
        {
            if (index >= _soundList.length) throw Error("SoundObjectContainer Error; Specifyed index is not in the children list.");
            var sound:SoundObject = _soundList.splice(index, 1)[0];
            sound._setParent(null);
            return sound;
        }
        
        
        /** Returns the child sound object instance that exists at the specified index.
         *  @param The child index of the SoundObject to find.
         *  @return founded SoundObject instance.
         */
        public function getChildAt(index:int) : SoundObject
        {
            if (index >= _soundList.length) throw Error("SoundObjectContainer Error; Specifyed index is not in the children list.");
            return _soundList[index];
        }
        
        
        /** Returns the child sound object that exists with the specified name. 
         *  If more than one child sound object has the specified name, the method returns the first object in the child list.
         *  @param The child name of the SoundObject to find.
         *  @return founded SoundObject instance. Returns null if its not found.
         */ 
        public function getChildByName(name:String) : SoundObject
        {
            for each (var sound:SoundObject in _soundList) {
                if (sound.name == name) return sound;
            }
            return null;
        }
        
        
        /** Returns the index position of a child SoundObject instance. 
         *  @param sound The SoundObject instance want to know.
         *  @return index of specifyed SoundObject. Returns -1 if its not found.
         */
        public function getChildIndex(sound:SoundObject) : Number
        {
            return _soundList.indexOf(sound);
        }
        
        
        /** Changes the position of an existing child in the sound object container. This affects the processing order of child objects. 
         *  @param child The child SoundObject instance for which you want to change the index number. 
         *  @param index The resulting index number for the child sound object.
         *  @param The SoundObject instance that you pass in the child parameter.
         */
        public function setChildIndex(child:SoundObject, index:int) : SoundObject
        {
            return addChildAt(removeChild(child), index);
        }
        
        
        
        
    // oprate ancestor
    //----------------------------------------
        /** @private [internal use] */
        override internal function _updateMute() : void
        {
            super._updateMute();
            for each (var sound:SoundObject in _soundList) sound._updateMute();
        }
        
        
        /** @private [internal use] */
        override internal function _updateVolume() : void
        {
            super._updateVolume();
            for each (var sound:SoundObject in _soundList) sound._updateVolume();
        }
        
        
        /** @private [internal use] */
        override internal function _limitVolume() : void
        {
            super._limitVolume();
            for each (var sound:SoundObject in _soundList) sound._limitVolume();
        }
        
        
        /** @private [internal use] */
        override internal function _updatePan() : void
        {
            super._updatePan();
            for each (var sound:SoundObject in _soundList) sound._updatePan();
        }
        
        
        /** @private [internal use] */
        override internal function _limitPan() : void
        {
            super._limitPan();
            for each (var sound:SoundObject in _soundList) sound._limitPan();
        }
    }
}


