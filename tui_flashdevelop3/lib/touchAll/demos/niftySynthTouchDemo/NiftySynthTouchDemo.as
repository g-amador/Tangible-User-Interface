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