/*
 * Tangible User Interfacer (former TouchAll) misc code.
 *
 * Copyright 2016 Gonçalo Amador <g.n.p.amador@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package touchAll.pong.cl.kirill 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	//import flash.events.TransformGestureEvent;
	
	import org.tuio.TuioTouchEvent;

	/**
	 * Based on source available at: http://kirill-poletaev.blogspot.com/2010/10/creating-ping-pong-game-using-as3.html
	 */

	public class PongGame extends MovieClip {
		private var _stage:Stage;
		private var _color:uint;
		private var _PlayerPaddle:Sprite = new Sprite();
		private var _EnemyPaddle:Sprite = new Sprite();
		private var _Ball:Sprite = new Sprite();
		private var _LineDrawing:Sprite = new Sprite();
		private var _plScore:Number = 0;
		private var _enScore:Number = 0;
		private var _plScoreShow:TextField = new TextField();
		private var _enScoreShow:TextField = new TextField();
		private var _Playing:Boolean = false;
		private var _BallMoveX:Number = 0;
		private var _BallMoveY:Number = 0;
		
		public function PongGame(stage:Stage = null, color:uint = 0x000000)	{
			trace("Game init");
			_stage = stage;
			_color = color;
			
			this.addChild(_PlayerPaddle);
			_PlayerPaddle.graphics.beginFill(_color);
			_PlayerPaddle.graphics.drawRect(0,0,10,70);
			_PlayerPaddle.x = 10;
			_PlayerPaddle.y = 10;
			_PlayerPaddle.graphics.endFill();
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, PlayerMovement);
			_stage.addEventListener(TuioTouchEvent.TOUCH_MOVE, touchPlayerMovement);
			
			this.addChild(_EnemyPaddle);
			_EnemyPaddle.graphics.beginFill(_color);
			_EnemyPaddle.graphics.drawRect(0,0,10,70);
			_EnemyPaddle.x = 380;
			_EnemyPaddle.y = 10;
			_EnemyPaddle.graphics.endFill();
			_stage.addEventListener(Event.ENTER_FRAME, EnemyMovement);
			
			this.addChild(_Ball);
			_Ball.graphics.beginFill(_color);
			_Ball.graphics.drawRect(0,0,10,10);
			_Ball.x = 195;
			_Ball.y = 195;
			_Ball.graphics.endFill();
			_stage.addEventListener(Event.ENTER_FRAME, BallMove);
			
			this.addChild(_LineDrawing);
			_LineDrawing.graphics.lineStyle(1, _color);
			_LineDrawing.graphics.moveTo(5,5);
			_LineDrawing.graphics.lineTo(5, 5);
			_LineDrawing.graphics.lineTo(395, 5);
			_LineDrawing.graphics.lineTo(395, 395);
			_LineDrawing.graphics.lineTo(5, 395);
			_LineDrawing.graphics.lineTo(5, 5);
			_LineDrawing.graphics.moveTo(200,5);
			_LineDrawing.graphics.lineTo(200, 400);
			
			this.addEventListener(MouseEvent.CLICK, StartGame);
			this.addEventListener(TuioTouchEvent.TAP, StartGame);
			this.addEventListener(MouseEvent.RIGHT_CLICK, StopGame);
			this.addEventListener(TuioTouchEvent.DOUBLE_TAP, StopGame);
			
			this.addChild(_plScoreShow);
			_plScoreShow.selectable = false;
			_plScoreShow.x = 100;
			_plScoreShow.y = 15;
			_plScoreShow.textColor = _color;
			_plScoreShow.text = "0";
			this.addChild(_enScoreShow);
			_enScoreShow.selectable = false;
			_enScoreShow.x = 300;
			_enScoreShow.y = 15;
			_enScoreShow.textColor = _color;
			_enScoreShow.text = "0";
		}
		
		public function stopGame():void	{
			if (_Playing)
			{
				trace("Game stoped!");
				_Ball.x = _Ball.y = 195;
				_Playing = false;
			}
		}
		
		
		private function StopGame(e:Event):void {
			stopGame();
		}
		
		private function StartGame(e:Event):void {
			if (!_Playing)
			{
				trace("Game started!");
				_Playing = true;
				_BallMoveX = (Math.random()-0.5)*10;
				_BallMoveY = (Math.random()-0.5)*10;
			}
		}
		
		private function PlayerMovement(e:MouseEvent):void {
			if (_Playing) {
				if (_stage.mouseY > 30 && _stage.mouseY < 355)
				{
					_PlayerPaddle.y = _stage.mouseY - 35;
				}
			}
		}
		
		private function touchPlayerMovement(e:TuioTouchEvent):void	{
			if (_Playing) {
				if (e.stageX > 30 && e.stageY < 355)
				{
					_PlayerPaddle.y = e.stageY - 35;
				}
			}
		}
		
		private function EnemyMovement(e:Event):void {
			if (_Playing) {
				if (_Ball.y > 30 && _Ball.y - 35 < _EnemyPaddle.y + 5)
				{
					_EnemyPaddle.y -=  5;
				}
				
				if (_Ball.y < 355 && _Ball.y - 35 > _EnemyPaddle.y + 5)
				{
					_EnemyPaddle.y +=  5;
				}	
			}
		}
		
		private function BallMove(e:Event):void
		{
			if (_Playing) {
				_Ball.x +=  _BallMoveX;
				_Ball.y +=  _BallMoveY;
				
				if (_Ball.y <= 5 && _BallMoveY < 0)
				{
					_BallMoveY *=  -1;
				}
				
				if (_Ball.y >= 385 && _BallMoveY > 0)
				{
					_BallMoveY *=  -1;
				}
				
				if (_Ball.hitTestObject(_PlayerPaddle) && _BallMoveX < 0)
				{
					_BallMoveX *=  -1;
					
					if (_BallMoveX < 8)
					{
						_BallMoveX++;
					}
					
					_BallMoveY = -Math.round((_PlayerPaddle.y + 35 - _Ball.y)/5);
				}
				
				if (_Ball.hitTestObject(_EnemyPaddle) && _BallMoveX > 0)
				{
					_BallMoveX *=  -1;
					
					if (_BallMoveX > 8)
					{
						_BallMoveX--;
					}
					
					_BallMoveY = -Math.round((_EnemyPaddle.y + 35 - _Ball.y)/5);
				}
				
				if (_Playing && _Ball.x < 0)
				{
					EnemyWin();
				}
				
				if (_Playing && _Ball.x > 400)
				{
					PlayerWin();
				}
			}
		}
		
		private function PlayerWin():void
		{
			trace("Player wins!");
			_Ball.x = _Ball.y = 195;
			_BallMoveX = Math.random() * 16 - 8;
			_BallMoveY = Math.random() * 16 - 8;
			_plScore++;
			_plScoreShow.textColor = _color;
			_plScoreShow.text = _plScore.toString();
		}
		
		private function EnemyWin():void
		{
			trace("Enemy wins!");
			_Ball.x = _Ball.y = 195;
			_BallMoveX = Math.random() * 16 - 8;
			_BallMoveY = Math.random() * 16 - 8;
			_enScore++;
			_enScoreShow.textColor = _color;
			_enScoreShow.text = _enScore.toString();
		}
	}
}
