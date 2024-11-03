shader_type canvas_item;

global uniform vec2 player_pos;

void vertex() {
  vec2 wpos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
  vec2 dir = wpos - player_pos;
  float d = exp(-dot(dir, dir) * 0.0001) * 0.4;
  VERTEX = VERTEX + dir * d;
}

void fragment() {
  COLOR.rg = UV;
}
