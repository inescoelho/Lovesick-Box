package  {
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.text.*;
	
	public class Button extends Sprite{				//classe que permite representa um botao simples de texto, com animacao  
		
		
		var button:SimpleButton;				//botao
		var up:DisplayObject;					//estado que deve ser apresentado quando o rato nao se encontra por cima
		var over:DisplayObject;					//estado que deve ser apresentado quando o rato se encontra por cima
		
		var flagVol:int=1;		//flag para indicar qual dos icones de Volume esta activo, 0->Off , 1-> On
		var homeIcon:Home;
		var helpIcon:Help;
		var skipIcon:Skip;
		var replayIcon:Replay;
		
		public function Button(name:String,cordX:int, cordY:int) {
			
			if (name == "Home")
				showHome(cordX, cordY);
			else if (name == "Replay")
				showReplay(cordX, cordY);
			else if(name == "Skip")
				showSkip(cordX, cordY);
			else
			{
				up = createText(name,0,.5);						//quando o rato nao esta por cima, mostra um texto nao-bold e meio esbatido
				over = createText(name, 1, 1);					//quando o rato nao esta por cima, mostra um texto bold e brilhante
				
				button = new SimpleButton();
				button.upState = up;
				button.downState = up;
				button.overState = over;			
				button.hitTestState =up;						//estabelece estado que serve de hit(a qual vai testar se recebeu o clique)
				button.width = 177;
				button.height = 100;
				
				button.x = cordX;
				button.y = cordY;
				
				addChild(button);								//adiciona o botao ao stage, ja nas coordenadas pretendidas
			
			}
		}
		
		function createText(name:String,bold:int,alpha:Number):MovieClip
		{
			var option:MovieClip = new MovieClip();
			var optionText:TextField = new TextField();
			var format:TextFormat = new TextFormat();		
			var hit:Shape = new Shape();
				
			hit.graphics.drawRect(0,0,100,25);	//desenha um rectangulo que servira de area de hit
			
			format.font = "Consolas";			//estabelece o formato do texto do botao
			format.size =18;
			if (bold == 1)						//se requerido, torna o texto a bold
				format.bold =true;
			
			optionText.defaultTextFormat = format;		//cria o texto do botao
			optionText.text =name;
			optionText.textColor = 0xffffff;
			optionText.selectable = false;				//retira a propriedade de ser selecionavel

			
			option.addChild(hit);				//adiciona a respectiva area de hit
			option.addChild(optionText);		//adiciona o texto ao movieclip envolvente
			option.alpha = alpha;
			option.mouseChildren = false;
			
			return option;
		}
		
		function showHome(cordX:int, cordY:int)				//adiciona o botao home ao stage nas coordenadas pretendidas
		{
			homeIcon = new Home();
			addChild(homeIcon);
			homeIcon.x = cordX;
			homeIcon.y = cordY;
			homeIcon.buttonMode = true;
		}
		
		function showReplay(cordX:int, cordY:int)			//adiciona o botao replay ao stage nas coordenadas pretendidas
		{
			replayIcon = new Replay();
			addChild(replayIcon);
			replayIcon.x = cordX;
			replayIcon.y = cordY;
			replayIcon.buttonMode = true;
		}
		
		function showSkip(cordX:int, cordY:int)
		{
			skipIcon = new Skip();
			addChild(skipIcon);
			skipIcon.x = cordX;
			skipIcon.y = cordY;
			skipIcon.buttonMode = true;
		}
	}
	
}
