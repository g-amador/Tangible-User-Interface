//----------------------------------------------------------------------------------------------------
// SiOPM channel parameters
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module {
    import org.si.sion.sequencer.base.MMLSequence;
    
    
    /** SiOPM Channel Parameters. This is a member of SiONVoice.
     *  @see org.si.sion.SiONVoice
     *  @see org.si.sion.module.SiOPMOperatorParam
     */
    public class SiOPMChannelParam
    {
    // valiables 11 parameters
    //--------------------------------------------------
        /** operator params x4 */
        public var operatorParam:Vector.<SiOPMOperatorParam>;
        
        /** operator count [0,4] */
        public var opeCount:int;
        /** algorism [0,15] */
        public var alg:int;
        /** feedback [0,7] */
        public var fb:int;
        /** feedback connection [0,3] */
        public var fbc:int;
        /** envelop frequency ratio */
        public var fratio:int;
        /** LFO wave shape */
        public var lfoWaveShape:int;
        /** LFO frequency */
        public var lfoFreqStep:int;
        
        /** amplitude modulation depth */
        public var amd:int;
        /** pitch modulation depth */
        public var pmd:int;
        /** [extention] master volume [0,1] */
        public var volumes:Vector.<Number>;
        /** [extention] panning */
        public var pan:int;

        /** LP filter cutoff */
        public var cutoff:int;
        /** LP filter resonance */
        public var resonanse:int;
        /** LP filter attack rate */
        public var far:int;
        /** LP filter decay rate 1 */
        public var fdr1:int;
        /** LP filter decay rate 2 */
        public var fdr2:int;
        /** LP filter release rate */
        public var frr:int;
        /** LP filter decay offset 1 */
        public var fdc1:int;
        /** LP filter decay offset 2 */
        public var fdc2:int;
        /** LP filter sustain offset */
        public var fsc:int;
        /** LP filter release offset */
        public var frc:int;
        
        /** Initializing sequence */
        public var initSequence:MMLSequence;
        
        
        /** LFO cycle time */
        public function set lfoFrame(fps:int) : void
        {
            lfoFreqStep = SiOPMTable.LFO_TIMER_INITIAL/(fps*2.882352941176471);
        }
        public function get lfoFrame() : int
        {
            return int(SiOPMTable.LFO_TIMER_INITIAL * 0.346938775510204 / lfoFreqStep);
        }
        
        
        /** constructor */
        function SiOPMChannelParam()
        {
            initSequence = new MMLSequence();
            volumes = new Vector.<Number>(SiOPMModule.STREAM_SIZE_MAX, true);

            operatorParam = new Vector.<SiOPMOperatorParam>(4);
            for (var i:int; i<4; i++) {
                operatorParam[i] = new SiOPMOperatorParam();
            }
            
            initialize();
        }
        
        
        /** initializer */
        public function initialize() : SiOPMChannelParam
        {
            var i:int;
            
            opeCount = 1;
            
            alg = 0;
            fb = 0;
            fbc = 0;
            lfoWaveShape = SiOPMTable.LFO_WAVE_TRIANGLE;
            lfoFreqStep = 12126;    // 12126 = 30frame/100fratio
            amd = 0;
            pmd = 0;
            fratio = 100;
            for (i=1; i<SiOPMModule.STREAM_SIZE_MAX; i++) { volumes[i] = 0; }
            volumes[0] = 0.5;
            pan = 64;
            
            cutoff = 128;
            resonanse = 0;
            far = 0;
            fdr1 = 0;
            fdr2 = 0;
            frr = 0;
            fdc1 = 128;
            fdc2 = 64;
            fsc = 32;
            frc = 128;
            
            for (i=0; i<4; i++) { operatorParam[i].initialize(); }
            
            initSequence.free();
            
            return this;
        }
        
        
        /** copier */
        public function copyFrom(org:SiOPMChannelParam) : SiOPMChannelParam
        {
            var i:int;
            
            opeCount = org.opeCount;
            
            alg = org.alg;
            fb = org.fb;
            fbc = org.fbc;
            lfoWaveShape = org.lfoWaveShape;
            lfoFreqStep = org.lfoFreqStep;
            amd = org.amd;
            pmd = org.pmd;
            fratio = org.fratio;
            for (i=0; i<SiOPMModule.STREAM_SIZE_MAX; i++) { volumes[i] = org.volumes[i]; }
            pan = org.pan;
            
            cutoff = org.cutoff;
            resonanse = org.resonanse;
            far = org.far;
            fdr1 = org.fdr1;
            fdr2 = org.fdr2;
            frr = org.frr;
            fdc1 = org.fdc1;
            fdc2 = org.fdc2;
            fsc = org.fsc;
            frc = org.frc;
            
            for (i=0; i<4; i++) { operatorParam[i].copyFrom(org.operatorParam[i]); }
            
            initSequence.free();
            
            return this;
        }
        
        
        /** information */
        public function toString() : String
        {
            var str:String = "SiOPMChannelParam : opeCount=";
            str += String(opeCount) + "\n";
            $("freq.ratio", fratio);
            $("alg", alg);
            $2("fb ", fb,  "fbc", fbc);
            $2("lws", lfoWaveShape, "lfq", SiOPMTable.LFO_TIMER_INITIAL*0.005782313/lfoFreqStep);
            $2("amd", amd, "pmd", pmd);
            $2("vol", volumes[0],  "pan", pan-64);
            $2("co", cutoff, "res", resonanse);
            str += "fenv=" + String(far) + "/" + String(fdr1) + "/"+ String(fdr2) + "/"+ String(frr) + "\n";
            str += "feco=" + String(fdc1) + "/"+ String(fdc2) + "/"+ String(fsc) + "/"+ String(frc) + "\n";
            for (var i:int=0; i<opeCount; i++) {
                str += operatorParam[i].toString() + "\n";
            }
            return str;
            function $ (p:String, i:int) : void { str += "  " + p + "=" + String(i) + "\n"; }
            function $2(p:String, i:int, q:String, j:int) : void { str += "  " + p + "=" + String(i) + " / " + q + "=" + String(j) + "\n"; }
        }
    }
}

