/*
 * Tangible User Interfacer (former TouchAll) code.
 *
 * Copyright 2016 Gonçalo Amador <g.n.p.amador@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package touchAll
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
	import org.tuio.fiducial.*;
	import org.tuio.gestures.*;
	import org.tuio.mouse.*;
	import org.tuio.windows7.*;
	
	/**
	 * @author Gonçalo Amador
	 * TO ADD:
	 * 1 - ...
	 */
	
	public class TouchAll extends MovieClip implements ITouchAll 
	{
		/* global variables */
		private var _stage:Stage;
		private var _width:int;
		private var _height:int;
		private var _color:uint;
		private var _tm:TuioManager;
		private var _gm:GestureManager;
		private var _packets_count:uint = 0;
		private var _log:String = "";
		public static var _mouseCursor:Sprite;
		public static var _background:Sprite = new Sprite;
		
		private var _debug:Boolean;
		private var _LCconnector:Boolean;
		private var _UDPconnector:Boolean;
		private var _TCPconnector:Boolean;
		private var _host:String;
		private var _port:int;
		private var _fiducialHandler:Boolean;
		private var _tuioManager:Boolean;
		private var _gestureManager:Boolean;
		private var _mouseToTouch:Boolean;
		public static var _tc:TuioClient;
		
		//Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		//Multitouch.inputMode = MultitouchInputMode.GESTURE;
		
		public function TouchAll(stage:Stage = null, width:int = 1280, height:int = 720, color:uint = 0x000000, debug:Boolean = true, mouseToTouch:Boolean = false,  
			LCconnector:Boolean = false, UDPconnector:Boolean = true, TCPconnector:Boolean = false, host:String = "127.0.0.1", port:int = 3333, 
			fiducialHandler:Boolean = true, tuioManager:Boolean = true, gestureManager:Boolean = true) {
			_stage = stage;
			_width = width;
			_height = height;
			_color = color;
			_debug = debug;
			_LCconnector = LCconnector;
			_UDPconnector = UDPconnector;
			_TCPconnector = TCPconnector;
			_host = host;
			_port = port;
			_fiducialHandler = fiducialHandler;
			_tuioManager = tuioManager;
			_gestureManager = gestureManager;
			_mouseToTouch = mouseToTouch;
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
			
			/* optional: activate tuio fiducial capture events */
			if (_fiducialHandler) {
				trace("fiducial Handler on.")
				var fiducialDispatcher:TuioFiducialDispatcher = TuioFiducialDispatcher.init(_stage);
				_tc.addListener(fiducialDispatcher);
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
				_tm = TuioManager.init(_stage, _tc);
				//_tm.touchTargetDiscoveryMode = TuioManager.TOUCH_TARGET_DISCOVERY_NONE
				
				/* add tuioManager tuio event listeners */
				_tm.addEventListener(TuioEvent.ADD, packetsCount);
				_tm.addEventListener(TuioEvent.REMOVE, packetsCount);
				_tm.addEventListener(TuioEvent.UPDATE, packetsCount);
			}		
			
			/* optional: treat Gestures */
			if (_gestureManager) {
				trace("gestureManager on.")
				_gm = GestureManager.init(_stage, _tc);
				//_gm.touchTargetDiscoveryMode = GestureManager.TOUCH_TARGET_DISCOVERY_NONE;
				
				GestureManager.addGesture(new DragGesture());
				GestureManager.addGesture(new ZoomGesture());
				GestureManager.addGesture(new RotateGesture());
				
				//GestureManager.addGesture(new ScrollGesture());
				GestureManager.addGesture(new PressTapGesture());
				GestureManager.addGesture(new OneDownOneMoveGesture());
			}
			
			/* optional: treat MouseEvents also as TouchEvents */
			if (_mouseToTouch) {
				var mouseToTouch:MouseToTouchDispatcher = new MouseToTouchDispatcher(_stage);
			}
			
			/* optional: convert the native TouchEvents into tuio TouchEvents */
			//var winTouch:Windows7TouchToTuioDispatcher = new Windows7TouchToTuioDispatcher(_stage,false,false);
			
			/* optional: dispatch the events by using the TuioManager */			
			//var winTouch:Windows7TouchToTuioDispatcher = new Windows7TouchToTuioDispatcher(_stage,true,false);
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
