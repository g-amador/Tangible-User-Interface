//----------------------------------------------------------------------------------------------------
// Scale class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.utils {
    /** Scale class. */
    public class Scale
    {
    // constants
    //--------------------------------------------------
        /** Scale table of C */
        protected const ST_MAJOR:int            = 0xab5;
        /** Scale table of Cm */
        protected const ST_MINOR:int            = 0x5ad;
        /** Scale table of Chm */
        protected const ST_HARMONIC_MINOR:int   = 0x9ad;
        /** Scale table of Cmm */
        protected const ST_MELODIC_MINOR:int    = 0xaad;
        /** Scale table of Cp */
        protected const ST_PENTATONIC:int       = 0x295;
        /** Scale table of Cmp */
        protected const ST_MINOR_PENTATONIC:int = 0x4a9;
        /** Scale table of Cb */
        protected const ST_BLUE_NOTE:int        = 0x4e9;
        /** Scale table of Cd */
        protected const ST_DIMINISH:int         = 0x249;
        /** Scale table of Ccd */
        protected const ST_COMB_DIMINISH:int    = 0x6db;
        /** Scale table of Cw */
        protected const ST_WHOLE_TONE:int       = 0x555;
        /** Scale table of Cc */
        protected const ST_CHROMATIC:int        = 0xfff;
        /** Scale table of Csus4 */
        protected const ST_PERFECT:int          = 0x0a1;
        /** Scale table of Csus47 */
        protected const ST_DPERFECT:int         = 0x4a1;
        /** Scale table of C5 */
        protected const ST_POWER:int            = 0x081;
        /** Scale table of Cu */
        protected const ST_UNISON:int           = 0x001;
        /** Scale table of Cdor */
        protected const ST_DORIAN:int           = 0x6ad;
        /** Scale table of Cphr */
        protected const ST_PHRIGIAN:int         = 0x5ab;
        /** Scale table of Clyd */
        protected const ST_LYDIAN:int           = 0xad5;
        /** Scale table of Cmix */
        protected const ST_MIXOLYDIAN:int       = 0x6b5;
        /** Scale table of Cloc */
        protected const ST_LOCRIAN:int          = 0x56b;
        /** Scale table of Cgyp */
        protected const ST_GYPSY:int            = 0x9b3;
        /** Scale table of Cspa */
        protected const ST_SPANISH:int          = 0x5ab;
        /** Scale table of Chan */
        protected const ST_HANGARIAN:int        = 0xacd;
        /** Scale table of Cjap */
        protected const ST_JAPANESE:int         = 0x4a5;
        /** Scale table of Cryu */
        protected const ST_RYUKYU:int           = 0x8b1;
        
        
        
        
    // valiables
    //--------------------------------------------------
        /** note table */
        protected var _scaleTable:int;
        /** notes on the scale */
        protected var _scaleNotes:Vector.<int>;
        /** scale name */
        protected var _scaleName:String;
        
        
        
        
    // properties
    //--------------------------------------------------
        /** Scale name.
         *  The regular expression of name is /(o[0-9])?([A-Ga-g])([+#\-])?([a-z0-9]+)?/.<br/>
         *  The 1st letter means center octave. default octave = 5 (when omit).<br/>
         *  The 2nd letter means base note.<br/>
         *  The 3nd letter (option) means note shift sign. "+" and "#" shift +1, "-" shifts -1.<br/>
         *  The 4th letters (option) means scale as follows.<br/>
         *  <table>
         *  <tr><th>the 3rd letters</th><th>scale</th></tr>
         *  <tr><td>(no matching), ion</td><td>Major scale</td></tr>
         *  <tr><td>m, nm, aeo</td><td>Natural minor scale</td></tr>
         *  <tr><td>hm</td><td>Harmonic minor scale</td></tr>
         *  <tr><td>mm</td><td>Melodic minor scale</td></tr>
         *  <tr><td>p</td><td>Pentatonic scale</td></tr>
         *  <tr><td>mp</td><td>Minor pentatonic scale</td></tr>
         *  <tr><td>b</td><td>Blue note scale</td></tr>
         *  <tr><td>d</td><td>Diminish scale</td></tr>
         *  <tr><td>cd</td><td>Combination of diminish scale</td></tr>
         *  <tr><td>w</td><td>Whole tone scale</td></tr>
         *  <tr><td>c</td><td>Chromatic scale</td></tr>
         *  <tr><td>sus4</td><td>table of sus4 chord</td></tr>
         *  <tr><td>sus47</td><td>table of sus47 chord</td></tr>
         *  <tr><td>5</td><td>Power chord</td></tr>
         *  <tr><td>u</td><td>Unison (octave scale)</td></tr>
         *  <tr><td>dor</td><td>Dorian mode</td></tr>
         *  <tr><td>phr</td><td>Phrigian mode</td></tr>
         *  <tr><td>lyd</td><td>Lydian mode</td></tr>
         *  <tr><td>mix</td><td>Mixolydian mode</td></tr>
         *  <tr><td>loc</td><td>Locrian mode</td></tr>
         *  <tr><td>gyp</td><td>Gypsy scale</td></tr>
         *  <tr><td>spa</td><td>Spanish scale</td></tr>
         *  <tr><td>han</td><td>Hangarian scale</td></tr>
         *  <tr><td>jap</td><td>Japanese scale (Ritsu mode)</td></tr>
         *  <tr><td>ryu</td><td>Japanese scale (Ryukyu mode)</td></tr>
         *  </table>
         *  If you want to set "G sharp harmonic minor scale", scaleName = "G+hm".
         */
        public function get scaleName() : String { return _scaleName; }
        public function set scaleName(name:String) : void {
            var rex:RegExp = /(o[0-9])?([A-Ga-g])([+#\-b])?([a-z0-9]+)?/;
            var mat:* = rex.exec(name);
            var i:int;
            if (mat) {
                _scaleName = name;
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
                    case "m":    _scaleTable = ST_MINOR;            break;
                    case "nm":   _scaleTable = ST_MINOR;            break;
                    case "aeo":  _scaleTable = ST_MINOR;            break;
                    case "hm":   _scaleTable = ST_HARMONIC_MINOR;   break;
                    case "mm":   _scaleTable = ST_MELODIC_MINOR;    break;
                    case "p":    _scaleTable = ST_PENTATONIC;       break;
                    case "mp":   _scaleTable = ST_MINOR_PENTATONIC; break;
                    case "b":    _scaleTable = ST_BLUE_NOTE;        break;
                    case "d":    _scaleTable = ST_DIMINISH;         break;
                    case "cd":   _scaleTable = ST_COMB_DIMINISH;    break;
                    case "w":    _scaleTable = ST_WHOLE_TONE;       break;
                    case "c":    _scaleTable = ST_CHROMATIC;        break;
                    case "sus4": _scaleTable = ST_PERFECT;          break;
                    case "sus47":_scaleTable = ST_DPERFECT;         break;
                    case "5":    _scaleTable = ST_POWER;            break;
                    case "u":    _scaleTable = ST_UNISON;           break;
                    case "dor":  _scaleTable = ST_DORIAN;           break;
                    case "phr":  _scaleTable = ST_PHRIGIAN;         break;
                    case "lyd":  _scaleTable = ST_LYDIAN;           break;
                    case "mix":  _scaleTable = ST_MIXOLYDIAN;       break;
                    case "loc":  _scaleTable = ST_LOCRIAN;          break;
                    case "gyp":  _scaleTable = ST_GYPSY;            break;
                    case "spa":  _scaleTable = ST_SPANISH;          break;
                    case "han":  _scaleTable = ST_HANGARIAN;        break;
                    case "jap":  _scaleTable = ST_JAPANESE;         break;
                    case "ryu":  _scaleTable = ST_RYUKYU;           break;
                    default:     _scaleTable = ST_MAJOR;            break;
                    }
                } else {
                    _scaleTable = ST_MAJOR;
                }
                _scaleNotes.length = 0;
                for (i=0; i<12; i++) if (_scaleTable & (1<<i)) _scaleNotes.push(i + baseNote);
                baseNote = baseNote % 12;
                _scaleTable = ((_scaleTable << baseNote) | (_scaleTable >> (12 - baseNote))) & 0xfff;
            } else {
                _scaleName = "C";
                _scaleTable = ST_MAJOR;
                _scaleNotes.length = 0;
                for (i=0; i<12; i++) if (_scaleTable & (1<<i)) _scaleNotes.push(i + 60);
            }
        }
        
        
        /** base note number */
        public function get baseNote() : int { return _scaleNotes[0]; }
        
        
        
        
    // constructor
    //--------------------------------------------------
        /** constructor 
         *  @param scaleName scale name.
         *  @see #scaleName
         */
        function Scale(scaleName:String = "")
        {
            _scaleNotes = new Vector.<int>();
            this.scaleName = scaleName;
        }
        
        
        /** set scale table manualy.
         *  @param name name of this scale.
         *  @param baseNote base note of this scale.
         *  @table Boolean table of available note on this scale. The length is 12. The index of 0 is base note.
@example If you want to set "F japanese scale (1 2 4 5 b7)".<br/>
<listing version="3.0">
    var table:Array = [1,0,1,0,0,1,0,1,0,0,1,0];  // c,d,f,g,b- is available on "C japanese scale".
    scale.setScaleTable("Fjap", 65, table);       // 65="F"s note number
</listing>
         */
        public function setScaleTable(name:String, baseNote:int, table:Array) : void
        {
            _scaleName = name;
            var i:int, imax:int = (table.length<12) ? table.length : 12;
            _scaleTable = 0;
            for (i=0; i<imax; i++) if (table[i]) _scaleTable |= (1<<i);
            _scaleNotes.length = 0;
            for (i=0; i<12; i++) if (_scaleTable & (1<<i)) _scaleNotes.push(i + baseNote);
            baseNote = baseNote % 12;
            _scaleTable = ((_scaleTable << baseNote) | (_scaleTable >> (12 - baseNote))) & 0xfff;
        }
        
        
        
        
    // operations
    //--------------------------------------------------
        /** check note availability on this scale. 
         *  @param note MIDI note number (0-127).
         *  @return Returns true if the note is on this scale.
         */
        public function check(note:int) : Boolean {
            note = note % 12;
            return Boolean(_scaleTable & (1<<note));
        }
        
        
        /** shift note to the nearest note on this scale. 
         *  @param note MIDI note number (0-127).
         *  @return Returns shifted note. if the note is on this scale, no shift.
         */
        public function shift(note:int) : int {
            var n:int, down:int, up:int;
            for (n=note%12, up=0;   (_scaleTable & (1<<n)) == 0; up++)   { if (++n == 12) n = 0; }
            for (n=note%12, down=0; (_scaleTable & (1<<n)) == 0; down++) { if (--n == -1) n = 11; }
            return note + ((down < up) ? (-down) : up);
        }
        
        
        /** get scale index from note. */
        public function getScaleIndex(note:int) : int {
            var base:int = baseNote, top:int = base+12, octaveShift:int = 0;
            while (note < base) {
                note += 12;
                octaveShift--;
            }
            while (note >= top) {
                note -= 12;
                octaveShift++;
            }
            var i:int, imax:int = _scaleNotes.length;
            for (i=0; i<imax; i++) if (note <= _scaleNotes[i]) break;
            return i + octaveShift*imax;
        }
        
        
        /** get note by index on this scale.
         *  @param index index on this scale. You can specify both posi and nega values.
         *  @param centerOctave The octave of index = 0.
         *  @return MIDI note number on this scale.
         */
        public function getNote(index:int) : int {
            var imax:int = _scaleNotes.length, octaveShift:int = 0;
            while (index < 0) {
                index += imax;
                octaveShift--;
            }
            while (index >= imax) {
                index -= imax;
                octaveShift++;
            }
            return _scaleNotes[index] + octaveShift*12;
        }
    }
}


