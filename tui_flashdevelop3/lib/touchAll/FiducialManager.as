package touchAll
{
	import flash.display.*;
	import flash.geom.Rectangle;
	
	import org.tuio.fiducial.*;
	
	import touchAll.piano.Piano;
	import touchAll.keyboard.CustomKeyboard;
	import touchAll.pong.cl.kirill.PongGame;
	
	/**
	 * ...
	 * @author Gonçalo Amador
	 */
	public class FiducialManager implements IDefault
	{
		private var _keyboard:CustomKeyboard;
		private var _pongGame:PongGame;
		private var _piano:Piano;
		private var _stage:Stage;
		private var _textColor:uint;
		private var _buttonColor:uint;
		private var _buttonTextColor:uint;
		private var _buttonOnColor:uint;
		private var _buttonOffColor:uint;
		private var _borderColor:uint;
		private var _white_keys_color:uint;
		
		public function FiducialManager(stage:Stage = null, textColor:uint = 0x8B8B8B, buttonColor:uint = 0x000000, buttonTextColor:uint = 0xFFFFFF, 
			buttonColorOn:uint = 0xBB0000, buttonColorOff:uint = 0x330000, borderColor:uint = 0x000000, white_keys_color:uint = 0xFEFEFE) {
			_stage = stage;
			
			_textColor = textColor;
			_buttonColor = buttonColor;
			_buttonTextColor = buttonTextColor;
			_buttonOnColor = buttonColorOn;
			_buttonOffColor = buttonColorOff;
			_borderColor = borderColor;
			_white_keys_color = white_keys_color;
		}
		
		/** 
		 * stage event listeners set up 
		 */
		public function stageEventListenersLoader():void {
			/* add stage Fiducial (object) event listeners */
			trace("add stage fiducial event listeners.");
			_stage.addEventListener(FiducialEvent.ADD, fiducialADD);
			_stage.addEventListener(FiducialEvent.MOVE, fiducialUPDATE);
			_stage.addEventListener(FiducialEvent.REMOVED, fiducialREMOVE);
		}
		
		/**
		 * background event listener set up
		 */ 
		public function backgroundEventListenersLoader():void {
			trace("backgroundEventListenersLoader.");
		}
		
		/* FIDUCIAL FUNCTIONS */
		/**
		 * handle fiducial (Object) add events
		 */
		public function fiducialADD(e:FiducialEvent):void {
			// debug mode console message if FiducialEvent.ADD event captured
			trace("Fiducial #" + e.fiducialId + " fiducial added.");
			
			if (e.fiducialId == 0)
			{					
				/* alternative 1: load keyboard class */
				_keyboard = new CustomKeyboard(e.x, e.y, 718, 200, e.x, e.y + 220, _buttonTextColor, _buttonColor, _borderColor); 
				//_keyboard.filters = [new GlowFilter(0x0055ff, .75, 100, 100, 2, 2, false, false)];
				
				_stage.addChild(_keyboard);
				
				/* alternative 2: load the content of *.swf file */
				//var _objectLoader:Loader = new Loader;
				//_objectLoader.load(new URLRequest("CustomKeyboard.swf"));
				//_stage.addChild(_objectLoader);
			}
			
			if (e.fiducialId == 1)
			{					
				_pongGame = new PongGame(_stage, _borderColor);
				_pongGame.x = e.x;
				_pongGame.y = e.y;
				_stage.addChild(_pongGame);
			}
			
			if (e.fiducialId == 2)
			{	
				_piano = new Piano(_textColor, _buttonTextColor, _buttonOnColor, _buttonOffColor, _white_keys_color);  
				//_piano = new Piano();
				_piano.x = e.x;
				_piano.y = e.y;
				_piano.rotation = 90;
				_piano.scaleX = 2;
				_piano.scaleY = 2;
				_stage.addChild(_piano);
			}
		}
		
		/**
		 * handle fiducial (Object) remove events
		 */
		public function fiducialREMOVE(e:FiducialEvent):void {
			trace("Fiducial #" + e.fiducialId + " fiducial removed.");
			
			if (e.fiducialId == 0)
			{
				/* alternative 1: remove keyboard class from stage */
				_stage.removeChild(_keyboard);
				
				/* alternative 2: remove loaded *.swf file from stage */
				//_stage.removeChild(_objectLoader);
			}			
			
			if (e.fiducialId == 1)
			{					
				_pongGame.stopGame();
				_stage.removeChild(_pongGame);
			}
			
			if (e.fiducialId == 2)
			{					
				_stage.removeChild(_piano);
			}
		}
		
		/**
		 * handle fiducial (Object) move events
		 */
		public function fiducialUPDATE(e:FiducialEvent):void {
			trace("Fiducial #" + e.fiducialId + " fiducial move.");
			
			if (e.fiducialId == 0) {
				_keyboard.update(e.x, e.y, e.x, e.y + 220);	
			}
			
			if (e.fiducialId == 1) {
				_pongGame.x = e.x;
				_pongGame.y = e.y;
			}
			
			if (e.fiducialId == 2)
			{					
				_piano.x = e.x;
				_piano.y = e.y;
			}
		}
	}
	
}