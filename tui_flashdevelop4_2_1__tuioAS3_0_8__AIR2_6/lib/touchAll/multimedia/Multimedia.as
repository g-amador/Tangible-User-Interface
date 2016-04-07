/*
 * Tangible User Interfacer (former TouchAll) misc code.
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
package touchAll.multimedia
{
	//import flash.ui.*;
	import flash.media.*;
	//import flash.utils.*;
	import flash.display.*;
	import flash.printing.*;
	//import flash.filters.*;
	//import flash.events.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TransformGestureEvent;
	//import flash.events.GestureEvent;
	import flash.events.PressAndTapGestureEvent;
	//import flash.events.TouchEvent;
	import flash.events.FileListEvent;
	import flash.filesystem.*;
	import flash.geom.*;
	import flash.net.*;
	
	import org.tuio.*;
	import org.tuio.gestures.*;
	
	import touchAll.*;
	
	/**
	 * @author Gonçalo Amador
	 * TO ADD:
	 * 1 - Support file open browse/print through touch/gesture events 
	 * 2 - ...
	 */
	
	public class Multimedia implements IMultimedia 
	{
		/* global variables */
		private var _stage:Stage;
		private var _multimedia:Array = new Array;
		private var _background:Sprite = TouchAll._background;		
		//private var _tm:TuioManager;
		
		public function Multimedia(stage:Stage) {
		//public function Multimedia(stage:Stage, _tm:TuioManager) {
			_stage = stage;
			//_tm = tm;
		}
		
		public function setBackground(background:Sprite):void {
			_background = background;
		}
		
		/**
		 * background event listener for multimedia set up
		 */ 
		public function backgroundMultimediaEventListenersLoader():void {
			_background.doubleClickEnabled = true;
			
			/* add background mouse/touch event listeners */
			trace("add background mouse/touch event listeners.");
			_background.addEventListener(MouseEvent.DOUBLE_CLICK, sortMultimedia);
			_background.addEventListener(MouseEvent.RIGHT_CLICK, multimediaFileExplorer);
			
			_background.addEventListener(TuioTouchEvent.DOUBLE_TAP, sortMultimedia);
			//_background.addEventListener(TuioTouchEvent.TAP, touchImageFileExplorer);			
		}
		
		/**
		 * load, display and handle an image
		 * @param	path - image URL
		 * @param	scaleX - image widht in %
		 * @param	scaleY - image height in %
		 */
		public function addImage(path:String, scaleX:Number = 0.25, scaleY:Number = 0.25):void {
			var image:Sprite = new Sprite;
			var imageLoader:Loader = new Loader;
			var fileRequest:URLRequest = new URLRequest(path);
			
			imageLoader.doubleClickEnabled = true;
			//imageLoader.mouseEnabled = false;
			
			/* load image from given path to an sprite object and put it in the multimedia list */
			imageLoader.load(fileRequest);
			image.addChild(imageLoader);
			_multimedia.push(image);
			
			/* set image dimentions */
			image.scaleX = scaleX;
			image.scaleY = scaleY;
			
			/* set image initial position */
			image.x = (Math.random() * 800);
			image.y = (Math.random() * 200);
			
			/* load an image event listeners */
			imageEventListenersLoader(image);
			
			/* add an image to the stage */
			_stage.addChild(image);
		}		
		
		/**
		 * load, display and handle an SWF
		 * @param	path - SWF URL
		 * @param	scaleX - video widht in %
		 * @param	scaleY - video height in %
		 */
		public function addSWF(path:String, scaleX:Number = 1, scaleY:Number = 1):void {
			addImage(path, scaleX, scaleY);
		}
		
		/**
		 * load, display and handle an video MP4 or FLV
		 * @param	path - video URL
		 * @param	widht - video widht
		 * @param	height - video height
		 */
		public function addVideo(path:String, widht:int = 320, height:int = 200):void {
			var st:SoundTransform = new SoundTransform(0.5);
			var nc:NetConnection = new NetConnection;
			nc.connect(null);
			
			var ns:NetStream = new NetStream(nc);
			var video:Video = new Video(widht, height);
			var movieClip:MovieClip = new MovieClip;
			var videoMenu:VideoMenu =  new VideoMenu(ns, path, video.x + widht / 4, video.y + height);
			
			movieClip.doubleClickEnabled = true;
			
			video.attachNetStream(ns);
			
			/* add an video and respective menu to an movie clip container and put it in the multimedia list */
			movieClip.addChild(video);
			movieClip.addChild(videoMenu);
			_multimedia.push(movieClip);
			
			/* set video and respective menu initial positions */
			movieClip.x = (Math.random() * 800);
			movieClip.y = (Math.random() * 200);	
			
			/* load an movie clip container event listeners */
			videoEventListenersLoader(movieClip);
						
			/* add an movie clip container to the stage */
			_stage.addChild(movieClip);
			
			/* onMetaData listener is required otherwise you get a ReferenceError */
			var listener:Object = new Object;
			listener.onMetaData = function(metadata:Object):void {
				trace(metadata.duration);
			};
			
			ns.client = listener;
			ns.soundTransform = st;
			ns.play(path);
			ns.pause();
		}
		
		/**
		 * image event listeners set up
		 * @param	image
		 */ 
		public function imageEventListenersLoader(image:Sprite):void {
			/* add image mouse event listeners */
			trace("add image mouse event listeners.");
			image.addEventListener(MouseEvent.MOUSE_MOVE, dragMultimedia);
			image.addEventListener(MouseEvent.MOUSE_WHEEL, scaleRotateMultimedia);
			image.addEventListener(MouseEvent.DOUBLE_CLICK, zoomInOutMultimedia);
			image.addEventListener(MouseEvent.RIGHT_CLICK, function(e:MouseEvent):void {
				trace("image mouse right click.");
				imagePrint(image);
			});
			
			/* add image touch/gesture event listeners */
			trace("add image touch/gesture event listeners.");
			image.addEventListener(TransformGestureEvent.GESTURE_PAN, touchDragMultimedia);
			image.addEventListener(TransformGestureEvent.GESTURE_ZOOM, touchScaleMultimedia);
			image.addEventListener(TransformGestureEvent.GESTURE_ROTATE, touchRotateMultimedia);
			
			image.addEventListener(TuioTouchEvent.DOUBLE_TAP, zoomInOutMultimedia);
			
			/*
			image.addEventListener(PressAndTapGestureEvent.GESTURE_PRESS_AND_TAP, function(e:PressAndTapGestureEvent):void {
				trace("one down one tap gesture event.");
			});
			
			image.addEventListener(OneDownOneMoveGesture.GESTURE_ONE_DOWN_ONE_MOVE, function(e:GestureEvent):void {
				trace("one down one move gesture event.");
			});
			image.addEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP, function(e:GestureEvent):void {
				trace("two fingers tap gesture event.");
			});
			*/
			
			/* alternative using tuioManager */
			//_tm.addEventListener(TouchEvent.DOUBLE_TAP, tuioManagerTouchZoomInOut);
		}
		
		/**
		 * video event listeners set up
		 * @param	video
		 */ 
		public function videoEventListenersLoader(video:MovieClip):void {
			/* add video mouse event listeners */
			trace("add video mouse event listeners.");
			video.addEventListener(MouseEvent.MOUSE_MOVE, dragMultimedia);
			video.addEventListener(MouseEvent.MOUSE_WHEEL, scaleRotateMultimedia);
			video.addEventListener(MouseEvent.DOUBLE_CLICK, zoomInOutMultimedia);
			
			/* add video touch/gesture event listeners */
			trace("add video touch/gesture event listeners.");
			video.addEventListener(TransformGestureEvent.GESTURE_PAN, touchDragMultimedia);
			video.addEventListener(TransformGestureEvent.GESTURE_ZOOM, touchScaleMultimedia);
			video.addEventListener(TransformGestureEvent.GESTURE_ROTATE, touchRotateMultimedia);
			
			video.addEventListener(TuioTouchEvent.DOUBLE_TAP, zoomInOutMultimedia);
			
			/*
			video.addEventListener(PressAndTapGestureEvent.GESTURE_PRESS_AND_TAP, function(e:PressAndTapGestureEvent):void {
				trace("one down one tap gesture event.");
			});
			
			video.addEventListener(OneDownOneMoveGesture.GESTURE_ONE_DOWN_ONE_MOVE, function(e:GestureEvent):void {
				trace("one down one move gesture event.");
			});
			video.addEventListener(GestureEvent.GESTURE_TWO_FINGER_TAP, function(e:GestureEvent):void {
				trace("two fingers tap gesture event.");
			});
			*/
			
			/* alternative using tuioManager */
			//_tm.addEventListener(TouchEvent.DOUBLE_TAP, tuioManagerTouchZoomInOut);
		}
		
		/**
		 * handle mouse right click for an image or SWF
		 * @param	image
		 */
		private function imagePrint(image:Sprite):void {
			trace("print an image or SWF.");
			var pj:PrintJob = new PrintJob; 
			var uiOpt:PrintUIOptions = new PrintUIOptions; 
			
			//pj.selectPaperSize(PaperSize.LEGAL); 
            //pj.orientation = PrintJobOrientation.LANDSCAPE; 
            //pj.copies = 2; 
            //pj.jobName = "Flash test print"; 
			
			// test for dialog support as a static property of PrintJob class 
            //if (PrintJob.supportsPageSetupDialog) 
            //{ 
                //pj.showPageSetupDialog; 
            //} 
			
            if (pj.start2(uiOpt, true)) 
            { 
                 try 
                { 
                    pj.addPage(image, new Rectangle(0, 0, 100, 100)); 
                } 
                catch (error:Error) 
                { 
                     // Do nothing. 
                } 
                pj.send(); 
            } 
            else 
            { 
                pj.terminate(); 
            } 
		}
		
		/**
		 * handle touch/mouse double tap/click events on the stage background for multimedia
		 */
		private function sortMultimedia(e:Event):void {
			trace("touch/mouse double tap/click event, multimedia sorted.");
			
			var x:int = 10;
			var y:int = 10;
			
			for each (var multimedia:DisplayObjectContainer in _multimedia)
			{	
				/* set multimedia in with no rotation */
				multimedia.rotation = 0;
				
				/* set multimedia initial position */
				multimedia.x = x;
				multimedia.y = y;
				
				x += 30;
				y += 30;
			}
		}
		
		/** 
		 * set multimedia in front of all multimedia in the stage 
		 */
		private function multimediaToFront(e:Event):void {
			//trace("multimedia to front.");
			var multimedia:* = _multimedia[_multimedia.indexOf(e.currentTarget)];
			_multimedia.splice(_multimedia.indexOf(e.currentTarget),1);
			_stage.removeChild(multimedia);
			_stage.addChild(multimedia);
			_multimedia.push(multimedia);
		}
		
		/**
		 * handle touch/mouse double tap/click events for an multimedia
		 */
		private function zoomInOutMultimedia(e:Event):void {
			//trace("touch/mouse multimedia zoom in/out.");
			multimediaToFront(e);
			
			/* set multimedia in with no rotation */
			e.currentTarget.rotation = 0;
			
			if (e.currentTarget.width != _stage.stageWidth)
			{				
				/* set multimedia dimentions */
				e.currentTarget.width = _stage.stageWidth;
				e.currentTarget.height = _stage.stageHeight;
				
				/* set multimedia initial position */
				e.currentTarget.x = 0;
				e.currentTarget.y = 0;
			}
			else {
				/* set multimedia dimentions */
				if (e.currentTarget is MovieClip) {
					e.currentTarget.scaleX = 1;
					e.currentTarget.scaleY = 1;	
				}
				else {
					e.currentTarget.scaleX = 0.25;
					e.currentTarget.scaleY = 0.25;	
				}
				
				/* set multimedia initial position */
				e.currentTarget.x = (Math.random() * 800);
				e.currentTarget.y = (Math.random() * 200);
			}
		}
		
		/**
		 * handle mouse right click events on background
		 */
		private function multimediaFileExplorer(e:MouseEvent):void {
			var files:File = new File;
			var imagesFilter:FileFilter = new FileFilter("Images", "*.jpg;*.gif;*.png");
			var videosFilter:FileFilter = new FileFilter("Videos", "*.flv;*.mp4");
			var swfFilter:FileFilter = new FileFilter("SWF", "*.swf"); 
			
			files.addEventListener(FileListEvent.SELECT_MULTIPLE, function(e:FileListEvent):void {
				trace("Selected");
				for each (var file:File in e.files) {		
					trace(file.nativePath);
					switch (file.extension) {
						case "jpg":
							trace("jpg");
							addImage(file.nativePath);
						break;
						case "gif":
							trace("gif");
							addImage(file.nativePath);
						break;
						case "png":
							trace("png");
							addImage(file.nativePath);
						break;
						case "png":
							trace("png");
							addImage(file.nativePath);
						break;
						case "swf":
							trace("swf");
							addImage(file.nativePath);
						break;
						case "flv":
							trace("flv");
							addVideo(file.nativePath);
						break;
						case "mp4":
							trace("mp4");
							addVideo(file.nativePath);
						break;
					}
				}
			});
			
			files.browseForOpenMultiple("Select Multimedia", [imagesFilter, videosFilter, swfFilter]);
		}
		
		/**
		 * handle mouse movement events for an multimedia
		 */
		private function dragMultimedia(e:MouseEvent):void {
			multimediaToFront(e);
			
			if (e.buttonDown == true) {
				//trace("mouse multimedia drag.");
				e.currentTarget.startDrag();
			}
			else
				e.currentTarget.stopDrag();
		}
		
		/**
		 * handle drag gesture events for an multimedia
		 */
		private function touchDragMultimedia(e:TransformGestureEvent):void {
			multimediaToFront(e);
			
			//trace("touch multimedia drag.");
			e.currentTarget.x += (e.offsetX);
			e.currentTarget.y += (e.offsetY);		
		}
		
		/**
		 * handle mouse wheel scroll events for an multimedia
		 */
		private function scaleRotateMultimedia(e:MouseEvent):void {
			multimediaToFront(e);
			
			if (e.buttonDown == false) {
				//trace("mouse multimedia rotate.");
				var m:Matrix = e.currentTarget.transform.matrix;
				m.tx -= _stage.mouseX;
				m.ty -= _stage.mouseY;
				
				if(e.delta > 0)
					m.rotate ( -15 * (Math.PI / 180));
				else
					m.rotate ( 15 * (Math.PI / 180));	
				
				m.tx += _stage.mouseX;
				m.ty += _stage.mouseY;
				e.currentTarget.transform.matrix = m;				
			}
			else {
				//trace("mouse multimedia scale.");
				if (e.delta > 0) {
					if ((e.currentTarget.scaleX > 0.15) && (e.currentTarget.scaleY > 0.15)) {
						e.currentTarget.scaleX -= 0.05;
						e.currentTarget.scaleY -= 0.05;
					}
				}
				else {
					if ((e.currentTarget.scaleX < 1) && (e.currentTarget.scaleY < 1)) {
						e.currentTarget.scaleX += 0.05;
						e.currentTarget.scaleY += 0.05;
					}
				}
			}
		}
		
		/**
		 * handle zoom gesture events for an multimedia
		 */
		private function touchScaleMultimedia(e:TransformGestureEvent):void {
			multimediaToFront(e);
			
			if ((e.currentTarget.scaleX > 0.15) && (e.currentTarget.scaleY > 0.15) && (e.currentTarget.scaleX < 1) && (e.currentTarget.scaleY < 1)) {
				//trace("touch multimedia scale.");
				e.currentTarget.scaleX += e.scaleX;
				e.currentTarget.scaleY += e.scaleY;
			}
		}
		
		/**
		 * handle rotate gesture events for an multimedia
		 */
		private function touchRotateMultimedia(e:TransformGestureEvent):void {
			//trace("touch multimedia rotate.");
			multimediaToFront(e);
			
			e.currentTarget.rotation += e.rotation;
		}
		
		/**
		 * handle touch double tap events for an multimedia
		 */
		private function tuioManagerTouchZoomInOutMultimedia(e:TuioTouchEvent):void {
			//trace("tuioManager multimedia zoom in/out.");
			
			multimediaToFront(e);
			
			/* set multimedia in with no rotation */
			e.relatedObject.parent.rotation = 0;
			
			if (e.relatedObject.parent.width != _stage.stageWidth) {				
				/* set multimedia dimentions */
				e.relatedObject.parent.width = _stage.stageWidth;
				e.relatedObject.parent.height = _stage.stageHeight;
				
				/* set multimedia initial position */
				e.relatedObject.parent.x = 0;
				e.relatedObject.parent.y = 0;
			}
			else {
				/* set multimedia dimentions */
				e.relatedObject.parent.scaleX = 0.25;
				e.relatedObject.parent.scaleY = 0.25;
				
				/* set multimedia initial position */
				e.relatedObject.parent.x = (Math.random() * 800);
				e.relatedObject.parent.y = (Math.random() * 200);
			}
		}			
	}
}
