package  {
	import flash.display.MovieClip;
	
	public class Box extends MovieClip {
		var moveLeft: Boolean;
		var moveRight: Boolean;
		var moveWithLeft: Boolean;
		var moveWithRight: Boolean;
		var dy: Number;
		var passTime: Number;
		var newX: Number;
		var newY: Number;
		var destructive: Boolean;	// informa se o bloco e' destriudo pela alavanca

		public function Box(cordX:int,cordY:int) {
			moveLeft = false;
			moveRight = false;
			moveWithLeft = false;
			moveWithRight = false;
			dy = 0;
			passTime = 0;
			newX = cordX;
			newY = cordY;
			destructive= false;
		}

		public function topSide():Number { return this.y - this.height; }
		public function bottomSide():Number { return this.y + this.height; }
		public function leftSide():Number { return this.x - this.width/2; }
		public function rightSide():Number { return this.x + this.width / 2; }
		
	}
	
}
