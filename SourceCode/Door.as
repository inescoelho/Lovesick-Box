package  {
	
	import flash.display.MovieClip;
	
	
	public class Door extends MovieClip {
		var bothHeroes: Boolean;	// informa se as duas personagens tem de chegar 'a porta
		var heroM: Boolean;
		var heroF: Boolean;
		
		public function Door() {
			bothHeroes = false;
			heroM = false;
			heroF = false;
		}
	}
	
}
