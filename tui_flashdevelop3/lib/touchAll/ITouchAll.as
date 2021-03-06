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
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TransformGestureEvent;
	
	import org.tuio.*;
	import org.tuio.fiducial.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	public interface ITouchAll 
	{
		/** 
		 * stage set up 
		 */
		function stageLoader():void; 
			
		/** 
		 * stage event listeners set up 
		 */
		function stageEventListenersLoader():void;
		
		/** 
		 * tuio set up 
		 */
		function tuioLoader():void;
		
		/**
		 * load default stage background
		 */
		function backgroundLoader():void;
	}
}
