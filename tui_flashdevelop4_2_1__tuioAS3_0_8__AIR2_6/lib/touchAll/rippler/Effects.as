package touchAll.rippler
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.tuio.*;

	import touchAll.TouchAll;
	
	/**
	 * ...
	 * @author Gonçalo Amador
	 */
	public class Effects extends Sprite
	{
		
		// Embed an image (Flex Builder only, use library in Flash Authoring)
		[Embed(source = "../../../bin/resources/shallow-water-750509-ga.jpg")]
        private var _sourceImage:Class;
        private var _target:Bitmap;
        private var _rippler:Rippler;
		private var _rain:Boolean = false;
		private var _rainIntensity:int = 20;
		
		private var _stage:Stage;
		
		public function Effects(stage:Stage = null):void 
		{
			_stage = stage;
			_stage.addEventListener(Event.ENTER_FRAME, rain);
		}
		
		/** 
		 * load background image to make touch or mouse over water riple effects 
		 */
		public function backgroundRippleLoader():void {
			/* create a Bitmap displayobject */ 
            _target = new Bitmap(new _sourceImage().bitmapData);
			//target.blendMode = BlendMode.ADD;
			
			/* create the Rippler instance to affect the Bitmap object */
            _rippler = new Rippler(_target, 10, 2);
			
			/* add the target to the stage */
            _stage.addChild(_target);
		}
		
		/**
		 * background event listener for ripple set up
		 */ 
		public function backgroundRippleEventListenersLoader():void {
			/* BACKGROUND RIPPLE EVENT LISTENERS */
			/* add background touch event listeners */	
			trace("add background touch event listeners.");
			TouchAll._background.addEventListener(TuioTouchEvent.TOUCH_UP, touchRipple);
			TouchAll._background.addEventListener(TuioTouchEvent.TOUCH_MOVE, touchRipple);
			TouchAll._background.addEventListener(TuioTouchEvent.TOUCH_MOVE, touchRainIntensity);
			TouchAll._background.addEventListener(TuioTouchEvent.DOUBLE_TAP, toggleRainOnOff);
			
			/* add background mouse event listeners */	
			trace("add background mouse event listeners.");
			TouchAll._background.addEventListener(MouseEvent.MOUSE_UP, mouseRipple);
			TouchAll._background.addEventListener(MouseEvent.MOUSE_MOVE, mouseRipple);
			TouchAll._background.addEventListener(MouseEvent.MOUSE_WHEEL, mouseRainIntensity);
			TouchAll._background.addEventListener(MouseEvent.DOUBLE_CLICK, toggleRainOnOff);
		}
		
		/**
		 * draw rain 
		 */
		private function rain(e:Event):void {
			if (_rain) {
				if ((Math.round(Math.random() * (10 - 1)) + 1) % 2 == 0) {
					for (var i:int = 0; i < _rainIntensity; i++ )
					{
						_rippler.drawRipple(Math.round(Math.random()*(_stage.width)), Math.round(Math.random()*(_stage.height)), Math.round(Math.random()*(10)), 1);
					}	
				}
			}
		}
		
		/**
		 * handle touch/mouse double tap/click events for the tuioCursor/circle
		 */
		private function toggleRainOnOff(e:Event):void {
			trace("Touch/Mouse Double Tap/Click detected.");
			_rain = !_rain;
		}
		
		/* TOUCH FUNCTIONS */
		/**
		 * handle touch up/movement events for the tuio cursor
		 */
		private function touchRipple(e:TuioTouchEvent):void {
			//trace("Touch Up/Movement detected.");
			
			/* 
			 * creates a ripple at mouse coordinates on mouse movement
			 * the ripple point of impact is size 20 and has alpha 1
			 */
			_rippler.drawRipple(e.localX, e.localY, 10, 1);
		}
		
		/**
		 * handle touch movement events for circle
		 */
		private function touchRainIntensity(e:TuioTouchEvent):void {
			trace("Mouse Scroll detected.");
			_rainIntensity = e.localY;
			trace(_rainIntensity);
		}
		
		/* MOUSE FUNCTIONS */
		/**
		 * handle mouse up/movement events for circle
		 */
		private function mouseRipple(e:MouseEvent):void {
			/* 
			 * creates a ripple at mouse coordinates on mouse movement
			 * the ripple point of impact is size 20 and has alpha 1
			 */
			_rippler.drawRipple(_target.mouseX, _target.mouseY, 10, 1);
		}
		
		/**
		 * handle mouse scroll events for circle
		 */
		private function mouseRainIntensity(e:MouseEvent):void {
			trace("Mouse Scroll detected.");
			_rainIntensity += e.delta;
			trace(_rainIntensity);
		}	
	}
}