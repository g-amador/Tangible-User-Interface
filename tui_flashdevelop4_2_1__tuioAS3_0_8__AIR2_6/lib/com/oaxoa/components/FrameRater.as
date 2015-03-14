/* FrameRater 0.1
** Actionscript 3 frame rate meter with graph
**
** Author: Pierluigi Pesenti
** http://blog.oaxoa.com
**
** Feel free to use or redistribute but please leave this credits
*/

package com.oaxoa.components {

	import flash.text.*;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;

	public class FrameRater extends Sprite {

		private var _timer:Timer;
		private var _text:TextField;
		private var _tf:TextFormat;
		private var _c:uint=0;
		private var _dropShadow:DropShadowFilter;
		private var _graph:Sprite;
		private var _graphBox:Sprite;
		private var _graphCounter:uint;
		private var _showGraph:Boolean;
		private var _graphColor:uint;
		
		public function FrameRater(textColor:uint = 0x000000, drawShadow:Boolean = false, showGraph:Boolean = true, graphColor:uint = 0xff0000) {
			
			_showGraph=showGraph;
			_graphColor = graphColor;
			
			if (_showGraph) {
				initGraph();
			}
			_dropShadow=new DropShadowFilter(1,90,0,1,2,2);
			_tf=new TextFormat();
			_tf.color=textColor;
			_tf.font="_sans";
			_tf.size=11;
			_text=new TextField();
			_text.width=100;
			_text.height=20;
			_text.x=3;
			if (drawShadow) {
				_text.filters=[_dropShadow];
			}
			addChild(_text);
			
			_timer=new Timer(500);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function onTimer(event:TimerEvent):void {
			var val:Number=computeTime();
			_text.text=Math.floor(val).toString()+" fps";
			_text.setTextFormat(_tf);
			_text.autoSize="left";
			if (_showGraph) {
				updateGraph(val);
			}
		}
		
		private function onFrame(event:Event):void {
			_c++;
		}
		
		public function computeTime():Number {
			var retValue:uint=_c;
			_c=0;
			return retValue * 2 - 1;
		}
		public function updateGraph(n:Number):void {
			if (_graphCounter>30) {
				_graph.x--;
			}
			_graphCounter++;
			_graph.graphics.lineTo(_graphCounter, 1+(stage.frameRate-n)/3);
		}
		
		private function initGraph():void {
			_graphCounter=0;
			_graph=new Sprite();
			_graphBox=new Sprite();
			_graphBox.graphics.beginFill(0xff0000);
			_graphBox.graphics.drawRect(0,0,36,100);
			_graphBox.graphics.endFill();
			_graph.mask=_graphBox;
			_graph.x=_graphBox.x=5;
			_graph.y=_graphBox.y=20;
			_graph.graphics.lineStyle(1, _graphColor);
			
			addChild(_graph);
			addChild(_graphBox);
		}
	}
}