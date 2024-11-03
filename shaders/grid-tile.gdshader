shader_type canvas_item;

global uniform vec2 player_pos;

uniform float line_width = 0.01;
uniform vec4 color_0 : source_color;
uniform vec4 color_1 : source_color;

varying float warp;

void vertex() {
  vec2 wpos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
  vec2 dir = wpos - player_pos;
  warp = exp(-dot(dir, dir) * 0.0001) * 0.4;
  VERTEX = VERTEX + dir * warp;
}

void fragment() {
  vec2 bl = smoothstep(vec2(0), vec2(line_width), UV);       // bottom-left
  vec2 tr = smoothstep(vec2(0), vec2(line_width),1.0-UV);   // top-right
  vec4 line_color = mix(color_0, vec4(1), warp);
  COLOR.rgba = mix(line_color, color_1, bl.x * bl.y * tr.x * tr.y);
  //float pct = 1.0 - borders.x * borders.y;
  //COLOR.a = pct;
}
