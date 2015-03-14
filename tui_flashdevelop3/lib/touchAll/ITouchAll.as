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