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
package touchAll.demos.googleMapsDemo
{
	import flash.ui.*;
	import flash.display.*;
	import flash.events.Event;
	
	import touchAll.*;
	import googleMapsAPI.GoogleMap;
	
	/**
	 * @author Gonçalo Amador
	 */
	[SWF(width="1280", height="720", frameRate="60", backgroundColor="#ffffff")]
	public class GoogleMapsDemo extends MovieClip
	{
		/* global variables */		
		private var tAll:TouchAll = new TouchAll(stage);
		private var googleMap:GoogleMap;
		
		public function GoogleMapsDemo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/* LOAD STAGE CONTENT */
			tAll.backgroundLoader();
			
			/* load Google Map */
			googleMap = new GoogleMap(stage);
			
			/* stage set up */
			tAll.stageLoader();
			tAll.stageEventListenersLoader();
			
			/* tuio set up */
			tAll.tuioLoader();
		}
	}
}
