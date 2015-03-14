package gestureRecognizers.recognizer.net.reclipse.handwriting {
	import gestureRecognizers.recognizer.net.reclipse.handwriting.*;
	import flash.utils.*;
	/**
	 * Class for handling ink points.  Includes a public Array instance for InkPoint storage.
	 * 
	 * @author Kyle Murray
	 * @version 0.7.1
	*/
	public dynamic class InkTimeline {
		public static const SEGMENT_STRAIGHT:int = 0;
		public static const SEGMENT_ONE:int = 1;
		public static const SEGMENT_TWO:int = 2;
		public static const SEGMENT_THREE:int = 3;
		public static const SEGMENT_FOUR:int = 4;
		public static const SEGMENT_POINT_ABOVE:int = 5;
		
		public var array:Array = new Array();
		public var segments:Array = new Array();
		public var segmentClassifications:Array = new Array();
		public var segmented:Boolean = false;
		public var segmentPartitions:Array;
		public var splitPartitions:Array = new Array();
		public var signature:Array = new Array();
		
		/**
		 * Constructor.  The input Array is controlled to allow only Array or InkTimeline elements.
		 * @param inputArray The Array of InkPoints or Array of Arrays of InkPoints.
		*/
		public function InkTimeline(inputArray:Array = null) {
			if(inputArray !== null){
				if(inputArray.every(isInkPoint)){
					array = inputArray;
				} else if(inputArray.every(isArray)){
					array = inputArray;
					segments = inputArray;
					segmented = true;
				} else {
					throw new ArgumentError('All InkTimeline.array elements must be of type: '+getQualifiedClassName(InkPoint)+' or: '+getQualifiedClassName(Array));
				}
			}
		}
		/**
		 * Checks if the input in an 'every' call is an InkPoint.
		 * @return Boolean.
		*/
		private function isInkPoint(element:*, index:int, _array:Array):Boolean {
			return (element is InkPoint);
		}
		/**
		 * Checks if the input in an 'every' call in an Array.
		 * @return Boolean.
		*/
		private function isArray(element:*, index:int, _array:Array):Boolean {
			return (element is Array);
		}
		/**
		 * Makes a copy of the InkTimeline instance.
		 * @return A copy.
		*/
		public function clone(original:InkTimeline):InkTimeline {
			return original;
		}
		/**
		 * Point with the greatest x coordinate.
		 * @return The greatest x coordinate.
		*/
		public function get maxX():Number {
			var curMax:Number = array[0].x;
			for(var i:int = 0; i < array.length; i++){
				if(array[i].x > curMax){
					curMax = array[i].x;
				}
			}
			return curMax;
		}
		/**
		 * Point with the least x coordinate.
		 * @return The least x coordinate.
		*/
		public function get minX():Number {
			var curMin:Number = array[0].x;
			for(var i:int = 0; i < array.length; i++){
				if(array[i].x < curMin){
					curMin = array[i].x;
				}
			}
			return curMin;
		}
		/**
		 * Point with the greatest y coordinate.
		 * @return The greatest y coordinate.
		*/
		public function get maxY():Number {
			var curMax:Number = array[0].y;
			for(var i:int = 0; i < array.length; i++){
				if(array[i].y > curMax){
					curMax = array[i].y;
				}
			}
			return curMax;
		}
		/**
		 * Point with the least y coordinate.
		 * @return The least y coordinate.
		*/
		public function get minY():Number {
			var curMin:Number = array[0].y;
			for(var i:int = 0; i < array.length; i++){
				if(array[i].y < curMin){
					curMin = array[i].y;
				}
			}
			return curMin;
		}
		/**
		 * A bounding box-like structure.
		 * @return The width of the stroke.
		*/
		public function get width():Number {
			return maxX - minX;	
		}
		/**
		 * A bounding box-like structure.
		 * @return The height of the stroke.
		*/
		public function get height():Number {
			return maxY - minY;
		}
		/**
		 * The width:height ratio.
		 * @return The width:height ratio.
		*/
		public function get ratioWH():Number {
			return width/height;
		}
		/**
		 * Determines whether or not two InkTimeline's bounding boxes intersect.
		 * @param _otherInk The InkTimeline to check.
		 * @param leniency Extends the bounding box to be lenient.
		 * @return The result of the check.
		*/
		public function intersectsWith(_otherInk:InkTimeline, leniency:Number = 0):Boolean {
			if((maxX + leniency >= _otherInk.minX) && (minX <= _otherInk.maxX + leniency) && (maxY + leniency >= _otherInk.minY) && (minY <= _otherInk.maxY + leniency)){
				return true;
			} else {
				return false;
			}
		}
		/**
		 * Determines if the latest stroke is a 'dot'-like structure above the previous stroke.
		 * @param _otherInk The InkTimeline to check against.  
		 * @param leniency Extendes the bounding box to be lenient.
		 * @return The result of the check.
		*/
		public function isDotAbove(_otherInk:InkTimeline, leniency:Number = 0):Boolean {
			if((minY < _otherInk.maxY) && (width <= (_otherInk.width + 2*(leniency))) && (height < _otherInk.height) && (maxX < _otherInk.maxX + leniency) && (minX > _otherInk.minX - leniency)){
				return true;
			} else {
				return false;
			}
		}
		/**
		 * Joins two InkTimelines.  Useful if the two intersect or one is a dot.
		 * @param _moreInk The InkTimeline that will be combined.
		 * @return The resulting InkTimeline.
		*/
		public function joinWith(_moreInk:InkTimeline):InkTimeline {
			var newTimeline:InkTimeline = clone(this);
			newTimeline.array = newTimeline.array.concat(_moreInk.array);
			newTimeline.segments = newTimeline.segments.concat(_moreInk.segments);
			newTimeline.segmentClassifications = newTimeline.segmentClassifications.concat(_moreInk.segmentClassifications);
			newTimeline.splitPartitions = newTimeline.splitPartitions.concat(_moreInk.splitPartitions);
			if(newTimeline.signature[newTimeline.signature.length - 1] == _moreInk.signature[_moreInk.signature.length - 1]){
				//newTimeline.signature.pop();
				trace('Element not removed from end of joined InkTimeline.');
			}
			newTimeline.signature = newTimeline.signature.concat(_moreInk.signature);
			if(newTimeline.segmented && _moreInk.segmented){
				newTimeline.segmented = true;
			} else {
				newTimeline.segmented = false;
			}
			return newTimeline;
		}
		/**
		 * Segments the InkTimeline into Arrays based on pivot points.
		 * @param _splitPoints The pivot points.
		*/
		public function segment(_splitPoints:Array):void {
			var previous:Number;
			for(var i:int = 0; i < _splitPoints.length; i++){
				if(_splitPoints[i] !== 0){
					//Turning point is array[i]
					if(segments.length === 0){
						segments.push(array.slice(0,i+1));
					} else {
						segments[segments.length] = array.slice(previous, i+1);
					}
					previous = i;
					//trace('X of timeline: '+ array[i].x + ', X of split: '+ _splitPoints[i].x);
					trace('Points Being Segmented X: '+array[i-1].x +' : '+ array[i].x +' : '+ array[i+1].x);
				}
			}
			segments[segments.length] = array.slice(previous, array.length);
			segmented = true;
			trace('Segs: '+segments.length);
		}
		/**
		 * Removes duplicate directional values.
		*/
		public function normalize():void {
			if(!splitPartitions){
				throw new Error('InkTimeline requires property "splitPartitions" for normalization.');
			}
			if(!segments){
				throw new Error('InkTimeline requires property "segments" for normalization.');
			}
			var sizeless:Array = new Array();
			for(var i:int = 0; i < splitPartitions.length; i++){
				sizeless.push(splitPartitions[i][0]);
			}
			trace('parts: '+splitPartitions);
			trace('array: '+ array);
			trace('signature: ' + sizeless);
			signature = sizeless;
		}
		/**
		 * Uses pressure data to find the last stroke in the collection of strokes.
		 * @return The lastest stroke.
		*/
		public function get latestStroke():InkTimeline {
			var stroke:InkTimeline;
			var searchInkTimeline:InkTimeline = clone(this);
			var havePressure:Array = new Array(searchInkTimeline.array.length);
			var startIndex:Number;
			var endIndex:Number;
			searchInkTimeline.array.reverse();
			for(var i:uint = 0; i < searchInkTimeline.array.length; i++){
				if(searchInkTimeline.array[i].pressure == 1){
					havePressure[i] = 1;
				} else {
					havePressure[i] = 0;
				}
			}
			if(havePressure.indexOf(1) < havePressure.indexOf(0)){
				startIndex = havePressure.indexOf(1);
				endIndex = havePressure.indexOf(0);
			} else if(havePressure.indexOf(1) > havePressure.indexOf(0)){
				startIndex = havePressure.indexOf(1);
				endIndex = havePressure.indexOf(0, havePressure.indexOf(1));
			}
			stroke = new InkTimeline(searchInkTimeline.array.slice(startIndex, endIndex));
			stroke.array.reverse();
			return InkTimeline(stroke);
		}
	}
}