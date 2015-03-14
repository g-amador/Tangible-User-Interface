package nl.niftysystems.audio
{	
	/*
	//AIR imports, uncomment for AIR usage
	*/
	//import flash.desktop.NativeApplication;
	
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.*;
	
	import org.si.sion.SiONDriver;
	import org.si.sion.effector.*;
	import org.si.sion.sequencer.SiMMLTrack;
	import org.si.sion.utils.*;
	
	//import org.tuio.connectors.*;
	//import org.tuio.osc.*;
	import org.tuio.*;
	
	import touchAll.*;
	import nl.niftysystems.touchKeyboard.*;
	
	/**
	 * NiftySynth
	 * 
	 * @author Peter Peerdeman & Timen Olthof Niftysystems 
	 * @link http://www.niftysystems.nl/audio
	 * 
	 * uses TUIO library code by Immanuel Bauer
	 * uses SiON library code by Kei Mesuda (keim)
	 */
	public class NiftySynth extends MovieClip implements ITuioListener {
		//Logo embedding
		[Embed(source="../../../../bin/assets/niftysystems.swf", symbol="Logo")]
		private var Logo:Class;
		private var logo:Sprite;
		
		//Constants
		private const CIRCLE_SIZE:int = 20;
		private const CIRCLE_COLOR:uint = 0xcccccc;
		private const FILL_COLOR:uint = 0xdfdfdf;
		private const STROKE_COLOR:uint = 0x555555;
		private const NUM_KEYS:int = 64;
		
		//Stage variables
		private var currentCircle:Circle;
		private var link:TextField;
		private var scaleText:TextField;
		private var voiceText:TextField;
		private var soundByteArray:ByteArray;
		private var bytes:ByteArray;
		
		//Mouse variables
		private var mouseIndex:int;
		private var mouseCircle:Circle;
		
		//TUIO variables
		//private var tuio:TuioClient;
		private var dictionary:Dictionary;
		
		//SiON variables
		private var driver:SiONDriver;
		private var keyFlag:Number;
		private var noteOffset:int;
		private var presetVoice:SiONPresetVoice;
		private var voiceList:Array;
		static public var voiceIndex:int;	
		static public var categoryIndex:int;	
		private var scale:Scale;
		
		//SiON effect variables
		private var lpf:SiCtrlFilterLowPass;
		private var cutoff:Number;
		private var resonance:Number;
		private var delaySendLevel:Number;
		private var chorusSendLevel:Number;
		private var reverbSendLevel:Number;
		
		private var _keyboard:ScreenBoard;
		private var _line:MovieClip = new MovieClip();
		private var _stage:Stage;
		
		static public var _ns:NiftySynth;
		
		//public function NiftySynth() {
		public function NiftySynth(stage:Stage = null) {	
			_stage = stage;
			//initializeAIR(); //uncomment for AIR usage
			initializeObjects();
			initializeStage();
			initializeTUIO();
			initializeSiON();
			resizeHandler(null);
			
			_ns = this;
		}
		
		//AIR functionality, uncomment for AIR usage
		//private function initializeAIR():void {
			//var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			//var mainWindow:NativeWindow = new NativeWindow(options);
			//mainWindow.addEventListener(Event.CLOSING, function(e:Event):void {NativeApplication.nativeApplication.exit(); });
			//mainWindow.title = "NiftySynth by NitySystems.nl : the multitouch audio experience";
			//mainWindow.width = 640;
			//mainWindow.height = 480;
			//mainWindow.maximize();
			//mainWindow.stage.addChild(this);
			//mainWindow.activate();
		//}
		
		private function initializeObjects():void {
			link = new TextField();
			scaleText = new TextField();
			voiceText = new TextField();
			soundByteArray = new ByteArray();
			bytes = new ByteArray();
			dictionary = new Dictionary();
			driver = new SiONDriver();
			presetVoice = new SiONPresetVoice();
			voiceList = presetVoice.categolies[5];
			lpf = new SiCtrlFilterLowPass();
			
			//Note offset depending on number of keys
			noteOffset = ((128 - NUM_KEYS) / 2) - 1;
			
			//Synthesizer default values
			voiceIndex = 16;	
			categoryIndex = 1;	
			cutoff = 1;
			resonance = 0;
			delaySendLevel = 0;
			chorusSendLevel = 0;
			reverbSendLevel = 0;
		}
		
		private function initializeStage():void {
			_stage.frameRate = 100;
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			
			//Logo
			logo = new Logo();
			logo.y = 20;
			logo.scaleX = 0.7;
			logo.scaleY = 0.7;
			
			//Text
			link.autoSize = TextFieldAutoSize.CENTER;
			link.selectable = false;
			link.addEventListener(MouseEvent.CLICK, openNS);
			link.defaultTextFormat = new TextFormat("Arial", null, 0xbcbcbc);
			link.appendText("http://www.niftysystems.nl/audio");
			link.y = 60;
			
			scaleText.alpha = 0;
			scaleText.selectable = false;
			scaleText.defaultTextFormat = new TextFormat("Arial", 100, 0xbcbcbc, true,null,null,null ,null,"center");
			scaleText.text = "C";
			scaleText.width = 130;
			scaleText.scaleX = 2;
			scaleText.scaleY = 2;
			scaleText.autoSize = TextFieldAutoSize.CENTER;
			
			voiceText.alpha = 1;
			voiceText.autoSize = TextFieldAutoSize.CENTER;
			voiceText.selectable = false;
			voiceText.width = 300;
			voiceText.defaultTextFormat = new TextFormat("Arial", 20, 0xbcbcbc, true);
			voiceText.text = ((voiceList.name.charAt() == "v") ? voiceList.name.substr(9) : voiceList.name) + 
				" " + String(voiceIndex + 1).substr( -3, 3) +	
				" " + voiceList[voiceIndex].name;
			
			_stage.addChild(logo);
			_stage.addChild(link);
			_stage.addChild(scaleText);
			_stage.addChild(voiceText);
			_stage.addChild(_line);
			
			//Interactions
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseClick);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			_stage.addEventListener(Event.RESIZE, resizeHandler);
			_stage.addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function resizeHandler(e:Event):void {
			logo.x = _stage.stageWidth/2-logo.width/2;
			TweenLite.to(logo, 0.5, {alpha:1.0});
			
			link.x = _stage.stageWidth/2-link.width/2;
			
			scaleText.x = _stage.stageWidth/2-scaleText.width/2;
			scaleText.y = _stage.stageHeight-250;
			TweenLite.to(scaleText, 0.5, {alpha:1.0});
			
			voiceText.x = _stage.stageWidth/2-voiceText.width/2;
			voiceText.y = _stage.stageHeight-50;
			TweenLite.to(voiceText, 0.5, {alpha:1.0});
		} 
		
		private function loop(e:Event):void {			
			//Visualization
			_line.graphics.clear();
			_line.graphics.beginFill(FILL_COLOR,0.5);
			_line.graphics.lineStyle (0, STROKE_COLOR, 1, false, LineScaleMode.NONE);
			_line.graphics.moveTo(-1, _stage.stageHeight/2);
			_line.graphics.lineStyle (5, STROKE_COLOR, 1, false, LineScaleMode.NONE);
			SoundMixer.computeSpectrum(soundByteArray);
			var a:Array = new Array();
			for(var i:uint=0; i<256; i++) {
				var num:Number = -soundByteArray.readFloat()*400 + _stage.stageHeight/2;
				_line.graphics.lineTo(((i*2)*_stage.stageWidth) / 512, num);
				a.push(num);
			}
			_line.graphics.lineTo(_stage.stageWidth, _stage.stageHeight/2);
			_line.graphics.lineStyle (0, STROKE_COLOR, 1, false, LineScaleMode.NONE);
			_line.graphics.lineTo(_stage.stageWidth, _stage.stageHeight);
			_line.graphics.lineTo(0, _stage.stageHeight);
			_line.graphics.lineTo( -1, _stage.stageHeight / 2);
			_line.graphics.endFill();
		}
		
		private function initializeTUIO():void {
			//this.tuio = new TuioClient(new UDPConnector("127.0.0.1", 3333));
			//this.tuio.addListener(this);
			TouchAll._tc.addListener(this);
		}
		
		private function initializeSiON():void {
			// Low pass filter and Effector settings
			lpf.initialize();
			lpf.control(1, 0);
			driver.effector.initialize();
			driver.effector.connect(0, lpf);
			
			//Effects (turned off for performance)
			var dly:SiEffectStereoDelay = new SiEffectStereoDelay();
			dly.initialize();
			dly.setParameters(200,0.2,false);
			
			var cho:SiEffectStereoChorus = new SiEffectStereoChorus();
			cho.initialize();
			cho.setParameters(20,0.2,4,20);
			
			var rev:SiEffectStereoReverb = new SiEffectStereoReverb();
			rev.initialize();
			rev.setParameters();
			
			driver.effector.connect(1, dly);
			driver.effector.connect(2, cho);
			driver.effector.connect(3, rev);
			
			//Initialize scale
			scale = new Scale("Cmp");
			
			//Start stream
			driver.play(null, false);
		}
		
		public function handleKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.DOWN){
				updateCategory(categoryIndex-1);
			} else if (event.keyCode == Keyboard.UP){
				updateCategory(categoryIndex+1);
			} else if (event.keyCode == Keyboard.LEFT){
				updateVoice(voiceIndex-1);
			} else if (event.keyCode == Keyboard.RIGHT){
				updateVoice(voiceIndex+1);
			} else if (event.keyCode == Keyboard.SPACE) {
				_stage.displayState = StageDisplayState.FULL_SCREEN;
				//_stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			} else if (event.keyCode == 75) { //k
				allNotesOff();
			} else if (event.keyCode == 67) { //c
				if (event.shiftKey)
					setScale("C#mp");
				else
					setScale("Cmp");
			} else if (event.keyCode == 68) { //d
				if (event.shiftKey)
					setScale("D#mp");
				else
					setScale("Dmp");
			} else if (event.keyCode == 69) { //e
				setScale("Emp");
			} else if (event.keyCode == 70) { //f
				if (event.shiftKey)
					setScale("F#mp");
				else
					setScale("Fmp");
			} else if (event.keyCode == 71) { //g
				if (event.shiftKey)
					setScale("G#mp");
				else
					setScale("Gmp");
			} else if (event.keyCode == 65) { //a
				if (event.shiftKey)
					setScale("A#mp");
				else
					setScale("Amp");
			} else if (event.keyCode == 66) { //b
				setScale("Bmp");
			}
		} 
		
		private function allNotesOff():void {
			for each (var trk:SiMMLTrack in driver.sequencer.tracks) trk.keyOff();
		}
		
		public function setScale(scaleName:String):void {
			//Sound
			allNotesOff();
			scale.scaleName = scaleName;	
			
			//GUI
			scaleText.text = scaleName.substr(0,1) + (scaleName.length==4 ? "#" : "");
		}
		
		public function updateCategory(index:int):void {
			//Sound
			var imax:int = presetVoice.categolies.length;
			if (index < 0) index = imax - 1;
			else if (index >= imax) index = 0;
			categoryIndex = index;
			voiceList = presetVoice.categolies[index];
			updateVoice(voiceIndex);
			
			//GUI
			voiceText.text = ((voiceList.name.charAt() == "v") ? voiceList.name.substr(9) : voiceList.name)
				+ " " + String(voiceIndex+1).substr(-3,3)
				+ " " + voiceList[voiceIndex].name;
		}
		
		public function updateVoice(index:int):void {
			if (voiceList) {
				//Sound
				if (index < 0) index = 0;
				else if (index >= voiceList.length) index = voiceList.length - 1;
				voiceIndex = index;
				
				//GUI
				voiceText.text = ((voiceList.name.charAt() == "v") ? voiceList.name.substr(9) : voiceList.name)
					+ " " + String(voiceIndex+1).substr(-3,3)
					+ " " + voiceList[voiceIndex].name;
			}
		}
		
		private function openNS(event:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.niftysystems.nl/audio"));
		}
		
		/**
		 * TuioCursor handling.
		 */
		
		public function addTuioCursor(tuioCursor:TuioCursor):void {
			// Sound
			var index:int = tuioCursor.x * NUM_KEYS;
			if ((keyFlag & (1<<index)) == 0) {
				keyFlag |= 1<<index;
				var track:SiMMLTrack = driver.noteOn(scale.getNote(index + noteOffset), voiceList[voiceIndex], 0);
				/* Effect send volumes
				track.channel.setStreamSend(1, delaySendLevel);
				track.channel.setStreamSend(2, chorusSendLevel);
				track.channel.setStreamSend(3, reverbSendLevel);
				*/
			}
			
			// Database
			dictionary[tuioCursor.sessionID.toString()] = new TouchNote(tuioCursor,index);
			
			// GUI
			new Circle(tuioCursor.sessionID.toString(), _stage, tuioCursor.x * _stage.stageWidth, tuioCursor.y * _stage.stageHeight, CIRCLE_SIZE, CIRCLE_COLOR);
		}
		
		public function updateTuioCursor(tuioCursor:TuioCursor):void {	
			// Sound
			var oldIndex:int = dictionary[tuioCursor.sessionID.toString()].index;
			var newIndex:int = tuioCursor.x * NUM_KEYS; 
			
			// Check if the index has changed
			if(oldIndex != newIndex) {
				// If so turn off old note
				keyFlag &= ~(1<<oldIndex);
				driver.noteOff(scale.getNote(oldIndex + noteOffset));
				
				// And turn on new note
				if ((keyFlag & (1<<newIndex)) == 0) {
					keyFlag |= 1<<newIndex;
					var track:SiMMLTrack = driver.noteOn(scale.getNote(newIndex + noteOffset), voiceList[voiceIndex], 0);
					dictionary[tuioCursor.sessionID.toString()].index = newIndex;
				}
			}
			cutoff = 1-tuioCursor.y //inverse for more intuitive control
			resonance = tuioCursor.y;
			lpf.control(cutoff, resonance);
			
			// GUI
			currentCircle = _stage.getChildByName(tuioCursor.sessionID.toString()) as Circle;
			currentCircle.x = tuioCursor.x * _stage.stageWidth;
			currentCircle.y = tuioCursor.y * _stage.stageHeight;
		}
		
		public function removeTuioCursor(tuioCursor:TuioCursor):void {
			// Sound
			var index:int = dictionary[tuioCursor.sessionID.toString()].index;
			keyFlag &= ~(1<<index);
			driver.noteOff(scale.getNote(index + noteOffset));
			
			// Database
			delete dictionary[tuioCursor.sessionID.toString()];
			
			// GUI
			currentCircle = _stage.getChildByName(tuioCursor.sessionID.toString()) as Circle;
			_stage.removeChild(currentCircle);
		}
		
		/**
		 * MouseEvent handling.
		 */
		
		public function onStageMouseClick(event:MouseEvent):void {	
			//Sound
			mouseIndex = (event.stageX / _stage.stageWidth) * NUM_KEYS;
			if ((keyFlag & (1<<mouseIndex)) == 0) {
				keyFlag |= 1<<mouseIndex;
				var track:SiMMLTrack = driver.noteOn(scale.getNote(mouseIndex + noteOffset), voiceList[voiceIndex], 0);
				/* Effect send volumes (turned off for performance)
				track.channel.setStreamSend(1, delaySendLevel);
				track.channel.setStreamSend(2, chorusSendLevel);
				track.channel.setStreamSend(3, reverbSendLevel);
				*/
			}
			
			//GUI
			mouseCircle = new Circle("mouseCircle", _stage, (event.stageX / _stage.stageWidth)*_stage.stageWidth, (event.stageY / _stage.stageHeight)*_stage.stageHeight, CIRCLE_SIZE, CIRCLE_COLOR);
			
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
		}
		
		public function onStageMouseMove(event:MouseEvent):void {
			//Sound
			var oldIndex:int = mouseIndex;
			var newIndex:int = (event.stageX / _stage.stageWidth) * NUM_KEYS; 
			
			//Check if the index has changed
			if(oldIndex != newIndex) {
				//If so turn off old note
				keyFlag &= ~(1<<oldIndex);
				driver.noteOff(scale.getNote(oldIndex + noteOffset));
				
				//And turn on new note
				if ((keyFlag & (1<<newIndex)) == 0) {
					keyFlag |= 1<<newIndex;
					var track:SiMMLTrack = driver.noteOn(scale.getNote(newIndex + noteOffset), voiceList[voiceIndex], 0);
					mouseIndex = newIndex;
				}
			}
			cutoff = 1-(event.stageY / _stage.stageHeight) //inverse for more intuitive control
			resonance = (event.stageY / _stage.stageHeight);
			lpf.control(cutoff, resonance);
			
			//GUI
			mouseCircle.x = (event.stageX / _stage.stageWidth)*_stage.stageWidth;
			mouseCircle.y = (event.stageY / _stage.stageHeight)*_stage.stageHeight;
		}
		
		public function onStageMouseUp(event:MouseEvent):void {
			//Sound
			keyFlag &= ~(1<<mouseIndex);
			driver.noteOff(scale.getNote(mouseIndex + noteOffset));
			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			
			//GUI
			_stage.removeChild(mouseCircle);
		}
		
		/**
		 * TuioObject handling.
		 */
		
		public function addTuioObject(tuioObject:TuioObject):void {
			trace("Fiducial #" + tuioObject.classID + " fiducial added.");
			
			if (tuioObject.classID == 3) {		
				_keyboard = new ScreenBoard(tuioObject.x * _stage.stageWidth + 40, tuioObject.y * _stage.stageHeight + 40); 
				//_keyboard.filters = [new GlowFilter(0x0055ff, .75, 100, 100, 2, 2, false, false)];
				
				_stage.addChild(_keyboard);
			}
		}
		
		public function updateTuioObject(tuioObject:TuioObject):void {
			trace("Fiducial #" + tuioObject.classID + " fiducial move.");
			
			if (tuioObject.classID == 3) {
				_keyboard.x = tuioObject.x * _stage.stageWidth + 40;
				_keyboard.y = tuioObject.y * _stage.stageHeight + 40;	
			}
		}
		
		public function removeTuioObject(tuioObject:TuioObject):void {
			trace("Fiducial #" + tuioObject.classID + " fiducial removed.");
			
			if (tuioObject.classID == 3) {
				_stage.removeChild(_keyboard);
			}	
		}
		
		/**
		 * TuioBlob handling.
		 */
		
		public function addTuioBlob(tuioBlob:TuioBlob):void {
		}
		
		public function updateTuioBlob(tuioBlob:TuioBlob):void {
		}
		
		public function removeTuioBlob(tuioBlob:TuioBlob):void {
		}
		
		public function newFrame(id:uint):void {
		}
	}
}