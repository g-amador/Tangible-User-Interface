package org.tuio.gestures {
	
	import flash.events.PressAndTapGestureEvent;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import org.tuio.TuioContainer;
	import org.tuio.TuioEvent;
	import org.tuio.TouchEvent;
	
	public class PressTapGesture extends Gesture {
		
		public function PressTapGesture() {
			this.addStep(new GestureStep(TouchEvent.TOUCH_DOWN, { tuioContainerAlias:"A", targetAlias:"A" } ));
			this.addStep(new GestureStep(TouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TouchEvent.TOUCH_UP, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TouchEvent.TAP, {minDelay:500, goto:2} ));
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			//trace("press tap " + getTimer());
			gsg.getTarget("A").dispatchEvent(new PressAndTapGestureEvent(PressAndTapGestureEvent.GESTURE_PRESS_AND_TAP, true, false, null, 0, 0, 0, 0, false, false, false, false, false));
		}
		
	}
	
}