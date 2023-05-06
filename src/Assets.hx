import dn.heaps.slib.*;
import dn.heaps.Sfx;

class Assets {
	public static var SBANK = dn.heaps.assets.SfxDirectory.load("sfx",true);
	public static var tiles : SpriteLib;
	public static var font : h2d.Font;
	//public static var music : Sfx;

	public static function init() {
		Sfx.setGroupVolume(0, 1);
		Sfx.setGroupVolume(1, 0.7);
		#if debug
		Sfx.toggleMuteGroup(1);
		#end

		//#if hl
		//music = new dn.Sfx( hxd.Res.music.music );
		//#else
		//music = new dn.Sfx( hxd.Res.music.f_music );
		//#end

		tiles = dn.heaps.assets.Atlas.load("tiles.atlas");
		//tiles.defineAnim("heroAimShoot","0(10), 1(10)");

		font = hxd.Res.minecraftiaOutline.toFont();
	}

	//public static function playMusic(isIn:Bool) {
		//music.stop();
		//music.playOnGroup(1,true);
	//}
}