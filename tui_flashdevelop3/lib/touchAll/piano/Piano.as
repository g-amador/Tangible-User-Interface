/********************************************************/
/*  Copyright © YoAmbulante (alex.nino@yoambulante.com) */
/*                                                      */
/*  You may modify or sell this code, you can do        */
/*  whatever you want with it, I don't mind. Just don't */
/*  forget to contribute with a beer thru the website.  */
/*                                                      */
/*  Visit http://www.yoambulante.com to clarify any     */
/*  doubt about this code. Note that donators have      */
/*  priority on information enquiries.                  */
/*                                                      */
/********************************************************/
package touchAll.piano
{
	import flash.display.Sprite;
	import flash.events.Event;	
	import flash.events.MouseEvent;
	//import flash.events.TransformGestureEvent;
	import flash.geom.ColorTransform;	
	import flash.text.TextField;
	
	import org.tuio.TouchEvent;
	
	/**
	 * ...
	 * @author Alex Nino (yoambulante.com)
	 */
	[SWF(width="220", height="480", frameRate="60", backgroundColor="#152D47")]
	public class Piano extends Sprite {
		private const OCTAVE_KEYS_TOTAL:uint = 12; //why 12? because of 12 is the total amount of notes in a octave, so why it is called octave then? dude, check in wikipedia.
		private const KEYS_TOTAL:uint = 72; //72 keys (6 octaves)		
		private var _textColor:uint;
		private var _buttonOnColor:uint;
		private var _buttonOffColor:uint;
		private var _buttonTextColor:uint;
		private var _white_keys_color:uint;
		
		static public var active_interpolation:Boolean = true;		
		
		public function Piano(textColor:uint = 0x8B8B8B, buttonTextColor:uint = 0xFFFFFF, buttonOnColor:uint = 0xBB0000, buttonOffColor:uint = 0x330000, white_keys_color:uint = 0xFEFEFE) {	
			_textColor = textColor;
			_buttonOnColor = buttonOnColor;
			_buttonOffColor = buttonOffColor;
			_buttonTextColor = buttonTextColor;
			_white_keys_color = white_keys_color;
			
			//create piano keys!
			PianoKey.initSamplesFromWaveFile();
			var key:PianoKey;
			var mod:int;
			var y_pos:Number = 10;
			var i:int;
			for (i = 0; i < KEYS_TOTAL; i++) {
				key = new PianoKey((7+24)-i, 88-i,white_keys_color); //first param: 7 pure-notes in a octave + (2 octave up) = 7 + 24. second parameter: it is the global midi position of that particular key note.
				key.y = y_pos;
				mod = i % OCTAVE_KEYS_TOTAL; 
				if (mod == 1 || mod == 3 || mod == 6 || mod == 8 || mod == 10){ //is it any chart-bemol (black key)?
					key.transform.colorTransform = new ColorTransform(1, 1, 1, 1, -200, -200, -200, 0); //then, make it black
					key.width -= 30;
					key.y -= 5;
				} else {
					//only move down the white keys.
					y_pos += key.height + 1; //one pixel space between notes. 
				}
				addChild(key);
			}
			//move the black keys on top
			for (i = 0; i < KEYS_TOTAL; i++) {				
				mod = i % 12;
				if (mod == 1 || mod == 3 || mod == 6 || mod == 8 || mod == 10){	//is it any chart-bemol ?							
					this.setChildIndex(this.getChildAt(i),i+1);
				}		
			}	
			
			//add controls
			var tf:TextField = new TextField();
			tf.textColor = _textColor;
			tf.text = "Hermite Interpolation, Alex Nino (yoambulante.com), Nov 29th 2007 4:05am"+"\nReusing same wave source note A4 (file size 80KB)";
			tf.width = 400;
			tf.x = 80;
			tf.y = 430;
			tf.rotationZ = -90;
			tf.selectable = false;
			addChild(tf);
			//Interpolation ON/OFF button
			tf = new TextField();
			tf.textColor = _buttonTextColor;
			tf.text = "Interpolation ON";
			tf.width = 94;
			tf.height = 20;
			tf.x = 140;
			tf.y = 430;
			tf.rotationZ = -90;
			tf.selectable = false;
			tf.background = true;
			tf.backgroundColor = _buttonOnColor;			
			tf.addEventListener(MouseEvent.CLICK, toggleInterpolation);
			tf.addEventListener(TouchEvent.TAP, toggleInterpolation);
			addChild(tf);
		}
		
		private function toggleInterpolation(e:Event):void {
			active_interpolation = !active_interpolation;
			TextField(e.target).backgroundColor = active_interpolation ? _buttonOnColor : _buttonOffColor;
			TextField(e.target).text = active_interpolation ? "Interpolation ON" : "Interpolation OFF";
		}
	}
	
}