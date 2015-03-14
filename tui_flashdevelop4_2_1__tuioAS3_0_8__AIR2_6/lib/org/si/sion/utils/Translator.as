//----------------------------------------------------------------------------------------------------
// Translators
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.utils {
    import org.si.sion.module.*;
    import org.si.sion.sequencer.SiMMLTable;
    
    
    /** Translator */
    public class Translator
    {
        /** constructor */
        function Translator()
        {
        }
        
        
        
        
    // mckc
    //--------------------------------------------------
        /** Translate ppmckc mml to SiOPM mml. */
        static public function mckc(mckcMML:String) : String
        {
            // If I have motivation ..., or I wish someone who know mck well would do ...
            return mckcMML;
        }
        
        
        
        
    // tsscp
    //--------------------------------------------------
        /** Translate pTSSCP mml to SiOPM mml. */
        static public function tsscp(tsscpMML:String, volumeByX:Boolean=true) : String
        {
            var mml:String, com:String, str1:String, str2:String, i:int, imax:int, volUp:String, volDw:String, rex:RegExp, rex_sys:RegExp, rex_com:RegExp, res:*;
            
        // translate mml
        //--------------------------------------------------
            var noteLetters:String = "cdefgab";
            var noteShift:Array  = [0,2,4,5,7,9,11];
            var panTable:Array = ["@v0","p0","p8","p4"];
            var table:SiMMLTable = SiMMLTable.instance;
            var charCodeA:int = "a".charCodeAt(0);
            var charCodeG:int = "g".charCodeAt(0);
            var charCodeR:int = "r".charCodeAt(0);
            var hex:String = "0123456789abcdef";
            var p0:int, p1:int, p2:int, p3:int, p4:int, reql8:Boolean, octave:int, revOct:Boolean, 
                loopOct:int, loopMacro:Boolean, loopMMLBefore:String, loopMMLContent:String;

            rex  = new RegExp("(;|(/:|:/|ml|mp|na|ns|nt|ph|@kr|@ks|@ml|@ns|@apn|@[fkimopqsv]?|[klopqrstvx$%<>(){}[\\]|_~^/&*]|[a-g][#+\\-]?)\\s*([\\-\\d]*)[,\\s]*([\\-\\d]+)?[,\\s]*([\\-\\d]+)?[,\\s]*([\\-\\d]+)?[,\\s]*([\\-\\d]+)?)|#(FM|[A-Z]+)=?\\s*([^;]*)|([A-Z])(\\(([a-g])([\\-+#]?)\\))?|.", "gms");
            rex_sys = /\s*([0-9]*)[,=<\s]*([^>]*)/ms;
            rex_com = /[{}]/gms;

            volUp = "(";
            volDw = ")";
            mml = "";
            reql8 = true;
            octave = 5;
            revOct = false;
            loopOct = -1;
            loopMacro = false;
            loopMMLBefore = undefined;
            loopMMLContent = undefined;
            res = rex.exec(tsscpMML);
            while (res) {
                if (res[1] != undefined) {
                    if (res[1] == ';') {
                        mml += res[0];
                        reql8 = true;
                    } else {
                        // mml commands
                        i = res[2].charCodeAt(0);
                        if ((charCodeA <= i && i <= charCodeG) || i == charCodeR) {
                            if (reql8) mml += "l8" + res[0];
                            else       mml += res[0];
                            reql8 = false;
                        } else {
                            switch (res[2]) {
                                case 'l':   { mml += res[0]; reql8 = false; }break;
                                case '/:':  { mml += "[" + res[3]; }break;
                                case ':/':  { mml += "]"; }break;
                                case '/':   { mml += "|"; }break;
                                case '~':   { mml += volUp + res[3]; }break;
                                case '_':   { mml += volDw + res[3]; }break;
                                case 'q':   { mml += "q" + String((int(res[3])+1)>>1); }break;
                                case '@m':  { mml += "@mask" + String(int(res[3])); }break;
                                case 'ml':  { mml += "@ml" + String(int(res[3])); }break;
                                case 'p':   { mml += panTable[int(res[3])&3]; }break;
                                case '@p':  { mml += "@p" + String(int(res[3])-64); }break;
                                case 'ph':  { mml += "@ph" + String(int(res[3])); }break;
                                case 'ns':  { mml += "kt"  + res[3]; }break;
                                case '@ns': { mml += "!@ns" + res[3]; }break;
                                case 'k':   { p0 = Number(res[3]) * 4;     mml += "k"  + String(p0); }break;
                                case '@k':  { p0 = Number(res[3]) * 0.768; mml += "k"  + String(p0); }break;
                                case '@kr': { p0 = Number(res[3]) * 0.768; mml += "!@kr" + String(p0); }break;
                                case '@ks': { mml += "@,,,,,,," + String(int(res[3]) >> 5); }break;
                                case 'na':  { mml += "!" + res[0]; }break;
                                case 'o':   { mml += res[0]; octave = int(res[3]); }break;
                                case '<':   { mml += res[0]; octave += (revOct) ? -1 :  1; }break;
                                case '>':   { mml += res[0]; octave += (revOct) ?  1 : -1; }break;
                                case '%':   { mml += (res[3] == '6') ? '%4' : res[0]; }break;
                                
                                case '@ml': { 
                                    p0 = int(res[3])>>7;
                                    p1 = int(res[3]) - (p0<<7);
                                    mml += "@ml" + String(p0) + "," + String(p1);
                                }break;
                                case 'mp': {
                                    p0 = int(res[3]); p1 = int(res[4]); p2 = int(res[5]); p3 = int(res[6]); p4 = int(res[7]);
                                    if (p3 == 0) p3 = 1;
                                    switch(p0) {
                                    case 0:  mml += "mp0"; break;
                                    case 1:  mml += "@lfo" + String((int(p1/p3)+1)*4*p2) + "mp" + String(p1);   break;
                                    default: mml += "@lfo" + String((int(p1/p3)+1)*4*p2) + "mp0," + String(p1) + "," + String(p0);   break;
                                    }
                                }break;
                                case 'v': {
                                    if (volumeByX) {
                                        p0 = (res[3].length == 0) ? 40 : ((int(res[3])<<2)+(int(res[3])>>2));
                                        if (res[4]) {
                                            p1 = (int(res[4])<<2) + (int(res[4])>>2);
                                            p2 = (p1 > 0) ? (int(Math.atan(p0/p1)*81.48733086305041)) : 128; // 81.48733086305041 = 128/(PI*0.5)
                                            p3 = (p0 > p1) ? p0 : p1;
                                            mml += "@p" + String(p2) + "x" + String(p3);
                                        } else {
                                            mml += "x" + String(p0);
                                        }
                                    } else {
                                        p0 = (res[3].length == 0) ? 10 : (res[3]);
                                        if (res[4]) {
                                            p1 = res[4];
                                            p2 = (p1 > 0) ? (int(Math.atan(p0/p1)*81.48733086305041)) : 128; // 81.48733086305041 = 128/(PI*0.5)
                                            p3 = (p0 > p1) ? p0 : p1;
                                            mml += "@p" + String(p2) + "v" + String(p3);
                                        } else {
                                            mml += "v" + String(p0);
                                        }
                                    }
                                }break;
                                case '@v': {
                                    if (volumeByX) {
                                        p0 = (res[3].length == 0) ? 40 : (int(res[3])>>2);
                                        if (res[4]) {
                                            p1 = int(res[4])>>2;
                                            p2 = (p1 > 0) ? (int(Math.atan(p0/p1)*81.48733086305041)) : 128; // 81.48733086305041 = 128/(PI*0.5)
                                            p3 = (p0 > p1) ? p0 : p1;
                                            mml += "@p" + String(p2) + "x" + String(p3);
                                        } else {
                                            mml += "x" + String(p0);
                                        }
                                    } else {
                                        p0 = (res[3].length == 0) ? 10 : (int(res[3])>>4);
                                        if (res[4]) {
                                            p1 = int(res[4])>>4;
                                            p2 = (p1 > 0) ? (int(Math.atan(p0/p1)*81.48733086305041)) : 128; // 81.48733086305041 = 128/(PI*0.5)
                                            p3 = (p0 > p1) ? p0 : p1;
                                            mml += "@p" + String(p2) + "v" + String(p3);
                                        } else {
                                            mml += "v" + String(p0);
                                        }
                                    }
                                }break;
                                case 's': {
                                    p0 = int(res[3]); p1 = int(res[4]);
                                    mml += "s" + table.tss_s2rr[p0&255];
                                    if (p1!=0) mml += ","  + String(p1*3);
                                }break;
                                case '@s': {
                                    p0 = int(res[3]); p1 = int(res[4]); p3 = int(res[6]);
                                    p2 = (int(res[5]) >= 100) ? 15 : int(Number(res[5])*0.09);
                                    mml += (p0 == 0) ? "@,63,0,0,,0" : (
                                        "@," + table.tss_s2ar[p0&255] + ","  + table.tss_s2dr[p1&255] + "," + table.tss_s2sr[p3&255] + ",," + String(p2)
                                    );
                                }break;
                                case '{': {
                                    i = 1;
                                    p0 = res.index + 1;
                                    rex_com.lastIndex = p0;
                                    do {
                                        res = rex_com.exec(tsscpMML);
                                            if (res == null) throw errorTranslation("{{...} ?");
                                        if (res[0] == '{') i++;
                                        else if (res[0] == '}') --i;
                                    } while (i);
                                    mml += "/*{" + tsscpMML.substring(p0, res.index) + "}*/";
                                    rex.lastIndex = res.index + 1;
                                }break;
                                    
                                case '[': { 
                                    if (loopMMLBefore) errorTranslation("[[...] ?");
                                    loopMacro = false;
                                    loopMMLBefore = mml;
                                    loopMMLContent = undefined;
                                    mml = res[3];
                                    loopOct = octave;
                                }break;
                                case '|': {
                                    if (!loopMMLBefore) errorTranslation("'|' can be only in '[...]'");
                                    loopMMLContent = mml; 
                                    mml = "";
                                }break;
                                case ']': {
                                    if (!loopMMLBefore) errorTranslation("[...]] ?");
                                    if (!loopMacro && loopOct==octave) {
                                        if (loopMMLContent)  mml = loopMMLBefore + "[" + loopMMLContent + "|" + mml + "]";
                                        else                 mml = loopMMLBefore + "[" + mml + "]";
                                    } else {
                                        if (loopMMLContent)  mml = loopMMLBefore + "![" + loopMMLContent + "!|" + mml + "!]";
                                        else                 mml = loopMMLBefore + "![" + mml + "!]";
                                    }
                                    loopMMLBefore = undefined;
                                    loopMMLContent = undefined;
                                }break;

                                case '}': 
                                    throw errorTranslation("{...}} ?");
                                case '@apn': case 'x':
                                    break;
                                
                                default: {
                                    mml += res[0];
                                }break;
                            }
                        }
                    }
                } else 
                
                if (res[10] != undefined) {
                    // macro expansion
                    if (reql8) mml += "l8" + res[10];
                    else       mml += res[10];
                    reql8 = false;
                    loopMacro = true;
                    if (res[11] != undefined) {
                        // note shift
                        i = noteShift[noteLetters.indexOf(res[12])];
                        if (res[13] == '+' || res[13] == '#') i++;
                        else if (res[13] == '-') i--;
                        mml += "(" + String(i) + ")";
                    }
                } else 
                
                if (res[8] != undefined) {
                    // system command
                    str1 = res[8];
                    switch (str1) {
                        case 'END':    { mml += "#END"; }break;
                        case 'OCTAVE': { 
                            if (res[9] == 'REVERSE') {
                                mml += "#REV{octave}"; 
                                revOct = true;
                            }
                        }break;
                        case 'OCTAVEREVERSE': { 
                            mml += "#REV{octave}"; 
                            revOct = true;
                        }break;
                        case 'VOLUME': {
                            if (res[9] == 'REVERSE') {
                                volUp = ")";
                                volDw = "(";
                                mml += "#REV{volume}";
                            }
                        }break;
                        case 'VOLUMEREVERSE': {
                            volUp = ")";
                            volDw = "(";
                            mml += "#REV{volume}";
                        }break;
                        
                        case 'TABLE': {
                            res = rex_sys.exec(res[9]);
                            mml += "#TABLE" + res[1] + "{" + res[2] + "}*0.25";
                        }break;
                        
                        case 'WAVB': {
                            res = rex_sys.exec(res[9]);
                            str1 = String(res[2]);
                            mml += "#WAVB" + res[1] + "{";
                            for (i=0; i<32; i++) {
                                p0 = int("0x" + str1.substr(i<<1, 2));
                                p0 = (p0<128) ? (p0+127) : (p0-128);
                                mml += hex.charAt(p0>>4) + hex.charAt(p0&15);
                            }
                            mml += "}";
                        }break;
                        
                        case 'FM': {
                            mml += "#FM{" + String(res[9]).replace(/([A-Z])([0-9])?(\()?/g, 
                                function() : String {
                                    var num:int = (arguments[2]) ? (int(arguments[2])) : 3;
                                    var str:String = (arguments[3]) ? (String(num) + "(") : "";
                                    return String(arguments[1]).toLowerCase() + str;
                                }
                            ) + "}" ;//))
                        }break;
                        
                        case 'FINENESS':
                        case 'MML':
                            // skip next ";"
                            res = rex.exec(tsscpMML);
                            break;
                        default: {
                            if (str1.length == 1) {
                                // macro
                                mml += "#" + str1 + "=";
                                rex.lastIndex -= res[9].length;
                                reql8 = false;
                            } else {
                                // other system events
                                res = rex_sys.exec(res[9]);
                                if (res[2].length == 0) return "#" + str1 + res[1];
                                mml += "#" + str1 + res[1] + "{" + res[2] + "}";
                            }
                        }break;
                    }
                } else 
                
                {
                    mml += res[0];
                }
                res = rex.exec(tsscpMML);
            }
            tsscpMML = mml;
            
            return tsscpMML;
        }
        
        
        
        
    // FM parameters
    //--------------------------------------------------
    // parse MML string
    //--------------------------------------------------
        /** parse inside of #&#64;{..}; */
        static public function parseParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setParamByArray(param, _splitDataString(param, dataString, 3, 15, "#@"));
        }
        
        
        /** parse inside of #OPL&#64;{..}; */
        static public function parseOPLParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setOPLParamByArray(param, _splitDataString(param, dataString, 2, 11, "#OPL@"));
        }
        
        
        /** parse inside of #OPM&#64;{..}; */
        static public function parseOPMParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setOPMParamByArray(param, _splitDataString(param, dataString, 2, 11, "#OPM@"));
        }
        
        
        /** parse inside of #OPN&#64;{..}; */
        static public function parseOPNParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setOPNParamByArray(param, _splitDataString(param, dataString, 2, 10, "#OPN@"));
        }
        
        
        /** parse inside of #OPX&#64;{..}; */
        static public function parseOPXParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setOPXParamByArray(param, _splitDataString(param, dataString, 2, 12, "#OPX@"));
        }
        
        
        /** parse inside of #MA&#64;{..}; */
        static public function parseMA3Param(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setMA3ParamByArray(param, _splitDataString(param, dataString, 2, 12, "#MA@"));
        }
        
        
    // set by Array
    //--------------------------------------------------
        /** set inside of #&#64;{..}; */
        static public function setParam(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam {
            return _setParamByArray(_checkOpeCount(param, data.length, 3, 15, "#@"), data);
        }
        
        
        /** set inside of #OPL&#64;{..}; */
        static public function setOPLParam(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam {
            return _setOPLParamByArray(_checkOpeCount(param, data.length, 2, 11, "#OPL@"), data);
        }
        
        
        /** set inside of #OPM&#64;{..}; */
        static public function setOPMParam(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam {
            return _setOPMParamByArray(_checkOpeCount(param, data.length, 2, 11, "#OPM@"), data);
        }
        
        
        /** set inside of #OPN&#64;{..}; */
        static public function setOPNParam(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam {
            return _setOPNParamByArray(_checkOpeCount(param, data.length, 2, 10, "#OPN@"), data);
        }
        
        
        /** set inside of #OPX&#64;{..}; */
        static public function setOPXParam(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam {
            return _setOPXParamByArray(_checkOpeCount(param, data.length, 2, 12, "#OPX@"), data);
        }
        
        
        /** set inside of #MA&#64;{..}; */
        static public function setMA3Param(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam {
            return _setMA3ParamByArray(_checkOpeCount(param, data.length, 2, 12, "#MA@"), data);
        }
        
        
        
        
    // internal functions
    //--------------------------------------------------
        // split dataString of #@ macro
        static private function _splitDataString(param:SiOPMChannelParam, dataString:String, chParamCount:int, opParamCount:int, cmd:String) : Array
        {
            var data:Array, i:int;
            
            // parse parameters
            if (dataString == "") {
                param.opeCount = 0;
            } else {
                data = dataString.replace(/^[^\d\-.]+|[^\d\-.]+$/g, "").split(/[^\d\-.]+/gm);
                for (i=1; i<5; i++) {
                    if (data.length == chParamCount + opParamCount*i) {
                        param.opeCount = i;
                        return data;
                    }
                }
                throw errorToneParameterNotValid(cmd, chParamCount, opParamCount);
            }
            return null;
        }
        
        
        // check param.opeCount
        static private function _checkOpeCount(param:SiOPMChannelParam, dataLength:int, chParamCount:int, opParamCount:int, cmd:String) : SiOPMChannelParam
        {
            var opeCount:int = (dataLength - chParamCount) / opParamCount;
            if (opeCount > 4 || opeCount*opParamCount+chParamCount != dataLength) throw errorToneParameterNotValid(cmd, chParamCount, opParamCount);
            param.opeCount = opeCount;
            return param;
        }
        
        
        // #@
        // alg[0-15], fb[0-7], fbc[0-3], 
        // (ws[0-1023], ar[0-63], dr[0-63], sr[0-63], rr[0-63], sl[0-15], tl[0-127], ksr[0-3], ksl[0-3], mul[], dt1[0-7], detune[], ams[0-3], phase[-1-255], fixedNote[0-127]) x operator_count
        static private function _setParamByArray(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            param.alg = int(data[0]);
            param.fb  = int(data[1]);
            param.fbc = int(data[2]);
            var dataIndex:int = 3, n:Number, i:int;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.setPGType(int(data[dataIndex++]) & 511); // 1
                opp.ar     = int(data[dataIndex++]) & 63;   // 2
                opp.dr     = int(data[dataIndex++]) & 63;   // 3
                opp.sr     = int(data[dataIndex++]) & 63;   // 4
                opp.rr     = int(data[dataIndex++]) & 63;   // 5
                opp.sl     = int(data[dataIndex++]) & 15;   // 6
                opp.tl     = int(data[dataIndex++]) & 127;  // 7
                opp.ksr    = int(data[dataIndex++]) & 3;    // 8
                opp.ksl    = int(data[dataIndex++]) & 3;    // 9
                n = Number(data[dataIndex++]);
                opp.fmul   = (n==0) ? 64 : int(n*128);      // 10
                opp.dt1    = int(data[dataIndex++]) & 7;    // 11
                opp.detune = int(data[dataIndex++]);        // 12
                opp.ams    = int(data[dataIndex++]) & 3;    // 13
                i = int(data[dataIndex++]);
                opp.phase  = (i==-1) ? i : (i & 255);           // 14
                opp.fixedPitch = (int(data[dataIndex++]) & 127)<<6;  // 15
            }
            return param;
        }
        
        
        // #OPL@
        // alg[0-5], fb[0-7], 
        // (ws[0-7], ar[0-15], dr[0-15], rr[0-15], egt[0,1], sl[0-15], tl[0-63], ksr[0,1], ksl[0-3], mul[0-15], ams[0-3]) x operator_count
        static private function _setOPLParamByArray(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:int = SiMMLTable.instance.alg_opl[param.opeCount-1][int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#OPL@ algorism", data[0]);
            
            param.fratio = 133;
            param.alg = alg;
            param.fb  = int(data[1]);
            var dataIndex:int = 2, i:int;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.setPGType(SiOPMTable.PG_MA3_WAVE + (int(data[dataIndex++])&31));    // 1
                opp.ar  = (int(data[dataIndex++]) << 2) & 63;   // 2
                opp.dr  = (int(data[dataIndex++]) << 2) & 63;   // 3
                opp.rr  = (int(data[dataIndex++]) << 2) & 63;   // 4
                // egt=0;decay tone / egt=1;holding tone           5
                opp.sr  = (int(data[dataIndex++]) != 0) ? 0 : opp.rr;
                opp.sl  = int(data[dataIndex++]) & 15;          // 6
                opp.tl  = int(data[dataIndex++]) & 63;          // 7
                opp.ksr = (int(data[dataIndex++])<<1) & 3;      // 8
                opp.ksl = int(data[dataIndex++]) & 3;           // 9
                i = int(data[dataIndex++]) & 15;                // 10
                opp.mul = (i==11 || i==13) ? (i-1) : (i==14) ? (i+1) : i;
                opp.ams = int(data[dataIndex++]) & 3;           // 11
                // multiple
            }
            return param;
        }
        
        
        // #OPM@
        // alg[0-7], fb[0-7], 
        // (ar[0-31], dr[0-31], sr[0-31], rr[0-15], sl[0-15], tl[0-127], ks[0-3], mul[0-15], dt1[0-7], dt2[0-3], ams[0-3]) x operator_count
        static private function _setOPMParamByArray(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:int = SiMMLTable.instance.alg_opm[param.opeCount-1][int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#OPN@ algorism", data[0]);

            param.alg = alg;
            param.fb  = int(data[1]);
            var dataIndex:int = 2;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.ar  = (int(data[dataIndex++]) << 1) & 63;       // 1
                opp.dr  = (int(data[dataIndex++]) << 1) & 63;       // 2
                opp.sr  = (int(data[dataIndex++]) << 1) & 63;       // 3
                opp.rr  = ((int(data[dataIndex++]) << 2) + 2) & 63; // 4
                opp.sl  = int(data[dataIndex++]) & 15;              // 5
                opp.tl  = int(data[dataIndex++]) & 127;             // 6
                opp.ksr = int(data[dataIndex++]) & 3;               // 7
                opp.mul = int(data[dataIndex++]) & 15;              // 8
                opp.dt1 = int(data[dataIndex++]) & 7;               // 9
                opp.detune = SiOPMTable.instance.dt2Table[data[dataIndex++] & 3];    // 10
                opp.ams = int(data[dataIndex++]) & 3;               // 11
            }
            return param;
        }
        
        
        // #OPN@
        // alg[0-7], fb[0-7], 
        // (ar[0-31], dr[0-31], sr[0-31], rr[0-15], sl[0-15], tl[0-127], ks[0-3], mul[0-15], dt1[0-7], ams[0-3]) x operator_count
        static private function _setOPNParamByArray(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:int = SiMMLTable.instance.alg_opm[param.opeCount-1][int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#OPN@ algorism", data[0]);

            param.alg = alg;
            param.fb  = int(data[1]);
            var dataIndex:int = 2;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.ar  = (int(data[dataIndex++]) << 1) & 63;       // 1
                opp.dr  = (int(data[dataIndex++]) << 1) & 63;       // 2
                opp.sr  = (int(data[dataIndex++]) << 1) & 63;       // 3
                opp.rr  = ((int(data[dataIndex++]) << 2) + 2) & 63; // 4
                opp.sl  = int(data[dataIndex++]) & 15;              // 5
                opp.tl  = int(data[dataIndex++]) & 127;             // 6
                opp.ksr = int(data[dataIndex++]) & 3;               // 7
                opp.mul = int(data[dataIndex++]) & 15;              // 8
                opp.dt1 = int(data[dataIndex++]) & 7;               // 9
                opp.ams = int(data[dataIndex++]) & 3;               // 10
            }
            return param;
        }
        
        
        // #OPX@
        // alg[0-15], fb[0-7], 
        // (ws[0-7], ar[0-31], dr[0-31], sr[0-31], rr[0-15], sl[0-15], tl[0-127], ks[0-3], mul[0-15], dt1[0-7], detune[], ams[0-3]) x operator_count
        static private function _setOPXParamByArray(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:int = SiMMLTable.instance.alg_opx[param.opeCount-1][int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#OPX@ algorism", data[0]);
            
            param.alg = (alg & 15);
            param.fb  = int(data[1]);
            param.fbc = (alg & 16) ? 1 : 0;
            var dataIndex:int = 2, i:int;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                i = int(data[dataIndex++]);
                opp.setPGType((i<7) ? (SiOPMTable.PG_MA3_WAVE+(i&7)) : (SiOPMTable.PG_CUSTOM+(i-7)));    // 1
                opp.ar  = (int(data[dataIndex++]) << 1) & 63;       // 2
                opp.dr  = (int(data[dataIndex++]) << 1) & 63;       // 3
                opp.sr  = (int(data[dataIndex++]) << 1) & 63;       // 4
                opp.rr  = ((int(data[dataIndex++]) << 2) + 2) & 63; // 5
                opp.sl  = int(data[dataIndex++]) & 15;              // 6
                opp.tl  = int(data[dataIndex++]) & 127;             // 7
                opp.ksr = int(data[dataIndex++]) & 3;               // 8
                opp.mul = int(data[dataIndex++]) & 15;              // 9
                opp.dt1 = int(data[dataIndex++]) & 7;               // 10
                opp.detune = int(data[dataIndex++]);                // 11
                opp.ams = int(data[dataIndex++]) & 3;               // 12
            }
            return param;
        }
        
        
        // #MA@
        // alg[0-15], fb[0-7], 
        // (ws[0-31], ar[0-15], dr[0-15], sr[0-15], rr[0-15], sl[0-15], tl[0-63], ksr[0,1], ksl[0-3], mul[0-15], dt1[0-7], ams[0-3]) x operator_count
        static private function _setMA3ParamByArray(param:SiOPMChannelParam, data:Array) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:int = SiMMLTable.instance.alg_ma3[param.opeCount-1][int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#MA@ algorism", data[0]);
            
            param.fratio = 133;
            param.alg = alg;
            param.fb  = int(data[1]);
            var dataIndex:int = 2, i:int;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.setPGType(SiOPMTable.PG_MA3_WAVE + (int(data[dataIndex++]) & 31)); // 1
                opp.ar  = (int(data[dataIndex++]) << 2) & 63;   // 2
                opp.dr  = (int(data[dataIndex++]) << 2) & 63;   // 3
                opp.sr  = (int(data[dataIndex++]) << 2) & 63;   // 4
                opp.rr  = (int(data[dataIndex++]) << 2) & 63;   // 5
                opp.sl  = int(data[dataIndex++]) & 15;          // 6
                opp.tl  = int(data[dataIndex++]) & 63;          // 7
                opp.ksr = (int(data[dataIndex++])<<1) & 3;      // 8
                opp.ksl = int(data[dataIndex++]) & 3;           // 9
                i = int(data[dataIndex++]) & 15;                // 10
                opp.mul = (i==11 || i==13) ? (i-1) : (i==14) ? (i+1) : i;
                opp.dt1 = int(data[dataIndex++]) & 7;           // 11
                opp.ams = int(data[dataIndex++]) & 3;           // 12
            }
            return param;
        }
        

        
        
    // get by Array
    //--------------------------------------------------
        /** get inside of #&#64;{..}; */
        static public function getParam(param:SiOPMChannelParam) : Array {
            if (param.opeCount == 0) return null;
            var res:Array = [param.alg, param.fb, param.fbc];
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                res.push(opp.pgType, opp.ar, opp.dr, opp.sr, opp.rr, opp.sl, opp.tl, opp.ksr, opp.ksl, opp.mul, opp.dt1, opp.detune, opp.ams, opp.phase, opp.fixedPitch>>6);
            }
            return res;
        }
        
        
        /** get inside of #OPL&#64;{..}; */
        static public function getOPLParam(param:SiOPMChannelParam) : Array {
            if (param.opeCount == 0) return null;
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opl);
            if (alg == -1) throw errorParameterNotValid("#OPL@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            var res:Array = [alg, param.fb];
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex],
                    ws :int = _pgTypeMA3(opp.pgType),
                    egt:int = (opp.sr == 0) ? 1 : 0,
                    tl :int = (opp.tl < 63) ? opp.tl : 63;
                if (ws == -1) throw errorParameterNotValid("#OPL@", "SiOPM ws" + String(opp.pgType));
                res.push(ws, opp.ar>>2, opp.dr>>2, opp.rr>>2, egt, opp.sl, tl, opp.ksr>>1, opp.ksl, opp.mul, opp.ams);
            }
            return res;
        }
        
        
        /** get inside of #OPM&#64;{..}; */
        static public function getOPMParam(param:SiOPMChannelParam) : Array {
            if (param.opeCount == 0) return null;
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opm);
            if (alg == -1) throw errorParameterNotValid("#OPM@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            var res:Array = [alg, param.fb];
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex],
                    dt2:int = _dt2OPM(opp.detune);
                res.push(opp.ar>>1, opp.dr>>1, opp.sr>>1, opp.rr>>2, opp.sl, opp.tl, opp.ksr, opp.mul, opp.dt1, dt2, opp.ams);
            }
            return res;
        }
        
        
        /** get inside of #OPN&#64;{..}; */
        static public function getOPNParam(param:SiOPMChannelParam) : Array {
            if (param.opeCount == 0) return null;
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opm);
            if (alg == -1) throw errorParameterNotValid("#OPN@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            var res:Array = [alg, param.fb];
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                res.push(opp.ar>>1, opp.dr>>1, opp.sr>>1, opp.rr>>2, opp.sl, opp.tl, opp.ksr, opp.mul, opp.dt1, opp.ams);
            }
            return res;
        }
        
        
        /** get inside of #OPX&#64;{..}; */
        static public function getOPXParam(param:SiOPMChannelParam) : Array {
            if (param.opeCount == 0) return null;
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opx);
            if (alg == -1) throw errorParameterNotValid("#OPX@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            var res:Array = [alg, param.fb];
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex],
                    ws :int = _pgTypeMA3(opp.pgType);
                if (ws == -1) throw errorParameterNotValid("#OPX@", "SiOPM ws" + String(opp.pgType));
                res.push(ws, opp.ar>>1, opp.dr>>1, opp.sr>>1, opp.rr>>2, opp.sl, opp.tl, opp.ksr, opp.mul, opp.dt1, opp.detune, opp.ams);
            }
            return res;
        }
        
        
        /** get inside of #MA&#64;{..}; */
        static public function getMA3Param(param:SiOPMChannelParam) : Array {
            if (param.opeCount == 0) return null;
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_ma3);
            if (alg == -1) throw errorParameterNotValid("#MA@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            var res:Array = [alg, param.fb];
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex],
                    ws :int = _pgTypeMA3(opp.pgType),
                    tl :int = (opp.tl < 63) ? opp.tl : 63;
                if (ws == -1) throw errorParameterNotValid("#MA@", "SiOPM ws" + String(opp.pgType));
                res.push(ws, opp.ar>>2, opp.dr>>2, opp.sr>>2, opp.rr>>2, opp.sl, tl, opp.ksr>>1, opp.ksl, opp.mul, opp.dt1, opp.ams);
            }
            return res;
        }
        
        
    // reconstruct MML string from channel parameters
    //--------------------------------------------------
        /** reconstruct mml text inside of #&#64;{..}; */
        static public function mmlParam(param:SiOPMChannelParam, separator:String, lineEnd:String, comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var mml:String = "", res:* = _checkDigit(param);
            mml += "{";
            mml += String(param.alg) + separator;
            mml += String(param.fb)  + separator;
            mml += String(param.fbc);
            if (comment) mml += "// " + comment;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                mml += _str(opp.pgType, res.ws) + separator;
                mml += _str(opp.ar, 2) + separator;
                mml += _str(opp.dr, 2) + separator;
                mml += _str(opp.sr, 2) + separator;
                mml += _str(opp.rr, 2) + separator;
                mml += _str(opp.sl, 2) + separator;
                mml += _str(opp.tl, res.tl) + separator;
                mml += String(opp.ksr) + separator;
                mml += String(opp.ksl) + separator;
                mml += _str(opp.mul, 2) + separator;
                mml += String(opp.dt1) + separator;
                mml += _str(opp.detune, res.dt) + separator;
                mml += String(opp.ams) + separator;
                mml += _str(opp.phase, res.ph) + separator
                mml += _str(opp.fixedPitch>>6, res.fn);
            }
            mml += "}" + _initSequence(param);
            
            return mml;
        }
        
        
        /** reconstruct mml text inside of #OPL&#64;{..}; */
        static public function mmlOPLParam(param:SiOPMChannelParam, separator:String, lineEnd:String, comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opl);
            if (alg == -1) throw errorParameterNotValid("#OPL@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            
            var mml:String = "", res:* = _checkDigit(param);
            mml += "{" + String(alg) + separator + String(param.fb);
            if (comment) mml += "  // " + comment;
                
            var pgType:int, tl:int;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                pgType = _pgTypeMA3(opp.pgType);
                if (pgType == -1) throw errorParameterNotValid("#OPL@", "SiOPM ws" + String(opp.pgType));
                mml += String(pgType) + separator;              // ws
                mml += _str(opp.ar >> 2, 2) + separator;        // ar
                mml += _str(opp.dr >> 2, 2) + separator;        // dr
                mml += _str(opp.rr >> 2, 2) + separator;        // rr
                mml += ((opp.sr == 0) ? "1" : "0") + separator; // egt
                mml += _str(opp.sl, 2) + separator;                 // sl
                mml += _str((opp.tl<63)?opp.tl:63, 2) + separator;  // tl
                mml += String(opp.ksr>>1) + separator;              // ksr
                mml += String(opp.ksl) + separator;                 // ksl
                mml += _str(opp.mul, 2) + separator;                // mul
                mml += String(opp.ams);                             // ams
            }
            mml += "}" + _initSequence(param);
            
            return mml;
        }
        
        
        /** reconstruct mml text inside of #OPM&#64;{..}; */
        static public function mmlOPMParam(param:SiOPMChannelParam, separator:String, lineEnd:String, comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opm);
            if (alg == -1) throw errorParameterNotValid("#OPM@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            
            var mml:String = "", res:* = _checkDigit(param);
            mml += "{" + String(alg) + separator + String(param.fb);
            if (comment) mml += "  // " + comment;
                
            var pgType:int, tl:int;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                // if (opp.pgType != 0) throw errorParameterNotValid("#OPM@", "SiOPM ws" + String(opp.pgType));
                mml += _str(opp.ar >> 1, 2) + separator;        // ar
                mml += _str(opp.dr >> 1, 2) + separator;        // dr
                mml += _str(opp.sr >> 1, 2) + separator;        // sr
                mml += _str(opp.rr >> 2, 2) + separator;        // rr
                mml += _str(opp.sl, 2) + separator;             // sl
                mml += _str(opp.tl, res.tl) + separator;        // tl
                mml += String(opp.ksl) + separator;             // ksl
                mml += _str(opp.mul, 2) + separator;            // mul
                mml += String(opp.dt1) + separator;             // dt1
                mml += String(_dt2OPM(opp.detune)) + separator; // dt2
                mml += String(opp.ams);                         // ams
            }
            mml += "}" + _initSequence(param);
            
            return mml;
        }
        
        
        /** reconstruct mml text inside of #OPN&#64;{..}; */
        static public function mmlOPNParam(param:SiOPMChannelParam, separator:String, lineEnd:String, comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opm);
            if (alg == -1) throw errorParameterNotValid("#OPN@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            
            var mml:String = "", res:* = _checkDigit(param);
            mml += "{" + String(alg) + separator + String(param.fb);
            if (comment) mml += "  // " + comment;

            var pgType:int, tl:int;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                // if (opp.pgType != 0) throw errorParameterNotValid("#OPN@", "SiOPM ws" + String(opp.pgType));
                mml += _str(opp.ar >> 1, 2) + separator;    // ar
                mml += _str(opp.dr >> 1, 2) + separator;    // dr
                mml += _str(opp.sr >> 1, 2) + separator;    // sr
                mml += _str(opp.rr >> 2, 2) + separator;    // rr
                mml += _str(opp.sl, 2) + separator;         // sl
                mml += _str(opp.tl, res.tl) + separator;    // tl
                mml += String(opp.ksl) + separator;         // ksl
                mml += _str(opp.mul, 2) + separator;        // mul
                mml += String(opp.dt1) + separator;         // dt1
                mml += String(opp.ams) + separator;         // ams
            }
            mml += "}" + _initSequence(param);
            
            return mml;
        }
        
        
        /** reconstruct mml text inside of #OPX&#64;{..}; */
        static public function mmlOPXParam(param:SiOPMChannelParam, separator:String, lineEnd:String, comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opx);
            if (alg == -1) throw errorParameterNotValid("#OPX@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            
            var mml:String = "", res:* = _checkDigit(param);
            mml += "{" + String(alg) + separator + String(param.fb);
            if (comment) mml += "  // " + comment;
            
            var pgType:int, tl:int;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                pgType = _pgTypeMA3(opp.pgType);
                if (pgType == -1) throw errorParameterNotValid("#OPX@", "SiOPM ws" + String(opp.pgType));
                mml += String(pgType) + separator;              // ws
                mml += _str(opp.ar >> 1, 2) + separator;        // ar
                mml += _str(opp.dr >> 1, 2) + separator;        // dr
                mml += _str(opp.sr >> 1, 2) + separator;        // sr
                mml += _str(opp.rr >> 2, 2) + separator;        // rr
                mml += _str(opp.sl, 2) + separator;             // sl
                mml += _str(opp.tl, res.tl) + separator;        // tl
                mml += String(opp.ksl) + separator;             // ksl
                mml += _str(opp.mul, 2) + separator;            // mul
                mml += String(opp.dt1) + separator;             // dt1
                mml += _str(opp.detune, res.dt) + separator;    // det
                mml += String(opp.ams);                         // ams
            }
            mml += "}" + _initSequence(param);
            
            return mml;
        }
        
        
        /** reconstruct mml text inside of #MA&#64;{..}; */
        static public function mmlMA3Param(param:SiOPMChannelParam, separator:String, lineEnd:String, comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_ma3);
            if (alg == -1) throw errorParameterNotValid("#MA@ alg", "SiOPM opc" + String(param.opeCount) + "/alg" + String(param.alg));
            
            var mml:String = "", res:* = _checkDigit(param);
            mml += "{" + String(alg) + separator + String(param.fb);
            if (comment) mml += "  // " + comment;
            
            var pgType:int, tl:int;
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                pgType = _pgTypeMA3(opp.pgType);
                if (pgType == -1) throw errorParameterNotValid("#MA@", "SiOPM ws" + String(opp.pgType));
                mml += String(pgType) + separator;                  // ws
                mml += _str(opp.ar >> 2, 2) + separator;            // ar
                mml += _str(opp.dr >> 2, 2) + separator;            // dr
                mml += _str(opp.sr >> 2, 2) + separator;            // sr
                mml += _str(opp.rr >> 2, 2) + separator;            // rr
                mml += _str(opp.sl, 2) + separator;                 // sl
                mml += _str((opp.tl<63)?opp.tl:63, 2) + separator;  // tl
                mml += String(opp.ksr>>1) + separator;              // ksr
                mml += String(opp.ksl) + separator;                 // ksl
                mml += _str(opp.mul, 2) + separator;                // mul
                mml += String(opp.dt1) + separator;                 // dt1
                mml += String(opp.ams);                             // ams
            }
            mml += "}" + _initSequence(param);
            
            return mml;
        }
        
        
        
        
    // internal functions
    //--------------------------------------------------
        // int to string with 0 filling
        static private function _str(v:int, length:int) : String {
            if (v>=0) return ("0000"+String(v)).substr(-length);
            return "-" + ("0000"+String(-v)).substr(-length+1);
        }
        
        
        // check parameters digit
        static private function _checkDigit(param:SiOPMChannelParam) : * {
            var res:* = {'ws':1, 'tl':2, 'dt':1, 'ph':1, 'fn':1};
            for (var opeIndex:int=0; opeIndex<param.opeCount; opeIndex++) {
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                res.ws = max(res.ws, String(opp.pgType).length);
                res.tl = max(res.tl, String(opp.tl).length);
                res.dt = max(res.dt, String(opp.detune).length);
                res.ph = max(res.ph, String(opp.phase).length);
                res.fn = max(res.fn, String(opp.fixedPitch>>6).length);
            }
            return res;
            
            function max(a:int, b:int) : int { return (a>b) ? a:b; }
        }
        
        
        // translate algorism by algorism list, return index in the list.
        static private function _checkAlgorism(oc:int, al:int, algList:Array) : int {
            var list:Array = algList[oc-1];
            for (var i:int=0; i<list.length; i++) if (al == list[i]) return i;
            return -1;
        }
        
        
        // translate pgType to MA3 valid.
        static private function _pgTypeMA3(pgType:int) : int {
            var ws:int = pgType - SiOPMTable.PG_MA3_WAVE;
            if (ws>=0 && ws<=31) return ws;
            switch (pgType) {
            case 0:                             return 0;   // sin
            case 1: case 2: case 128: case 255: return 24;  // saw
            case 4: case 192: case 191:         return 16;  // triangle
            case 5: case 72:                    return 6;   // square
            }
            return -1;
        }
        
        
        // find dt2 value
        static private function _dt2OPM(detune:int) : int {
                 if (detune <= 100) return 0;   // 0
            else if (detune <= 420) return 1;   // 384
            else if (detune <= 550) return 2;   // 500
            return 3;                           // 608
        }
        
        
        // reconstruct initializing sequence
        static private function _initSequence(param:SiOPMChannelParam) : String {
            var mml:String = "";
            if (param.cutoff<128 || param.resonanse>0 || param.far>0 || param.frr>0) {
                mml += "@f" + String(param.cutoff) + "," + String(param.resonanse);
                if (param.far>0 || param.frr>0) {
                    mml += "," + String(param.far)  + "," + String(param.fdr1) + "," + String(param.fdr2) + "," + String(param.frr);
                    mml += "," + String(param.fdc1) + "," + String(param.fdc2) + "," + String(param.fsc)  + "," + String(param.frc);
                }
            }
            return mml;
        }
        
        
        
    // errors
    //--------------------------------------------------
        static public function errorToneParameterNotValid(cmd:String, chParam:int, opParam:int) : Error
        {
            return new Error("Translator error : Parameter count is not valid in '" + cmd + "'. " + String(chParam) + " parameters for channel and " + String(opParam) + " parameters for each operator.");
        }
        
        
        static public function errorParameterNotValid(cmd:String, param:String) : Error
        {
            return new Error("Translator error : Parameter not valid. '" + param + "' in " + cmd);
        }
        
        
        static public function errorTranslation(str:String) : Error
        {
            return new Error("Translator Error : mml error. '" + str + "'");
        }
    }
}

