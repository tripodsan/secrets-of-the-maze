shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform float lod: hint_range(0.0, 5) = 0.0;

uniform float darken: hint_range(0.0, 1.0) = 0.0;

void fragment(){
  vec4 color = texture(SCREEN_TEXTURE, UV, lod);
  color.rgb = mix(color.rgb, vec3(0), darken);
  COLOR = color;
}
