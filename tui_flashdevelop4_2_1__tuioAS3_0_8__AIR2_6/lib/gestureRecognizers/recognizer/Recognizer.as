package gestureRecognizers.recognizer {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.text.*;
	import flash.utils.*;
	import gestureRecognizers.recognizer.net.reclipse.handwriting.*;
	/**
	 * Angle and stroke recognition to be used in handwriting recognition.
	 * 
	 * @author Kyle Murray
	 * @version 0.6.7
	*/
	public class Recognizer extends Sprite {
		private var mousePos:InkPoint = new InkPoint();
		private var previousMousePos:InkPoint = new InkPoint();
		private var currentAngle:Number = 0;
		private var previousAngle:Number = 0;
		private var mouseDown:Boolean = false;
		private var line:Shape = new Shape();
		private var jitterAllowance:Number = 5;
		private var angleSensitivity:Number = 50;
		private var inkPath:InkTimeline = new InkTimeline();
		private var toggle:Boolean = false;
		private var lastColor:Number = 0;
		private var childCount:Number = 0;
		private var unimportantChildStart:Number = 0;
		private var segmentConsistency:Number = 4;
		private var straightLineAngleAllowance:Number = 40;
		private var intersectLeniency:Number = 5;
		private var strokes:Array = new Array(new InkTimeline(new Array(new InkPoint(0,0,0,0), new InkPoint(0,0,0,0))));
		private var definitionStrokes:Array = new Array(new InkTimeline(new Array(new InkPoint(0,0,0,0), new InkPoint(0,0,0,0))));
		private var hasDrawn:Boolean = false;
		
		private var recogMode:Boolean = true;
		
		private var definedCharacters:Object = new Object();
		
		public var modeText:TextField = new TextField();
		public var descText:TextField = new TextField();
		public var charText:TextField = new TextField();
		public var defButton:TextField = new TextField();
		public var recogButton:TextField = new TextField();
		public var recogText:TextField = new TextField();
		public var format:TextFormat = new TextFormat();
		
		/**
		 * Constructor.  This is intended to be the main document class.
		*/
		public function Recognizer() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addChildAt(line, childCount++);
			//Mode TextField
			modeText.x = 0;
			modeText.y = 0;
			modeText.width = 100;
			modeText.height = 20;
			modeText.selectable = false;
			modeText.text = recogMode ? 'Recognition Mode' : 'Definition Mode';
			modeText.addEventListener(MouseEvent.MOUSE_DOWN, changeRecogMode);
			addChildAt(modeText, childCount++);
			//Character Entry Description Text
			descText.x = modeText.width + modeText.x + 25;
			descText.y = 0;
			descText.width = 150;
			descText.height = 20;
			descText.selectable = false;
			descText.text = 'Character To Define: ';
			addChildAt(descText, childCount++);
			//Character Entry Field
			charText.x = descText.x + descText.width;
			charText.y = 0;
			charText.width = 25;
			charText.height = 20;
			charText.type = TextFieldType.INPUT;
			charText.text = 'a';
			charText.border = true;
			charText.maxChars = 1;
			addChildAt(charText, childCount++);
			//Definition Button TF
			defButton.x = charText.x + charText.width + 10;
			defButton.y = 0;
			defButton.width = 125;
			defButton.height = 20;
			defButton.selectable = false;
			defButton.text = 'DEFINE CHARACTER';
			defButton.background = true;
			defButton.backgroundColor = 0x4BA3FE;
			defButton.addEventListener(MouseEvent.MOUSE_UP, callDefineCharacter);
			addChildAt(defButton, childCount++);
			//Recog Character Button
			recogButton.x = defButton.x + defButton.width + 10;
			recogButton.y = 0;
			recogButton.width = 150;
			recogButton.height = 20;
			recogButton.selectable = false;
			recogButton.text = 'RECOGNIZE CHARACTER';
			recogButton.background = true;
			recogButton.backgroundColor = 0x4BA3FE;
			recogButton.addEventListener(MouseEvent.MOUSE_UP, callRecognize);
			addChildAt(recogButton, childCount++);
			//Recog Text
			recogText.x = stage.stageWidth - 150;
			recogText.y = 20;
			recogText.width = 150;
			recogText.height = 150;
			recogText.selectable = false;
			recogText.border = true;
			recogText.background = true;
            format.size = 95;
            recogText.defaultTextFormat = format;
			addChildAt(recogText, childCount++);
			//Add no children after this line
			unimportantChildStart = childCount;
		}
		/**
		 * Calls the defineCharacter from a MouseEvent.
		 * @param event The MouseEvent called from a listener.
		*/
		private function callDefineCharacter(event:MouseEvent = null):void {
			defineCharacter();
		}
		/**
		 * When in definition mode, this method defines a new CharacterDefinition with a key 
		 * specified by the contents of the 'letter to define' TextField.  If the character is 
		 * already defined, the method only adds the appropriate signature to the letter and 
		 * updates the ratio.
		*/
		private function defineCharacter():void {
			if(hasDrawn){
				if(charText.text != ''){
					if(definedCharacters[charText.text]){
						definedCharacters[charText.text].addSample(definitionStrokes[definitionStrokes.length - 1].signature, definitionStrokes[definitionStrokes.length - 1].ratioWH);
						} else {
						definedCharacters[charText.text] = new CharacterDefinition(charText.text, definitionStrokes[definitionStrokes.length - 1].signature, definitionStrokes[definitionStrokes.length - 1].ratioWH);
					}
					trace(definedCharacters[charText.text].toString());
				}
			}
		}
		/**
		 * When in recognition mode, this method uses the recognition algorithm to attempt to
		 * recognize a character based on user input.  The best guess is displayed in a large 
		 * TextField to the right of the Stage.
		*/
		private function recognizeCharacter():void {
			if(hasDrawn){
				var possibleMatches:Array = new Array();
				var matchesPriority:Array = new Array();
				for each (var character:CharacterDefinition in definedCharacters){
					if(character.signatureCount(strokes[strokes.length - 1].signature) > 1){
						possibleMatches.push(character._name);
						matchesPriority.push(1);
					} else if(character.signatureCount(strokes[strokes.length - 1].signature) > 0){
						possibleMatches.push(character._name);
						matchesPriority.push(2);
					} else if(character.subSignatureCount(strokes[strokes.length - 1].signature) > 0){
						possibleMatches.push(character._name);
						matchesPriority.push(3);
					}
				}
				var guesses:Array = new Array();
				if(matchesPriority.indexOf(1) !== -1){
					for(var i:int = 0; i < matchesPriority.length; i++){
						if(matchesPriority[i] !== 1){
							possibleMatches.splice(i,1);
							matchesPriority.splice(i,1);
						}
					}
					guesses = possibleMatches;
				} else if(matchesPriority.indexOf(2) !== -1){
					for(i = 0; i < matchesPriority.length; i++){
						if(matchesPriority[i] !== 2){
							possibleMatches.splice(i,1);
							matchesPriority.splice(i,1);
						}
					}
					guesses = possibleMatches;
				} else if(matchesPriority.length !== 0){
					guesses = possibleMatches;
				}
				var bestGuess:String = new String();
				trace('Guesses: ' + guesses);
				var curLowest:Number
				if(guesses.length > 0){
					curLowest = definedCharacters[guesses[0]].ratioDifference(strokes[strokes.length - 1].ratioWH);
					var lowestIndex:int = 0;
					for(i = 0; i < guesses.length; i++){
						if(curLowest > definedCharacters[guesses[i]].ratioDifference(strokes[strokes.length - 1].ratioWH)){
							lowestIndex = i;
							curLowest = definedCharacters[guesses[i]].ratioDifference(strokes[strokes.length - 1].ratioWH)
						}
					}
					trace('Guess is from Possible Matches');
					bestGuess = definedCharacters[guesses[lowestIndex]]._name;
				} else {
					curLowest = Infinity;
					var lowestCharacterName:String = new String();
					for each (character in definedCharacters){
						if(character.ratioDifference(strokes[strokes.length - 1].ratioWH) < curLowest){
							curLowest = character.ratioDifference(strokes[strokes.length - 1].ratioWH);
							lowestCharacterName = character._name;
						}
					}
					trace('Guess not from Possible Matches');
					bestGuess = lowestCharacterName;				
				}
				trace('Priorities: '+ matchesPriority);
				trace('Possible Matches: '+possibleMatches);
				trace('Best Match: '+bestGuess);
				recogText.text = bestGuess;
			}
		}
		/**
		 * Recognizes a character when the Recognize button is pressed.
		 * @param event The event from the button press.
		*/
		private function callRecognize(event:MouseEvent = null):void {
			recognizeCharacter();
		}
		private function onKeyUp(event:KeyboardEvent = null):void {
			//Recognizes a character.  Bound to Spacebar.
			if(event.keyCode === 32){
				recognizeCharacter();
			}
			//Defines a character.  Bound to 'd' key.
			if(event.keyCode === 68){
				defineCharacter();
			}
			//Outputs all of the defined characters
			if(event.keyCode === 84){
				for each(var character:CharacterDefinition in definedCharacters){
					trace(character.toString());
				}
			}
		}
		/**
		 * This method calculates the angle of the hypotenuse of a fictional right triangle 
		 * generated between two points.  
		 * @param previous The point that occurs prior to the most recent point.
		 * @param current The most recent point being analyzed.
		 * @return An angle in degrees: 0 <= Angle <= 360.
		*/
		private function calcAngle(previous:InkPoint, current:InkPoint):Number {
			var tHeight:Number = previous.y - current.y;
			var tWidth:Number = previous.x - current.x;
			var radianAngle:Number = Math.atan(tHeight/tWidth);
			var degreeAngle:Number = radianAngle * 180/Math.PI;
			if((current.x >= previous.x) && (current.y <= previous.y)){
				degreeAngle = Math.abs(degreeAngle);
			} else if((current.x <= previous.x) && (current.y <= previous.y)){
				degreeAngle = 90 + (90 - degreeAngle);
			} else if((current.x <= previous.x) && (current.y >= previous.y)){
				degreeAngle = 180 + Math.abs(degreeAngle);
			} else if((current.x >= previous.x) && (current.y >= previous.y)){
				degreeAngle = 270 + (90 - degreeAngle);
			}
			return degreeAngle;
		}
		/**
		 * This method is used to find the difference in angle between two angles. 
		 * @param previous The first angle used for calculations.
		 * @param current The second angle used for calculations.  To produce usable output, 
		 * this should be the angle directly after 'previous'.
		 * @return A Number >= -180 and <= 180.  
		*/
		private function angleDifference(previous:Number, current:Number):Number {
			var angleDifference:Number;
			if((previous < 90) && (current > 270)){
				angleDifference =  -360 + current - previous;
			} else if((previous > 270) && (current < 90)){
				angleDifference = 360 - previous + current;
			} else {
				angleDifference = current - previous;
			}
			return angleDifference;
		}
		/**
		 * Marks split points in a stroke where the input device made a quick direction change.
		 * @param _inkPath The stroke to be analyzed.
		 * @param toleranceAngle The definition of a quick direction change.  (Degree)
		 * @return An Array of points that are the pivot point in a direction change.
		*/
		private function splitPoints(_inkPath:InkTimeline, toleranceAngle:Number):Array {
			var differences:Array = new Array();
			var splitPointArray:Array = [0];
			for(var i:int = 1; i < _inkPath.array.length; i++){
				if((i+1) < _inkPath.array.length){
					differences.push(angleDifference(calcAngle(_inkPath.array[i-1], _inkPath.array[i]), calcAngle(_inkPath.array[i], _inkPath.array[i+1])));;
					if((differences[differences.length-1] > toleranceAngle) || (differences[differences.length-1] < -toleranceAngle)){
						splitPointArray.push(_inkPath.array[i]);
					} else {
						splitPointArray.push(0);
					}
				}
			}
			splitPointArray.push(0);
			trace('splitPointArray: '+splitPointArray);
			return splitPointArray;
		}
		//First Pass
		/**
		 * Defines properties in an InkTimeline that are later used to help recognize the character.
		 * @param _splitPointInkTimeline This InkTimeline should have been analyzed by the 
		 * splitPoints method already to produce suitable output.
		 * @param _splitPoints The Array of points to be used as segment delimiters.
		*/
		private function segmentInkTimeline(_splitPointInkTimeline:InkTimeline, _splitPoints:Array):void {
			for(var i:int = 0; i < _splitPoints.length; i++){
				if(_splitPoints[i] !== 0){
					//Turning point is array[i]
					trace('X of timeline: '+ _splitPointInkTimeline.array[i].x + ', X of split: '+ _splitPoints[i].x);
					trace('Points Being Segmented X: '+_splitPointInkTimeline.array[i-1].x +' : '+ _splitPointInkTimeline.array[i].x +' : '+ _splitPointInkTimeline.array[i+1].x);
				}
			}
		}
		//Second Pass
		/**
		 * This method further segments the already segmented InkTimeline into segments that 
		 * have an integer value representing quadrant that the segment moved to from 
		 * beginning to end.
		 * @param _inkPath The InkPath whose segments are going to be classified.
		 * @param segmentsArray The initial segments which will be segmented further.
		 * @return An InkTimeline that has been partitioned into classified segments.
		*/
		private function classifySegments(_inkPath:InkTimeline, segmentsArray:Array):InkTimeline {
			var differences:Array = new Array(segmentsArray.length);
			for(var i:int = 0; i < segmentsArray.length; i++){
				differences[i] = new Array();
			}
			var difference:Array = new Array(segmentsArray.length);
			for(i = 0; i < difference.length; i++){
				difference[i] = new Number(0);
			}
			var splitPartitions:Array = new Array();
			for(var k:int = 0; k < segmentsArray.length; k++){
				for(i = 1; i < segmentsArray[k].length; i++){
					if((i+1) < segmentsArray[k].length){
						differences[k][differences[k].length -1] = angleDifference(calcAngle(segmentsArray[k][i-1], segmentsArray[k][i]), calcAngle(segmentsArray[k][i], segmentsArray[k][i+1]));
						difference[k] += differences[k][differences[k].length-1];
					}
				}
				var pointArray:Array = [0];
				for(var j:int = 1; j < segmentsArray[k].length; j++){
					pointArray[j] = getQuad(calcAngle(segmentsArray[k][j-1], segmentsArray[k][j]));
				}
				trace('PointArray: ' + pointArray);
				var previous:Number = 0;
				var partitions:Array = new Array();
				var firstRun:Boolean = true;
				for(j = segmentConsistency; j < pointArray.length; j++){
					if((j % segmentConsistency) === 0 ){
						for(var q:int = 0; q < segmentConsistency; q++){
							partitions.push(most(pointArray.slice(previous, j)));
						}
						if(firstRun){
							firstRun = false;
							partitions.push(most(pointArray.slice(previous, j)));
						}
						previous = j;
					}
				}
				if(pointArray.length <= segmentConsistency){
					for(q = 0; q < pointArray.length; q++){
						partitions.push(pointArray[pointArray.length - 1]);
					}
				}
				while(pointArray.length > partitions.length){
					partitions.push(partitions[partitions.length-1]);		
				}
				//normalize point array
				trace('Partitions: '+partitions);
				//split partitions
				splitPartitions.push([partitions[0]]);
				for(j = 1; j < partitions.length; j++){
					if(partitions[j] == partitions[j-1]){
						splitPartitions[splitPartitions.length - 1].push(partitions[j]);
					} else {
						splitPartitions.push([partitions[j]]);
					}
				}
			}
			trace('Partitions: '+partitions);
			trace('Total Differences: '+difference);
			_inkPath.splitPartitions = splitPartitions;
			return _inkPath;
		}
		/**
		 * Finds the most common type of point in a group.  Ties are setting by greatest 
		 * point-type value.
		 * @param _array An Array of points to compare.
		*/
		private function most(_array:Array):Number {
			/**
			 * @TODO Make this a better function. Find a better way to settle ties.
			*/
			var list:Array = new Array(0,0,0,0);
			for(var m:int = 0; m < _array.length; m++){
				switch (_array[m]){
					case 1:
					list[0] += 1;
					break;
					case 2:
					list[1] += 1;
					break;
					case 3:
					list[2] += 1;
					break;
					case 4:
					list[3] += 1;
					break;
					default:
					break;
				}
			}
			var biggest:Number = 0;
			for(m = 0; m < list.length; m++){
				if(list[m] > biggest){
					biggest = m;
				}
			}
			return biggest+1;
		}
		/**
		 * This method gets the quadrant that an angle would be in if drawn out from the origin. 
		 * @param angle The angle (in degrees) of the angle to be classified into a quadrant.
		 * @return An integer, though technically a Number, that represents the cartesian quadrant.
		*/
		private function getQuad(angle:Number):Number {
			if((angle >= 0) && (angle < 90)){
				return 1;
			} else if((angle >= 90) && (angle < 180)){
				return 2;
			} else if((angle >= 180) && (angle < 270)){
				return 3;
			} else {
				return 4;
			}
		}
		/**
		 * Colorizes the strokes to show the segments after the first pass.  Completely optional.
		 * @param _inkPath The InkTimeline to be colorized.
		 * @param splitPoints The points that delimit each color.
		*/
		private function drawSplitInkTimeline(_inkPath:InkTimeline, splitPoints:Array):void {
			var splitLine:Sprite = new Sprite();
			splitLine.graphics.moveTo(_inkPath.array[0].x, _inkPath.array[0].y);
			splitLine.graphics.lineStyle(1,nextColor());
			for(var i:int = 0; i < _inkPath.array.length-1; i++){
				//trace('SPI: '+splitPoints[i]);
				if(splitPoints[i] != 0){
					splitLine.graphics.lineStyle(1, nextColor());
				}
				splitLine.graphics.lineTo(_inkPath.array[i+1].x, _inkPath.array[i+1].y);
			}
			splitLine.graphics.lineTo(_inkPath.array[_inkPath.array.length-1].x, _inkPath.array[_inkPath.array.length-1].y);
			addChildAt(splitLine, childCount++);
		}
		/**
		 * Alternates the colors accessed by the drawing methods.  
		 * @return A hexidecimal number representing an RGB color.  (Not ARGB)
		*/
		private function nextColor():Number {
			var colorsArray:Array = new Array(0xFF0000, 0xFF9900, 0xFF00FF, 0x00FF00, 0x0000FF, 0xFFFF00);
			var next:Number;
			if(lastColor + 1 > colorsArray.length){
				next = colorsArray[0];
				lastColor = 0;
			} else {
				next = colorsArray[lastColor++];
			}
			return next;
		}
		/**
		 * Useful for eliminating jitter in a straight segment, though not used in recognition.
		 * @param _inkPath The InkTimeline to be analyzed.
		 * @return The angle (in degrees) of change in the stroke as a whole.
		*/
		private function strokeAngleDifference(_inkPath:InkTimeline):Number {
			var differences:Array = new Array();
			var difference:Number = 0;
			for(var i:int = 1; i < _inkPath.array.length; i++){
				if((i+1) < _inkPath.array.length){
					differences.push(angleDifference(calcAngle(_inkPath.array[i-1], _inkPath.array[i]), calcAngle(_inkPath.array[i], _inkPath.array[i+1])));
					//trace('AD: '+angleDifference(calcAngle(_inkPath.array[i-1], _inkPath.array[i]), calcAngle(_inkPath.array[i], _inkPath.array[i+1])));
				}
			}
			for(i = 0; i < differences.length; i++){
				difference += differences[i];
			}
			trace('Total Difference: '+difference);
			return difference;
		}
		/**
		 * Clears all of the characters drawn.  Buttons and text are left intact.
		*/
		private function clearDisplay():void {
			for(var i:int = childCount - 1; i >= unimportantChildStart; i--){
				removeChildAt(i);
			}
			line.graphics.clear();
			childCount = unimportantChildStart;
		}
		/**
		 * Switches between recognition mode and definition mode.  Recognition mode is default.
		 * @param event The event that is triggered by the button press.
		*/
		private function changeRecogMode(event:MouseEvent = null):void {
			recogMode = !recogMode;
			modeText.text = recogMode ? 'Recognition Mode' : 'Definition Mode';
			strokes = new Array(new InkTimeline(new Array(new InkPoint(0,0,0,0), new InkPoint(0,0,0,0))));
			definitionStrokes = new Array(new InkTimeline(new Array(new InkPoint(0,0,0,0), new InkPoint(0,0,0,0))));
			clearDisplay();
			hasDrawn = false;
		}
		/**
		 * Colorizes the latest stroke and adds a definition or signature to the collection.  
		 * @param inkLatestStroke This method should only be used with the last stroke when 
		 * using real-time recognition.
		*/
		private function recognizerMouseUp(inkLatestStroke:InkTimeline):void {
			drawSplitInkTimeline(inkLatestStroke, splitPoints(inkLatestStroke, angleSensitivity));
			inkLatestStroke.segment(splitPoints(inkLatestStroke, angleSensitivity));
			inkLatestStroke = classifySegments(inkLatestStroke, inkLatestStroke.segments);
			inkLatestStroke.normalize();				
			if(inkLatestStroke.intersectsWith(strokes[strokes.length - 1], intersectLeniency) || strokes[strokes.length - 1].intersectsWith(inkLatestStroke, intersectLeniency)){
				trace('The last two strokes intersect');
				inkLatestStroke = inkLatestStroke.joinWith(strokes[strokes.length - 1]);
				trace('Joined Sig: ' + inkLatestStroke.signature);
				strokes.pop();
			} else if(inkLatestStroke.isDotAbove(strokes[strokes.length - 1], intersectLeniency)){
				trace('The last stroke is a dot');
				inkLatestStroke.signature.push(InkTimeline.SEGMENT_POINT_ABOVE)
				trace('Joined Sig: ' + inkLatestStroke.signature);
				strokes.pop();
			} else {
				trace('No Intersection');
			}
			strokes.push(inkLatestStroke);
		}
		/**
		 * Similar in function to the recognition mode version of this method.  Doesn't colorize.
		 * @param This method should only be used with the lastest stroke when using real-time 
		 * recognition.
		*/
		private function definitionMouseUp(inkLatestStroke:InkTimeline):void {
			inkLatestStroke.segment(splitPoints(inkLatestStroke, angleSensitivity));
			inkLatestStroke = classifySegments(inkLatestStroke, inkLatestStroke.segments);
			inkLatestStroke.normalize();				
			if(inkLatestStroke.intersectsWith(definitionStrokes[definitionStrokes.length - 1], intersectLeniency) || definitionStrokes[definitionStrokes.length - 1].intersectsWith(inkLatestStroke, intersectLeniency)){
				trace('The last two strokes intersect');
				inkLatestStroke = inkLatestStroke.joinWith(definitionStrokes[definitionStrokes.length - 1]);
				trace('Joined Sig: ' + inkLatestStroke.signature);
				strokes.pop();
			} else if(inkLatestStroke.isDotAbove(definitionStrokes[definitionStrokes.length - 1], intersectLeniency)){
				trace('The last stroke is a dot');
				inkLatestStroke.signature.push(InkTimeline.SEGMENT_POINT_ABOVE)
				trace('Joined Sig: ' + inkLatestStroke.signature);
				definitionStrokes.pop();
			} else {
				trace('No Intersection');
			}
			definitionStrokes.push(inkLatestStroke);
		}
		/**
		 * Event handler that reacts to mouse motion.  This handler provides much of the base 
		 * information for recognition.  It also draws the points that are being analyzed.
		 * @param event The MouseEvent that calls this handler.  Not used.
		*/
		private function onMouseMove(event:MouseEvent = null):void {
			mousePos = new InkPoint(mouseX, mouseY, getTimer(), Number(mouseDown));
			if(mouseY > modeText.height){
				if(mouseDown){
					toggle = true;
					if((Math.abs(mousePos.x - previousMousePos.x) + Math.abs(mousePos.y - previousMousePos.y)) > jitterAllowance){
						inkPath.array.push(mousePos);
						currentAngle = calcAngle(previousMousePos, mousePos);
						trace(angleDifference(previousAngle, currentAngle));
						//trace(calcAngle(previousMousePos, mousePos));
						line.graphics.lineStyle(1,0x000000);
						//line.graphics.moveTo(previousMousePos.x, previousMousePos.y);
						line.graphics.lineTo(mouseX, mouseY);
						previousAngle = calcAngle(previousMousePos, mousePos);
						previousMousePos = new InkPoint(mouseX, mouseY, getTimer());
					}
				}
			}
		}
		/**
		 * When the mouse is down and moving, a line is drawn.  
		 * @param event Not used, but passed anyway as this is a handler method.
		*/
		private function onMouseDown(event:MouseEvent = null):void {
			mouseDown = true;
			if(mouseY > modeText.height){
				line.graphics.moveTo(mouseX, mouseY);
				inkPath.array.push(new InkPoint(mouseX, mouseY, getTimer()-1, 0));
				inkPath.array.push(mousePos);
				toggle = false;
			}
		}
		/**
		 * Ends line drawing.  If the mouse has moved since it was depressed, a stroke 
		 * will be defined.  
		 * @param event Not used, but passed anyway as this is a handler method.
		*/
		private function onMouseUp(event:MouseEvent = null):void {
			mouseDown = false;
			if(mouseY > modeText.height){
				var inkLatestStroke:InkTimeline = inkPath.latestStroke;
				strokeAngleDifference(inkLatestStroke);
				if(toggle){
					hasDrawn = true;
					if(recogMode){
						recognizerMouseUp(inkLatestStroke);
					} else {
						definitionMouseUp(inkLatestStroke);
					}
				}
			}
		}
	}
}