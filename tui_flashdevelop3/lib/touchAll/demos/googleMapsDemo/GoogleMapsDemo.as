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