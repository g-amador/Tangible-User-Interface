/*
 * Based on FluidSolver.java
 * by Alexander McKenzie
 * 12 March, 2004
 *
 * Actionscript 3 fluid solver with vorticity confinement
 * and buoyancy force based on studies from Jos Stam.
 *
 * Original comments by Alexander McKenzie
 *
 * @author Pierluigi Pesenti
 * @version 0.2
*/
package com.oaxoa.misc {
	
	public class FluidSolver {
		
		private var n:int;
		private var size:int;
		private var dt:Number;
		
		private var visc:Number = 0;
		private var diff:Number = 0;
		
		private var tmp:Array;
		
		public var d:Array;
		public var dOld:Array;
		private var u:Array;
		private var uOld:Array;
		private var v:Array;
		private var vOld:Array;
		private var curl:Array;
		
		public function FluidSolver() {
			
		}
		
		public function setup(ns:int, dts:Number):void {
			n = ns;
			dt = dts;
			size = (n + 2) * (n + 2);
			
			reset();
		}
		
		 // Reset the datastructures.
		 // We use 1d arrays for speed.
		public function reset():void {
			d    = new Array();
			dOld = new Array();
			u    = new Array();
			uOld = new Array();
			v    = new Array();
			vOld = new Array();
			curl = new Array();
			
			for (var i:int = size-1; i >=0; i--) {
				u[i] = uOld[i] = v[i] = vOld[i] = 0.0;
				d[i] = dOld[i] = curl[i] = 0.0;
			}
		}
		
		/**
		 * Calculate the buoyancy force as part of the velocity solver.
		 * Fbuoy = -a*d*Y + b*(T-Tamb)*Y where Y = (0,1). The constants
		 * a and b are positive with appropriate (physically meaningful)
		 * units. T is the temperature at the current cell, Tamb is the
		 * average temperature of the fluid grid. The density d provides
		 * a mass that counteracts the buoyancy force.
		 *
		 * In this simplified implementation, we say that the tempterature
		 * is synonymous with density (since smoke is *hot*) and because
		 * there are no other heat sources we can just use the density
		 * field instead of a new, seperate temperature field.
		 *
		 * @param Fbuoy Array to store buoyancy force for each cell.
		 **/
		public function buoyancy(Fbuoy:Array):void {
			var Tamb:Number = 0;
			var a:Number = 0.000625;
			var b:Number = 0.025;
			var i:int;
			var j:int;
			
			// sum all temperatures
			for (i = 1; i <= n; i++) {
				for (j = 1; j <= n; j++) {
					Tamb += d[I(i, j)];
				}
			}
			
			// get average temperature
			Tamb /= (n * n);
			
			// for each cell compute buoyancy force
			for (i = n; i >= 1; i--) {
				for (j = n; j >= 1; j--) {
					Fbuoy[I(i, j)] = a * d[I(i, j)] + -b * (d[I(i, j)] - Tamb);
				}
			}
		}
		
		/**
		 * Calculate the curl at position (i, j) in the fluid grid.
		 * Physically this represents the vortex strength at the
		 * cell. Computed as follows: w = (del x U) where U is the
		 * velocity vector at (i, j).
		 *
		 * @param i The x index of the cell.
		 * @param j The y index of the cell.
		 **/
		public function curlf(i:int, j:int):Number {
			var du_dy:Number = (u[I(i, j + 1)] - u[I(i, j - 1)]) * 0.5;
			var dv_dx:Number = (v[I(i + 1, j)] - v[I(i - 1, j)]) * 0.5;
			
			return du_dy - dv_dx;
		}
		
		/**
		 * Calculate the vorticity confinement force for each cell
		 * in the fluid grid. At a point (i,j), Fvc = N x w where
		 * w is the curl at (i,j) and N = del |w| / |del |w||.
		 * N is the vector pointing to the vortex center, hence we
		 * add force perpendicular to N.
		 *
		 * @param Fvc_x The array to store the x component of the
		 *        vorticity confinement force for each cell.
		 * @param Fvc_y The array to store the y component of the
		 *        vorticity confinement force for each cell.
		 **/
		public function vorticityConfinement(Fvc_x:Array, Fvc_y:Array):void {
			var dw_dx:Number;
			var dw_dy:Number;
			var length:Number;
			var v:Number;
			var i:int;
			var j:int;
			
			// Calculate magnitude of curlf(u,v) for each cell. (|w|)
			var  tt:Number;
			for (i = n; i >= 1; i--) {
				for (j = n; j >= 1; j--) {
					tt=curlf(i, j)
					curl[I(i, j)] = tt<0 ? tt*-1:tt;
				}
			}
			
			for (i = 2; i < n; i++) {
				for (j = 2; j < n; j++) {
					// Find derivative of the magnitude (n = del |w|)
					dw_dx = (curl[I(i + 1, j)] - curl[I(i - 1, j)]) * 0.5;
					dw_dy = (curl[I(i, j + 1)] - curl[I(i, j - 1)]) * 0.5;
					
					// Calculate vector length. (|n|)
					// Add small factor to prevent divide by zeros.
					length = Math.sqrt(dw_dx * dw_dx + dw_dy * dw_dy) + 0.000001;
					
					// N = ( n/|n| )
					dw_dx /= length;
					dw_dy /= length;
					
					v = curlf(i, j);
					
					// N x w
					Fvc_x[I(i, j)] = dw_dy * -v;
					Fvc_y[I(i, j)] = dw_dx *  v;
				}
			}
		}
		
		/**
		 * The basic velocity solving routine as described by Stam.
		 **/
		public function velocitySolver():void {
			var i:int;
			
			// add velocity that was input by mouse
			addSource(u, uOld);
			addSource(v, vOld);
			
			// add in vorticity confinement force
			vorticityConfinement(uOld, vOld);
			addSource(u, uOld);
			addSource(v, vOld);
			
			// add in buoyancy force
			buoyancy(vOld);
			addSource(v, vOld);
			
			// swapping arrays for economical mem use
			// and calculating diffusion in velocity.
			swapU();
			diffuse(1, u, uOld, visc);
			
			swapV();
			diffuse(2, v, vOld, visc);
			
			// we create an incompressible field
			// for more effective advection.
			project(u, v, uOld, vOld);
			
			swapU();
			swapV();
			
			// self advect velocities
			advect(1, u, uOld, uOld, vOld);
			advect(2, v, vOld, uOld, vOld);
			
			// make an incompressible field
			project(u, v, uOld, vOld);
			
			// clear all input velocities for next frame
			for (i = size-1; i >=0; i--) {
				uOld[i] = 0;
				vOld[i] = 0;
			}
		}
		
		/**
		 * The basic density solving routine.
		 **/
		public function densitySolver():void {
			var i:int;
			
			// add density inputted by mouse
			addSource(d, dOld);
			swapD();
			
			diffuse(0, d, dOld, diff);
			swapD();
			
			advect(0, d, dOld, u, v);
			
			// clear input density array for next frame
			for (i = size-1; i >= 0; i--) {
				dOld[i] = 0;
			}
		}
		
		private function addSource(x:Array, x0:Array):void {
			var i:int;
			for (i = size-1; i >=0; i--) {
				x[i] += dt * x0[i];
			}
		}
		
		/**
		 * Calculate the input array after advection. We start with an
		 * input array from the previous timestep and an and output array.
		 * For all grid cells we need to calculate for the next timestep,
		 * we trace the cell's center position backwards through the
		 * velocity field. Then we interpolate from the grid of the previous
		 * timestep and assign this value to the current grid cell.
		 *
		 * @param b Flag specifying how to handle boundries.
		 * @param d Array to store the advected field.
		 * @param d0 The array to advect.
		 * @param du The x component of the velocity field.
		 * @param dv The y component of the velocity field.
		 **/
		private function advect(b:int, d:Array, d0:Array, du:Array, dv:Array):void {
			var i:int;
			var j:int;
			
			var i0:int;
			var j0:int;
			var i1:int;
			var j1:int;
			
			var x:Number;
			var y:Number;
			var s0:Number;
			var t0:Number;
			var s1:Number;
			var t1:Number;
			var dt0:Number;
			
			dt0 = dt * n;
			
			for (i = n; i >= 1; i--) {
				for (j = n; j >= 1; j--) {
					// go backwards through velocity field
					x = i - dt0 * du[I(i, j)];
					y = j - dt0 * dv[I(i, j)];
					
					// interpolate results
					if (x > n + 0.5) {
						x = n + 0.5;
					}
					if (x < 0.5) {
						x = 0.5;
					}
					
					i0 = int(x);
					i1 = i0 + 1;
					
					if (y > n + 0.5) {
						y = n + 0.5;
					}
					if (y < 0.5) {
						y = 0.5;
					}
					
					j0 = int(y);
					j1 = j0 + 1;
					
					s1 = x - i0;
					s0 = 1 - s1;
					t1 = y - j0;
					t0 = 1 - t1;
					
					d[I(i, j)] = s0 * (t0 * d0[I(i0, j0)] + t1 * d0[I(i0, j1)]) + s1 * (t0 * d0[I(i1, j0)] + t1 * d0[I(i1, j1)]);
				}
			}
			setBoundry(b, d);
		}
		
		/**
		 * Recalculate the input array with diffusion effects.
		 * Here we consider a stable method of diffusion by
		 * finding the densities, which when diffused backward
		 * in time yield the same densities we started with.
		 * This is achieved through use of a linear solver to
		 * solve the sparse matrix built from this linear system.
		 *
		 * @param b Flag to specify how boundries should be handled.
		 * @param c The array to store the results of the diffusion
		 * computation.
		 * @param c0 The input array on which we should compute
		 * diffusion.
		 * @param diff The factor of diffusion.
		 **/
		private function diffuse(b:int, c:Array, c0:Array, diff:Number):void {
			var a:Number = dt * diff * n * n;
			linearSolver(b, c, c0, a, 1 + 4 * a);
		}
		/**
		 * Use project() to make the velocity a mass conserving,
		 * incompressible field. Achieved through a Hodge
		 * decomposition. First we calculate the divergence field
		 * of our velocity using the mean finite differnce approach,
		 * and apply the linear solver to compute the Poisson
		 * equation and obtain a "height" field. Now we subtract
		 * the gradient of this field to obtain our mass conserving
		 * velocity field.
		 *
		 * @param x The array in which the x component of our final
		 * velocity field is stored.
		 * @param y The array in which the y component of our final
		 * velocity field is stored.
		 * @param p A temporary array we can use in the computation.
		 * @param div Another temporary array we use to hold the
		 * velocity divergence field.
		 *
		 **/
		public function project(x:Array, y:Array, p:Array, div:Array):void {
			var i:int;
			var j:int;
			
			for (i = n; i >= 1; i--) {
				for (j = n; j >= 1; j--) {
					div[I(i, j)] = (x[I(i+1, j)] - x[I(i-1, j)] + y[I(i, j+1)] - y[I(i, j-1)]) * - 0.5 / n;
					p[I(i, j)] = 0;
				}
			}
			
			setBoundry(0, div);
			setBoundry(0, p);
			
			linearSolver(0, p, div, 1, 4);
			
			for (i = n; i >= 1; i--) {
				for (j = n; j >= 1; j--) {
					x[I(i, j)] -= 0.5 * n * (p[I(i+1, j)] - p[I(i-1, j)]);
					y[I(i, j)] -= 0.5 * n * (p[I(i, j+1)] - p[I(i, j-1)]);
				}
			}
			
			setBoundry(1, x);
			setBoundry(2, y);
		}
		
		/**
		 * Iterative linear system solver using the Gauss-sidel
		 * relaxation technique. Room for much improvement here...
		 *
		 **/
		public function linearSolver(b:int, x:Array, x0:Array, a:Number, c:Number):void {
			var k:int;
			var i:int;
			var j:int;
			
			for (k = 0; k < 4; k++) {
				for (i = n; i >= 1; i--) {
					for (j = n; j >= 1; j--) {
						x[I(i, j)] = (a * ( x[I(i-1, j)] + x[I(i+1, j)] + x[I(i, j-1)] + x[I(i, j+1)]) + x0[I(i, j)]) / c;
					}
				}
				setBoundry(b, x);
			}
		}
		
		// specifies simple boundry conditions.
		private function setBoundry(b:int, x:Array):void {
			var i:int;
			
			for (i = n; i >= 1; i--) {
				
				if(b==1) {
					x[I(  0, i  )] = -x[I(1, i)];
					x[I(n+1, i  )] = -x[I(n, i)];
				} else {
					x[I(  0, i  )] = x[I(1, i)];
					x[I(n+1, i  )] = x[I(n, i)];
				}
				
				if(b==2) {
					x[I(  i, 0  )] = -x[I(i, 1)];
					x[I(  i, n+1)] = -x[I(i, n)];
				} else {
					x[I(  i, 0  )] = x[I(i, 1)];
					x[I(  i, n+1)] = x[I(i, n)];
				}
			}
			
			x[I(  0,   0)] = 0.5 * (x[I(1, 0  )] + x[I(  0, 1)]);
			x[I(  0, n+1)] = 0.5 * (x[I(1, n+1)] + x[I(  0, n)]);
			x[I(n+1,   0)] = 0.5 * (x[I(n, 0  )] + x[I(n+1, 1)]);
			x[I(n+1, n+1)] = 0.5 * (x[I(n, n+1)] + x[I(n+1, n)]);
		}
		
		// util array swapping methods
		public function swapU():void {
			tmp = u;
			u = uOld;
			uOld = tmp;
		}
		
		public function swapV():void {
			tmp = v;
			v = vOld;
			vOld = tmp;
		}
		
		public function swapD():void {
			tmp = d;
			d = dOld;
			dOld = tmp;
		}
		
		// util method for indexing 1d arrays
		private function I(i:uint, j:uint):uint {
			return i + (n + 2) * j;
		}
	}
}


