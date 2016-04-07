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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TransformGestureEvent;
	
	import org.tuio.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	public interface IMultimedia
	{
		/**
		 * background event listener for multimedia set up
		 */
		function backgroundMultimediaEventListenersLoader():void;
		
		/**
		 * load, display and handle an image
		 * @param	path - image URL
		 * @param	scaleX - image widht in %
		 * @param	scaleY - image height in %
		 */
		function addImage(path:String, scaleX:Number = 0.25, scaleY:Number = 0.25):void;
		
		/**
		 * load, display and handle an SWF
		 * @param	path - SWF URL
		 * @param	scaleX - video widht in %
		 * @param	scaleY - video height in %
		 */
		function addSWF(path:String, scaleX:Number = 1, scaleY:Number = 1):void;
		
		/**
		 * load, display and handle an video MP4 or FLV
		 * @param	path - video URL
		 * @param	widht - video widht
		 * @param	height - video height
		 */
		function addVideo(path:String, widht:int = 320, height:int = 200):void;
		
		/**
		 * image event listeners set up
		 * @param	image
		 */ 
		function imageEventListenersLoader(image:Sprite):void;
		
		/**
		 * video event listeners set up
		 * @param	video
		 */ 
		function videoEventListenersLoader(video:MovieClip):void;
	}
}
