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