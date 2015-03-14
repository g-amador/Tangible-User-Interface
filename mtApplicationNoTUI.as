package touchAll.demos.multimediaTouchDemo 
{
	import flash.ui.*;
	import flash.display.*;
	import flash.events.Event;
	//import flash.events.TouchEvent;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	
	import touchAll.ITouchAll;
	import touchAll.multimedia.Multimedia;
	
	import org.tuio.*;
	import org.tuio.connectors.*;
	import org.tuio.debug.*;
	import org.tuio.gestures.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	[SWF(width="1280", height="720", frameRate="60", backgroundColor="#ffffff")]
	public class MultimediaNoTouchAllDemo extends MovieClip implements ITouchAll 
	{
		/* global variables */	
		private var background:Sprite = new Sprite;
		private var packets_count:uint = 0;
		private var log:String = "";
		private var mouseCursor:Sprite;
		
		private var tc:TuioClient;
		private var tm:TuioManager;
		private var gm:GestureManager;
		
		private var multimedia:Multimedia = new Multimedia(stage);
		
		public function MultimediaNoTouchAllDemo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/* LOAD STAGE CONTENT */
			backgroundLoader();
			multimedia.setBackground(background);
			multimedia.backgroundMultimediaEventListenersLoader();
			
			/* load images */
			multimedia.addImage("resources/summer.jpg");
			multimedia.addImage("resources/palacio.jpg");
			multimedia.addImage("resources/lake.jpg");
			multimedia.addImage("resources/forest.jpg");
			//multimedia.addImage("file:///G:/touch/Source%20Code/TouchProject/bin/resources/forest.jpg");
			
			/* load an SWF */
			//multimedia.addSWF("resources/test.swf");
			
			/* load an MP4 and FLV */
			multimedia.addVideo("resources/South Park Mac vs. PC.mp4");
			multimedia.addVideo("resources/South Park Mac vs. PC vs. Linux.flv");
			
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
			background.blendMode = BlendMode.ALPHA;
			background.graphics.beginFill(0xFFFFFF,1);
			background.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			background.graphics.endFill();
			
			/* set activate doubleClick mouse checks */
			trace("set activate doubleClick mouse checks.");
			background.doubleClickEnabled = true;
			
			/* add the background to the stage */
			trace("add the background to the stage.");
			stage.addChild(background);	
		}
		
		/** 
		 * stage set up 
		 */
		public function stageLoader():void {
			/* STAGE SET UP */	
			trace("STAGE SET UP.");
			stage.stageWidth = 1280;
			stage.stageHeight = 720;
			
			/* AIR stage settings */
			trace("AIR stage settings.");
			//stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			/* set activate doubleClick mouse checks */
			trace("set activate doubleClick mouse checks.");
			stage.doubleClickEnabled = true;
			
			/* load an circle to track mouse cursor */
			trace("load an circle to track mouse cursor.");
			addMouseCursor(); 			
		}
		
		/** 
		 * stage event listeners set up 
		 */
		public function stageEventListenersLoader():void {
			/* STAGE EVENT LISTENERS */
			/* add stage keyboard event listeners */
			trace("add stage keyboard event listeners.");
			stage.addEventListener(KeyboardEvent.KEY_DOWN, showTuioNetworkPacketsLog);
			
			/* add stage mouse event listeners */
			trace("add stage mouse event listeners.");
			stage.addEventListener(MouseEvent.MOUSE_MOVE, followMouse);			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);	
		}	
		
		/**
		 * Show total tuio events captured log 
		 */
		private function packetsCount(e:TuioEvent):void {
			var date:Date = new Date();
			packets_count++;
			
			log += packets_count + " Packet captured TuioEvent at " + date.fullYear;
			
			if ((date.month + 1) < 10) {
				log += "-0" + (date.month + 1);
			}
			else {
				log += "-" + (date.month + 1);
			}
			
			if (date.date < 10) {
				log += "-0" + date.date;
			}
			else {
				log += "-" + date.date;
			}
			
			if (date.hours < 10) {
				log += " 0" + date.hours;
			}
			else {
				log += " " + date.hours;
			}
			
			if (date.minutes < 10) {
				log += ":0" + date.minutes;
			}
			else {
				log += ":" + date.minutes;
			}
			
			if (date.seconds < 10) {
				log += ":0" + date.seconds;
			}
			else {
				log += ":" + date.seconds;
			}
			
			if (date.milliseconds < 10) {
				log += ".00" + date.milliseconds;
			} else if (date.milliseconds < 100) {
				log += ".0" + date.milliseconds;
			}
			else {
				log += "." + date.milliseconds;
			}
			
			log += "\n";
		}
		
		/**
		 * handle stage "F1" keyboard events 
		 */
		private function showTuioNetworkPacketsLog(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.F1) {
				trace("touch hold.");
				trace(log);
				trace("Packets captured " + packets_count + "\n");				
			}
		}
		
		/**
		 * display a circle where mouse cursor is
		 */
		private function addMouseCursor():void {
			/* Create a Sprite instance called mouseCursor */
			mouseCursor = new Sprite;
			
			/*
			 * Set blend mode "DARKEN" and 
			 * fill a circle at the starting position (0,0) of radius 5, with rgb color '_color' and alpha blending 1 or 
			 * draw a circle with line thickness 1.1, with rgb color '_color' and alpha blending 1. 
			 */
			//mouseCursor.blendMode = BlendMode.DARKEN;
			//mouseCursor.graphics.beginFill(0x770000, 1);
			mouseCursor.graphics.lineStyle(1.1, 0x000000, 1, false, LineScaleMode.NONE);
			mouseCursor.graphics.drawCircle(0, 0, 20);
			//mouseCursor.graphics.endFill();
			
			/* set circle center at mouse coursor position */
			mouseCursor.x = mouseCursor.mouseX;
			mouseCursor.y = mouseCursor.mouseY;
			
			/* set circle visibility default value */
			mouseCursor.visible = false;
			
			/* add the circle to the stage */
			stage.addChild(mouseCursor);
		}
		
		/**
		 * handle mouse movement events for the circle
		 */
		private function followMouse(e:MouseEvent):void {
			if (mouseCursor != null) {
				mouseCursor.x = stage.mouseX;
				mouseCursor.y = stage.mouseY;
			}
		}
		
		/**
		 * handle mouse down events for circle
		 */
		private function mouseDown(e:MouseEvent):void {
			if (mouseCursor != null) {
				mouseCursor.visible = true;
			}
		}
		
		/**
		 * handle mouse up events for circle
		 */
		private function mouseUp(e:MouseEvent):void {
			if (mouseCursor != null) {
				mouseCursor.visible = false;
			}
		}
		
		/** 
		 * tuio set up
		 */
		public function tuioLoader():void {
			var tc:TuioClient;
			
			trace("tuioClient UDP connector.")
			tc = new TuioClient(new UDPConnector("127.0.0.1", 3333));
			
			trace("tuioDebug on.")
			tc.addListener(TuioDebug.init(stage)); 
			
			/* tuioManager setup (a container which processes the Tuio tracking data received by the given TuioClient) creation */
			trace("tuioManager on.")
			tm = TuioManager.init(stage, tc);
			
			/* add tuioManager tuio event listeners */
			tm.addEventListener(TuioEvent.ADD, packetsCount);
			tm.addEventListener(TuioEvent.REMOVE, packetsCount);
			tm.addEventListener(TuioEvent.UPDATE, packetsCount);
			
			trace("gestureManager on.")
			gm = GestureManager.init(stage, tc);
				
			GestureManager.addGesture(new DragGesture());
			GestureManager.addGesture(new ZoomGesture());
			GestureManager.addGesture(new RotateGesture());				
			GestureManager.addGesture(new PressTapGesture());
			GestureManager.addGesture(new OneDownOneMoveGesture());
		}		
	}
}
