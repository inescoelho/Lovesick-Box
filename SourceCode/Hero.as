package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	
	public class Hero extends MovieClip {
		var moveLeft: Boolean;
		var moveRight: Boolean;
		var jump: Boolean;			// se a personagem esta a saltar
		var push: Boolean;			// se a personagem esta a empurrar a caixa
		var jumpSpeed: Number;		// velocidade de salto
		var walkSpeed: Number;		// velocidade a andar
		var pushSpeed: Number;		// velocidade a empurrar a caixa
		var dy: Number;				// velocidade de queda
		var passTime : Number;		// para controlar a animacao por tempo
		var animstate: String;		// tipo posicao da personagem
		var inAir: Boolean;			// se esta no ar
		var scale: Number;
		var walkAnimation: Array;	// frames que possuem a animacao de caminhar
		var pushAnimation: Array;	// frames que possuem a animacao de empurrar
		var animstep: int;			// frame corrente da animacao
		var dir: int;				// direcao 1: direita -1: esquerda
		var fallDist: Number;		// distancia de queda
		var inFall: Boolean;		// em queda
		var newX: Number;			// novas coordenadas x e y
		var newY: Number;
		var die: Boolean;			// se morreu
		var lever: Boolean;			// se acionou a alavanca
		var stepTimer: Number;		// para controlar o ritmo dos efeitos sonoros a caminhar e a empurrar a caixa
		var pushTimer: Number;
		var destructivel: Boolean;	// se vai ser retirado do jogo (destruido pela alavanca)
		var canSwitch: Boolean;		// se pode ser alternado com a outra personagem
		
		
		public function Hero(cordX:int, cordY:int) {
			moveLeft = false;
			moveRight = false;
			jump = false;
			push = false;
			dy = 0;
			passTime = 0;
			jumpSpeed = 0;
			walkSpeed = 0.15;	//0.15
			pushSpeed = 0.08;
			animstate = "stand";
			inAir = false;
			scale = 0.7;
			walkAnimation = new Array(1,2,3,4,5,6);
			pushAnimation = new Array(8,9,10,11,12,13);
			animstep = 7;	// 7: stand
			dir = 1;
			fallDist = 0;
			inFall = true;
			newX = cordX;
			newY = cordY;
			die = false;
			lever = false;
			stepTimer = 0;
			pushTimer = 0;
			destructivel = false;
			canSwitch = true;
		}
		
		public function topSide():Number { return this.y - this.height; }
		public function bottomSide():Number { return this.y; }
		public function leftSide():Number { return this.x - 16; }
		public function rightSide():Number { return this.x + 16; }
	}
	
}
