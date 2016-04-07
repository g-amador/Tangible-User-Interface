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
	import org.tuio.fiducial.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	public interface IDefault
	{
		/** 
		 * stage event listeners set up 
		 */
		function stageEventListenersLoader():void;
		
		/**
		 * background event listeners set up
		 */ 
		function backgroundEventListenersLoader():void;
		
		/**
		 * handle fiducial (Object) add events
		 */
		function fiducialADD(e:FiducialEvent):void;
		
		/**
		 * handle fiducial (Object) remove events
		 */
		function fiducialREMOVE(e:FiducialEvent):void;
		
		/**
		 * handle fiducial (Object) move events
		 */
		function fiducialUPDATE(e:FiducialEvent):void;
	}
	
}
