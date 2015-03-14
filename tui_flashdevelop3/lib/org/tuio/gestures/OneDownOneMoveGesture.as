package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.events.GestureEvent;
	import flash.utils.getTimer;
	import org.tuio.TuioContainer;
	import org.tuio.TuioEvent;
	import org.tuio.TouchEvent;
	
	public class OneDownOneMoveGesture extends Gesture {
		
		public static const GESTURE_ONE_DOWN_ONE_MOVE:String = "org.tuio.gestures.OneDownOneMoveGesture";
		
		public function OneDownOneMoveGesture() {
			this.addStep(new GestureStep(TouchEvent.TOUCH_DOWN, { tuioContainerAlias:"A", targetAlias:"A" } ));
			this.addStep(new GestureStep(TouchEvent.TOUCH_UP, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TouchEvent.TOUCH_DOWN, {tuioContainerAlias:"B"} ));
			this.addStep(new GestureStep(TouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TouchEvent.TOUCH_UP, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TouchEvent.TOUCH_UP, {tuioContainerAlias:"B", die:true}));
			this.addStep(new GestureStep(TouchEvent.TOUCH_MOVE, {tuioContainerAlias:"B", goto:4}));
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			//trace("one down one move " + getTimer());
			gsg.getTarget("A").dispatchEvent(new GestureEvent(GESTURE_ONE_DOWN_ONE_MOVE, true, false, null, 0, 0, false, false, false, false, false));
		}
		
	}
	
}