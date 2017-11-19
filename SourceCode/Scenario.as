package  {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;
	
	// classe que le o desenho do nivel do respectivo ficheiro de texto e insere os elementos no stage
	public class Scenario extends MovieClip {
		
		var levelLoader:URLLoader;		// para ler o ficheiro de texto
		var fixedObjects:Array;			// array de plataformas fixas
		var dynamicObjects:Array;		// array de elementos interativos
		var boxes:Array;				// array de caixas do jogo
		var heros:Array;				// array de personagens do jogo
		var stg: Stage;
		var bothHeroes: Boolean = false;	// informacao se as duas personagens tem de chegar 'a porta
		var extraLevel: int = 0;			// informacao se se trata de um nivel extra e qual o seu tipo
		public var READ_DONE:String='the file was read';	// evento para informar que carregou o nivel
		
		
		public function initScenario(stg: Stage)
		{
			levelLoader = new URLLoader();
			fixedObjects=new Array();
			dynamicObjects = new Array();
			boxes = new Array();
			heros = new Array();
			this.stg = stg;
		}

		
		public function readLevel(nLevel:int)		//escuta o termino da leitura do ficheiro que contem a configuracao do nivel
		{
			levelLoader.load(new URLRequest("Levels/level"+nLevel+".txt"));
			levelLoader.addEventListener(Event.COMPLETE,loadLevel);
		}
		
		public function loadLevel(e:Event)		//faz a leitura da configuracao do ficheiro, e constroi o cenario
		{
			var texto:String = e.target.data;
			var col:int=22;
			var lin:int=16;
			var i:int;
			var j:int;
			var existFemale:int = 0;
			
			for (i = 0; i < lin; i++)
				for (j =0; j < col; j++)
				{
					switch (texto.charAt(i*col+j))			//para cada caracter do ficheiro de texto,adiciona tipo ao stage, bem como ao array correspondente
					{
						case '+':{		// caixa
							var box : Box;
							box = new Box(j*32+16,i*32+32);
							boxes.push(box);
							stg.addChild(box);
							box.x=j*32+box.width/2;
							box.y = i * 32+box.height;
							
							break;
						}
						case '=':{		// tipo de plataforma fixa
							var plat1 : Ground1;
							plat1 = new Ground1();
							fixedObjects.push(plat1);
							stg.addChild(plat1);
							plat1.x=j*32;
							plat1.y = i * 32;
							break;
						}
						case '-':{		// tipo de plataforma fixa
							var plat2 : Ground2;
							plat2 = new Ground2();
							fixedObjects.push(plat2);
							stg.addChild(plat2);
							plat2.x=j*32;
							plat2.y = i * 32;
							break;
						}
						case ':':{		// tipo de plataforma fixa
							var plat3 : Ground3;
							plat3 = new Ground3();
							fixedObjects.push(plat3);
							stg.addChild(plat3);
							plat3.x=j*32;
							plat3.y = i * 32;
							break;
						}
						case '.':{		// tipo de plataforma fixa
							var plat4 : Ground4;
							plat4 = new Ground4();
							fixedObjects.push(plat4);
							stg.addChild(plat4);
							plat4.x=j*32;
							plat4.y = i * 32;
							break;
						}
						case '*':{		// tipo de plataforma fixa
							var plat5 : Ground5;
							plat5 = new Ground5();
							fixedObjects.push(plat5);
							stg.addChild(plat5);
							plat5.x=j*32;
							plat5.y = i * 32;
							break;
						}
						case '_':{		// tipo de plataforma fixa
							var plat6 : Ground6;
							plat6 = new Ground6();
							fixedObjects.push(plat6);
							stg.addChild(plat6);
							plat6.x=j*32;
							plat6.y = i * 32;
							break;
						}
						case 'o':{		// tipo de plataforma fixa
							var plat7 : Ground7;
							plat7 = new Ground7();
							fixedObjects.push(plat7);
							stg.addChild(plat7);
							plat7.x=j*32;
							plat7.y = i * 32;
							break;
						}
						case 'x':{		// tipo de plataforma fixa invisivel
							var plat8 : Ground8;
							plat8 = new Ground8();
							fixedObjects.push(plat8);
							stg.addChild(plat8);
							plat8.x=j*32;
							plat8.y = i * 32;
							break;
						}
						case 'd':{		// porta para passar de nivel
							var door : Door;
							door = new Door();
							dynamicObjects.push(door);
							stg.addChild(door);
							door.x=j*32;
							door.y = i * 32 + 32;
							door.bothHeroes = this.bothHeroes;
							break;
						}
						case '#':{		// picos
							var spike : Spike;
							spike = new Spike();
							dynamicObjects.push(spike);
							stg.addChild(spike);
							spike.x=j*32;
							spike.y = i * 32 + 32;
							break;
						}
						case 'l':{		// alavanca
							var lever : Lever;
							lever = new Lever();
							dynamicObjects.push(lever);
							stg.addChild(lever);
							lever.x=j*32+lever.width/2;
							lever.y = i * 32 + 32;
							lever.gotoAndStop(1);
							break;
						}
						// heroM at [0] and heroF at [1]
						case 'M':{
							var heroM : HeroM;
							heroM = new HeroM(j*32+16,i*32+32);
							heros[0] = heroM;
							stg.addChild(heroM);
							heroM.x=j*32+heroM.width/2;
							heroM.y = i * 32 + heroM.width;
							heroM.scaleX = heroM.scale;
							heroM.scaleY = heroM.scale;
							break;
						}
						// heroM at [0] and heroF at [1]
						case 'F':{
							var heroF : HeroF;
							existFemale = 1;
							heroF = new HeroF(j * 32 + 16, i * 32 + 32);
							heros[1] = heroF;
							stg.addChild(heroF);
							heroF.x=j*32+heroF.width/2;
							heroF.y = i * 32.4 + heroF.width;
							heroF.scaleX = heroF.scale;
							heroF.scaleY = heroF.scale;
							break;
						}
						case 'f':{				// personagem feminina que vai ser destruida
							var herof : HeroF;
							herof = new HeroF(j * 32 + 16, i * 32 + 32);
							heros[1] = herof;
							stg.addChild(herof);
							herof.x=j*32+herof.width/2;
							herof.y = i * 32.4 + herof.width;
							herof.scaleX = herof.scale;
							herof.scaleY = herof.scale;
							herof.destructivel = true;
							break;
						}
						case 'B':{				// nivel do tipo que necessita que ambas as personagens cheguem 'a porta
							this.bothHeroes = true;
							break;
						}
						case 'C':{				// extra nivel onde ira ler carregada uma mensagem de texto tipo 1
							this.extraLevel = 1;
							var text1: ExtraText1 = new ExtraText1();
							stg.addChild(text1);
							break;
						}
						case 'D':{				// extra nivel onde ira ler carregada uma mensagem de texto tipo 2
							this.extraLevel = 2;
							var text2: ExtraText2 = new ExtraText2();
							stg.addChild(text2);
							break;
						}
						default:break;
					}
				
				}	
				dispatchEvent(new Event(READ_DONE));									//gera evento de leitura e contrucao terminada
				// configura a ordem conforme os objectos sao mostrados no stage
				if (door)
					stg.setChildIndex(door, stg.numChildren - 1);
				if (heroM)
					stg.setChildIndex(heroM, stg.numChildren - 1);
				if (existFemale == 1)
					stg.setChildIndex(heroF, stg.numChildren - 1);
				if (extraLevel == 1)
					stg.setChildIndex(text1, stg.numChildren - 1);
				else if (extraLevel == 2)
					stg.setChildIndex(text2, stg.numChildren - 1);
		}

		function getFixedObjects():Array
		{
			return fixedObjects;
		}
		
		public function getDynamicObjects():Array
		{
			return dynamicObjects;
		}
		
		
		public function getBoxes():Array
		{
			return boxes;
		}
		
		public function getHeros():Array
		{
			return heros;
		}
		
		// limpa todos os objectos no jogo, excepto o proprio cenario
		public function clean()
		{			
			while (stg.numChildren > 1)
				stg.removeChildAt(1);
		}
		
	}

	
}