shader_type canvas_item;

uniform float delta:hint_range(0.0,6.282, 0.1);
uniform float amount:hint_range(0.0,1.0,0.1);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
void fragment() {
  vec2 to_center = UV.xy - vec2(0.5, 0.5);
  float l = length(to_center);
  vec2 displacement = to_center * sin(amount*4.0*PI+4.0*l)*0.3*(1.0-amount);
  vec4 c = texture(SCREEN_TEXTURE, min(vec2(1.0, 1.0), max(vec2(0.0, 0.0), UV.xy-displacement)));
  COLOR = vec4(mix(1.0, c.r, amount), mix(1.0, c.g, amount), mix(1.0, c.b, amount), 1.0);
  
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
