import hxd.Key;

class Boot extends hxd.App {
	public static var ME : Boot;

	var speed = 1.;

	// Boot
	static function main() {
		hxd.Res.initEmbed();
		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;

		engine.backgroundColor = 0xff<<24|0xFF00FF;
		onResize();

		new Main();
	}

	override function onResize() {
		super.onResize();
		dn.Process.resizeAll();
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);

		var tmod = hxd.Timer.tmod;

		#if debug
		if( !Console.ME.isActive() ) {
			if( Key.isPressed(Key.NUMPAD_SUB) )
				speed = speed==1 ? 0.35 : speed==0.35 ? 0.1 : 1;

			if( Key.isPressed(Key.P) )
				speed = speed==0 ? 1 : 0;

			if( Key.isDown(Key.NUMPAD_ADD) )
				speed = 5;
			else if( speed>1 )
				speed = 1;
		}
		#end

		dn.heaps.slib.SpriteLib.TMOD = tmod*speed;
		if( speed>0 )
			dn.Process.updateAll(tmod*speed);
	}
}

