shader_type canvas_item;


uniform sampler2D noise0: source_color;

uniform float distortion: hint_range(-1.0, 1.0, 0.02) = 0.2;
uniform vec2 scroll0 = vec2(0.1, 0.);
uniform int border = 0;

void fragment() {
  vec2 n_uv = vec2(TIME * 0.01, UV.y);
  float n0 = texture(noise0, fract(n_uv + scroll0 * TIME)).r;
  float d = distortion;
  if (((border & 1) != 0) && UV.y < 0.2) {
    d = mix(0, d, UV.y / 0.2);
  }
  if (((border & 2) != 0) && UV.x > 0.8) {
    d = mix(0, d, (1.0 - UV.x) / 0.2);
  }
  if (((border & 4) != 0) && UV.y > 0.8) {
    d = mix(0, d, (1.0 - UV.y) / 0.2);
  }
  if (((border & 8) != 0) && UV.x < 0.2) {
    d = mix(0, d, UV.x / 0.2);
  }
  
  vec4 color = texture(TEXTURE, (UV + vec2(n0, 0) * d));
  
  //
  COLOR = color;
}
