shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float amount: hint_range(0.0, 5.0, 0.1);

void fragment() {
  vec2 center = UV.xy - vec2(0.5, 0.5);
  vec2 dist_red = center * 0.01 * amount;
  vec2 dist_green = center * 0.03 * amount;
  vec2 dist_blue = center * 0.05 * amount;

  float r = texture(SCREEN_TEXTURE, max(vec2(0.0, 0.0), min(vec2(1.0, 1.0), UV.xy + dist_red))).r;
  float g = texture(SCREEN_TEXTURE, max(vec2(0.0, 0.0), min(vec2(1.0, 1.0), UV.xy + dist_green))).g;
  float b = texture(SCREEN_TEXTURE, max(vec2(0.0, 0.0), min(vec2(1.0, 1.0), UV.xy + dist_blue))).b;
  COLOR = vec4(r, g, b, 1.0);
}
