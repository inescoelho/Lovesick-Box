package  {
	import flash.utils.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.system.fscommand;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.SharedObject;
	import flash.ui.Mouse;
	import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
	import flash.errors.IOError;
	
	import org.bytearray.gif.player.GIFPlayer;	// Codigo para carregamento de gifs, baseado em: AS3 GIFPlayer 0.2  www.bytearray.org  thibault@bytearray.org
	
	public class Navegacao extends MovieClip {
		
		var engine:Engine;
		var backG:Background;
		var gameTitle:Title;
		var option1:Button;
		var option2:Button;
		var option3:Button;
		var option4:Button;
		var option5:Button;
		var option6:Button;
		
		var volumeIcons:Array;
		var flagVol:int = 1;		//flag para indicar qual dos icones de Volume esta activo, 0->Off , 1-> On
		var sound:Sound;
		var channel:SoundChannel;
		var transf:SoundTransform;
		var menuSoundPlaying:int = 1;		//flags indicadoras de se o som de fundo dos menus estao a tocar ou nao
		var gameSoundPlaying:int = 0;		//flags indicadoras de se o som de jogo  esta a tocar ou nao
		
		var optionHome:Button;
		var optionHelp:Button;
		var optionSkip:Button;
		var optionReplay:Button;
		var currentLevel:int = 1;													//variavel indicadora do nivel presente
		var myBestScore:SharedObject = SharedObject.getLocal("myBestScore");		//cookie local para guardar o nivel atingido
		
		function init()
		{
			myBestScore.data.gameLevel = 1;
			playMusic("Sounds/Silence_Await.mp3");				//comeca por tocar a musica de fundo e mostra o menu
			showMainMenu();
		}

		function showBack()										//coloca background
		{	
			backG = new Background();
			addChild(backG);
		}
		
		function showTitle()									//coloca titulo
		{	
			gameTitle = new Title();
			addChild(gameTitle);
			gameTitle.y = 30;
		}
		
		function showMainMenu()
		{	
			gameSoundPlaying = 0;				//entrada no menu, indica que o som de jogo ira parar de tocar
			
			if (menuSoundPlaying == 0)			//se o som de menu nao estiver a tocar
			{
				channel.stop();								//para qualquer som que estivesse a tocar antes
				playMusic("Sounds/Silence_Await.mp3");		//toca a musica do menu
				menuSoundPlaying = 1;						//indica que o som de menu esta a tocar
			}
			
			if (flagVol == 0)
				turnMusicOff();							//se a flag de som estiver desactivada, desliga o som da musica atual
				
			showBack();									//mostra fundo
			showTitle();								//mostra logo
			
			option1 = new Button("Play", 280, 200);													//cria botao de play
			option1.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){showHelp(1)});		//mostra primeiro ecra de ajuda
			
			option2 = new Button("Chapter Selection", 220, 240);									//cria botao de selecao de cpaitulos
			option2.addEventListener(MouseEvent.CLICK,showChapterSelection);						//mostra menu de selecção de caitulos, quando clicado 
			
			//option3 = new Button("Multiplayer", 250, 250);										//cria botao de multiplayer
			//option3.addEventListener(MouseEvent.CLICK, playMultiplayer);							//joga em modo de multiplayer, quando clicado (por implementar)
			
			option4 = new Button("Credits", 265, 280);												//cria botao de creditos
			option4.addEventListener(MouseEvent.CLICK, function(e: MouseEvent) { showCredits() });	//mostra creditos, quando clicado 

			option5 = new Button("Help", 280, 320);													//cria botao de ajuda
			option5.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){showHelp(0)});		//mostra ajuda, quando clicado, sem mostrar o botao de next
			
			option6 = new Button("Exit", 280, 360);													//cria botao de saida
			option6.addEventListener(MouseEvent.CLICK, exitGame);									//sai do jogo, quando clicado
			
			showIconVolumeHandler(20,430);															//cria/mostra botao de som
			
			addChild(option1);																		//adiciona os varios componentes ao stage
			addChild(option2);
			//addChild(option3);
			addChild(option4);
			addChild(option5);
			addChild(option6);	
			
		}
		
		function showChapterSelection(e:MouseEvent)
		{
			var chapterText1:TextField = new TextField();					//varias caixas de texto,  dos varios capitulos a colocar por baixo das imagens
			var chapterText4:TextField = new TextField();
			var chapterText7:TextField = new TextField();
			var chapterText10:TextField = new TextField();
			var chapterText13:TextField = new TextField();
			var chapterText16:TextField = new TextField();
			var format:TextFormat = new TextFormat();						//formato dos textos
			
			format.font = "Consolas";										//estabelece o formato do texto que acompanha as imagens
			format.size = 18;
			
			
			var i:int;
			var j:int = 1;
			
			if (flagVol == 1)												//toca o som de clique, apenas se o som estiver activo
			{
				var snd:SoundButton = new SoundButton();
				snd.play();
			}
			
			removeChild(gameTitle);											//retira componentes anteriores, (do menu principal)	
			removeChild(option1);
			removeChild(option2);
			//removeChild(option3);
			removeChild(option4);
			removeChild(option5);
			removeChild(option6);
			
			var mini1:Mini1 = new Mini1();									//cria imagens de selecao de capitulos
			var mini4:Mini4 = new Mini4();
			var mini7:Mini7 = new Mini7();
			var mini10:Mini10 = new Mini10();
			var mini13:Mini13 = new Mini13();				
			var mini16:Mini16 = new Mini16();
			
			optionHome = new Button("Home",20, 430);						//cria botao de home
			optionHome.addEventListener(MouseEvent.CLICK,goHome);			//vai para o menu principal, quando clicado
			
			volumeIcons[flagVol].x = 70;									//ajusta a posicao do icone de som
		
			addChild(optionHome);
			
			
			//myBestScore.clear();											//apagar cookie apenas para debug/testar
			
			var bestLevel:int = myBestScore.data.gameLevel;					//guarda o melhor nivel numa var auxiliar
			for (i = 1; i <= 16; i=i+3) {									//selecao de quais os capitulos disponiveis para jogar(apenas aqueles ja passados)
																			//18 niveis, 6 checkpoints 
				if (i <= bestLevel)
				{
					switch (i)												//se o i nivel, for menor que o melhor nivel, torna a respectiva imagem/botao disponivel
					{
						case 1: {							
							mini1.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { playGame(1) } );		//joga o nivel 1, quando clicado na imagem/botao
							mini1.addEventListener(MouseEvent.MOUSE_OVER, makeBigger);								//torna maior na passagem do rato por cima
							mini1.addEventListener(MouseEvent.MOUSE_OUT, makeSmaller);								//torna mais pequeno na saida do rato
							mini1.buttonMode = true;
							
							addChild(mini1);								//adiciona no stage, no lugar especifico
							mini1.x = 45;
							mini1.y = 80;
							
							chapterText1.defaultTextFormat = format;		//cria o texto da imagem
							chapterText1.text ="Chapter 1";
							chapterText1.textColor = 0xffffff;
							chapterText1.selectable = false;
							
							chapterText1.x = 65;
							chapterText1.y = 190;
							addChild(chapterText1);				
							
							break;
						}
						case 4: {
							mini4.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { playGame(4) } );
							mini4.addEventListener(MouseEvent.MOUSE_OVER, makeBigger);
							mini4.addEventListener(MouseEvent.MOUSE_OUT, makeSmaller);
							mini4.buttonMode = true;
							
							addChild(mini4);
							mini4.x = 245;
							mini4.y = 80;
							
							chapterText4.defaultTextFormat = format;		
							chapterText4.text ="Chapter 2";
							chapterText4.textColor = 0xffffff;
							chapterText4.selectable = false;
							
							chapterText4.x = 265;
							chapterText4.y = 190;
							addChild(chapterText4);		
							
							break;
						}
						case 7: {
							mini7.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { playGame(7) } );
							mini7.addEventListener(MouseEvent.MOUSE_OVER, makeBigger);
							mini7.addEventListener(MouseEvent.MOUSE_OUT, makeSmaller);
							mini7.buttonMode = true;
														
							addChild(mini7);
							mini7.x = 445;
							mini7.y = 80;
							
							chapterText7.defaultTextFormat = format;		
							chapterText7.text ="Chapter 3";
							chapterText7.textColor = 0xffffff;
							chapterText7.selectable = false;
							
							chapterText7.x = 465;
							chapterText7.y = 190;
							addChild(chapterText7);		
							
							break;
						}
						case 10: {
							mini10.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { playGame(10) } );
							mini10.addEventListener(MouseEvent.MOUSE_OVER, makeBigger);
							mini10.addEventListener(MouseEvent.MOUSE_OUT, makeSmaller);
							mini10.buttonMode = true;
														
							addChild(mini10);
							mini10.x = 45;
							mini10.y = 250;
							
							chapterText10.defaultTextFormat = format;		
							chapterText10.text ="Chapter 4";
							chapterText10.textColor = 0xffffff;
							chapterText10.selectable = false;
							
							chapterText10.x = 65;
							chapterText10.y = 355;
							chapterText10.height = 50;
							addChild(chapterText10);	
							
							break;
						}
						case 13: {
							mini13.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { playGame(13) } );
							mini13.addEventListener(MouseEvent.MOUSE_OVER, makeBigger);
							mini13.addEventListener(MouseEvent.MOUSE_OUT, makeSmaller);
							mini13.buttonMode = true;
														
							addChild(mini13);
							mini13.x = 245;
							mini13.y = 250;
							
							chapterText13.defaultTextFormat = format;		
							chapterText13.text ="Chapter 5";
							chapterText13.textColor = 0xffffff;
							chapterText13.selectable = false;
							
							chapterText13.x = 265;
							chapterText13.y = 355;
							chapterText13.height = 50;
							addChild(chapterText13);	
							
							break;
						}
						case 16: {
							mini16.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { playGame(16) } );
							mini16.addEventListener(MouseEvent.MOUSE_OVER, makeBigger);
							mini16.addEventListener(MouseEvent.MOUSE_OUT, makeSmaller);
							mini16.buttonMode = true;
														
							addChild(mini16);
							mini16.x = 445;
							mini16.y = 250;
							
							chapterText16.defaultTextFormat = format;		
							chapterText16.text ="Chapter 6";
							chapterText16.textColor = 0xffffff;
							chapterText16.selectable = false;
							
							chapterText16.x = 465;
							chapterText16.y = 355;
							chapterText16.height = 50;
							addChild(chapterText16);	
							
							break;
						}
					}
					
				}
				else {										//se nao estiver dentro da gama dos niveis passados, desactiva o botao, e torna-o mais esbatido
					switch(i)
					{
						case 1: {
							addChild(mini1);				//adiciona no stage, no lugar especifico
							mini1.x = 45;
							mini1.y = 80;	
							
							mini1.alpha = 0.3;				//torna a imagem mais esbatida
							mini1.buttonMode = false;
							
							chapterText1.defaultTextFormat = format;		//cria o texto da imagem
							chapterText1.text ="Chapter 1";
							chapterText1.textColor = 0xffffff;
							chapterText1.selectable = false;
							
							chapterText1.x = 65;
							chapterText1.y = 190;
							chapterText1.alpha = 0.3;
							addChild(chapterText1);	
							break;
						}
						case 4: {
							addChild(mini4);
							mini4.x = 245;
							mini4.y = 80;
							
							mini4.alpha = 0.3;
							mini4.buttonMode = false;
							
							chapterText4.defaultTextFormat = format;		
							chapterText4.text ="Chapter 2";
							chapterText4.textColor = 0xffffff;
							chapterText4.selectable = false;
							
							chapterText4.x = 265;
							chapterText4.y = 190;
							chapterText4.alpha = 0.3;
							addChild(chapterText4);	
							break;
						}
						case 7: {
							addChild(mini7);
							mini7.x = 445;
							mini7.y = 80;
							
							mini7.alpha = 0.3;
							mini7.buttonMode = false;
							
							chapterText7.defaultTextFormat = format;		
							chapterText7.text ="Chapter 3";
							chapterText7.textColor = 0xffffff;
							chapterText7.selectable = false;
							
							chapterText7.x = 465;
							chapterText7.y = 190;
							chapterText7.alpha = 0.3;
							addChild(chapterText7);
							break;
						}
						case 10: {
							addChild(mini10);
							mini10.x = 45;
							mini10.y = 250;
							
							mini10.alpha = 0.3;
							mini10.buttonMode = false;
							
							chapterText10.defaultTextFormat = format;		
							chapterText10.text ="Chapter 4";
							chapterText10.textColor = 0xffffff;
							chapterText10.selectable = false;
							
							chapterText10.x = 65;
							chapterText10.y = 355;
							chapterText10.alpha = 0.3;
							chapterText10.height = 50;
							addChild(chapterText10);	
							break;
						}
						case 13: {
							addChild(mini13);
							mini13.x = 245;
							mini13.y = 250;
							
							mini13.alpha = 0.3;
							mini13.buttonMode = false;
							
							chapterText13.defaultTextFormat = format;		
							chapterText13.text ="Chapter 5";
							chapterText13.textColor = 0xffffff;
							chapterText13.selectable = false;
							
							chapterText13.x = 265;
							chapterText13.y = 355;
							chapterText13.alpha = 0.3;
							chapterText13.height = 50;
							addChild(chapterText13);	
							break;
						}
						case 16: {
							addChild(mini16);
							mini16.x = 445;
							mini16.y = 250;
							
							mini16.alpha = 0.3;
							mini16.buttonMode = false;
							
							chapterText16.defaultTextFormat = format;		
							chapterText16.text ="Chapter 6";
							chapterText16.textColor = 0xffffff;
							chapterText16.selectable = false;
							
							chapterText16.x = 465;
							chapterText16.y = 355;
							chapterText16.alpha = 0.3;
							chapterText16.height = 50;
							addChild(chapterText16);	
							break;
						}
					}
				}
			}
		}
		
		function makeBigger(e:MouseEvent)		//aumenta a imagem, quando o rato passa por cima desta
		{
			e.target.scaleX = 1.1;		
			e.target.scaleY = 1.1;
		}
		
		function makeSmaller(e:MouseEvent)		//diminui a imagem(volta ao normal), quando o rato nao esta por cima desta
		{
			e.target.scaleX = 1.0;
			e.target.scaleY = 1.0;
		}
		
		function showCredits()
		{
			cleanUp();															// limpa o stage
			showBack(); 														//mostra o fundo
			showIconVolumeHandler(20,430);										//mostra o icone de som
			
			if (flagVol == 1)													//toca o som de clique, apenas se o som estiver activo
			{
				var snd:SoundButton = new SoundButton();
				snd.play();
			}			
			
			var titulo: Title = new Title();

			var mainTitle: String = "Credits";

			var title1: String = "Programming and Graphics:";
			var texto1: String = "Alexandre Pinto\n\nInês Coelho\n\nMiguel Avim";

			var title2: String = "Sound:";
			var texto2: String = "Freesound.org\ndig.ccmixter.org";

			var title3: String = "Special thanks:";
			var texto3: String = "Our beta-testers";

			textCredits(mainTitle, 40, 100, 275, 125);								//mostra os varios textos, nas varias coordenadas, com diferentes tamanhos e alturas

			textCredits(title1, 20, 40, 100, 225);
			textCredits(texto1, 30, 200, 100, 270);

			textCredits(title2, 20, 40, 400, 200);
			textCredits(texto2, 25, 100, 400, 240);

			textCredits(title3, 20, 40, 400, 325);
			textCredits(texto3, 25, 40, 400, 365);

			addChild(titulo);
			titulo.scaleX = 0.6;
			titulo.scaleY = 0.6;
			titulo.x = 140;
			titulo.y = 30;

			volumeIcons[flagVol].x = 70;											//ajusta a posicao do icone de som

			optionHome = new Button("Home",20, 430);								//cria botao de home
			optionHome.addEventListener(MouseEvent.CLICK,goHome);					//vai para o menu principal, quando clicado
			addChild(optionHome);
		}


		function textCredits(texto:String, size: int, altura: Number,cordX:int,cordY:int)		//cria e apresenta um texto com uma determinada altura,tamanho, e posicao
		{
			var inputText:TextField = new TextField();
			var format:TextFormat = new TextFormat();		
				
			format.leading = -20;
			format.font = "Gabriola";			//estabelece o formato do texto do botao
			format.size = size;
			
			inputText.defaultTextFormat = format;		//cria o texto do bottao
			inputText.text =texto;
			inputText.textColor = 0xffffff;				// cor: branco
			inputText.selectable = false;


			addChild(inputText);
			inputText.x = cordX;
			inputText.y = cordY;
			inputText.width = 300;
			inputText.height = altura;
		}
			
		
		function showHelp(flag:int)
		{
			if (flagVol == 1)													//toca o som de clique, apenas se o som estiver activo
			{
				var snd:SoundButton = new SoundButton();
				snd.play();
			}
			
			removeChild(gameTitle);												//retira componentes anteriores, (do menu principal)
			removeChild(option1);
			removeChild(option2);
			//removeChild(option3);
			removeChild(option4);
			removeChild(option5);
			removeChild(option6);
			
			var helpScreen: HelpScreen = new HelpScreen();						//cria a imagem de ajuda
			addChild(helpScreen);												//adicona a imagem
			
			volumeIcons[flagVol].x = 70;										//ajusta a posicao do icone de som
			setChildIndex(volumeIcons[flagVol], numChildren - 1);				//coloca o botao de volume totalmente visivel, prevenindo que fique em 'layers anteriores'
				
			optionHome = new Button("Home",20, 430);							//cria botao de home
			optionHome.addEventListener(MouseEvent.CLICK, goHome);				//vai para o menu principal, quando clicado
			addChild(optionHome);	
			
			if (flag == 1)
			{
				optionSkip = new Button("Skip", 580, 430);
				optionSkip.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { playGame(1) } );
				addChild(optionSkip);																			//adiciona botao de skip/next, para poder seguir para o jogo
			}	
			
		}
		
		function playGame(level:int)
		{
			if (flagVol == 1)													//toca o som de clique, apenas se o som estiver activo
			{
				var snd:SoundButton = new SoundButton();
				snd.play();
			}
			
			currentLevel = level;												//atualiza o nivel currente
			
			if (currentLevel == 1 || currentLevel == 4 || currentLevel == 7 || currentLevel == 10 || currentLevel == 13 || currentLevel == 16 || currentLevel == 19)
			{
				cleanUp();														//limpa o ecra
				showLoadingWait(level);											//mostra ecra de pre-loading interno, se necessario carregar um novo cenario
			}
			else
				startGame(level);												//senao for preciso loading, joga o nivel 
		}
		
		function showLoadingWait(level:int)
		{
			var delay:int=2000;													//delay antes de iniciar o carregamento do  cenario/gif
			
			switch(level)														//dependendo do nivel,vai colocar a respectiva imagem de loading
			{
				case 1: {
					var loadImg:PrologueImage = new PrologueImage();
					addChild(loadImg);
					break;
				}
				case 4: {
					var loadImg4:LoadingImage4 = new LoadingImage4();	
					addChild(loadImg4);
					break;
				}
				case 7: {
					var loadImg7:LoadingImage7 = new LoadingImage7();	
					addChild(loadImg7);
					break;
				}
				case 10: {
					var loadImg10:LoadingImage10 = new LoadingImage10();
					addChild(loadImg10);
					break;
				}
				case 13: {
					var loadImg13:LoadingImage13 = new LoadingImage13();
					addChild(loadImg13);
					break;
				}
				case 16: {
					var loadImg16:LoadingImage16 = new LoadingImage16();	
					addChild(loadImg16);
					break;
				}
				case 19:{
					var loadImg19:LoadingImage19 = new LoadingImage19();	
					addChild(loadImg19);
					break;
				}
			}
			

			setTimeout(showScenarioGif, delay, level);			//chama a funcao para mostrar o cenario, depois de um certo delay
		}
		
		function showScenarioGif()
		{
			var myGIFPlayer:GIFPlayer = new GIFPlayer();    		//cenario/gif
			
			var lev=arguments[0];
			
			myGIFPlayer.addEventListener(Event.COMPLETE, function(e:Event) { showSkipButton(myGIFPlayer,lev) } );			//quando o carregamento estiver completo, mostra  o botao de skip
			
			switch(currentLevel)									//dependendo do nivel atingido, vai carregar o respectivo cenario/gif
			{
				case 1:
				{
					myGIFPlayer.load (new URLRequest("Images/bg1.gif"));
					break;
				}
				case 4:
				{
					myGIFPlayer.load (new URLRequest("Images/bg2.gif"));
					break;
				}
				case 7:
				{
					myGIFPlayer.load (new URLRequest("Images/bg3.gif"));
					break;
				}
				case 10:
				{
					myGIFPlayer.load (new URLRequest("Images/bg4.gif"));
					break;
				}
				case 13:
				{
					myGIFPlayer.load (new URLRequest("Images/bg5.gif"));
					break;
				}
				case 16:
				{
					myGIFPlayer.load (new URLRequest("Images/bg6.gif"));
					break;
				}
				case 19:
				{
					myGIFPlayer.load (new URLRequest("Images/bg7.gif"));
					break;
				}
				
			}
			
			
		}
		
		function showSkipButton(gif:GIFPlayer,lev:int)			//mostra o botao de skip para o jogo, quando for clicado mostra o cenario e começa o jogo
		{
			optionSkip = new Button("Skip", 580, 430);
			optionSkip.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { SkipAndStart(gif,lev) } );
			addChild(optionSkip);																				//adiciona botao de skip/next, para poder seguir para o jogo
		}
		
		function SkipAndStart(gif:GIFPlayer,lev:int)			//limpa, mostra o cenario e começa o jogo
		{
			cleanUp();							//limpa o ecra
			addChild(gif);						//adiciona o cenario ao stage
			
			startGame(lev);						//inicia o jogo com o argumento passado na chamada desta funcao, que sera o nivel a ser jogado
		}
		
		function startGame(level:int)
		{
			fscommand("fullscreen", "true");									//permite fullscreen
			fscommand("allowscale", "true");									//permite maximizar
				
			menuSoundPlaying = 0;												//indica que som do menu vai deixar de tocar
			
			if (gameSoundPlaying == 0)											//se o som do jogo nao estava a tocar antes
			{
				channel.stop();													//para qualquer som que estivesse a tocar antes
				playMusic("Sounds/Earth.mp3");									//toca o som do jogo
				gameSoundPlaying = 1;											//indica que o som de jogo esta atualmente a tocar
			}
			
			if (flagVol == 0)													
				turnMusicOff();													//se a flag de som estiver desactivada, desliga o som da musica atual
			
			
			
			optionHome = new Button("Home",50, 10);								//cria botao de home
			optionHome.addEventListener(MouseEvent.CLICK, goHome);				//vai para o menu principal, quando clicado
			addChild(optionHome);													
			
			if (this.contains(volumeIcons[flagVol])==false)
				showIconVolumeHandler(100, 10);									//mostra botao de som apenas se ja nao la estiver
			
			optionReplay = new Button("Replay",150, 10);						//cria botao de replay
			optionReplay.addEventListener(MouseEvent.CLICK, rePlay);			//volta a jogar o nivel,quando clicado 
			addChild(optionReplay);												//adicona o botao
			
			
			currentLevel = level;												//atualiza o nivel currente
			
			engine = new Engine();												//cria nova instancia de um novo jogo
			engine.startEngine(level, stage);									//inicia o jogo
			engine.addEventListener(engine.LEVEL_UP,nextLevel);					//adiciona um listener, para ficar a escuta de quando passa de nivel
			engine.soundOn = Boolean(flagVol);									//estabelece flag de som interna do jogo, para ligar ou desligar os efeitos especiais
			
		}
		
		function rePlay(e:MouseEvent)
		{
			if (flagVol == 1)								//toca o som de clique, apenas se o som estiver activo
			{
				var snd:SoundButton = new SoundButton();
				snd.play();
			}
			
			engine.stopGame();								//para o jogo atual
			engine.startEngine(currentLevel,stage);			//inicia um novo jogo, no mesmo nivel atual
		}
		
		function nextLevel(e:Event)
		{
			engine.stopGame();								//para o jogo atual
			
			currentLevel++;									//incrementa o nivel
			
			if (currentLevel == 21)							//se for o ultimo nivel, vai para a frame 5, onde mostra uma animacao
				setTimeout(gotoAndStop, 600, 5);
				
			else											//senao, se for algum dos seguintes niveis, actualiza se necessario o melhor nivel, e joga-o de seguida
			{
				if (currentLevel == 4 || currentLevel == 7 || currentLevel == 10 || currentLevel == 13 || currentLevel == 16)
				{
					if (currentLevel > (myBestScore.data.gameLevel)){
						myBestScore.data.gameLevel = currentLevel;			//actualiza o progresso, apenas se tiver passado mais 3 niveis (dentro de um capitulo) do que o melhor resultado
						myBestScore.flush();
					}
				}
				
				playGame(currentLevel); //joga o proximo nivel
			}
		}
	
		
		function showIconVolumeHandler(cordX:int,cordY:int)
		{		
			
			volumeIcons = new Array();			//array de 2 icones de volume
			volumeIcons.push(new SoundOff());
			volumeIcons.push(new SoundOn());
			
			addChild(volumeIcons[flagVol]);		//adiciona ao stage o icone activo
			volumeIcons[flagVol].x = cordX;		//estabelece as coordenadas
			volumeIcons[flagVol].y = cordY;
			volumeIcons[flagVol].buttonMode = true;
			
			volumeIcons[flagVol].addEventListener(MouseEvent.CLICK, changeIcon);		//muda icone, quando clicado
			volumeIcons[flagVol].addEventListener(MouseEvent.CLICK, controlSound);		//controla som, quando clicado
			
		}
		
		function changeIcon(e:MouseEvent)
		{
			var prevX:int = volumeIcons[flagVol].x;		//guarda as coordenadas do icone anterior
			var prevY:int = volumeIcons[flagVol].y;			

			var snd:SoundButton = new SoundButton();	//toca o som de clique
			snd.play();
			
			removeChild(volumeIcons[flagVol]);			//remove o anterior
					
			flagVol = (flagVol + 1) % 2;				//muda a flag para outro icone
			
			showIconVolumeHandler(prevX, prevY);		//adicona o novo icone
			
			stage.focus = stage;
			
		}
		
		function playMusic(title:String)
		{
			var urlSound:URLRequest = new URLRequest(title);
			sound = new Sound();
			 
			sound.load(urlSound);						//carrega e inicia o streaming do som, com o titulo passado por parametro
			channel = sound.play(0,9999);				//play, desde o inicio, repetidamente
		}
		
		function turnMusicOn()
		{
			transf = new SoundTransform(1.0, 0.0);		//estabelece estado do som, ativo(volume on), para as duas colunas
			channel.soundTransform = transf;			//associa ao canal de som
			if (engine)
				engine.soundOn = true;					//ativa, se existir o jogo, o som de efeitos especiais
				
		}
		
		function turnMusicOff()
		{
			transf = new SoundTransform(0.0, 0.0);		//estabelece estado do som, desativo(volume off), para as duas colunas
			channel.soundTransform = transf;			//associa ao canal de som
			if (engine)
				engine.soundOn = false;					//ativa, se existir o jogo, o som de efeitos especiais
		}
		
		function controlSound(e:MouseEvent)
		{
			if (flagVol == 1)							//dependo da flag, ativa ou desativa o som
				turnMusicOn();							
			else
				turnMusicOff();
		}
		
		function goHome(e:MouseEvent)
		{
			if (flagVol == 1)							//toca o som de clique, apenas se o som estiver activo
			{
				var snd:SoundButton = new SoundButton();
				snd.play();
			}
			
			cleanUp();									//limpa o ecra
			if (engine)	
				engine.stopGame();						//se estiver a jogar, para o jogo		
			showMainMenu();								//mostra menu principal
		}		
		
		/*function playMultiplayer(e:MouseEvent)		//joga em modo de multiplayer, por implementar
		{
			if (flagVol == 1)
			{
				var snd:SoundButton = new SoundButton();
				snd.play();
			}
		}*/
		
		function cleanUp()								//limpa ecra
		{			
			while (numChildren > 0)
				removeChildAt(0);
		}
		
		function exitGame(e:MouseEvent)
		{
			if (flagVol == 1)							//toca o som de clique, apenas se o som estiver activo
			{
				var snd:SoundButton = new SoundButton();
				snd.play();
			}
			
			cleanUp();									//limpa o ecra
			fscommand("quit");							//sai da aplicacao
		}
	}
}
