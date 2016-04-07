/*
 * Tangible User Interfacer (former TouchAll) demo code.
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
package touchAll.demos.multimediaTouchDemo
{
	import flash.ui.*;
	import flash.display.*;
	import flash.events.Event;
	
	import touchAll.*;
	import touchAll.multimedia.Multimedia;
	
	/**
	 * @author Gonçalo Amador
	 */
	[SWF(width="1280", height="720", frameRate="60", backgroundColor="#ffffff")]
	public class MultimediaTouchDemo extends MovieClip
	{
		/* global variables */		
		private var tAll:TouchAll = new TouchAll(stage);
		
		//private var tAll:TouchAll = new TouchAll(stage, 1280, 720, 0x000000, true, true);
		//private var tAll:TouchAll = new TouchAll(stage,1280,720, 0x000000, true, false, false, false, true, "10.0.4.145", 3000);
		private var multimedia:Multimedia = new Multimedia(stage);
		
		public function MultimediaTouchDemo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/* LOAD STAGE CONTENT */
			tAll.backgroundLoader();
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
			multimedia.addVideo("resources/Asus Xtion Pro test using OpenNI & OpenCV.mp4");
			multimedia.addVideo("resources/Asus Xtion Pro test using OpenNI & OpenCV.flv");
			
			/* stage set up */
			tAll.stageLoader();
			tAll.stageEventListenersLoader();
			
			/* tuio set up */
			tAll.tuioLoader();
		}
	}
}
