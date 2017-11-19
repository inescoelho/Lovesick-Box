package  {
	
	import flash.display.MovieClip;
	
	
	public class HeroF extends Hero {
		
	
		
		public function HeroF(cordX:int, cordY:int) {
			// constructor code
			super(cordX, cordY);
			scale = 0.8;			// tem uma escala diferente do heroM (0.7) (para ajustar o seu tamanho)
		}

		public override function leftSide():Number { return this.x - 14; }		// possui uma largura diferente do heroM
		public override function rightSide():Number { return this.x + 14; }
		
	}
	
}
