/*
 * Tangible User Interfacer (former TouchAll) demo.
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
package touchAll.demos.cube3Ddemo
{
	import flash.display.*;
	import flash.events.Event;
	//import flash.events.TransformGestureEvent;
		
	import touchAll.*;
	import touchAll.cube3D.Cube3D;
	 
	[SWF(width="1280", height="720", frameRate="60", backgroundColor="#000000")]
	public class Cube3Ddemo extends MovieClip 
	{
		private var tAll:TouchAll = new TouchAll(stage);
		private var cube3D:Cube3D = new Cube3D(stage);
		
		public function Cube3Ddemo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			/* stage set up */
			tAll.stageLoader();
			tAll.stageEventListenersLoader();	
			
			/* tuio set up */
			tAll.tuioLoader();
		}
	}
}
