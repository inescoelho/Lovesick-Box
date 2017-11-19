package  {
	
	import flash.display.MovieClip;
	
	
	public class Plataforma extends MovieClip {
		var dy: Number;				// velocidade de queda
		var passTime: Number;		// para controlar a movimentacao pelo tempo
		var destructive: Boolean;	// se e' um elemento para ser retirado do jogo
		
		public function Plataforma() {
			dy = 0;
			passTime = 0;
			destructive = false;
		}
		
		public function topSide():Number { return this.y; }
		public function bottomSide():Number { return this.y + this.height; }
		public function leftSide():Number { return this.x; }
		public function rightSide():Number { return this.x + width; }
	}
	
}
