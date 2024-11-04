shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
  vec2 center = UV.xy - vec2(0.5, 0.5);
  vec3 col = texture(SCREEN_TEXTURE, UV).rgb;
  COLOR.rgb = vec3(col.r * 0.3 + col.g * 0.59 + col.b * 0.11) * 0.2;
  COLOR.a = 1.0;
}
