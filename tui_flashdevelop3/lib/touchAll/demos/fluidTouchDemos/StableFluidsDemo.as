package touchAll.demos.fluidTouchDemos
{
	//import flash.ui.*;
	import flash.display.*;
	import flash.events.Event;
	
	import com.oaxoa.misc.Render;
	
	import touchAll.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	[SWF(width="200", height="200", frameRate="60", backgroundColor="#ffffff")]
	public class StableFluidsDemo extends MovieClip
	{
		private var tAll:TouchAll = new TouchAll(stage, 200, 200);
		private var render:Render = new Render(stage, 200);
		
		public function StableFluidsDemo():void 
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
		}
		
	}

}