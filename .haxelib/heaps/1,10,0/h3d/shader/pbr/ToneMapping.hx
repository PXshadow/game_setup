package h3d.shader.pbr;


class ToneMapping extends ScreenShader {

	static var SRC = {

		@param var hdrTexture : Sampler2D;
		@param var exposureExp : Float;
		@const var isSRBG : Bool;
		@const var mode : Int;
		@param var invGamma : Float;

		var hdrColor : Vec4;

		function __init__fragment() {
			hdrColor = hdrTexture.get(calculatedUV);
		}

		function fragment() {
			var color = hdrColor;
			color.rgb *= exposureExp;
			switch( mode ) {
			case 0:
				// linear
				color.rgb = color.rgb.saturate();
			case 1:
				// reinhard
				color.rgb = color.rgb / (color.rgb + vec3(1.));
			}
			// gamma correct
			if( !isSRBG )
				color.rgb = pow(color.rgb, vec3(invGamma));
			pixelColor = color;
		}
	}

	public var exposure(default,set) : Float;
	public var gamma(default,set) : Float;

	public function new() {
		super();
		exposure = 0;
		gamma = 2.0;
	}

	function set_exposure(v) {
		exposureExp = Math.exp(v);
		return exposure = v;
	}

	function set_gamma(v:Float) {
		invGamma = 1.0/v;
		return gamma = v;
	}
}
