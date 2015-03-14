package touchAll.piano
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	//import flash.events.TransformGestureEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.tuio.TouchEvent;
	
	import touchAll.piano.Piano;
	
	/**
	 * This class is the graphic representation of a single key.
	 * @author Alex Nino
	 */
	public class PianoKey extends Sprite {		
		[Embed(source = '../../../bin/resources/waveA4.raw', mimeType = 'application/octet-stream')]
		static private var Piano_A4_Infinity:Class;
		[Embed(source = '../../../bin/resources/pianoA4.raw', mimeType = 'application/octet-stream')]
		static private var Piano_A4:Class;		
		static private var piano_A4_samples:Vector.<Number>;	
		static private var piano_A4_samples_total:uint;	
		static private const NORMALIZE_FROM_16BIT:Number = 1 / 0xFFFF * 2; //use for converting from 16-bit sample value to normalized value +/- 1.0
		
		private var key_up:Sprite;
		private var key_down:Sprite;
		private var _note:int; //this is the key index (where in the piano keyboard is), waveform samples starts in A4.
		private var _noteLP:Number; //this value is only used when applying LOW-PASS filter.
		private var _midi_note:int; //this is the global midi position of this key-note.
		private var _note_factor:Number; //how much from A4 this note needs to be stretched or shrunk (used when interpolating samples)
		private var sindex:uint; //sample index for current note.
		private var new_len:uint; //new lenght after stretch		
		private var start_fading:uint; //a limit for fade out		
		private var fade_out:Number; //use to release the note smoothly
		private var sound_buffer:Sound;
		private var sound_channel:SoundChannel;
		//private var white_keys_color:uint;
		
		public function PianoKey(key:int, midi_key:int, white_keys_color:uint = 0xFEFEFE) {
			sound_buffer = new Sound();		
			
			//I have originaly wrote this program in 2007 and then I just recompile it in 2010 using SampleDataEvent.SAMPLE_DATA for Flash Player 10
			sound_buffer.addEventListener(SampleDataEvent.SAMPLE_DATA, soundBufferGenerator);
			_note = key;
			_noteLP = midi_key * 5;
			_midi_note = midi_key;
			if (_note < 0){
				_note_factor = Math.pow(2,(Math.abs(_note)/12)); //starting from A4 stretch samples this amount.
			} else {
				_note_factor = Math.pow(0.5,_note/12); //starting from A4 shrink up samples this amount.		
			}
			new_len = Math.floor( piano_A4_samples_total * _note_factor );
			start_fading = (87-_midi_note) * 9000;
			
			//draw the key_note visually.
			key_up = new Sprite();
			key_up.graphics.beginFill(white_keys_color, 1);
			key_up.graphics.drawRect(0, 0, 70, 10);
			addChild(key_up);
			key_up.visible = true;
			
			key_down = new Sprite();
			key_down.graphics.beginGradientFill(GradientType.LINEAR, [white_keys_color, 0x8B8B8B], [1,1], [127, 255]);
			key_down.graphics.drawRect(0, 0, 68, 10);
			addChild(key_down);
			key_down.visible = false;
			this.addEventListener(MouseEvent.MOUSE_DOWN, press);						
			this.addEventListener(TouchEvent.TOUCH_DOWN, touchPress);
		}
		
		public function get note_index():int { return _note; }
		public function get midi_note():int { return _midi_note; }
		public function get note_factor():int { return _note_factor; }
		
		public function get pressed():Boolean { return key_down.visible; }
		
		public function press(e:MouseEvent):void {
			key_down.visible = true;
			key_up.visible = false;
			this.addEventListener(MouseEvent.MOUSE_UP, release);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, release);			
			sindex = 0;
			last = 0;
			fade_out = 1;
			if (sound_channel == null){
				sound_channel = sound_buffer.play(); //start generating dynamic audio, see soundBufferGenerator function
			}			
		}
		
		public function release(e:MouseEvent):void {
			this.removeEventListener(MouseEvent.MOUSE_UP, release);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, release);
			key_down.visible = false;
			key_up.visible = true;			
		}
		
		public function touchPress(e:TouchEvent):void {
			key_down.visible = true;
			key_up.visible = false;
			this.addEventListener(TouchEvent.TOUCH_UP, touchRelease);
			this.stage.addEventListener(TouchEvent.TOUCH_UP, touchRelease);			
			sindex = 0;
			last = 0;
			fade_out = 1;
			if (sound_channel == null){
				sound_channel = sound_buffer.play(); //start generating dynamic audio, see soundBufferGenerator function
			}			
		}
		
		public function touchRelease(e:TouchEvent):void {
			this.removeEventListener(TouchEvent.TOUCH_UP, touchRelease);
			this.stage.removeEventListener(TouchEvent.TOUCH_UP, touchRelease);
			key_down.visible = false;
			key_up.visible = true;			
		}
		
		private function soundBufferGenerator(e:SampleDataEvent):void {							
			if (fade_out <= 0) {
				sound_channel.stop();
				sound_channel = null;
				return;
			}
			var sam:Number; //audio sample
			var si:int; //sample index
			for (si = 0; si < 4096; si++) { 				
				sam = next_sample;
				//write buffer.
				e.data.writeFloat(sam); //right				
				e.data.writeFloat(sam); //left
			}					
		}
				
		private var pos:Number;
		private var i:uint;
		private var step:Number;
		//sample values calculated on hermite interpolation.
		private var s1:Number;
		private var s2:Number;
		private var s3:Number;
		private var s4:Number;
		private var last:Number; //last sample value (used only in lowpass filter).
		private var hermite:Number; //this is the hermite value interpolated
		public function get next_sample():Number {
			//check if key was just released
			if (!key_down.visible) {
				fade_out -= .00001;
			}
			if (sindex < new_len) {				
				//stretch waveform depending on note pitch
				pos = sindex / new_len * piano_A4_samples_total;
				i = Math.floor(pos); 
				if (Piano.active_interpolation){
					step = pos - i; //between 0.0 and 1.0					
					s1 = readSampleAt(i-1);
					s2 = readSampleAt(i);
					s3 = readSampleAt(i+1);
					s4 = readSampleAt(i + 2);								
					//Alex Nino - yoambulante.com (I've spent few hour of my life in the next couple of lines)
					//apply lowpass filter in order to have a better simulation.
					hermite = HermiteInterpolate(s1, s2, s3, s4, step) * fade_out;
					last = lowpass( last,  hermite,  _midi_note, _noteLP);						
				} else {
					last = readSampleAt(i);
				}
				sindex++ //next time will read next sample.				
				return last;
			}
			return 0;
		}
		
		//static functions
		
		static public function initSamplesFromWaveFile():void {
			//initialize main samples bytearray which contains a piano key note A4. RAW files 16 bits (mono) 44100
			//note a RAW file it the same of a WAV file, it just doesn't have any header
			var samples:ByteArray = new Piano_A4 as ByteArray;
			samples.endian = Endian.LITTLE_ENDIAN; //important! never ever forget this, I have wasted 4 hours of my life because of this.			
			//add few seconds of intinite note in sustain mode.
			var inf:ByteArray = new Piano_A4_Infinity as ByteArray;
			inf.endian = Endian.LITTLE_ENDIAN;			
			var i:int;
			for (i = 0; i < 500; i++) {
				samples.position = samples.length;
				inf.position = 0;
				samples.writeBytes(inf);
			}									
			piano_A4_samples_total = Math.floor(samples.length / 2); //each sample uses 2 bytes (16 bits sample data)
			piano_A4_samples = new Vector.<Number>(piano_A4_samples_total, true);
			samples.position = 0;
			var fadeout:uint = piano_A4_samples_total - 44100*3; //fade out three seconds note A4 and so the rest
			for (i = 0; i < piano_A4_samples_total; i++) {
				piano_A4_samples[i] = Number(samples.readShort() * NORMALIZE_FROM_16BIT);
				if (i > fadeout) {					
					piano_A4_samples[i] *= 1 - ((i - fadeout) / (44100*3));
				}
			}			
		}
		static private function readSampleAt(sample:int):Number {
			if (sample >= 0 && sample < piano_A4_samples_total){
				//piano_A4_samples.position = p;
				//return piano_A4_samples.readShort() * NORMALIZE_FROM_16BIT; //it returns a sample normalized value between +/- 1.0
				return piano_A4_samples[sample];
			}
			return 0;
		}
		
		private static function HermiteInterpolate(y0:Number,y1:Number,y2:Number,y3:Number,mu:Number,tension:Number = 0,bias:Number = 0):Number {
			/* Tension: 1 is high, 0 normal, -1 is low
		       Bias: 0 is even, positive is towards first segment, negative towards the other */
			var mu2:Number = mu * mu;
			var mu3:Number = mu2 * mu;
			var m0:Number  = (y1-y0)*(1+bias)*(1-tension)/2;
			m0 += (y2-y1)*(1-bias)*(1-tension)/2;
			var m1:Number  = (y2-y1)*(1+bias)*(1-tension)/2;
			m1 += (y3-y2)*(1-bias)*(1-tension)/2;
			var a0:Number =  2*mu3 - 3*mu2 + 1;
			var a1:Number =    mu3 - 2*mu2 + mu;
			var a2:Number =    mu3 -   mu2;
			var a3:Number = -2*mu3 + 3*mu2;
		
			return (a0*y1+a1*m0+a2*m1+a3*y2);
		}
		
		private static function lowpass(prev:Number, value:Number, dt:Number, rc:Number):Number { // Return RC low-pass filter			
			//see Algorithmic implementation in
			//http://en.wikipedia.org/wiki/Low-pass_filter 
			var alpha:Number = dt / (rc + dt);
			return alpha * value + ( 1 - alpha ) * prev;
		}
	}

}
