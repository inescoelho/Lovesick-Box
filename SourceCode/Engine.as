// O codigo para movimentacao da personagem do jogo, colisao com as plataformas e para a sua animacao por frames foi baseado
// no codigo do livro "ActionScript 3.0 Game Programming University" de "Gary Rosenzweig's"

package  {
	import flash.display.*;
	import flash.events.*;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.*;
	import flash.media.SoundTransform;
	
	public class Engine extends MovieClip {
		
		var hero: Hero;
		var fallObjects: Array;
		var gravity:Number = .00003;  	// 0.00003 Define a aceleração da gravidade
		var lastTime:Number = 0;		// contador de tempo e diferenca de tempo
		var timeDiff: int = 0;			// para realizar as animacoes baseadas em tempo
		var fixedObjects: Array;		// plataformas fixas
		var dynamicObjects: Array;		// objectos interativos
		var boxes: Array;				// caixas existentes no cenario
		var heros: Array;				// personagens do jogo
		var scenario: Scenario;			// instancia da classe que carrega o nivel
		var stag: Stage;
		var level: int;
		public var LEVEL_UP:String = "Level up";	//evento gerado sempre que se passa de nivel
		var stepSound: Step;			// para controlar o ritmo a que
		var pushSound: Push;			// reproduz o som de andar e empurrar
		var leverSound: LeverSound;
		var explosionSound: Explosion;	// diversos efeitos de som do jogo
		var levelUpSound: Checkpoint;
		var landSound: Land;
		var dieSound: DieSound;
		var switchSound: Switch;
		var init: Boolean; 				// auxiliar usada para controlar a queda da personagem
		var soundOn: Boolean;			
		
		// Inicia o motor de jogo
		public function startEngine(level:int,stg:Stage) {
			this.level = level;
			stag = stg;
			scenario = new Scenario();
			scenario.initScenario(stag);
			scenario.readLevel(level);
			fixedObjects = new Array();
			dynamicObjects = new Array();
			fallObjects = new Array();
			boxes = new Array();
			heros = new Array();
			stepSound = new Step();
			pushSound = new Push();
			leverSound = new LeverSound();
			explosionSound = new Explosion();
			levelUpSound = new Checkpoint();
			landSound = new Land();
			dieSound = new DieSound();
			switchSound = new Switch();
			init = false;
			soundOn = true;
			
			stag.focus = stag;
			scenario.addEventListener(scenario.READ_DONE, getObjects);	// listener para controlar se o scenario terminou de carregar o nivel
			stag.addEventListener(KeyboardEvent.KEY_UP, keyPressedUp);
			stag.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedDown);
		}

		// carrega os objectos do jogo para os respectivos arrays
		function getObjects(e: Event) {
			
			heros = scenario.getHeros();
			if(heros[0])
				hero = heros[0];
			else
				hero = heros[1];
				
			if (heros[1])
				heros[1].gotoAndStop(7);	// inicialmente o heroF nao esta a ser controlado e fica na posicao "stand"
			hero.fallDist = 0;				// distancia de queda
			fixedObjects = scenario.getFixedObjects();
			boxes = scenario.getBoxes();
			dynamicObjects = scenario.getDynamicObjects();
			addEventListener(Event.ENTER_FRAME, playGame);	// listener principal para chamar o metodo playgame
															// para actualizar todos os acontecimentos no jogo
		}

		// Escuta o evento gerado por uma tecla premida
		function keyPressedDown(e:KeyboardEvent)
			{
				// Para o caso do hero
				if (e.keyCode == 37)	// seta para a esquerda
					hero.moveLeft = true;
				else if (e.keyCode == 39)	// seta para a direita
					hero.moveRight = true;
				else if (e.keyCode == 38) {	// seta para cima
					if (!hero.inAir)
						hero.jump = true;
				}
				if (e.keyCode == 40) 	// seta para baixo (aciona a alavanca)
					hero.lever = true;

				if (e.keyCode == 65 && hero.y == hero.newY && hero.canSwitch) {	// tecla "A" para alternar entre personagem
					switchHero();
				}
				
			}

			// Escuta o evento gerado por uma tecla solta
			function keyPressedUp(e:KeyboardEvent)
			{
				// Para o caso do hero
				if (e.keyCode == 37)
					hero.moveLeft = false;
				else if (e.keyCode == 39)
					hero.moveRight = false;	
			}
		
		// Metodo responsavel por actualizar todos os acontecimentos no jogo
		public function playGame(e: Event) {
			if (lastTime == 0) 
				lastTime = getTimer();
			var timeDiff:int = getTimer()-lastTime;
			lastTime += timeDiff;

			moveHero(timeDiff);			// metodo para as movimentações do hero
			checkInteration();			// metodo para verificar as interações do hero e da box
			moveBox(timeDiff);			// metodo para as movimentações da box
			moveFallObjects(timeDiff);	// metodo para movimentar os fall objects
		}

		// Metodo para movimentacao do hero
		public function moveHero(timeDiff: Number) {
			if (timeDiff < 1) return;
			
			hero.inFall = true;		// Considera que inicialmente o hero esta em queda
			var speed: Number = hero.walkSpeed;
			hero.animstate = "stand";
			// o hero morre caso a queda seja maior que 120px
			if (hero.fallDist > 120) {
				if (!hero.die) {
					hero.die = true;
					if (soundOn)
						dieSound.play();
				}
				// remove os listeners do eventos 'a estuda (caso ainda existam) para terminar o jogo
				if (stag.hasEventListener(KeyboardEvent.KEY_DOWN)) {
					stag.removeEventListener(KeyboardEvent.KEY_UP, keyPressedUp);
					stag.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressedDown);
				}
			}
			// reduz a velocidade do hero caso esteja a empurra a box
			if (hero.push)
					speed = hero.pushSpeed;
			// para controlar o ritmo a que e' reproduzido o som
			if (soundOn) {
				hero.stepTimer += timeDiff;
				hero.pushTimer += timeDiff;
			}
			
			// Movimenta o hero para a esquerda
			if (hero.moveLeft) {
				hero.newX = hero.x - speed * timeDiff;
				hero.animstate = "walk";
			}
			
			// Movimenta o hero para a direita
			else if (hero.moveRight) {
				hero.newX = hero.x + speed * timeDiff;
				hero.animstate = "walk";
			}

			
			// Reproduz o som dos passos
			if (soundOn) {
				if (hero.animstate == "walk") {
					if (hero.stepTimer > 400) {
						stepSound.play();
						hero.stepTimer = 0;
					}
				}
			}
			
			// Inicia os parametros para o salto do hero
			if (hero.jump) {
				hero.jump = false;
				hero.passTime = 0;
				hero.jumpSpeed = 0.05;
				hero.dy = -hero.jumpSpeed;
				hero.animstate = "jump";
				hero.inAir = true;
			}
			// define a animacao do boneco a empurrar
			if (hero.push && (hero.moveLeft || hero.moveRight))
				hero.animstate = "push";
				
			// Reproduz o som de empurrar a caixa
			if (soundOn) {
				if (hero.animstate == "push") {
					if (hero.pushTimer > 350) {	// reproduz o som caso a ultima vez tenha sido a mais de 350ms
						pushSound.play();	
						hero.pushTimer = 0;
					}
				}
			}

			// calcula as posicoes de y do hero a saltar ou em queda
			hero.passTime += timeDiff;
			hero.newY +=  hero.dy * hero.passTime;		// newY : nova coordenada Y da personagem
			hero.dy = hero.dy + gravity * hero.passTime;
			if (hero.dy > .05)	hero.dy = .05;		// 0.05 para limitar a velocidade maxima na queda devido ao atrito do ar

			if (hero.inFall) {		// contabiliza a distancia que o hero cai
				if (init == true)	// no inicio do jogo a distancia que caiu e' zero
					hero.fallDist += hero.dy * hero.passTime;
				else {
					hero.fallDist = 0;
					init = true;
				}
			}
			// se o hero esta no ar, tem a animacao de saltar
			if (hero.inAir) {
				hero.animstate = "jump";
			}
			// controlo das frames a mostrar conforme o estado do hero
			if (hero.animstate == "walk") {
				hero.animstep += Math.round(timeDiff/49);			// 49: valor para definir a velocidade entre frames
				if (hero.animstep >= hero.walkAnimation.length) {
					hero.animstep = 0;
				}
				hero.gotoAndStop(hero.walkAnimation[Math.floor(hero.animstep)]);	// vai para a respectiva frame
			}
			
			else if (hero.animstate == "push") {
				hero.animstep += Math.round(timeDiff/50);
				if (hero.animstep >= hero.pushAnimation.length) {
					hero.animstep = 0;
				}
				hero.gotoAndStop(hero.pushAnimation[Math.floor(hero.animstep)]);
			} 
			else {
				hero.gotoAndStop(hero.animstate);
			}
			// define o tamanho e a direcao do hero conforme a sua movimentacao
			if (hero.moveLeft && hero.dir == 1) {
				hero.scaleX = -0.7;
				hero.dir = -1;
			}
			else if (hero.moveRight && hero.dir == -1) {
				hero.scaleX = 0.7;
				hero.dir = 1;
			}
			
		}


		// Para verificar colisoes e interagir com os objectos do jogo
		public function checkInteration() {
			var i,j:int;

				// Verifica se o hero aterrou num objecto fixo (plataforma)
				for (i = 0; i < fixedObjects.length; i++) {
					if (fixedObjects[i])
						if ((hero.x+hero.width/2 > fixedObjects[i].leftSide()) && (hero.x-hero.width/2 < fixedObjects[i].rightSide())) {
							if ((hero.y <= fixedObjects[i].topSide()) && (hero.newY > fixedObjects[i].topSide())) {
								if (soundOn)
									playLandSound(hero);
								hero.newY = fixedObjects[i].topSide();	// actualiza a posicao da personagem
								hero.dy = 0;							// velocidade de queda
								hero.inAir = false;
								hero.inFall = false;
								hero.passTime = 0;
								hero.fallDist = 0;						// distancia de queda
								break;
							}
						}
				}

				// Verifica se a box aterrou num objecto fixo (plataforma)
				for (i = 0; i < fixedObjects.length; i++) {
					if (fixedObjects[i])
						for (j = 0; j < boxes.length; j++) {
							if ((boxes[j].x+boxes[j].width/2 > fixedObjects[i].leftSide()) && (boxes[j].x-boxes[j].width/2 < fixedObjects[i].rightSide())) {
								if ((boxes[j].y <= fixedObjects[i].topSide()) && (boxes[j].newY > fixedObjects[i].topSide())) {
									if (soundOn)
										playLandSound(boxes[j]);
									boxes[j].newY = fixedObjects[i].topSide();
									boxes[j].dy = 0;
									boxes[j].passTime = 0;
									break;
								}
							}
						}
				}
				
				
				// Verifica se os fallObjects sairam da ára de jogo e remove-os
				for (j = 0; j < fallObjects.length; j++) {
					if (fallObjects[j])
						if (fallObjects[j].y > 400) {
							fallObjects[j].parent.removeChild(fallObjects[j]);
							fallObjects.splice(j, 1);	// remove esse elemento do array
						}	
				}
				
				
				// Verifica se a box aterrou noutra box
				for(i=0;i<boxes.length;i++) {
					for(j=0;j<boxes.length;j++) {
						if ((boxes[j].x+boxes[j].width/2 > boxes[i].leftSide()) && (boxes[j].x-boxes[j].width/2 < boxes[i].rightSide())) {
							if ((boxes[j].y <= boxes[i].topSide()) && (boxes[j].newY > boxes[i].topSide())) {
								if (soundOn)
									playLandSound(boxes[j]);
								boxes[j].newY = boxes[i].topSide();
								// a caixa que esta em cima recebe as caracteristicas da caixa de baixo para se movimentar
								if(boxes[j].y < boxes[i].y) {
									boxes[j].moveWithRight = boxes[i].moveRight;
									boxes[j].moveWithLeft = boxes[i].moveLeft;
								}
								else if (boxes[i].y < boxes[j].y) {
									boxes[i].moveWithRight = boxes[j].moveRight;
									boxes[i].moveWithLeft = boxes[j].moveLeft;
								}
								boxes[j].dy = 0;
								boxes[j].passTime = 0;
								break;
							}
						}
					}
				}
				
				
				
			// verifica se o hero bate numa parede
			for (i = 0; i < fixedObjects.length; i++) {
				if (fixedObjects[i])
					if ((hero.newY > fixedObjects[i].topSide()) && (hero.newY-hero.height < fixedObjects[i].bottomSide())) {
						if ((hero.x-hero.width/2 >= fixedObjects[i].rightSide()) && (hero.newX-hero.width/2 <= fixedObjects[i].rightSide())) {
							hero.newX = fixedObjects[i].rightSide() + hero.width / 2 + 2;
							break;
						}
						if ((hero.x+hero.width/2 <= fixedObjects[i].leftSide()) && (hero.newX+hero.width/2 >= fixedObjects[i].leftSide())) {
							hero.newX = fixedObjects[i].leftSide() - hero.width / 2 - 2;
							break;
						}
					}
			}
			
			// verifica se a box bate numa parede
			for(i=0;i<fixedObjects.length;i++) {
				if (fixedObjects[i])
					for (j = 0; j < boxes.length; j++) {
				/**/	if ((boxes[j] && boxes[j].newY > fixedObjects[i].topSide() +2) && (boxes[j].newY < fixedObjects[i].bottomSide() +2)) {
							// esquerda
							if ((boxes[j].x-boxes[j].width/2 >= fixedObjects[i].rightSide()) && (boxes[j].newX-boxes[j].width/2 <= fixedObjects[i].rightSide())) {
								boxes[j].newX = fixedObjects[i].rightSide() + boxes[j].width / 2 + 2;
								if (hero.dir == -1)
									hero.newX = fixedObjects[i].rightSide() + boxes[j].width + hero.width / 2 + 2;
								if (!fixedObjects[i].destructive)
									fixedObjects.push(boxes.splice(j, 1)[0]);	// transforma a box num objecto fixo
								break;
							}
							// direita
							if ((boxes[j] && boxes[j].x+boxes[j].width/2 <= fixedObjects[i].leftSide()) && (boxes[j].newX+boxes[j].width/2 >= fixedObjects[i].leftSide())) {
								boxes[j].newX = fixedObjects[i].leftSide() - boxes[j].width / 2 - 2;
								if (hero.dir == 1)
									hero.newX = fixedObjects[i].leftSide() - boxes[j].width -hero.width / 2-2;
								if (!fixedObjects[i].destructive)
									fixedObjects.push(boxes.splice(j, 1)[0]);	// transforma a box num objecto fixo
								break;
							}
						}
					}
			}
			
			// Verifica se o hero bate por baixo de um objecto fixo
			for (i = 0; i < fixedObjects.length; i++) {
				if (fixedObjects[i])
					if ((hero.x+hero.width/2 > fixedObjects[i].leftSide()) && (hero.x-hero.width/2 < fixedObjects[i].rightSide())) {
						if ((hero.topSide() > fixedObjects[i].bottomSide()) && (hero.newY-hero.height < fixedObjects[i].bottomSide())) {
							hero.dy = 0.01
							break;
						}
					}
			}
			
			
			// Verifica se o hero aterra na box
			for(i=0; i<boxes.length; i++) {
				if ((hero.x+hero.width/2 > boxes[i].leftSide()) && (hero.x-hero.width/2 < boxes[i].rightSide())) {
					if ((hero.y <= boxes[i].topSide()) && (hero.newY > boxes[i].topSide())) {
						if (soundOn)
							playLandSound(hero);
						hero.newY = boxes[i].topSide();
						hero.dy = 0;
						hero.inAir = false;
						hero.inFall = false;
						hero.passTime = 0;
						hero.fallDist = 0;
						break;
					}
				}
			}
			
			hero.push = false;
			// Verifica se o hero empurra a box
			for (i = 0; i < boxes.length; i++) {
				boxes[i].moveLeft = boxes[i].moveRight = false;
		/**/	if (hero.bottomSide() > boxes[i].topSide() +2 && hero.topSide() < boxes[i].topSide()) {
					// direita
					if (hero.rightSide() > boxes[i].leftSide() && hero.rightSide() < boxes[i].rightSide()) {
						boxes[i].moveRight = true;
						hero.push = true;
					}
					// esquerda
					if (hero.leftSide() < boxes[i].rightSide() && hero.leftSide() > boxes[i].leftSide()) {
						boxes[i].moveLeft = true;
						hero.push = true;
					}
				}
			}
			
			// verifica se a box bate noutra box
			for(i=0;i<boxes.length;i++) {
				for(j=0;j<boxes.length;j++) {
			/**/	if ((boxes[j].newY > boxes[i].topSide() +2) && (boxes[j].newY < boxes[i].bottomSide() +2)) {
						// direita
						if ((boxes[j].x+boxes[j].width/2 <= boxes[i].leftSide()) && (boxes[j].newX+boxes[j].width/2 >= boxes[i].leftSide())) {
							boxes[j].newX = boxes[i].leftSide() - boxes[j].width / 2;
							if (hero.dir == 1 && hero.x < boxes[j].x && hero.push)
								hero.newX = boxes[j].leftSide() - hero.width / 2-2;
							fixedObjects.push(boxes.splice(j, 1)[0]);	// transforma a box num objecto fixo
							if (j < i)
								i--;
							fixedObjects.push(boxes.splice(i, 1)[0]);	// transforma tambem a outra box num objecto fixo
							break;
						}
						// esquerda
						if ((boxes[j].x-boxes[j].width/2 >= boxes[i].rightSide()) && (boxes[j].newX-boxes[j].width/2 <= boxes[i].rightSide())) {
							boxes[j].newX = boxes[i].rightSide() + boxes[j].width / 2;
							if (hero.dir == -1 && hero.x > boxes[j].x && hero.push)
								hero.newX = boxes[j].rightSide() + hero.width / 2+2;
							fixedObjects.push(boxes.splice(j, 1)[0]);
							if (j < i)		// se a box j esta no array 'a esquerda da box i
								i--;		// actualiza o indice
							fixedObjects.push(boxes.splice(i, 1)[0]);	// remove a box das boxes e adiciona-a aos objectos fixos
							break;
						}
					}
				}
			}
			
			// Verifica a interacao do hero com os objectos dinamicos (porta, picos, alavanca)
			for (i = 0; i < dynamicObjects.length; i++) {
				if (dynamicObjects[i] is Door) {
					if (hero.topSide() > dynamicObjects[i].y - dynamicObjects[i].height && hero.topSide() < dynamicObjects[i].y)
						if (hero.x > dynamicObjects[i].x+10 && hero.x < dynamicObjects[i].x + 32 && !hero.die) {
							if (dynamicObjects[i].bothHeroes) {		// se e' necessario as duas personagens chegarem 'a porta
								if (hero == heros[0]) {				// se o heroM chegou 'a porta
									dynamicObjects[i].heroM = true;
									hero.gotoAndStop(7);			// coloca-o na posicao "stand"
									switchHero();					// troca de personagem
									hero.canSwitch = false;			// impede que se volte a alternar de personagem
								}
								else if (hero == heros[1]) {
									dynamicObjects[i].heroF = true;
									hero.gotoAndStop(7);
									switchHero();
									hero.canSwitch = false;
								}
								if (dynamicObjects[i].heroM && dynamicObjects[i].heroF) {	// se as duas personagens chegaram 'a porta
									dispatchEvent(new Event(LEVEL_UP));						// gera evento para passar para o nivel seguinte
								}
							}
							else {
								dispatchEvent(new Event(LEVEL_UP));			// caso apenas seja necessario que uma personagem chegue 'a porta
							}
							if (soundOn)
								levelUpSound.play();
						}
				}
				else if (dynamicObjects[i] is Spike) {					// picos
					if (dynamicObjects[i].hitTestObject(hero)) {
						if (!hero.die) {								// mata a personagem
							hero.die = true;
							if (soundOn) {
								playLandSound(hero);
								dieSound.play();
							}
						}
					}
				}
				else if (dynamicObjects[i] is Lever) {					// alavanca
					if (dynamicObjects[i].hitTestObject(hero) && hero.lever) {	// se a personagem acionou a alavanca e esta junto a ela
						dynamicObjects[i].gotoAndStop(2);
						if (scenario.extraLevel == 2) {			// caso seja um nivel do tipo D (nivel extra 2)
							if (soundOn)
								leverSound.play();
						}
						else {
							if (soundOn)
								explosionSound.play();
							if (heros[1] && !heros[1].destructivel)		// se o heroF nao for para remover
								switchHero();							// troca de personagem
							for (j = fixedObjects.length - 1; j >= 0; j--) {
								if (fixedObjects[j].destructive) {			// remove os elementos destrutiveis do cenario
									fallObjects.push(fixedObjects[j]);		// adiciona os elementos a remover aos fallObjects
									fallObjects[fallObjects.length - 1].passTime = 0;
									fixedObjects.splice(j, 1);
								}
							}
						}
						if (heros[1] && heros[1].destructivel) {		// se o heroF for para remover, adiciona-o aos fallObjects
							fallObjects.push(heros[1]);
							fallObjects[fallObjects.length - 1].passTime = 0;
							heros[1] = null;							// o heroF deixa de existir
						}
						if (scenario.extraLevel == 2)					// se for um nivel extra tipo 2, passa para o nivel seguinte
							dispatchEvent(new Event(LEVEL_UP));
						dynamicObjects.splice(i, 1);					// desactiva a alavanca
					}
				}
			}
			
			// Caso o hero tenha aterrado numa plataforma mas morrido, termina o jogo
			if (hero.die == true && hero.inFall == false) {
				hero.alpha -= 0.1;
				if (hero.alpha <= 0)
					stopGame();
			}	
			
			// Actualiza as posicoes do hero e das boxes
			hero.y = hero.newY;
			hero.x = hero.newX;
			for (i = 0; i < boxes.length; i++) {
				boxes[i].x = boxes[i].newX;	
				boxes[i].y = boxes[i].newY;
			}
		}
		
		// metodo responsavel por movimentar as caixas do jogo
		public function moveBox(timeDiff: Number) {
			var i:int;
			
			// Caso o hero empurre a box, esta acompanha o movimento do hero
			for (i = 0; i < boxes.length; i++) {
				if (boxes[i].moveRight && hero.dir == 1 || boxes[i].moveWithRight && hero.dir == 1)
					boxes[i].newX = hero.rightSide() + boxes[i].width / 2;
				else if (boxes[i].moveLeft && hero.dir == -1 || boxes[i].moveWithLeft && hero.dir == -1)
					boxes[i].newX = hero.leftSide() - boxes[i].width / 2;
				
				// calcula as posicoes de y da box em queda
				boxes[i].passTime += timeDiff;
				boxes[i].newY +=  (boxes[i].dy)* boxes[i].passTime;
				boxes[i].dy = boxes[i].dy + gravity * boxes[i].passTime;
				if (boxes[i].dy > .05)		// 0.05
					boxes[i].dy = .05;		// para limitar a velocidade maxima na queda devido ao atrito do ar

			}	
		}
		
		public function playLandSound(object: Object) {
			if (object.newY - object.y > 1)	// para garantir que o objecto esta (esteve) em queda
				landSound.play();
		}

		// metodo responsavel por movimentar e retirar do jogo os "fall objects" (objectos a serem destruidos)
		public function moveFallObjects(timeDiff: Number) {
			var i:int;
			
			for (i = 0; i < fallObjects.length; i++) {
				fallObjects[i].passTime += timeDiff;
				fallObjects[i].y +=  (fallObjects[i].dy) * fallObjects[i].passTime;
				fallObjects[i].rotation += (timeDiff * .1 - (i%3)*2);	// para os objectos rodarem de maneira diferente
				
				fallObjects[i].alpha -= .02;
				fallObjects[i].dy = fallObjects[i].dy + gravity * fallObjects[i].passTime;
				if (fallObjects[i].dy > .05)		// 0.05
					fallObjects[i].dy = .05;		// para limitar a velocidade maxima na queda devido ao atrito do ar
			}	
		}

		// alterna entre personagens
		public function switchHero() {
			
			if (heros.length == 2) {	// para garantir que existem 2 personagens
				if (soundOn)
					switchSound.play();
				hero.moveLeft = false;
				hero.moveRight = false;
				if (hero == heros[0])
					hero = heros[1];
				else
					hero = heros[0];
			}
		}
		
		// termina o jogo limpando o stage e removendo os listeners
		public function stopGame() {
			
			scenario.clean();
			heros = null;
			scenario.removeEventListener(scenario.READ_DONE, getObjects);
			removeEventListener(Event.ENTER_FRAME, playGame);
			if (stag.hasEventListener(KeyboardEvent.KEY_DOWN)) {
				stag.removeEventListener(KeyboardEvent.KEY_UP, keyPressedUp);
				stag.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressedDown);
			}
		}
		
	}
	
}
