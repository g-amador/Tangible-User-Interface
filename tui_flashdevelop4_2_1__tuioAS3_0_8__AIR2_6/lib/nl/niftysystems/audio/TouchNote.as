package nl.niftysystems.audio
{
	import org.tuio.TuioCursor;

	public class TouchNote
	{
		public var tuioCursor:TuioCursor;
		public var index:int;
		
		public function TouchNote(tuioCursor:TuioCursor, index:int)
		{
			this.index = index;
			this.tuioCursor = tuioCursor;
		}
	}
}