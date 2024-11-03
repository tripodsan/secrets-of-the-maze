shader_type canvas_item;

global uniform vec4 player_pos_and_vel;

uniform float line_width = 0.01;
uniform vec4 color_0 : source_color;
uniform vec4 color_1 : source_color;

varying float warp;

void vertex() {
  vec2 wpos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
  float amp = length(player_pos_and_vel.zw) * 0.001;
  vec2 dir = wpos - player_pos_and_vel.xy;
  warp = exp(-dot(dir, dir) * 0.0001) * amp;
  VERTEX = VERTEX + dir * warp;
}

void fragment() {
  vec2 bl = smoothstep(vec2(0), vec2(line_width), UV);       // bottom-left
  vec2 tr = smoothstep(vec2(0), vec2(line_width),1.0-UV);   // top-right
  vec2 c = abs(UV - vec2(0.5)); // corners
  vec4 line_color = mix(color_0, vec4(1), warp * c.x * c.y * 1.1);
  COLOR.rgba = mix(line_color, color_1, bl.x * bl.y * tr.x * tr.y);
  //float pct = 1.0 - borders.x * borders.y;
  //COLOR.a = pct;
}
