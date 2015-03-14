package touchAll
{
	import org.tuio.TuioFiducialEvent;
	
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
		function fiducialADD(e:TuioFiducialEvent):void;
		
		/**
		 * handle fiducial (Object) remove events
		 */
		function fiducialREMOVE(e:TuioFiducialEvent):void;
		
		/**
		 * handle fiducial (Object) move events
		 */
		function fiducialUPDATE(e:TuioFiducialEvent):void;
	}
	
}