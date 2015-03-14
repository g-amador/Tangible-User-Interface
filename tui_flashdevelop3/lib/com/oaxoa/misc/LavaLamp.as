package com.oaxoa.misc
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import flash.filters.*;
	
	import com.oaxoa.components.FrameRater;
	
	import org.tuio.*;
	import touchAll.*;
	
	/**
	 * ...
	 * @author Gonçalo Amador
	 */
	public class  LavaLamp extends Sprite {
		private var w:Number=300;
		private var rect:Rectangle=new Rectangle(0,0,w,w);
		private var point:Point=new Point(0,0);
		private var a:Array=[new Point(1,1), new Point(3,3)];
		 
		private var bd:BitmapData;
		private var bd2:BitmapData;
		private var bmp:Bitmap;
		 
		private var bevel:BevelFilter;
		private var blur:BlurFilter;
		private var glow:GlowFilter;
		 
		private var shape:Shape;
		private var fr:FrameRater;		
		
		private var threshold:int = 50;
		private var toggleBlur:Boolean = false;
		
		private var _stage:Stage;
		
		public function LavaLamp(stage:Stage = null):void {
			_stage = stage;
			
			initFilters();
			initBmp();
			initInterface();
		}
		
		private function onframe(event:Event):void {
			a[0].x+=1;
			a[0].y+=1;
			a[1].x+=2;
			a[1].y+=0;
			bd.perlinNoise(105,105,2,0,false,true, 7, true, a);
			bd2.fillRect(rect, 0x00000000);
			bd2.threshold(bd, rect, point, ">", threshold/255*0xffffff, 0xffff8000, 0x00ffffff, false);
		}
		 
		private function initBmp():void {
			bd=new BitmapData(w,w);
			bd2=new BitmapData(w,w);
			bmp=new Bitmap(bd2);
			bmp.filters=[blur, bevel, glow];
			_stage.addChild(bmp);
			_stage.addEventListener(Event.ENTER_FRAME, onframe);
			TouchAll._background.addEventListener(MouseEvent.MOUSE_WHEEL, changeThreshold);
			TouchAll._background.addEventListener(TouchEvent.TOUCH_MOVE, touchChangeThreshold);
		}
		 
		private function initFilters():void {
			bevel=new BevelFilter();
			bevel.blurX=bevel.blurY=20;
			bevel.distance=10;
			bevel.highlightColor=0xffffff;
			bevel.shadowColor=0xCC0000;
			blur=new BlurFilter(2,2);
			glow = new GlowFilter(0xFFAA00, 1, 20, 20, 2, 1, false, false);
			TouchAll._background.addEventListener(MouseEvent.CLICK, switchFilters);
			TouchAll._background.addEventListener(TouchEvent.DOUBLE_TAP, switchFilters);
		}
		
		private function initInterface():void {
			// draw the white bar
			shape=new Shape();
			shape.graphics.beginFill(0xffffff, .75);
			shape.graphics.drawRect(0,0,w,30);
			shape.graphics.endFill();
			shape.y = w - 30;
			// create FrameRater
			fr=new FrameRater();
			fr.y=w-30;
			// add iutems to display list
			_stage.addChild(shape);
			_stage.addChild(fr);
		}
		
		private function changeThreshold(event:MouseEvent):void {
			threshold += event.delta;
			//trace(threshold);
		} 
		
		private function touchChangeThreshold(event:TouchEvent):void {
			threshold = (event.localY);
			//trace(threshold);
		} 
		
		private function switchFilters(event:Event):void {
			toggleBlur ? bmp.filters = [blur, bevel, glow] : bmp.filters = [blur];
			toggleBlur = !toggleBlur;
		}
	}
	
}