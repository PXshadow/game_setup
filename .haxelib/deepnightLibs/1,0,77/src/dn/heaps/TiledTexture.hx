package dn.heaps;

class TiledTexture extends h2d.TileGroup {
	var invalidated = true;
	public var width(default,set) : Int;
	public var height(default,set) : Int;

	public var pivotX(default,set) = 0.;
	public var pivotY(default,set) = 0.;

	public function new(wid:Int, hei:Int, ?texTile:h2d.Tile, ?p:h2d.Object) {
		super(texTile, p);
		width = wid;
		height = hei;
	}

	inline function set_width(v) {  invalidated = true; return width = v;  }
	inline function set_height(v) {  invalidated = true; return height = v;  }
	inline function set_pivotX(v) {  invalidated = true; return pivotX = v;  }
	inline function set_pivotY(v) {  invalidated = true; return pivotY = v;  }

	public inline function resize(wid:Int,hei:Int) {
		width = wid;
		height = hei;
	}

	function build() {
		clear();
		if (tile == null) return;
		var x = 0;
		var y = 0;
		var ox = M.round( -pivotX*width );
		var oy = M.round( -pivotY*height );
		var w = Std.int( tile.width );
		var h = Std.int( tile.height );
		while( y<height) {
			add( x+ox, y+oy, tile.sub( 0, 0, M.fmin(width-x,tile.width), M.fmin(height-y,tile.height) ) );
			x += w;
			if( x>=width ) {
				x = 0;
				y += h;
			}
		}
	}

	override function sync(ctx:h2d.RenderContext) {
		if( invalidated ) {
			invalidated = false;
			build();
		}
		super.sync(ctx);
	}

	override function drawTo(t:h3d.mat.Texture) {
		if (tile == null) return;
		var x = 0;
		var y = 0;
		var ox = M.round( -pivotX*width );
		var oy = M.round( -pivotY*height );
		var w = Std.int( tile.width );
		var h = Std.int( tile.height );
		while( y<height) {
			var bmp = new h2d.Bitmap( tile.sub( 0, 0, M.fmin(width-x,tile.width), M.fmin(height-y,tile.height) ) );
			bmp.x = x+ox;
			bmp.y = y+oy;
			bmp.drawTo(t);
			x += w;
			if( x>=width ) {
				x = 0;
				y += h;
			}
		}
	}
}
