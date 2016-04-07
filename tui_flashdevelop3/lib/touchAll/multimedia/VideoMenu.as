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
	import flash.display.*;
	import flash.media.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.*;
	
	import org.tuio.*;
	
	/**
	 * ...
	 * @author Gonçalo Amador
	 */
	public class VideoMenu extends MovieClip
	{
		/* global variables */
		private var _path:String;
		private var _ns:NetStream;
		private var stoped:Boolean = true;
		private var playButton:Sprite = new Sprite;
		private var pauseButton:Sprite = new Sprite;
		private var stopButton:Sprite = new Sprite;
		private var volumeUpButton:Sprite = new Sprite;
		private var volumeDownButton:Sprite = new Sprite;
		private var st:SoundTransform = new SoundTransform(0.5);
		
		public function VideoMenu(ns:NetStream = null, path:String = "", x:uint = 0, y:uint = 0) 
		{
			/* local button sprites and loaders */
			var playButtonLoader:Loader = new Loader;
			var stopButtonLoader:Loader = new Loader;
			var pauseButtonLoader:Loader = new Loader;
			var volumeUpButtonLoader:Loader = new Loader;
			var volumeDownButtonLoader:Loader = new Loader;
			
			/* global variables set up */
			_ns = ns;
			_path = path;
			
			//buttonLoader.doubleClickEnabled = true;
			//buttonLoader.mouseEnabled = false;
			
			/* load each button's image from given path to an sprite object */
			playButtonLoader.load(new URLRequest("resources/buttons/Button Play.png"));
			playButton.addChild(playButtonLoader);
			stopButtonLoader.load(new URLRequest("resources/buttons/Button Stop.png"));
			stopButton.addChild(stopButtonLoader);
			pauseButtonLoader.load(new URLRequest("resources/buttons/Button Pause.png"));
			pauseButton.addChild(pauseButtonLoader);
			volumeUpButtonLoader.load(new URLRequest("resources/buttons/Button Add.png"));
			volumeUpButton.addChild(volumeUpButtonLoader);
			volumeDownButtonLoader.load(new URLRequest("resources/buttons/Button Delete.png"));
			volumeDownButton.addChild(volumeDownButtonLoader);
			
			/* set buttons dimentions */
			playButton.scaleX = playButton.scaleY = 0.11;
			stopButton.scaleX = stopButton.scaleY = 0.11;
			pauseButton.scaleX = pauseButton.scaleY = 0.11;
			volumeUpButton.scaleX = volumeUpButton.scaleY = 0.11;
			volumeDownButton.scaleX = volumeDownButton.scaleY = 0.11;
			
			/* set buttons initial positions */
			playButton.x = x + 50;
			playButton.y = y + 10;
			stopButton.x = x + 10;
			stopButton.y = y + 10;
			pauseButton.x = x + 50;
			pauseButton.y = y + 10;
			volumeUpButton.x = x + 90;
			volumeUpButton.y = y + 10;	
			volumeDownButton.x = x + 130;
			volumeDownButton.y = y + 10;
			
			/* BUTTONS EVENT LISTENERS SET UP */
			/* add buttons mouse event listeners */
			trace("add buttons mouse event listeners.");
			playButton.addEventListener(MouseEvent.MOUSE_UP, playButtonUp);
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, playButtonDown);
			stopButton.addEventListener(MouseEvent.MOUSE_UP, stopButtonUp);
			stopButton.addEventListener(MouseEvent.MOUSE_DOWN, stopButtonDown);
			pauseButton.addEventListener(MouseEvent.MOUSE_UP, pauseButtonUp);
			pauseButton.addEventListener(MouseEvent.MOUSE_DOWN, pauseButtonDown);
			volumeUpButton.addEventListener(MouseEvent.MOUSE_UP, volumeUpButtonUp);
			volumeUpButton.addEventListener(MouseEvent.MOUSE_DOWN, volumeUpButtonDown);
			volumeDownButton.addEventListener(MouseEvent.MOUSE_UP, volumeDownButtonUp);
			volumeDownButton.addEventListener(MouseEvent.MOUSE_DOWN, volumeDownButtonDown);
			
			/* add buttons touch event listeners */
			trace("add buttons touch event listeners.");
			playButton.addEventListener(TouchEvent.TOUCH_UP, playButtonUp);
			playButton.addEventListener(TouchEvent.TOUCH_DOWN, playButtonDown);
			stopButton.addEventListener(TouchEvent.TOUCH_UP, stopButtonUp);
			stopButton.addEventListener(TouchEvent.TOUCH_DOWN, stopButtonDown);
			pauseButton.addEventListener(TouchEvent.TOUCH_UP, pauseButtonUp);
			pauseButton.addEventListener(TouchEvent.TOUCH_DOWN, pauseButtonDown);
			volumeUpButton.addEventListener(TouchEvent.TOUCH_UP, volumeUpButtonUp);
			volumeUpButton.addEventListener(TouchEvent.TOUCH_DOWN, volumeUpButtonDown);
			volumeDownButton.addEventListener(TouchEvent.TOUCH_UP, volumeDownButtonUp);
			volumeDownButton.addEventListener(TouchEvent.TOUCH_DOWN, volumeDownButtonDown);
			
			pauseButton.visible = false;
			
			/* add buttons */
			addChild(pauseButton);
			addChild(playButton);
			addChild(stopButton);
			addChild(volumeUpButton);
			addChild(volumeDownButton);
		}
		
		private function buttonUp(e:Event):void {
			e.currentTarget.blendMode = BlendMode.NORMAL;
		}
		
		private function buttonDown(e:Event):void {
			e.currentTarget.blendMode = BlendMode.DIFFERENCE;			
			//e.currentTarget.blendMode = BlendMode.HARDLIGHT;
			//e.currentTarget.blendMode = BlendMode.SUBTRACT;
		}		
		
		private function playButtonUp(e:Event):void {
			buttonUp(e);
			
			if (stoped) {
				_ns.play(_path);
			}
			else {
				_ns.togglePause();
			}
			
			stoped = false;
			playButton.visible = false;
			pauseButton.visible = true;
		}
		
		private function playButtonDown(e:Event):void {
			buttonDown(e);
		}
		
		private function stopButtonUp(e:Event):void {
			buttonUp(e);
			
			_ns.pause();
			//_ns.close();
			stoped = true;
			pauseButton.visible = false;
			playButton.visible = true;
		}
		
		private function stopButtonDown(e:Event):void {
			buttonDown(e);
		}
		
		private function pauseButtonUp(e:Event):void {
			buttonUp(e);
			
			_ns.togglePause();
			pauseButton.visible = false;
			playButton.visible = true;
		}
		
		private function pauseButtonDown(e:Event):void {
			buttonDown(e);
		}
		
		private function volumeUpButtonUp(e:Event):void {
			buttonUp(e);
			
			if (st.volume <= 0.9) {
				st.volume += 0.1;
				st.volume = Math.abs(st.volume);
				_ns.soundTransform = st;	
			}
			trace("volume " + st.volume);
		}
		
		private function volumeUpButtonDown(e:Event):void {
			buttonDown(e);
		}
		
		private function volumeDownButtonUp(e:Event):void {
			buttonUp(e);
			
			if (st.volume >= 0.1) {
				st.volume -= 0.1;
				st.volume = Math.abs(st.volume);
				_ns.soundTransform = st;	
			}
			trace("volume " + st.volume);
		}
		
		private function volumeDownButtonDown(e:Event):void {
			buttonDown(e);
		}
	}

}
