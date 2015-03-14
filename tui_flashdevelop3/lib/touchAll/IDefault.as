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