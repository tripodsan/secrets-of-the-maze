shader_type canvas_item;

uniform float amount:hint_range(0.0,1.0,0.1);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;

void fragment() {
  vec2 to_center = UV.xy - vec2(0.5, 0.5);
  float l = length(to_center);
  vec2 displacement = to_center * sin(amount*4.0*PI+4.0*l)*0.3*(1.0-amount);
  vec4 c = texture(SCREEN_TEXTURE, UV.xy-displacement);
  COLOR = vec4(mix(1.0, c.r, amount), mix(1.0, c.g, amount), mix(1.0, c.b, amount), 1.0);

}
