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
package touchAll.cube3D
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	//import flash.events.TransformGestureEvent;
	import flash.geom.*;
	import flash.filters.*;
	
	import org.tuio.TouchEvent;
	
	public class Cube3D
	{
		private var numFaces:int = 6;
		private var numVertices:int = 8;
		private var fLen:Number = 500;
		private var objRad:Number = 70;
		private var shBack:Shape = new Shape();
		
		private var doRotate:Boolean=false;
		private var prevX:Number;
		private var prevY:Number;
		private var velX:Number = 1;
		private var velY:Number = 2;
		private var velMag:Number = 5;
		
		private var spBoard:Sprite = new Sprite();
		private var spObject:Sprite = new Sprite();
		private var spObjImage:Sprite = new Sprite();
		
		private var facesVec:Vector.<Array> = new Vector.<Array>();
		private var vertsVec:Vector.<Vector3D> = new Vector.<Vector3D>();
		
		private var facesColors:Array = [0xFFFFCC, 0x00FF66, 0x0066FF, 0x33FFFF, 0x9A7DDF, 0xFFCCFF];
		
		public function Cube3D(_stage:Stage = null):void 
		{
			_stage.addChild(spBoard);
			
			spBoard.x = 1280 / 2;
			spBoard.y = 720 / 2;
			spBoard.filters = [ new DropShadowFilter() ];	 
			
			spBoard.addChild(shBack);
			
			drawBack();
			
			spBoard.addChild(spObjImage);
			
			spObject.rotationX = 0;
			spObject.rotationY = 0;
			spObject.rotationZ = 0;
			
			setVertices();
			setFaces();
			rotateObj(0,0,0);
			
			spBoard.addEventListener(MouseEvent.MOUSE_MOVE, boardMove);
			spBoard.addEventListener(MouseEvent.MOUSE_DOWN, boardDown);
			spBoard.addEventListener(MouseEvent.MOUSE_UP, boardUp);
			
			spBoard.addEventListener(TouchEvent.TOUCH_MOVE, touchBoardMove);
			spBoard.addEventListener(TouchEvent.TOUCH_DOWN, touchBoardDown);
			spBoard.addEventListener(TouchEvent.TOUCH_UP, boardUp);			
			
			_stage.addEventListener(Event.ENTER_FRAME,whenEnterFrame);
		}
		
		private function drawBack():void {
			shBack.graphics.beginFill(0xFFFFFF);
			shBack.graphics.drawRect(-640,-360,1280,720);
			shBack.graphics.endFill();
		}
		
		private function setVertices():void {
			vertsVec[0]=new Vector3D(- objRad,- objRad,- objRad);
			vertsVec[1]=new Vector3D(objRad,- objRad,- objRad);
			vertsVec[2]=new Vector3D(objRad,- objRad,objRad);
			vertsVec[3]=new Vector3D(- objRad,- objRad,objRad);
			vertsVec[4]=new Vector3D(- objRad,objRad,- objRad);
			vertsVec[5]=new Vector3D(objRad,objRad,- objRad);
			vertsVec[6]=new Vector3D(objRad,objRad,objRad);
			vertsVec[7]=new Vector3D(- objRad,objRad,objRad);
		}
		
		private function setFaces():void {
			facesVec[0]=[0,4,5,1];
			facesVec[1]=[1,5,6,2];
			facesVec[2]=[2,6,7,3];
			facesVec[3]=[3,7,4,0];
			facesVec[4]=[4,5,6,7];
			facesVec[5]=[0,1,2,3];
		}
		
		private function rotateObj(rotx:Number,roty:Number,rotz:Number):void {
			var i:int;
			var j:int;
		 
			var distArray:Array=[];
		 
			var dispVec:Vector.<Point>=new Vector.<Point>();
			var newVertsVec:Vector.<Vector3D>=new Vector.<Vector3D>();
			var zAverage:Number;
		 	
			var dist:Number;
			var curFace:int;
			var curFaceLen:int;
			var curObjMat:Matrix3D;
		 
			spObject.transform.matrix3D.appendRotation(rotx,Vector3D.X_AXIS);
			spObject.transform.matrix3D.appendRotation(roty,Vector3D.Y_AXIS);
			spObject.transform.matrix3D.appendRotation(rotz,Vector3D.Z_AXIS);
		 
			curObjMat=spObject.transform.matrix3D.clone();
			spObjImage.graphics.clear();
		 
			for (i=0; i<numVertices; i++) {
				newVertsVec[i]=curObjMat.deltaTransformVector(vertsVec[i]);
			}
		 
			for (i=0; i<numVertices; i++) {
				newVertsVec[i].w=(fLen+newVertsVec[i].z)/fLen;
				newVertsVec[i].project();
			}
		 
			for (i=0; i<numFaces; i++) {
				curFaceLen=facesVec[i].length;
				zAverage=0;
				for (j=0; j<curFaceLen; j++) {
					zAverage+=newVertsVec[facesVec[i][j]].z;
				}
				zAverage/=curFaceLen;
				dist=zAverage;
				distArray[i]=[dist,i];
			}
		 
			distArray.sort(byDist);
		 
			for (i=0; i<numVertices; i++) {
				dispVec[i]=new Point();
				dispVec[i].x=newVertsVec[i].x;
				dispVec[i].y=newVertsVec[i].y;
			}
		 
			for (i=0; i<numFaces; i++) {
				spObjImage.graphics.lineStyle(1,0xCC0000);
				curFace=distArray[i][1];
				curFaceLen=facesVec[curFace].length;
				spObjImage.graphics.beginFill(facesColors[curFace],0.7);
				spObjImage.graphics.moveTo(dispVec[facesVec[curFace][0]].x,
				dispVec[facesVec[curFace][0]].y);
		 
				for (j=1; j<curFaceLen; j++) {
					spObjImage.graphics.lineTo(dispVec[facesVec[curFace][j]].x,
					dispVec[facesVec[curFace][j]].y);
				}
		 
				spObjImage.graphics.lineTo(dispVec[facesVec[curFace][0]].x,
				dispVec[facesVec[curFace][0]].y);
				spObjImage.graphics.endFill();
			}
		}
		
		private function byDist(v:Array,w:Array):Number {
			if (v[0]>w[0]) {
				return -1;
			} else if (v[0]<w[0]) {
				return 1;
			} else {
				return 0;
			}
		}
		
		private function resetObj():void {
			spObject.transform.matrix3D=new Matrix3D();
			rotateObj(0,0,0);
		}
		
		private function boardDown(e:MouseEvent):void {
			prevX=e.stageX;
			prevY=e.stageY;
			velX=0;
			velY=0;
			velMag=0;
			doRotate=true;
		}
		 
		private function boardMove(e:MouseEvent):void {
			var locX:Number=prevX;
			var locY:Number=prevY;
		 
			if (doRotate) {
				prevX=e.stageX;
				prevY=e.stageY;
				velX=-1*(prevX-locX);
				velY=1*(prevY-locY);
				velMag=Math.abs(velX)+Math.abs(velY);
				rotateObj(prevY-locY,-(prevX-locX),0);
			}
		}
		
		private function touchBoardDown(e:TouchEvent):void {
			prevX=e.stageX;
			prevY=e.stageY;
			velX=0;
			velY=0;
			velMag=0;
			doRotate=true;
		}
		
		private function touchBoardMove(e:TouchEvent):void {
			var locX:Number=prevX;
			var locY:Number=prevY;
		 
			if (doRotate) {
				prevX=e.stageX;
				prevY=e.stageY;
				velX=-1*(prevX-locX);
				velY=1*(prevY-locY);
				velMag=Math.abs(velX)+Math.abs(velY);
				rotateObj(prevY-locY,-(prevX-locX),0);
			}
		}
		
		private function boardUp(e:Event):void {
			doRotate=false;
		}
		
		private function whenEnterFrame(e:Event):void {
			if (! doRotate&&velMag>0) {
				rotateObj(velY,velX,0);
			}
		}
	}
}
