package gestureRecognizers.recognizer.net.reclipse.handwriting {
	/**
	 * Lightweight class similar to flash.geom.Point that can contain pressure data.
	 * 
	 * @author Kyle Murray
	 * @version 1.0.0
	*/
	public class InkPoint {
		private var _x:Number;
		private var _y:Number;
		private var _timestamp:Number;
		private var _pressure:Number;
		/**
		 * Constructor.
		*/
		public function InkPoint(x:Number = 0, y:Number = 0, timestamp:Number = 0, pressure:Number = 0) {
			_x = x;
			_y = y;
			_timestamp = timestamp;
			_pressure = pressure;
		}
		public function set x(x:Number):void {
			_x = x;
		}
		/**
		 * The x property of the InkPoint.
		 * @return The Number representing this property.
		*/
		public function get x():Number {
			return _x;
		}
		/**
		 * The y property of the InkPoint.
		 * @return The Number representing this property.
		*/
		public function set y(y:Number):void {
			_y = y;
		}
		public function get y():Number {
			return _y;
		}
		/**
		 * The time that this InkPoint was created in the execution of the script.  
		 * @return The time in milliseconds.
		*/
		public function get timestamp():Number {
			return _timestamp;
		}
		/**
		 * The pressure of the input device that created this point.
		 * @return A Number, 0 represents no pressure at all, 1-1023 represents an amount of pressure.
		*/
		public function get pressure():Number {
			return _pressure;
		}
	}
}