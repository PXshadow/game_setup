import dn.Process;
import dn.Tweenie;
import dn.Lib;
import dn.heaps.slib.*;
import hxd.Key;
import Entity;

class Game extends dn.Process {
	public static var ME : Game;

	public var scroller : h2d.Layers;
	public var vp : Viewport;
	public var fx : Fx;
	public var level : Level;
	//public var hero : en.Hero;
	var clickTrap : h2d.Interactive;
	var mask : h2d.Graphics;

	var energy : Float;

	public var hud : h2d.Flow;
	//public var treeRoot : en.Branch;
	public var mouseScroll : { x:Int, y:Int, scrolling:Bool, active:Bool }
	//public var cm : dn.Cinematic;
	var linkPreview : h2d.Graphics;
	var barBg : HSprite;
	var bar : HSprite;
	var barThreshold : HSprite;
	public var teintHue = 0.4;

	public function new(ctx:h2d.Object) {
		super(Main.ME);

		ME = this;
		createRoot(ctx);
		//Console.ME.runCommand("+ bounds");

		//cm = new dn.Cinematic(Const.FPS);

		scroller = new h2d.Layers();
		root.add(scroller,Const.DP_BG);
		vp = new Viewport();
		fx = new Fx();

		clickTrap = new h2d.Interactive(1,1,Main.ME.root);
		clickTrap.onPush = onMouseDown;
		clickTrap.onRelease = onMouseUp;
		clickTrap.enableRightButton = true;
		mouseScroll = { x:0, y:0, scrolling:false, active:false } ;


		mask = new h2d.Graphics(Main.ME.root);
		mask.visible = false;
		mask.beginFill(0x0,1);
		mask.drawRect(0,0, 1, 1);
		energy = Const.BUY*5;
		#if debug
		energy = Const.MAX_ENERGY;
		#end

		hud = new h2d.Flow();
		root.add(hud, Const.DP_UI);
		hud.horizontalSpacing = 1;

		barBg = Assets.tiles.h_get("barBg",hud);
		bar = Assets.tiles.h_get("bar",hud);
		hud.getProperties(bar).isAbsolute = true;
		barThreshold = Assets.tiles.h_get("barThreshold",hud);
		hud.getProperties(barThreshold).isAbsolute = true;

		level = new Level();
		var pt = level.getPixel(0x00FF00);
		var e = new en.Branch(pt.cx,pt.cy);
		vp.repos(e);
		var e = new en.Branch(pt.cx,pt.cy-1,e);
		new en.Branch(pt.cx+1,pt.cy-1,e);
		new en.Branch(pt.cx+1,pt.cy-2,e);
		new en.Branch(pt.cx-1,pt.cy-2,e);

		for(pt in level.getPixels(0xFF0000))
			new en.Obstacle(pt.cx, pt.cy);

		var pt = level.getPixel(0x007400);
		var e = new en.Branch(pt.cx, pt.cy); e.cd.setS("locked",Const.INFINITE);
		var e = new en.Branch(pt.cx, pt.cy-1, e); e.cd.setS("locked",Const.INFINITE);
		var x = new en.Branch(pt.cx-1, pt.cy-2, e); x.cd.setS("locked",Const.INFINITE);
		var e = new en.Branch(pt.cx+1, pt.cy-2, e); e.cd.setS("locked",Const.INFINITE);
		var e = new en.Branch(pt.cx+1, pt.cy-3, e); e.cd.setS("locked",Const.INFINITE);

		for(pt in level.getPixels(0x33beff))
			new en.Bonus(pt.cx, pt.cy);

		linkPreview = new h2d.Graphics();
		scroller.add(linkPreview, Const.DP_UI);

		updateHud();
		onResize();

		var tf = new h2d.Text(Assets.font);
		scroller.add(tf,Const.DP_TREE);
		tf.text =
			"1- Create flowers to get energy (flowers pop at the END of any branch).\n"
			+"2- Balance tree size and energy production.\n"
			+"3- Click on flowers to create seeds and plant new trees.\n"
			+"4- Right click to remove branches.\n"
			+"5- Flee pollution.";
		tf.textColor = 0x4D61B3;
		var pt = level.getPixel(0xd02dff);
		tf.x = Const.GRID*pt.cx;
		tf.y = Const.GRID*pt.cy;
	}

	public function updateHud() cd.setS("invalidateHud",Const.INFINITE);
	function _updateHud() {
		if( !cd.has("invalidateHud") )
			return;

		//hud.removeChildren();
		cd.unset("invalidateHud");

		bar.setPos(1,1);
		bar.scaleX = M.fclamp(energy/Const.MAX_ENERGY,0,1) * (barBg.tile.width-2);
		barBg.set(energy<=Const.BUY ? "barBgOff" : "barBg");
		barThreshold.x = 1+Const.BUY/Const.MAX_ENERGY * (barBg.tile.width-2);

		onResize();

	}


	public function hasEnergy(v:Float) {
		return energy>=v;
	}
	public function remEnergy(v:Float) {
		if( Math.isNaN(v) )
			throw "illegal rem v="+v;
		energy-=v;
		energy = M.fmax(0,energy);
	}
	public function addEnergy(v:Float) {
		if( Math.isNaN(v) )
			throw "illegal add v="+v;
		energy+=v;
		energy = M.fmin(Const.MAX_ENERGY,energy);
	}

	function onMouseDown(ev:hxd.Event) {
		var m = getMouse();
		mouseScroll.x = m.x;
		mouseScroll.y = m.y;
		mouseScroll.active = true;
		mouseScroll.scrolling = false;
	}

	function onMouseUp(ev:hxd.Event) {
		var m = getMouse();
		mouseScroll.active = false;
		if( mouseScroll.scrolling )
			return;

		var none = true;
		for(e in Entity.ALL)
			if( e.isAlive() && m.cx==e.cx && m.cy==e.cy ) {
				if( e.is(en.Branch) )
					none = false;
				e.onClick(ev.button);
			}

		if( ev.button==0 && energy>Const.BUY ) {
			var b = getParentBranchPreview(m.cx, m.cy, m.x, m.y);
			if( b!=null ) {
				remEnergy(Const.BUY);
				new en.Branch(b.fcx, b.fcy, b.to);
			}
		}
	}

	function getParentBranchPreview(cx:Int,cy:Int, x:Float, y:Float) : Null<{ fcx:Int, fcy:Int, to:en.Branch }> {
		if( level.hasColl(cx,cy) )
			return null;

		for(e in en.Branch.ALL)
			if( e.cx==cx && e.cy==cy )
				return null;

		var dh = new DecisionHelper(en.Branch.ALL);
		dh.keepOnly( function(e) return !e.cd.has("locked") && e.isAlive() && M.fabs(e.cx-cx)<=1 && M.fabs(e.cy-cy)<=1 && e.getTreeDepth()<=Const.MAX_TREE_DEPTH );
		if( dh.countRemaining()==0 )
			return null;
		dh.score( function(e) return -e.distPxFree(x,y)*0.1 );
		dh.score( function(e) return -e.getTreeDepth()*2);
		dh.score( function(e) return e.isBranchEnd() ? -5 : 0);
		var e = dh.getBest();
		if( e==null )
			return null;

		var a = Math.atan2(cy-e.cy, cx-e.cx);
		return {
			fcx : e.cx+M.round(Math.cos(a)*1),
			fcy : e.cy+M.round(Math.sin(a)*1),
			to : e,
		}
	}


	override public function onResize() {
		super.onResize();
		clickTrap.width = w();
		clickTrap.height = h();

		hud.x = Std.int( vp.wid*0.5 - hud.outerWidth*0.5 );
		hud.y = 4;

		mask.scaleX = w();
		mask.scaleY = h();
	}

	override public function onDispose() {
		super.onDispose();

		mask.remove();
		clickTrap.remove();

		for(e in Entity.ALL)
			e.destroy();
		gc();

		if( ME==this )
			ME = null;
	}

	function gc() {
		var i = 0;
		while( i<Entity.ALL.length )
			if( Entity.ALL[i].destroyed )
				Entity.ALL[i].dispose();
			else
				i++;
	}

	override function postUpdate() {
		super.postUpdate();
		_updateHud();
		if( mouseScroll.scrolling ) {
			var m = getMouse();
			mouseScroll.x = m.x;
			mouseScroll.y = m.y;
		}
	}

	public function getMouse() {
		var gx = hxd.Window.getInstance().mouseX;
		var gy = hxd.Window.getInstance().mouseY;
		var x = Std.int( gx/Const.SCALE-scroller.x );
		var y = Std.int( gy/Const.SCALE-scroller.y );
		return {
			x : x,
			y : y,
			cx : Std.int(x/Const.GRID),
			cy : Std.int(y/Const.GRID),
		}
	}

	//public function hasCinematic() {
		//return !cm.isEmpty();
	//}

	public function controlsLocked() {
		return Console.ME.isActive();
	}

	override public function update() {
		super.update();

		var m = getMouse();
		if( mouseScroll.active ) {
			if( !mouseScroll.scrolling && M.dist(m.x,m.y, mouseScroll.x,mouseScroll.y)>=5 )
				mouseScroll.scrolling = true;

			if( mouseScroll.scrolling ) {
				mouseScroll.scrolling = true;
				vp.dx -= (m.x-mouseScroll.x)*0.5;
				vp.dy -= (m.y-mouseScroll.y)*0.5;
			}
		}

		// Updates
		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate();
		for(e in Entity.ALL) if( !e.destroyed ) e.update();
		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		gc();

		if( Key.isPressed(hxd.Key.R) ) {
			Main.ME.startGame();
		}

		#if debug
		if( Key.isPressed(hxd.Key.K) ) {
			for(e in en.Obstacle.ALL)
				e.destroy();
		}
		#end

		var b = getParentBranchPreview(m.cx,m.cy,m.x,m.y);
		if( b!=null ) {
			linkPreview.visible = true;
			linkPreview.clear();
			linkPreview.lineStyle(2, 0xFFC600, 1);
			linkPreview.moveTo((b.fcx+0.5)*Const.GRID, (b.fcy+0.5)*Const.GRID);
			linkPreview.lineTo(b.to.centerX, b.to.centerY);
		}
		else
			linkPreview.visible = false;

		if( !cd.hasSetS("expand", 6) ) {
			var all = en.Obstacle.ALL.copy();
			Lib.shuffleArray(all,Std.random);
			var i = 0;
			while( i<all.length*0.6 ) {
				var e = all[i];
				if( !level.hasPollution(e.cx-1,e.cy) && !level.hasColl(e.cx-1,e.cy) ) new en.Obstacle(e.cx-1,e.cy);
				if( !level.hasPollution(e.cx+1,e.cy) && !level.hasColl(e.cx+1,e.cy) ) new en.Obstacle(e.cx+1,e.cy);
				if( !level.hasPollution(e.cx,e.cy-1) && !level.hasColl(e.cx,e.cy-1) ) new en.Obstacle(e.cx,e.cy-1);
				if( !level.hasPollution(e.cx,e.cy+1) && !level.hasColl(e.cx,e.cy+1) ) new en.Obstacle(e.cx,e.cy+1);
				i++;
			}
		}

		updateHud();
	}
}
