//----------------------------------------------------------------------------------------------------
// Chord class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.utils {
    /** Chord class. */
    public class Chord
    {
    // constants
    //--------------------------------------------------
        /** Chord table of C */
        protected const CT_MAJOR  :int = 0x1091091;
        /** Chord table of Cm */
        protected const CT_MINOR  :int = 0x1089089;
        /** Chord table of C7 */
        protected const CT_7TH    :int = 0x0490491;
        /** Chord table of Cm7 */
        protected const CT_MIN7   :int = 0x0488489;
        /** Chord table of CM7 */
        protected const CT_MAJ7   :int = 0x0890891;
        /** Chord table of CmM7 */
        protected const CT_MM7    :int = 0x0888889;
        /** Chord table of C9 */
        protected const CT_9TH    :int = 0x0484491;
        /** Chord table of Cm9 */
        protected const CT_MIN9   :int = 0x0484489;
        /** Chord table of CM9 */
        protected const CT_MAJ9   :int = 0x0884891;
        /** Chord table of CmM9 */
        protected const CT_MM9    :int = 0x0884889;
        /** Chord table of Cadd9 */
        protected const CT_ADD9   :int = 0x1084091;
        /** Chord table of Cmadd9 */
        protected const CT_MINADD9:int = 0x1084089;
        /** Chord table of C69 */
        protected const CT_69TH   :int = 0x1204211;
        /** Chord table of Cm69 */
        protected const CT_MIN69  :int = 0x1204209;
        /** Chord table of Csus4 */
        protected const CT_SUS4   :int = 0x10a10a1;
        /** Chord table of Csus47 */
        protected const CT_SUS47  :int = 0x04a04a1;
        /** Chord table of Cdim */
        protected const CT_DIM    :int = 0x1489489;
        /** Chord table of Carg */
        protected const CT_AUG    :int = 0x1111111;
        
        
        
        
    // valiables
    //--------------------------------------------------
        /** note table */
        protected var _chordTable:int;
        /** notes on the chord */
        protected var _chordNotes:Vector.<int>;
        /** chord name */
        protected var _chordName:String;
        
        
        
        
    // properties
    //--------------------------------------------------
        /** Chord name.
         *  The regular expression of name is /(o[0-9])?([A-Ga-g])([+#\-])?([a-z0-9]+)?(,[0-9]+[+#\-]?)?(,[0-9]+[+#\-]?)?/.<br/>
         *  The 1st letter means center octave. default octave = 5 (when omit).<br/>
         *  The 2nd letter means base note.<br/>
         *  The 3nd letter (option) means note shift sign. "+" and "#" shift +1, "-" shifts -1.<br/>
         *  The 4th letters (option) means chord as follows.<br/>
         *  <table>
         *  <tr><th>the 3rd letters</th><th>chord</th></tr>
         *  <tr><td>(no matching), maj</td><td>Major chord</td></tr>
         *  <tr><td>m</td><td>Minor chord</td></tr>
         *  <tr><td>7</td><td>7th chord</td></tr>
         *  <tr><td>m7</td><td>Minor 7th chord</td></tr>
         *  <tr><td>M7</td><td>Major 7th chord</td></tr>
         *  <tr><td>mM7</td><td>Minor major 7th chord</td></tr>
         *  <tr><td>9</td><td>9th chord</td></tr>
         *  <tr><td>m9</td><td>Minor 9th chord</td></tr>
         *  <tr><td>M9</td><td>Major 9th chord</td></tr>
         *  <tr><td>mM9</td><td>Minor major 9th chord</td></tr>
         *  <tr><td>add9</td><td>Add 9th chord</td></tr>
         *  <tr><td>madd9</td><td>Minor add 9th chord</td></tr>
         *  <tr><td>69</td><td>6,9th chord</td></tr>
         *  <tr><td>m69</td><td>Minor 6,9th chord</td></tr>
         *  <tr><td>sus4</td><td>Sus4 chord</td></tr>
         *  <tr><td>sus47</td><td>Sus4 7th chord</td></tr>
         *  <tr><td>dim</td><td>Diminish chord</td></tr>
         *  <tr><td>arg</td><td>Augment chord</td></tr>
         *  The 5th and 6th letters (option) means tension notes.<br/>
         *  </table>
         *  If you want to set "F sharp minor 7th", chordName = "F+m7".
         */
        public function get chordName() : String { return _chordName; }
        public function set chordName(name:String) : void {
            var rex:RegExp = /(o[0-9])?([A-Ga-g])([+#\-b])?([a-z0-9]+)?(,([0-9]+[+#\-]?))?(,([0-9]+[+#\-]?))?/;
            var mat:* = rex.exec(name);
            var i:int;
            if (mat) {
                _chordName = name;
                var baseNote:int = [9,11,0,2,4,5,7][String(mat[2]).toLowerCase().charCodeAt() - 'a'.charCodeAt()];
                if (mat[3]) {
                    if (mat[3]=='+' || mat[3]=='#') baseNote++;
                    else if (mat[3]=='-') baseNote--;
                }
                if (baseNote < 0) baseNote += 12;
                else if (baseNote > 11) baseNote -= 12;
                if (mat[1]) baseNote += int(mat[1].charAt(1)) * 12;
                else baseNote += 60;
                if (mat[4]) {
                    switch(mat[4]) {
                    case "m":     _chordTable = CT_MINOR;   break;
                    case "7":     _chordTable = CT_7TH;     break;
                    case "m7":    _chordTable = CT_MAJ7;    break;
                    case "M7":    _chordTable = CT_MIN7;    break;
                    case "mM7":   _chordTable = CT_MM7;     break;
                    case "9":     _chordTable = CT_9TH;     break;
                    case "m9":    _chordTable = CT_MIN9;    break;
                    case "M9":    _chordTable = CT_MAJ9;    break;
                    case "mM9":   _chordTable = CT_MM9;     break;
                    case "add9":  _chordTable = CT_ADD9;    break;
                    case "madd9": _chordTable = CT_MINADD9; break;
                    case "69":    _chordTable = CT_69TH;    break;
                    case "m69":   _chordTable = CT_MIN69;   break;
                    case "sus4":  _chordTable = CT_SUS4;    break;
                    case "sus47": _chordTable = CT_SUS47;   break;
                    case "dim":   _chordTable = CT_DIM;     break;
                    case "arg":   _chordTable = CT_AUG;     break;
                    default:      _chordTable = CT_MAJOR;   break;
                    }
                } else {
                    _chordTable = CT_MAJOR;
                }
                _chordNotes.length = 0;
                for (i=0; i<25; i++) if (_chordTable & (1<<i)) _chordNotes.push(i + baseNote);
            } else {
                _chordName = "C";
                _chordTable = CT_MAJOR;
                _chordNotes.length = 0;
                for (i=0; i<25; i++) if (_chordTable & (1<<i)) _chordNotes.push(i + 60);
            }
        }
        
        
        /** base note number */
        public function get baseNote() : int { return _chordNotes[0]; }
        
        
        
        
    // constructor
    //--------------------------------------------------
        /** constructor 
         *  @param chordName chord name.
         *  @see #chordName
         */
        function Chord(chordName:String = "")
        {
            _chordNotes = new Vector.<int>();
            this.chordName = chordName;
        }
        
        
        /** set chord table manualy.
         *  @param name name of this chord.
         *  @param baseNote base note of this chord.
         *  @table Boolean table of available note on this chord. The index of 0 is base note.
@example If you want to set "Dm11".<br/>
<listing version="3.0">
    var table:Array = [1,0,0,1,0,0,0,1,0,0,1,0,0,0,1,0,0,1,0,1,0,0,1];  // Dm11 = d,f,a,<c,e,g,<c
    chord.setScaleTable("Dm11", 62, table);  // 62 = "D"s ntoe number.
</listing>
         */
        public function setScaleTable(name:String, baseNote:int, table:Array) : void
        {
            _chordName = name;
            var i:int, imax:int = (table.length<12) ? table.length : 12;
            _chordTable = 0;
            for (i=0; i<imax; i++) if (table[i]) _chordTable |= (1<<i);
            _chordNotes.length = 0;
            for (i=0; i<12; i++) if (_chordTable & (1<<i)) _chordNotes.push(i + baseNote);
        }
        
        
        
        
    // operations
    //--------------------------------------------------
        /** check note availability on this chord. 
         *  @param note MIDI note number (0-127).
         *  @return Returns true if the note is in this chord.
         */
        public function check(note:int) : Boolean {
            if (note < _chordNotes[0]) return false;
            var i:int, imax:int = _chordNotes.length;
            for (i=0; i<imax; i++) {
                if (note == _chordNotes[i]) return true;
            }
            return false;
        }
        
        
        /** shift note to the nearest note on this chord. 
         *  @param note MIDI note number (0-127).
         *  @return Returns shifted note. if the note is in this chord, no shift.
         */
        public function shift(note:int) : int {
            var i:int, imax:int = _chordNotes.length, octaveShift:int = 0;
            while (note < _chordNotes[0]) {
                note += 12;
                octaveShift -= 12;
            }
            for (i=0; i<imax; i++) {
                if (note <= _chordNotes[i]) return _chordNotes[i] + octaveShift;
            }
            return _chordNotes[imax-1];
        }
        
        
        /** get note by index on this chord.
         *  @param index index on this chord. You can specify both posi and nega values.
         *  @param centerOctave The octave of index = 0.
         *  @return MIDI note number on this chord.
         */
        public function getNote(index:int) : int {
            return _chordNotes[index];
        }
    }
}


