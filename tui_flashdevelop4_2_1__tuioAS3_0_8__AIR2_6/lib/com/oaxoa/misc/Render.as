package com.oaxoa.misc 
{
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.filters.BlurFilter;
	
	import org.tuio.*;
	
	import com.oaxoa.misc.FluidSolver;
	import com.oaxoa.components.FrameRater;
	
	/**
	 * Original source available at http://blog.oaxoa.com/2008/01/21/actionscript-3-fluids-simulation/
	 * TO ADD:
	 * 1 - bigger dimmensions resolution
	 * 2 - 3D
	 * 3 - surface tracking rendering 
	 * 4 - ...
	 */
	public class Render
	{
		// frame dimensions (dxd pixels)
		private var d:int;
		
		// solver variables
		private var n:int = 32;
		private var dt:Number = 0.1;
		private var fs:FluidSolver = new FluidSolver();
		
		// cell index
		private var tx:int;
		private var ty:int;
		
		// cell dimensions
		private var dg:int;
		private var dg_2:int;
		
		// cell position
		private var dx:int;
		private var dy:int;
		
		// fluid velocity
		private var u:int;
		private var v:int;
		private var c:int;
		
		private var bd:BitmapData
		private var adding:Boolean = false;
		
		private var _stage:Stage;
		
		public function Render(stage:Stage = null, dimensions:int = 200):void {
			_stage = stage;
			d = dimensions;
			bd = new BitmapData(d, d, false, 0x000000);
			
			var blur:BlurFilter=new BlurFilter(5,5,5);
			var bmp:Bitmap=new Bitmap(bd);
			bmp.filters=[blur];
			var holder:Sprite=new Sprite;
			holder.doubleClickEnabled = true;
			holder.addChild(bmp);
			_stage.addChild(holder);
			
			
			
			var fr:FrameRater=new FrameRater(0xffffff, true);
			fr.y=10;
			_stage.addChild(fr);
			
			reset();
		 
			_stage.addEventListener(Event.ENTER_FRAME, onframe);
			
			holder.addEventListener(MouseEvent.DOUBLE_CLICK, ondoubleclicktap);
			holder.addEventListener(MouseEvent.MOUSE_MOVE, onmove);
			holder.addEventListener(MouseEvent.MOUSE_DOWN, ondown);
			holder.addEventListener(MouseEvent.MOUSE_UP, onup);
			
			holder.addEventListener(TuioTouchEvent.DOUBLE_TAP, ondoubleclicktap);
			holder.addEventListener(TuioTouchEvent.TOUCH_MOVE, touchonmove);
			holder.addEventListener(TuioTouchEvent.TOUCH_DOWN, ondown);
			holder.addEventListener(TuioTouchEvent.TOUCH_UP, onup);
		}
		
		private function reset():void {
			dg   = d  / n;
			dg_2 = dg / 2;
			fs.setup(n, dt);
		}
		 
		private function paint():void {
			var c:int;
			// clear screen
			bd.fillRect(new Rectangle(0, 0, d, d), 0x000000);
		 
			fs.velocitySolver();
			fs.densitySolver();
			for (var i:int = (n+1); i >= 1; i--) {
				// x position of current cell
				dx = int(((i - 0.5) * dg ));
				for (var j:int = (n+1); j >= 1; j--) {
					// y position of current cell
					dy = int(( (j - 0.5) * dg ));
					// draw density
					var dd:Number=fs.d[I(i, j)];
					if (dd > 0.0) {
						var r:Number=dd*255;
						if(r>255) r=255;
						c = r << 16 | r << 8 | r;
						if (c < 0) {
							c = 0;
						}
						bd.fillRect(new Rectangle(dx-dg_2, dy-dg_2, dg, dg), c);
					}
				}
			}
		}
		 
		private function onframe(event:Event):void {
			paint();
		}
			
		private function ondown(event:Event):void {
			adding = true;
		}
		
		private function onup(event:Event):void {
			adding = false;	
		}
		
		private function ondoubleclicktap(event:Event):void {
			reset();
		}
		
		private function onmove(event:MouseEvent):void {
			if(adding) {
				tx=int(_stage.mouseX/dg);
				ty=int(_stage.mouseY/dg);
				if(tx>n) tx=n;
				if(tx<1) tx=1;
				if(ty>n) ty=n;
				if(ty<1) ty=1;
		 
				fs.dOld[I(tx, ty)]=30;
			}
		}
		
		private function touchonmove(event:TuioTouchEvent):void {
			if(adding) {
				tx=int(event.localX/dg);
				ty=int(event.localY/dg);
				if(tx>n) tx=n;
				if(tx<1) tx=1;
				if(ty>n) ty=n;
				if(ty<1) ty=1;
		 
				fs.dOld[I(tx, ty)]=30;
			}
		}
		 
		// util function for indexing
		private function I(i:int, j:int):int {
			return i + (n + 2) * j;
		}
	}
	
}