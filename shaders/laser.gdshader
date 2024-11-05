shader_type canvas_item;

uniform sampler2D laserTexture: repeat_enable;
uniform float animation;

void fragment() {
  float a = texture(laserTexture, vec2(UV.x+animation, UV.y)).a;
  COLOR = a*vec4(1.0-UV.x*0.5, 0.5, 1.0-UV.x*0.5, UV.x*2.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
