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
package touchAll.demos.tronFiducialsDemo
{
	import flash.display.*;
	import flash.events.Event;
	//import flash.events.TransformGestureEvent;
	
	import org.tuio.fiducial.*;
	
	import touchAll.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	//[SWF(width = "1280", height = "720", frameRate = "60", backgroundColor = "#ffffff")]
	[SWF(width = "1280", height = "720", frameRate = "60", backgroundColor = "#000000")]
	public class TronFiducialsDemo extends MovieClip implements IDefault
	{
		/* global variables */		
		private var tAll:TouchAll = new TouchAll(stage, 1280, 720, 0x0055ff, false);
		//private var fm:FiducialManager = new FiducialManager(stage, 0x000000, 0x000000, 0xffffff, 0x000000, 0x00BB00, 0x000000, 0xaaaaaa);
		private var fm:FiducialManager = new FiducialManager(stage, 0x0055ff, 0x000000, 0x0055ff, 0x000000, 0x00BB00, 0x0055ff, 0x0055ff);
		
		public function TronFiducialsDemo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/* LOAD STAGE CONTENT */
			tAll.backgroundLoader();
			//backgroundEventListenersLoader();
			
			/* stage set up */
			tAll.stageLoader();
			stageEventListenersLoader();	
			
			/* tuio set up */
			tAll.tuioLoader();
		}
		
		public function stageEventListenersLoader():void {
			tAll.stageEventListenersLoader();
			fm.stageEventListenersLoader();
		}
		
		public function backgroundEventListenersLoader():void {
			trace("backgroundEventListenersLoader.");
		}
		
		public function fiducialADD(e:FiducialEvent):void {
			// debug mode console message if Fiducial event captured
			//trace("Fiducial #" + e.fiducialId + " fiducial added.");
			
			fm.fiducialADD(e);
		}
		
		public function fiducialREMOVE(e:FiducialEvent):void {
			// debug mode console message if Fiducial event captured
			//trace("Fiducial #" + e.fiducialId + " fiducial removed.");
			
			fm.fiducialREMOVE(e);
		}
		
		public function fiducialUPDATE(e:FiducialEvent):void {
			// debug mode console message if Fiducial event captured
			//trace("Fiducial #" + e.fiducialId + " fiducial update.");
			
			fm.fiducialUPDATE(e);
		}
	}
}
