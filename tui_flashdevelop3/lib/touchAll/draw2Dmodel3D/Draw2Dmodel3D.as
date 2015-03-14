package touchAll.draw2Dmodel3D
{
	
	import flash.ui.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	import flash.text.*;

	import org.tuio.*;
	import org.tuio.debug.*;
	import org.tuio.connectors.*;
	
	/**
	 * @author Gonçalo Amador
	 * TO ADD:
	 * 1 - 3D rotation
	 * 2 - port to touch 
	 * 3 - ...
	 */
	
	//  [SWF(width="1280", height="720", frameRate="60", backgroundColor="#000000")]    
	public class Draw2Dmodel3D extends MovieClip
	{
		private var _tm:TuioManager;
		private var _button1:TextField;
		private var _button2:TextField;
		private var _drawBackground:Sprite = new Sprite;
		private var _buttonsBackground:Sprite = new Sprite;
		private var _lines:Shape = new Shape;
		private var _point:Shape = new Shape;
		private var _lastStartPoint:Vector3D = null;
		private var _closestPoint:Vector3D = null;
		private var _pointsToExtrudeCount:Number = 0;
		private var _oldPointsToExtrudeCount:Number = 0;
		private var _points3D:Array = new Array;
		private var _breakLines:Array = new Array;
		private var _drawClosedLines:Boolean = false;
		private var _isNextStartPoint:Boolean = false;
		private var _buttonsOnColor:uint = 0x000000; 
		private var _buttonsOffColor:uint = 0x006600;
		private var _buttonsTextColor:uint = 0x888888;
		private var _dActive:Boolean = false;
		private var _fActive:Boolean = false;
		private var _vActive:Boolean = false;
		private var _xActive:Boolean = false;
		private var _yActive:Boolean = false;
		private var _zActive:Boolean = false;
		
		public function Draw2Dmodel3D(): void {
			var _tc:TuioClient = new TuioClient(new UDPConnector("127.0.0.1", 3333));
			_tc.addListener(TuioDebug.init(stage));  
			_tm = TuioManager.init(stage, _tc); 
			
			_drawBackground.graphics.beginFill(0x00ffff,1);
			_drawBackground.graphics.drawRect(0, 40, stage.stageWidth, stage.stageHeight - 40);
			_drawBackground.graphics.endFill();
			
			_buttonsBackground.graphics.beginFill(0x888888,1);
			_buttonsBackground.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight - _drawBackground.height);
			_buttonsBackground.graphics.endFill();
			
			_drawBackground.addChild(_lines);
			_drawBackground.addChild(_point);
			
			stage.addChild(_drawBackground);	
			stage.addChild(_buttonsBackground);	
			
			addButton1();
			addButton2();
			
			_drawBackground.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_drawBackground.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownMove);
			_drawBackground.addEventListener(MouseEvent.MOUSE_MOVE, mouseDownMove);
			_drawBackground.addEventListener(MouseEvent.MOUSE_WHEEL, extrude);
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		/* BUTTONS SETUP FUNCTIONS */
		/**
		 * Button1 setup
		 */ 
		private function addButton1():void {
			_button1 = new TextField();
			_button1.textColor = _buttonsTextColor;
			_button1.text = _drawClosedLines ? "  Draw closed lines ON" : " Draw closed lines OFF";
			_button1.width = 120;
			_button1.height = 20;
			_button1.x = 10;
			_button1.y = 10;
			_button1.selectable = false;
			_button1.background = true;
			_button1.backgroundColor = _drawClosedLines ? _buttonsOnColor : _buttonsOffColor;			
			_button1.addEventListener(MouseEvent.CLICK, toggleButton1OnOff);
			stage.addChild(_button1);
		}
		
		/**
		 * Button1 mouse click events handling
		 */ 
		private function toggleButton1OnOff(e:MouseEvent):void {
			_drawClosedLines = !_drawClosedLines;
			TextField(e.currentTarget).backgroundColor = _drawClosedLines ? _buttonsOnColor : _buttonsOffColor;
			TextField(e.currentTarget).text = _drawClosedLines ? "  Draw closed lines ON" : " Draw closed lines OFF";
			
			if (!_drawClosedLines) {	
				if (_lastStartPoint != null) {
					_points3D.push(_lastStartPoint);
				}
				
				if (_points3D.length != 0) {
					_breakLines.push(_points3D.length - 1);
				}	
			}
			else {
				if (_points3D.length != 0) {
					_points3D.splice(_points3D.length, 1);
				}
				
				_isNextStartPoint = !_isNextStartPoint;
			}
		}
		
		/**
		 * Button2 setup
		 */ 
		private function addButton2():void {
			_button2 = new TextField();
			_button2.textColor = _buttonsTextColor;
			_button2.text = " Clear lines";
			_button2.width = 60;
			_button2.height = 20;
			_button2.x = 140;
			_button2.y = 10;
			_button2.selectable = false;
			_button2.background = true;
			_button2.backgroundColor = _buttonsOnColor;			
			_button2.addEventListener(MouseEvent.MOUSE_UP, button2Up);
			_button2.addEventListener(MouseEvent.MOUSE_DOWN, button2Down);
			stage.addChild(_button2);
		}
		
		/**
		 * Button2 mouse up events handling
		 */ 
		private function button2Up(e:MouseEvent):void {
			_point.graphics.clear();
			_lines.graphics.clear();
			_lastStartPoint = null;
			_closestPoint = null;
			_points3D = new Array;
			_breakLines = new Array;
			_drawClosedLines = false;
			_isNextStartPoint = false;
			//_drawBackground.rotationY = 0;
			_dActive = _fActive = _vActive = false;
			_xActive = _yActive = _zActive = false;
			
			stage.removeChild(_button1);
			addButton1();
			TextField(e.currentTarget).backgroundColor = _buttonsOnColor;
		}
		
		/**
		 * Button2 mouse down events handling
		 */ 
		private function button2Down(e:MouseEvent):void {
			TextField(e.currentTarget).backgroundColor = _buttonsOffColor;
		}
		
		/* DRAW AND AUXILIAR NEAREST POINT FUNCTIONS */
		/**
		 * Get the closest 3D point to point3D from the _points3D array
		 * @param	point3D - the point to find the closest from the _points3D array
		 * @return  the closest 3D point to point3D from the _points3D array
		 */
		private function nearestPoint(point3D:Vector3D):Vector3D {
			var closestPoint:Vector3D = null;
			var smallerDistance:Number = 0;
				
			for each(var point:Vector3D in _points3D) {
				if (smallerDistance == 0) {
					smallerDistance = Vector3D.distance(point, point3D);
					closestPoint = point;
				}
				
				var aux:Number = Vector3D.distance(point, point3D);
				
				if (aux <= smallerDistance) {
					smallerDistance = aux;
					closestPoint = point;
				}
			}
			
			return (closestPoint);
		}
		
		/**
		 * Get the index of point3D from the _points3D array
		 * @param	point3D - the point to find the index from the _points3D array
		 * @return  the index of point3D from the _points3D array
		 */
		private function pointIndex(point3D:Vector3D):int {
			var index:int = 0;
			var distance:Number = 0;
				
			for (var i:int = 0; i < _points3D.length; i++) {
				distance = Vector3D.distance(_points3D[i], point3D);
				
				if (distance == 0) {
					index = i;
					break;
				}
			}
			
			return index;
		}
		
		/**
		 * Setup extrude for the closest point from the mouse cursor position from the points in the _points3D array
		 */	
		private function extrudePoint():void {
			_closestPoint = nearestPoint(new Vector3D(mouseX, mouseY));
			
			if (_drawClosedLines) {			
				if (_lastStartPoint != null) {
					_points3D.push(_lastStartPoint);
				}
				if (_points3D.length != 0) {
					_breakLines.push(_points3D.length - 1);
				}	
				
				_drawClosedLines = !_drawClosedLines;
				stage.removeChild(_button1);
				addButton1();
			}
			
			_points3D.push(new Vector3D(_closestPoint.x, _closestPoint.y, _closestPoint.z));
			_points3D.push(new Vector3D(_closestPoint.x, _closestPoint.y, _closestPoint.z));
			_breakLines.push(_points3D.length - 1);
		}
		
		/**
		 * Setup extrude for all the existing points in the _points3D array
		 */	
		private function extrudePoints():void {
			var i:int, j:int;
			
			if (_drawClosedLines) {			
				if (_lastStartPoint != null) {
					_points3D.push(_lastStartPoint);
				}
				if (_points3D.length != 0) {
					_breakLines.push(_points3D.length - 1);
				}	
				
				_drawClosedLines = !_drawClosedLines;
				stage.removeChild(_button1);
				addButton1();
			}
			
			_oldPointsToExtrudeCount = _pointsToExtrudeCount;
			_pointsToExtrudeCount = _points3D.length;
			
			trace(_points3D.length);
			trace(_breakLines.length);
			
			for (i = 0; i < _pointsToExtrudeCount; i++) {
				_points3D.push(new Vector3D(_points3D[i].x, _points3D[i].y, _points3D[i].z));
				_points3D.push(new Vector3D(_points3D[i].x, _points3D[i].y, _points3D[i].z));
				_breakLines.push(_points3D.length - 1);
			}
			
			for (i = 0, j = 0; i < _pointsToExtrudeCount; i++) {
				_points3D.push(new Vector3D(_points3D[i].x, _points3D[i].y, _points3D[i].z));
				if (_breakLines[j] == i) {
					_breakLines.push(_points3D.length - 1);
					j++;
				}
			}
			
			trace(_points3D.length);
			trace(_breakLines.length);
		}
		
		/**
		 * Draw a given point
		 * @param	point - a given point to draw
		 */
		private function drawPoint(point:Point ):void {
			_point.graphics.clear();
			_point.graphics.beginFill(0x00ff00, 1);
			_point.graphics.drawCircle(point.x, point.y, 5);
			_point.graphics.endFill();
		}
		
		/**
		 * Draw the closest 3D point to point3D from the _points3D array
		 * @param	point3D - a given point from which to find the closest from the _points3D array
		 */
		private function drawNearestPoint(point3D:Vector3D):void {
			var closestPoint:Vector3D = nearestPoint(point3D);
			
			if (closestPoint != null) {	
				var point:Point = local3DToGlobal(closestPoint);
				drawPoint(point);
			}
		}
		
		/**
		 * Draw an line between each pair of consecutive points stored in _points3D 
		 */
		private function drawLines():void {
			var point3D:Point;
			
			_lines.graphics.clear();
			point3D = local3DToGlobal(_points3D[0]);
			_lines.graphics.moveTo(point3D.x, point3D.y);
			_lines.graphics.beginFill(0xF46000, 1);
			_lines.graphics.drawCircle(point3D.x, point3D.y, 5);
			_lines.graphics.endFill();
			for (var i:int = 0, j:int = 0; i < _points3D.length; i++) {
				if (_points3D[i + 1] != undefined) {
					point3D = local3DToGlobal(_points3D[i + 1]);
					if (_breakLines[j] != undefined) {
						if (_breakLines[j] == i) {
							_lines.graphics.beginFill(0xF46000, 1);
							_lines.graphics.lineStyle(8, 0xF46000, 0);
							_lines.graphics.drawCircle(point3D.x, point3D.y, 5);
							_lines.graphics.endFill();
							_lines.graphics.lineStyle(10, 0xF46000, 0);
							j++;
						}
						else {
							_lines.graphics.lineStyle(10, 0xF46000);
						}
					} else {
						_lines.graphics.lineStyle(10, 0xF46000);
					}
					_lines.graphics.lineTo(point3D.x, point3D.y);
				}
			}
			
			if (_drawClosedLines) {
				_lines.graphics.lineStyle(10, 0xF46000);
				_lines.graphics.lineTo(_lastStartPoint.x, _lastStartPoint.y);
			}
		}
		
		/* MOUSE/KEYBOARD EVENT HANDLING */
		
		private function mouseUp(e:MouseEvent):void {
			//trace(_points3D.length);
			
			if (!_drawClosedLines) {			
				if (_points3D[0] != undefined) {
					_breakLines.push(_points3D.length - 1);
				}
			}
		}
		
		private function mouseDownMove(e:MouseEvent):void {
			if (e.buttonDown) {
				_xActive = _yActive = _zActive = false;
				_point.graphics.clear();
				_points3D.push(new Vector3D(mouseX, mouseY));
				trace(_points3D.length);
				
				if (_drawClosedLines) {
					if (_isNextStartPoint) {	
						_lastStartPoint = _points3D[_points3D.length - 1];
						_isNextStartPoint = !_isNextStartPoint;
					}
				}
				
				drawLines();
			}
		}
		
		private function extrude(e:MouseEvent):void {
			if (_fActive) {
				if (_points3D[0] != undefined) {
					var i:int;
				
					if (_xActive) {
						trace("extrude points in x");
						for (i = _pointsToExtrudeCount; i < (_points3D.length - _pointsToExtrudeCount); i+=2) {
							_points3D[i].x += e.delta;		
						}
						
						for (i = (_points3D.length - _pointsToExtrudeCount); i < _points3D.length; i++) {
							_points3D[i].x += e.delta;		
						}					
						drawLines();
					}
					
					if (_yActive) {
						trace("extrude points in y");
						for (i = _pointsToExtrudeCount; i < (_points3D.length - _pointsToExtrudeCount); i+=2) {
							_points3D[i].y += e.delta;		
						}
						
						for (i = (_points3D.length - _pointsToExtrudeCount); i < _points3D.length; i++) {
							_points3D[i].y += e.delta;		
						}					
						drawLines();
					}
					
					if (_zActive) {
						trace("extrude points in z");
						for (i = _pointsToExtrudeCount; i < (_points3D.length - _pointsToExtrudeCount); i+=2) {
							_points3D[i].z += e.delta;		
						}
						
						for (i = (_points3D.length - _pointsToExtrudeCount); i < _points3D.length; i++) {
							_points3D[i].z += e.delta;		
						}					
						drawLines();
					}
				}
			}
				
			if (_vActive) {
				if (_points3D[0] != undefined) {
					if (_xActive) {
						trace("extrude point in x");
						//trace(_closestPoint);						
						//trace(_points3D.length);
						_points3D[_points3D.length - 1].x += e.delta;						
						drawPoint(local3DToGlobal(_points3D[_points3D.length - 1]));
						drawLines();
					}
					
					if (_yActive) {
						trace("extrude point in y");
						//trace(_closestPoint);	
						//trace(_points3D.length);
						_points3D[_points3D.length - 1].y += e.delta;						
						drawPoint(local3DToGlobal(_points3D[_points3D.length - 1]));
						drawLines();
					}
					
					if (_zActive) {
						trace("extrude point in z");
						//trace(_closestPoint);	
						//trace(_points3D.length);
						_points3D[_points3D.length - 1].z += e.delta;						
						drawPoint(local3DToGlobal(_points3D[_points3D.length - 1]));
						drawLines();
					}
				}
			}					
			
			if (_dActive) {
				if (_points3D != null) {
					if (_closestPoint != null) {
						if (_xActive) {
							trace("shift point in x");				
							_points3D[pointIndex(_closestPoint)].x += e.delta;
							drawPoint(local3DToGlobal(_closestPoint));
							drawLines();
						}
						
						if (_yActive) {
							trace("shift point in y");
							_points3D[pointIndex(_closestPoint)].y += e.delta;
							drawPoint(local3DToGlobal(_closestPoint));
							drawLines();
						}
						
						if (_zActive) {
							trace("shift point in z");
							_points3D[pointIndex(_closestPoint)].z += e.delta;
							trace(_points3D[pointIndex(_closestPoint)]);
							drawPoint(local3DToGlobal(_closestPoint));
							drawLines();
						}	
					}
				}
			}
		}
		
		private function keyUp(e:KeyboardEvent):void {
			//trace("keyboard key up event");
			switch(e.keyCode) {
				case Keyboard.SPACE:
					_point.graphics.clear();
					break;
				case Keyboard.F:
					_point.graphics.clear();
					break;
				case Keyboard.V:
					_point.graphics.clear();
					break;
				case Keyboard.D:
					_point.graphics.clear();
					break;
				case Keyboard.X:
					_point.graphics.clear();
					break;
				case Keyboard.Y:
					_point.graphics.clear();
					break;
				case Keyboard.Z:
					_point.graphics.clear();
					break;
			}
		}
		
		private function keyDown(e:KeyboardEvent):void {
			//trace("keyboard key down event");
			switch(e.keyCode) {
				case Keyboard.SPACE:
					drawNearestPoint(new Vector3D(mouseX, mouseY));
					break;
				case Keyboard.F:
					//trace("F key event");
					_fActive = !_fActive;
					_dActive = _vActive = false;
					_xActive = _yActive = _zActive = false;
					break;
				case Keyboard.V:
					//trace("V key event");
					_vActive = !_vActive;
					_closestPoint = null;
					_dActive = _fActive = false;
					_xActive = _yActive = _zActive = false;
					break;			
				case Keyboard.D:
					//trace("D key event");
					_dActive = !_dActive;
					_closestPoint = null;
					_vActive = _fActive = false;
					_xActive = _yActive = _zActive = false;
					break;
				case Keyboard.X:
					//trace("X key event");
					_xActive = !_xActive;
					if (_points3D[0] != undefined) {
						if (_vActive) {
							if (_xActive) {
								trace("X key event _xActive _vActive");
								extrudePoint();
								drawPoint(local3DToGlobal(_closestPoint));
							}
						}
						if (_dActive) {
							_closestPoint = nearestPoint(new Vector3D(mouseX, mouseY));
							drawPoint(local3DToGlobal(_closestPoint));
						}
						if (_fActive) {
							extrudePoints();
						}
					}
					break;
				case Keyboard.Y:
					//trace("Y key event");
					_yActive = !_yActive;
					if (_points3D[0] != undefined) {
						if (_vActive) {
							if (_yActive) {
								trace("Y key event _yActive _vActive");
								extrudePoint();
								drawPoint(local3DToGlobal(_closestPoint));
							}
						}
						if (_dActive) {
							_closestPoint = nearestPoint(new Vector3D(mouseX, mouseY));
							drawPoint(local3DToGlobal(_closestPoint));
						}
						if (_fActive) {
							extrudePoints();
						}
					}
					break;
				case Keyboard.Z:
					//trace("Z key event");
					_zActive = !_zActive;
					if (_points3D[0] != undefined) {
						if (_vActive) {
							if (_zActive) {
								trace("Z key event _zActive _vActive");
								extrudePoint();
								drawPoint(local3DToGlobal(_closestPoint));
							}
						}
						if (_dActive) {
							_closestPoint = nearestPoint(new Vector3D(mouseX, mouseY));
							drawPoint(local3DToGlobal(_closestPoint));
						}
						if (_fActive) {
							extrudePoints();
						}
					}
					break;
			}
		}
	}
}