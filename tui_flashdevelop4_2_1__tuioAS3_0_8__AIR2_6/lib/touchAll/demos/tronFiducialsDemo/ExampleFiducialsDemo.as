package touchAll.demos.tronFiducialsDemo
{
	import flash.ui.*;
	import flash.display.*;
	//import flash.filters.*;
	//import flash.events.*;
	import flash.events.Event;
	//import flash.events.TouchEvent;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	//import flash.events.TransformGestureEvent;
	
	import org.tuio.*;
	import org.tuio.connectors.*;
	import org.tuio.debug.*;
	import org.tuio.gestures.*;
	
	import touchAll.piano.Piano;
	import touchAll.keyboard.CustomKeyboard;
	import touchAll.pong.cl.kirill.PongGame;
	
	/**
	 * @author Gonçalo Amador
	 */
	[SWF(width = "1280", height = "720", frameRate = "60", backgroundColor = "#ffffff")]
	//[SWF(width = "1280", height = "720", frameRate = "60", backgroundColor = "#000000")]
	public class ExampleFiducialsDemo extends MovieClip
	{
		/* global variables */		
		private var _stage:Stage;
		private var _width:int = 1280;
		private var _height:int = 720;
		private var _color:uint = 0x000000;
		private var _tm:TuioManager;
		private var _gm:GestureManager;
		private var _packets_count:uint = 0;
		private var _log:String = "";
		private var _mouseCursor:Sprite;
		private var _background:Sprite = new Sprite;
		
		private var _keyboard:CustomKeyboard;
		private var _pongGame:PongGame;
		private var _piano:Piano;
		private var _textColor:uint = 0x8B8B8B;
		private var _buttonColor:uint = 0x000000;
		private var _buttonTextColor:uint = 0xFFFFFF;
		private var _buttonOnColor:uint = 0xBB0000;
		private var _buttonOffColor:uint = 0x330000;
		private var _borderColor:uint = 0x000000;
		private var _white_keys_color:uint = 0xFEFEFE;
		
		private var _debug:Boolean = true;
		private var _LCconnector:Boolean = false;
		private var _UDPconnector:Boolean = true;
		private var _TCPconnector:Boolean = false;
		private var _host:String = "127.0.0.1";
		private var _port:int = 3333;
		private var _fiducialHandler:Boolean = true;
		private var _tuioManager:Boolean = true;
		private var _gestureManager:Boolean = true;
		private var _mouseToTouch:Boolean = false;
		private var _tc:TuioClient;
		
		public function ExampleFiducialsDemo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_stage = stage;
			
			/* LOAD STAGE CONTENT */
			backgroundLoader();
			//backgroundEventListenersLoader();
			
			/* stage set up */
			stageLoader();
			stageEventListenersLoader();	
			
			/* tuio set up */
			tuioLoader();
		}
		
		/* BACKGROUND FUNCTIONS */
		/**
		 * load default stage background
		 */
		public function backgroundLoader():void {
			/*
			 * Set blend mode "ALPHA" and 
			 * fill background at the starting position (0,0), with rgb color 0xFFFFFF and alpha blending 1 
			 */
			_background.blendMode = BlendMode.ALPHA;
			_background.graphics.beginFill(0xFFFFFF,1);
			_background.graphics.drawRect(0,0,_stage.stageWidth,_stage.stageHeight);
			_background.graphics.endFill();
			
			/* set activate doubleClick mouse checks */
			trace("set activate doubleClick mouse checks.");
			_background.doubleClickEnabled = true;
			
			/* add the background to the stage */
			trace("add the background to the stage.");
			_stage.addChild(_background);	
		}
		
				
		public function backgroundEventListenersLoader():void {
			trace("backgroundEventListenersLoader.");
		}
		
		/** 
		 * stage set up 
		 */
		public function stageLoader():void {
			/* STAGE SET UP */	
			trace("STAGE SET UP.");
			_stage.stageWidth = _width;
			_stage.stageHeight = _height;
			
			/* AIR stage settings */
			trace("AIR stage settings.");
			//_stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			
			/* set activate doubleClick mouse checks */
			trace("set activate doubleClick mouse checks.");
			_stage.doubleClickEnabled = true;
			
			/* load an circle to track mouse cursor */
			trace("load an circle to track mouse cursor.");
			if (_debug) {
				addMouseCursor(); 
			}			
		}
		
		/** 
		 * stage event listeners set up 
		 */
		public function stageEventListenersLoader():void {
			/* STAGE EVENT LISTENERS */
			/* add stage keyboard event listeners */
			trace("add stage keyboard event listeners.");
			if (_tuioManager) {
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, showTuioNetworkPacketsLog);
			}
			
			/* add stage mouse event listeners */
			trace("add stage mouse event listeners.");
			if (_debug) {
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, followMouse);
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);	
			}
			
			/* add stage Fiducial (object) event listeners */
			trace("add stage fiducial event listeners.");
			_stage.addEventListener(TuioFiducialEvent.ADD, fiducialADD);
			_stage.addEventListener(TuioFiducialEvent.MOVE, fiducialUPDATE);
			_stage.addEventListener(TuioFiducialEvent.REMOVED, fiducialREMOVE);
		}
		
		/* FIDUCIAL FUNCTIONS */
		/**
		 * handle fiducial (Object) add events
		 */
		public function fiducialADD(e:TuioFiducialEvent):void {
			// debug mode console message if FiducialEvent.ADD event captured
			trace("Fiducial #" + e.fiducialId + " fiducial added.");
			
			if (e.fiducialId == 0)
			{					
				/* alternative 1: load keyboard class */
				_keyboard = new CustomKeyboard(e.x, e.y, 718, 200, e.x, e.y + 220, _buttonTextColor, _buttonColor, _borderColor); 
				//_keyboard.filters = [new GlowFilter(0x0055ff, .75, 100, 100, 2, 2, false, false)];
				
				_stage.addChild(_keyboard);
				
				/* alternative 2: load the content of *.swf file */
				//var _objectLoader:Loader = new Loader;
				//_objectLoader.load(new URLRequest("CustomKeyboard.swf"));
				//_stage.addChild(_objectLoader);
			}
			
			if (e.fiducialId == 1)
			{					
				_pongGame = new PongGame(_stage, _borderColor);
				_pongGame.x = e.x;
				_pongGame.y = e.y;
				_stage.addChild(_pongGame);
			}
			
			if (e.fiducialId == 2)
			{	
				_piano = new Piano(_textColor, _buttonTextColor, _buttonOnColor, _buttonOffColor, _white_keys_color);  
				//_piano = new Piano();
				_piano.x = e.x;
				_piano.y = e.y;
				_piano.rotation = 90;
				_piano.scaleX = 2;
				_piano.scaleY = 2;
				_stage.addChild(_piano);
			}
		}
		
		/**
		 * handle fiducial (Object) remove events
		 */
		public function fiducialREMOVE(e:TuioFiducialEvent):void {
			trace("Fiducial #" + e.fiducialId + " fiducial removed.");
			
			if (e.fiducialId == 0)
			{
				/* alternative 1: remove keyboard class from stage */
				_stage.removeChild(_keyboard);
				
				/* alternative 2: remove loaded *.swf file from stage */
				//_stage.removeChild(_objectLoader);
			}			
			
			if (e.fiducialId == 1)
			{					
				_pongGame.stopGame();
				_stage.removeChild(_pongGame);
			}
			
			if (e.fiducialId == 2)
			{					
				_stage.removeChild(_piano);
			}
		}
		
		/**
		 * handle fiducial (Object) move events
		 */
		public function fiducialUPDATE(e:TuioFiducialEvent):void {
			trace("Fiducial #" + e.fiducialId + " fiducial move.");
			
			if (e.fiducialId == 0) {
				_keyboard.update(e.x, e.y, e.x, e.y + 220);	
			}
			
			if (e.fiducialId == 1) {
				_pongGame.x = e.x;
				_pongGame.y = e.y;
			}
			
			if (e.fiducialId == 2)
			{					
				_piano.x = e.x;
				_piano.y = e.y;
			}
		}
		
		/** 
		 * tuio set up 
		 */
		public function tuioLoader():void {
			//var _tc:TuioClient;
			
			/* tuio client setup (a LC/UDP/TCP socket that connects to the server '_host' using port '_port') creation */
			if (_LCconnector) { 
				trace("tuioClient LC connector.")
				_tc = new TuioClient(new LCConnector());	
			}
			
			if (_TCPconnector) { 
				trace("tuioClient TCP connector.")
				_tc = new TuioClient(new TCPConnector(_host, _port));	
			}
			
			if (_UDPconnector) {
				trace("tuioClient UDP connector.")
				_tc = new TuioClient(new UDPConnector(_host, _port));
			}		
			
			/* optional: activate tuio debug mode to display touches */
			if (_debug) {
				trace("tuioDebug on.")
				_tc.addListener(TuioDebug.init(_stage)); 
			}
			
			/* tuioManager setup (a container which processes the Tuio tracking data received by the given TuioClient) creation */
			//if (_tuioManager) {
			if (_tuioManager) {
				trace("tuioManager on.")
				_tm = TuioManager.init(_stage);
				_tc.addListener(_tm);
				//_tm.touchTargetDiscoveryMode = TuioManager.TOUCH_TARGET_DISCOVERY_NONE
				
				/* add tuioManager tuio event listeners */
				_tm.addEventListener(TuioEvent.ADD, packetsCount);
				_tm.addEventListener(TuioEvent.REMOVE, packetsCount);
				_tm.addEventListener(TuioEvent.UPDATE, packetsCount);
			}		
			
						/* optional: activate tuio fiducial capture events */
			if (_fiducialHandler) {
				trace("fiducial Handler on.")
				/* add tuioManager tuio event listeners */
				_tm.addEventListener(TuioFiducialEvent.ADD, packetsCount);
				_tm.addEventListener(TuioFiducialEvent.MOVE, packetsCount);
				_tm.addEventListener(TuioFiducialEvent.REMOVED, packetsCount);	
			}
			
			/* optional: treat Gestures */
			if (_gestureManager) {
				trace("gestureManager on.")
				_gm = GestureManager.init(_stage);
				//_tc.addListener(_gm);
				//_gm.touchTargetDiscoveryMode = GestureManager.TOUCH_TARGET_DISCOVERY_NONE;
				
				GestureManager.addGesture(new DragGesture());
				GestureManager.addGesture(new ZoomGesture(TwoFingerMoveGesture.TRIGGER_MODE_MOVE));  //TRIGGER_MODE_TOUCH for NativeTuioAdapter
				GestureManager.addGesture(new RotateGesture(TwoFingerMoveGesture.TRIGGER_MODE_MOVE)); //TRIGGER_MODE_TOUCH for NativeTuioAdapter				
				GestureManager.addGesture(new ScrollGesture(TwoFingerMoveGesture.TRIGGER_MODE_MOVE));
				GestureManager.addGesture(new PressTapGesture());
				GestureManager.addGesture(new OneDownOneMoveGesture());
			}
		}
		
		/**
		 * Show total tuio events captured log 
		 */
		private function packetsCount(e:TuioEvent):void {
			var date:Date = new Date();
			_packets_count++;
			
			_log += _packets_count + " Packet captured TuioEvent at " + date.fullYear;
			
			if ((date.month + 1) < 10) {
				_log += "-0" + (date.month + 1);
			}
			else {
				_log += "-" + (date.month + 1);
			}
			
			if (date.date < 10) {
				_log += "-0" + date.date;
			}
			else {
				_log += "-" + date.date;
			}
			
			if (date.hours < 10) {
				_log += " 0" + date.hours;
			}
			else {
				_log += " " + date.hours;
			}
			
			if (date.minutes < 10) {
				_log += ":0" + date.minutes;
			}
			else {
				_log += ":" + date.minutes;
			}
			
			if (date.seconds < 10) {
				_log += ":0" + date.seconds;
			}
			else {
				_log += ":" + date.seconds;
			}
			
			if (date.milliseconds < 10) {
				_log += ".00" + date.milliseconds;
			} else if (date.milliseconds < 100) {
				_log += ".0" + date.milliseconds;
			}
			else {
				_log += "." + date.milliseconds;
			}
			
			_log += "\n";
		}
		
		/**
		 * handle stage "F1" keyboard events 
		 */
		private function showTuioNetworkPacketsLog(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.F1) {
				trace("touch hold.");
				trace(_log);
				trace("Packets captured " + _packets_count + "\n");				
			}
		}
		
		/* MOUSE CURSOR FUNCTIONS */
		/**
		 * display a circle where mouse cursor is
		 */
		private function addMouseCursor():void {
			/* Create a Sprite instance called _mouseCursor */
			_mouseCursor = new Sprite;
			
			/*
			 * Set blend mode "DARKEN" and 
			 * fill a circle at the starting position (0,0) of radius 5, with rgb color '_color' and alpha blending 1 or 
			 * draw a circle with line thickness 1.1, with rgb color '_color' and alpha blending 1. 
			 */
			//_mouseCursor.blendMode = BlendMode.DARKEN;
			//_mouseCursor.graphics.beginFill(0x770000, 1);
			_mouseCursor.graphics.lineStyle(1.1, _color, 1, false, LineScaleMode.NONE);
			_mouseCursor.graphics.drawCircle(0, 0, 20);
			//_mouseCursor.graphics.endFill();
			
			/* set circle center at mouse coursor position */
			_mouseCursor.x = _mouseCursor.mouseX;
			_mouseCursor.y = _mouseCursor.mouseY;
			
			/* set circle visibility default value */
			_mouseCursor.visible = false;
			
			/* add the circle to the stage */
			_stage.addChild(_mouseCursor);
		}
		
		/**
		 * handle mouse movement events for the circle
		 */
		private function followMouse(e:MouseEvent):void {
			if (_mouseCursor != null) {
				_mouseCursor.x = _stage.mouseX;
				_mouseCursor.y = _stage.mouseY;
			}
		}
		
		/**
		 * handle mouse down events for circle
		 */
		private function mouseDown(e:MouseEvent):void {
			if (_mouseCursor != null) {
				_mouseCursor.visible = true;
			}
		}
		
		/**
		 * handle mouse up events for circle
		 */
		private function mouseUp(e:MouseEvent):void {
			if (_mouseCursor != null) {
				_mouseCursor.visible = false;
			}
		}
	}
}