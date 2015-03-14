package gestureRecognizers.recognizer.net.reclipse.handwriting {
	import gestureRecognizers.recognizer.net.reclipse.handwriting.*;
	/**
	 * Data storage and methods for interacting with normalized input sequences.
	 * 
	 * @author Kyle Murray
	 * @version 0.3.8
	*/
	public dynamic class CharacterDefinition {
		public var _name:String;
		public var _signature:Array = new Array();
		public var _signatures:Array = new Array();
		private var _ratio:Number;
		private var _ratios:Array = new Array();
		
		/**
		 * Constructor.  A full definition can be provided here.
		 * @param name The name of the character, this should be one character but can be more.
		 * @param signature An Array of integers (hopefully) unique to a certain character.
		 * @param ratio A ratio of width:height in the character.  Used as a fallback mechanism.
		*/
		public function CharacterDefinition(name:String = null, signature:Array = null, ratio:Number = NaN){
			if((name != null) && (signature != null) && (!isNaN(ratio))){
				_name = name;
				_signatures.push(signature);
				_ratio = ratio;
				_ratios.push(_ratio);
			}
		}
		/**
		 * Averages the total collection of ratios.
		 * @return A Number that is the average width:height ratio in the character. 
		*/
		public function get ratio():Number {
			var total:Number = 0;
			for(var i:int = 0; i < _ratios.length; i++){
				total += _ratios[i];
			}
			return total/_ratios.length;
		}
		/**
		 * Adds a ratio to the collection.
		 * @param nextRatio The ratio to be added.
		 * @return The average ratio with the new ratio included.
		*/
		public function pushRatio(nextRatio:Number):Number {
			_ratios.push(nextRatio);
			return ratio;
		}
		/**
		 * Calculates the difference between two ratios.  Useful for comparison.
		 * @param inputRatio A ratio from an external Object.
		 * @return The difference.
		*/
		public function ratioDifference(inputRatio:Number):Number {
			return Math.abs(ratio - inputRatio);
		}
		/**
		 * Adds a new signature to the Array of known signatures.
		 * @param nextSignature The newest signature.
		 * @return The total number of signatures.
		*/
		public function pushSignature(nextSignature:Array):Number {
			_signatures.push(nextSignature);
			return _signatures.length;
		}
		/**
		 * A key componenent of recognition.  
		 * @param inputSignature The signature to be compared.
		 * @return The number of instances of the inputSignature that are found in the Array 
		 * of defined signatures.
		*/
		public function signatureCount(inputSignature:Array):Number {
			var count:Number = 0;
			for(var i:int = 0; i < _signatures.length; i++){
				if(_signatures[i].toString() === inputSignature.toString()){
					count++
				}
			}
			return count;
		}
		/**
		 * Another key component of recognition.
		 * @param inputSignature The signature to be compared.
		 * @return The number of times that the contents of the inputSignature are found in 
		 * any of the known signatures.  Similar to a substring.  Should be >= signatureCount.
		*/
		public function subSignatureCount(inputSignature:Array):Number {
			var count:Number = 0;
			for(var i:int = 0; i < _signatures.length; i++){
				if(_signatures[i].toString().indexOf(inputSignature.toString()) != -1 ){
					count++;
				}
			}
			return count;
		}
		//Form = name:1,2,3; 1,2,2; 1,3,3:ratio
		/**
		 * Used for permanent storage of CharacterDefinitions.
		 * @return a String representation of all data in the CharacterDefinition.
		*/
		public function toString():String {
			/**
			 *@TODO Add way to know the number of ratios so that averaging is accurate 
			 * between sessions. 
			*/
			var returnString:String = '';
			returnString += _name
			returnString += ':';
			for(var i:int = 0; i < _signatures.length; i++){
				if(i != _signatures.length - 1){
					for(var j:int = 0; j < _signatures[i].length; j++){
						if(j != _signatures[i].length - 1){
							returnString += _signatures[i][j];
							returnString += ',';
						} else {
							returnString += _signatures[i][j];
						}
					}
					returnString += ';';
				} else {
					for(j = 0; j < _signatures[i].length; j++){
						if(j != _signatures[i].length - 1){
							returnString += _signatures[i][j];
							returnString += ',';
						} else {
							returnString += _signatures[i][j];
						}
					}
				}
			}
			returnString += ':';
			returnString += ratio.toString();
			return returnString;
		}
		/**
		 * Enables a CharacterDefinition to be defined through syntax like the toString method.
		 * @param inputString The sample to be added.
		*/
		public function addStringSample(inputString:String):void {
			if(_name != null){
				if(inputString.split(':')[0] != _name){
					throw new ArgumentError('Sample must have the same name property as the CharacterDefinition it is being added to.');
				}
			} else {
				_name = inputString.split(':')[0];
			}
			var inputSignaturesArray:Array = inputString.split(':')[1].split(';');
			for(var i:int = 0; i < inputSignaturesArray.length; i++){
				var individualSignature:Array = inputSignaturesArray[i].split(',');
				_signatures.push(new Array());
				for(var j:int = 0; j < individualSignature.length; j++){
					_signatures[_signatures.length - 1].push(Number(individualSignature[j]));
				}
			}
			var inputRatio:Number = Number(inputString.split(':')[2]);
			_ratios.push(inputRatio);
		}
		/**
		 * Allows addition character definitions for the same character.
		 * @param inputSignature The signature to be added.
		 * @param inputRatio The width:height ratio of the character being added.
		*/
		public function addSample(inputSignature:Array, inputRatio:Number):void {
			_signatures.push(inputSignature);
			_ratios.push(inputRatio);
		}
	}
}