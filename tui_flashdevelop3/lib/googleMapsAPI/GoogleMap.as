package googleMapsAPI
{
	import flash.display.*;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.printing.*;
	import flash.geom.*;
	
	import org.tuio.*;
	
	import googleMapsAPI.*;
	
	import com.google.maps.*;
	import com.google.maps.controls.*;
	import com.google.maps.overlays.*;
	
	/**
	 * @author Gonçalo Amador
	 */
	public class GoogleMap
	{
		private var map:Map;
		private var _stage:Stage;
		
		public function GoogleMap(stage:Stage = null):void {
			_stage = stage;
			
			/* Create an instance of the Map Class */
			trace("Create an instance of the Map Class.");
			map = new Map;
			
			/* Insert key */
			trace("Insert key.");
			map.key = "ABQIAAAA1OrOdW7RZQu1yFR29RLoXRT2yXp_ZAY8_ufC3CFXhHIE1NvwkxQjbIpx8ZYn994OyfO5vSUlLhFa4Q";
			
			/* Insert url */
			trace("Insert url.");
			map.url = "127.0.0.1";
			
			/* Set GPS sensor enabled off */
			trace("Set GPS sensor enabled off.");
			map.sensor = "false";
			
			/* Add Google Map controls */
			trace("Add Google Map controls.");
			map.addControl(new ZoomControl);
			map.addControl(new ScaleControl);
			map.addControl(new MapTypeControl);
			
			/* Add Google Map to the stage */
			trace("Add Google Map to the stage.");
			_stage.addChild(map);
			
			/* Add Google Map event listeners */
			trace("Add Google Map event listeners.");
			map.addEventListener(MapEvent.MAP_READY, mapOk);	
			map.addEventListener(TransformGestureEvent.GESTURE_PAN, pan);
			map.addEventListener(TransformGestureEvent.GESTURE_ZOOM, zoomInOut);
			map.addEventListener(TouchEvent.DOUBLE_TAP, mapType);
			
		}
		
		private function mapType(e:TouchEvent):void {
			//trace("touch tap google map.");
			switch (map.getCurrentMapType()) {
				case MapType.NORMAL_MAP_TYPE:
					map.setMapType(MapType.SATELLITE_MAP_TYPE);
					break;
				case MapType.SATELLITE_MAP_TYPE:
					map.setMapType(MapType.HYBRID_MAP_TYPE);
					break;
				case MapType.HYBRID_MAP_TYPE:
					map.setMapType(MapType.PHYSICAL_MAP_TYPE);
					break;
				case MapType.PHYSICAL_MAP_TYPE:
					map.setMapType(MapType.NORMAL_MAP_TYPE);
					break;
			}
		}
		
		private function zoomInOut(e:TransformGestureEvent):void {
			//trace("zoom gesture google map.");
			map.setZoom(map.getZoom() - e.scaleX, true);
		}
		
		private function pan(e:TransformGestureEvent):void {
			//trace("move gesture google map.");
			map.panBy(new Point(e.offsetX, e.offsetY));
		}
		
		private function mapOk(event:MapEvent):void {
			/* Create an instance of the marker class and 
			/* Pass the site to mark on the Google Map longitude and latitude */
			trace("Create an instance of the marker class and Pass the site to mark on the Google Map longitude and latitude.");
			var marker:Marker = new Marker(new LatLng( -23.5635963, -46.6538854));
			
			/* Add the Mark to the Google Map */
			trace("Add the Mark to the Google Map.");
			map.addOverlay(marker);
			
			/* Center the map in a specific position */
			trace("Center the map in a specific position.");
			map.setCenter(new LatLng( -23.5635963, -46.6538854), 16, MapType.NORMAL_MAP_TYPE);

			/* Enable Google Map zoom using mouse scrool and keyboard control */
			trace("Enable Google Map zoom using mouse scrool and keyboard control.");
			map.enableScrollWheelZoom();
			map.enableControlByKeyboard();
		}
	}
}