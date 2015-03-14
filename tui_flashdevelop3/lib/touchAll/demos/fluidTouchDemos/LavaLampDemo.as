package touchAll.demos.fluidTouchDemos
{
	//import flash.ui.*;
	import flash.display.*;
	import flash.events.Event;
	
	import com.oaxoa.misc.LavaLamp;
	
	import touchAll.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	[SWF(width="300", height="300", frameRate="60", backgroundColor="#ffffff")]
	public class LavaLampDemo extends MovieClip
	{
		/* global variables */		
		private var tAll:TouchAll = new TouchAll(stage, 300, 300);
		private var lavaLamp:LavaLamp = new LavaLamp(stage); 
		
		public function LavaLampDemo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/* LOAD STAGE CONTENT */
			tAll.backgroundLoader();
			
			/* stage set up */
			tAll.stageLoader();
			tAll.stageEventListenersLoader();	
			
			/* tuio set up */
			tAll.tuioLoader();
		}	
	}

}