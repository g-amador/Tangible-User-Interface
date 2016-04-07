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
package touchAll.demos.niftySynthTouchDemo
{
	//import flash.ui.*;
	import flash.display.*;
	import flash.events.Event;
	import nl.niftysystems.touchKeyboard.ScreenBoard;
	
	import touchAll.*;
	
	import nl.niftysystems.audio.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	[SWF(width="1280", height="720", frameRate="60", backgroundColor="#ffffff")]
	public class NiftySynthTouchDemo extends MovieClip
	{
		/* global variables */		
		private var tAll:TouchAll = new TouchAll(stage);
		private var ns:NiftySynth;
		
		public function NiftySynthTouchDemo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/* stage set up */
			tAll.stageLoader();
			tAll.stageEventListenersLoader();	
			
			/* tuio set up */
			tAll.tuioLoader();
			
			ns = new NiftySynth(stage);
		}
	}
}
