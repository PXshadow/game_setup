import dn.Lib;

class Viewport extends dn.Process {
	public static var PARALAX = 0.4;
	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;

	public var x = 0.;
	public var y = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var wid(get,never) : Int;
	public var hei(get,never) : Int;
	public var screenWid(get,never) : Int;
	public var screenHei(get,never) : Int;

	public function new() {
		super(Game.ME);
	}

	inline function get_screenWid() return Boot.ME.s2d.width;
	inline function get_screenHei() return Boot.ME.s2d.height;

	inline function get_wid() {
		return M.ceil( Boot.ME.s2d.width / Const.SCALE );
	}

	inline function get_hei() {
		return M.ceil( Boot.ME.s2d.height / Const.SCALE );
	}

	public function repos(e:Entity) {
		x = e.centerX;
		y = e.centerY-Const.GRID*3;
	}

	override public function update() {
		super.update();

		// Balance between hero & mobs
		//var tx = game.treeRoot.centerX;
		//var ty = game.treeRoot.centerY-Const.GRID*3;
		//var n = 1.0;
		//var w = 1;
		//tx/=n;
		//ty/=n;
		//var a = Math.atan2(ty-y, tx-x);
		//var d = dn.M.dist(x, y, tx, ty);
		//if( d>=10 ) {
			//var s = 0.5 * M.fclamp(d/100,0,1);
			////var s = 0.03 + 0.8 * M.fclamp(d/100,0,1);
			//dx+=Math.cos(a)*s;
			//dy+=Math.sin(a)*s;
		//}

		//game.fx.markerFree(tx,ty,0xFFFF00, true);
		//game.fx.markerFree(x,y,0xFF00FF, true);

		//if( !game.mouseScroll.active ) {
			x+=dx;
			y+=dy;
			dx*=0.7;
			dy*=0.7;
			//dx*=0.97;
			//dy*=0.97;
			//if( M.dist(x,y,tx,ty)<=20 ) {
				//dx*=0.8;
				//dy*=0.8;
			//}
		//}
		x = M.fclamp(x,wid*0.5,level.wid*Const.GRID-wid*0.5);
		y = M.fclamp(y,hei*0.5,level.hei*Const.GRID-hei*0.5);
		game.scroller.x = Std.int( -x + wid*0.5 );
		game.scroller.y = Std.int( -y + hei*0.5 );
		game.level.bg.x = game.scroller.x*PARALAX;
		game.level.bg.y = game.scroller.y*PARALAX;
	}
}