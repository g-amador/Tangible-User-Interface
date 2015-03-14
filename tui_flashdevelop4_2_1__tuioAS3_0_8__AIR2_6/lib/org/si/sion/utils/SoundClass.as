//----------------------------------------------------------------------------------------------------
// To create flash.media.Sound class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.utils
{
    import flash.display.Loader;
    import flash.events.Event;
    import flash.utils.ByteArray;
    import flash.media.Sound;
    
    
    /**
     * Refer from http://www.flashcodersbrighton.org/wordpress/?p=9
     * @modified Kei Mesuda
     */
    public final class SoundClass
    {
        static private var _header:Vector.<uint> = Vector.<uint>([ // little endian
            0x09535746, 0xFFFFFFFF, 0x5f050078, 0xa00f0000, 0x010c0000, 0x08114400, 0x43000000, 0xffffff02, 
            0x000b15bf, 0x00010000, 0x6e656353, 0x00312065, 0xc814bf00, 0x00000000, 0x00000000, 0x002e0010, 
            0x08000000, 0x756f530a, 0x6c43646e, 0x00737361, 0x616c660b, 0x6d2e6873, 0x61696465, 0x756f5305, 
            0x4f06646e, 0x63656a62, 0x76450f74, 0x44746e65, 0x61707369, 0x65686374, 0x6c660c72, 0x2e687361, 
            0x6e657665, 0x05067374, 0x16021601, 0x16011803, 0x07050007, 0x03070102, 0x05020704, 0x03060507, 
            0x00020000, 0x00020000, 0x00020000, 0x02010100, 0x01000408, 0x01000000, 0x04010102, 0x00030001, 
            0x06050101, 0x4730d003, 0x01010000, 0x06070601, 0x49d030d0, 0x00004700, 0x01010202, 0x30d01f05, 
            0x035d0065, 0x5d300366, 0x30046604, 0x0266025d, 0x66025d30, 0x1d005802, 0x01681d1d, 0xbf000047, 
            0xFFFFFF03, 0x3f0001FF  // The last byte of "3f" means 44.1kHz/16bit/stereo
        ]);
        static private var _footer:Vector.<uint> = Vector.<uint>([ // little endian
            0x000f133f, 0x00010000, 0x6f530001, 0x43646e75, 0x7373616c, 0x0f0b4400, 0x40000000, 0x00000000
        ]);
        
        
        /** create Sound class.
         *  @param samples The Vector.<Number> wave data creating from. The LRLR type stereo data.
         *  @param onComplete callback function when finished to create. 
         */
        static public function create(samples:Vector.<Number>, onComplete:Function) : void {
            var size:int = samples.length * 2; // *2(16bit)
            var bytes:ByteArray = new ByteArray();
            bytes.endian = "littleEndian";
            bytes.length = size + 299;
            bytes.position = 0;
            _write(_header);
            bytes.position = 4;
            bytes.writeUnsignedInt(size + 299);
            bytes.position = 257;
            bytes.writeUnsignedInt(size + 7);
            bytes.position = 264;
            imax = samples.length;
            var i:int, imax:int;
            for (i=0; i<imax; i++) { bytes.writeShort(samples[i]*32767); }
            _write(_footer);
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onComplete);
            loader.loadBytes(bytes);
            
            function _write(vu:Vector.<uint>) : void { for each (var ui:uint in vu) { bytes.writeUnsignedInt(ui); } }
            
            function _onComplete(e:Event) : void {
                var soundClass:Class = loader.contentLoaderInfo.applicationDomain.getDefinition("SoundClass") as Class;
                onComplete((soundClass) ? (new soundClass()) as Sound : null);
            }
        }
    }
}

