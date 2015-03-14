//----------------------------------------------------------------------------------------------------
// SiON Voice data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion {
    import org.si.sion.utils.Translator;
    import org.si.sion.sequencer.SiMMLVoice;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.sion.module.SiOPMChannelParam;
    
    
    /** SiON Voice data. This includes SiOPMChannelParam.
     *  @see org.si.sion.module.SiOPMChannelParam
     *  @see org.si.sion.module.SiOPMOperatorParam
     */
    public class SiONVoice extends SiMMLVoice
    {
    // constant
    //--------------------------------------------------
        static public const CHIPTYPE_SIOPM:String = "";
        static public const CHIPTYPE_OPL:String = "OPL";
        static public const CHIPTYPE_OPM:String = "OPM";
        static public const CHIPTYPE_OPN:String = "OPN";
        static public const CHIPTYPE_OPX:String = "OPX";
        static public const CHIPTYPE_MA3:String = "MA3";
        static public const CHIPTYPE_PMS_GUITAR:String = "PMSGuitar";
        
        
        
        
    // variables
    //--------------------------------------------------
        /** voice name */
        public var name:String;
        
        /** chip type */
        public var chipType:String;
        
        
        
        
    // constrctor
    //--------------------------------------------------
        /** create new SiONVoice instance with '%' parameters, attack rate, release rate and pitchShift.
         *  @param moduleType Module type. 1st argument of '%'.
         *  @param channelNum Channel number. 2nd argument of '%'.
         *  @param ar Attack rate (0-63).
         *  @param rr Release rate (0-63).
         *  @param dt pitchShift (64=1halftone).
         */
        function SiONVoice(moduleType:int=5, channelNum:int=0, ar:int=63, rr:int=63, dt:int=0)
        {
            super();
            
            name = "";
            chipType = "";
            setModuleType(moduleType, channelNum);
            channelParam.operatorParam[0].ar = ar;
            channelParam.operatorParam[0].rr = rr;
            pitchShift = dt;
        }
        
        
        
        
    // parameter setter / getter
    //--------------------------------------------------
        /** Set by #&#64; parameters Array */
        public function set param(args:Array)    : void { Translator.setParam(channelParam, args);    chipType = ""; }
        
        /** Set by #OPL&#64; parameters Array */
        public function set paramOPL(args:Array) : void { Translator.setOPLParam(channelParam, args); chipType = "OPL"; }
        
        /** Set by #OPM&#64; parameters Array */
        public function set paramOPM(args:Array) : void { Translator.setOPMParam(channelParam, args); chipType = "OPM"; }
        
        /** Set by #OPN&#64; parameters Array */
        public function set paramOPN(args:Array) : void { Translator.setOPNParam(channelParam, args); chipType = "OPN"; }
        
        /** Set by #OPX&#64; parameters Array */
        public function set paramOPX(args:Array) : void { Translator.setOPXParam(channelParam, args); chipType = "OPX"; }
        
        /** Set by #MA&#64; parameters Array */
        public function set paramMA3(args:Array) : void { Translator.setMA3Param(channelParam, args); chipType = "MA3"; }
        
        
        /** Get #&#64; parameters by Array */
        public function get param()    : Array { return Translator.getParam(channelParam); }
        
        /** Get #OPL&#64; parameters by Array */
        public function get paramOPL() : Array { return Translator.getOPLParam(channelParam); }
        
        /** Get #OPM&#64; parameters by Array */
        public function get paramOPM() : Array { return Translator.getOPMParam(channelParam); }
        
        /** Get #OPN&#64; parameters by Array */
        public function get paramOPN() : Array { return Translator.getOPNParam(channelParam); }
        
        /** Get #OPX&#64; parameters by Array */
        public function get paramOPX() : Array { return Translator.getOPXParam(channelParam); }
        
        /** Get #MA&#64; parameters by Array */
        public function get paramMA3() : Array { return Translator.getMA3Param(channelParam); }
        
        
        /** get MML.
         *  @param index voice number.
         *  @param type chip type. choose string from SiONVoice.CHIPTYPE_* or null to detect automatically.
         *  @return mml string of this voice setting.
         */
        public function getMML(index:int, type:String = null) : String {
            if (type == null) type = chipType;
            switch (type) {
            case "OPL": return "#OPL@" + String(index) + Translator.mmlOPLParam(channelParam, " ", "\n", name);
            case "OPM": return "#OPM@" + String(index) + Translator.mmlOPMParam(channelParam, " ", "\n", name);
            case "OPN": return "#OPN@" + String(index) + Translator.mmlOPNParam(channelParam, " ", "\n", name);
            case "OPX": return "#OPX@" + String(index) + Translator.mmlOPXParam(channelParam, " ", "\n", name);
            case "MA3": return "#MA@"  + String(index) + Translator.mmlMA3Param(channelParam, " ", "\n", name);
            default:    return "#@"    + String(index) + Translator.mmlParam   (channelParam, " ", "\n", name);
            }
            return "";
        }
        
        
        /** Set phisical modeling synth guitar parameters.
         *  @param ar attack rate of plunk energy
         *  @param dr decay rate of plunk energy
         *  @param tl total level of plunk energy
         *  @param fixedPitch plunk noise pitch
         *  @param ws wave shape of plunk
         *  @param tension sustain rate of the tone
         */
        public function setPMSGuitar(ar:int=48, dr:int=48, tl:int=0, fixedPitch:int=0, ws:int=20, tension:int=8) : void {
            moduleType = 11;
            channelNum = 1;
            param = [1, 0, 0, ws, ar, dr, 0, 63, 15, tl, 0, 0, 1, 0, 0, 0, 0, fixedPitch];
            psmTension = tension;
            chipType = "PMSGuitar";
        }
        
        
        /** Set low pass filter envelop parameters.
         *  @param cutoff LP filter cutoff
         *  @param resonanse LP filter resonance
         *  @param far LP filter attack rate
         *  @param fdr1 LP filter decay rate 1
         *  @param fdr2 LP filter decay rate 2
         *  @param frr LP filter release rate
         *  @param fdc1 LP filter decay cutoff 1
         *  @param fdc2 LP filter decay cutoff 2
         *  @param fsc LP filter sustain cutoff
         *  @param frc LP filter release cutoff
         */
        public function setLPFEnvelop(cutoff:int=128, resonanse:int=0, far:int=0, fdr1:int=0, fdr2:int=0, frr:int=0, fdc1:int=128, fdc2:int=64, fsc:int=32, frc:int=128) : void {
            channelParam.cutoff = cutoff;
            channelParam.resonanse = resonanse;
            channelParam.far = far;
            channelParam.fdr1 = fdr1;
            channelParam.fdr2 = fdr2;
            channelParam.frr = frr;
            channelParam.fdc1 = fdc1;
            channelParam.fdc2 = fdc2;
            channelParam.fsc = fsc;
            channelParam.frc = frc;
        }
    }
}


