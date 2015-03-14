package touchAll.demos.fluidTouchDemos
{
	//import flash.ui.*;
	import flash.display.*;
	import flash.events.Event;
	
	import touchAll.*;
	import touchAll.rippler.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	[SWF(width="1280", height="720", frameRate="60", backgroundColor="#ffffff")]
	public class RippleTouchDemo extends MovieClip
	{
		/* global variables */		
		private var tAll:TouchAll = new TouchAll(stage);
		private var ripplerEffetcs:Effects = new Effects(stage);
		
		public function RippleTouchDemo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/* LOAD STAGE CONTENT */
			ripplerEffetcs.backgroundRippleLoader();
			ripplerEffetcs.backgroundRippleEventListenersLoader();
			tAll.backgroundLoader();
			
			/* stage set up */
			tAll.stageLoader();
			tAll.stageEventListenersLoader();	
			
			/* tuio set up */
			tAll.tuioLoader();
		}
	}
}