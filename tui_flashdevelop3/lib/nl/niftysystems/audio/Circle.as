package nl.niftysystems.audio {
	
	import flash.display.*;
	import flash.filters.BlurFilter;
	
	public class Circle extends Sprite {
		
		public function Circle(name:String, container:DisplayObjectContainer, x:int, y:int, radius:int, color:uint){
			//Fill
			this.blendMode = BlendMode.DARKEN;
			this.graphics.lineStyle(1, color, 1, false, LineScaleMode.NONE);
			this.graphics.beginFill(color, 0.5);
			this.graphics.drawCircle(0,0,radius);
			this.graphics.endFill();
			
			//Outline
			this.graphics.lineStyle (2, 0x000000, 1, false, LineScaleMode.NONE);
			this.graphics.drawCircle(0,0,radius);
			
			this.x = x;
			this.y = y;
			this.name = name;
			
			this.filters = [new BlurFilter(10, 10, 1)];
			
			container.addChild(this);
		}
		
	}

}