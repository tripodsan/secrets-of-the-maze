shader_type canvas_item;

global uniform vec4 player_pos_and_vel;

uniform float line_width = 0.01;
uniform vec4 color_0 : source_color;
uniform vec4 color_1 : source_color;
uniform bool debug = false;

varying float warp;

void vertex() {
  // lock sides based on vertext color: RGBA. > 50% means no lock, < 50% means lock
  // the color is pass with the modulate propery of the tiles.
  // R: top-left, G: bottom-left: B: bottom-right, A: top-right
  if (
    (COLOR.r > 0.5 && VERTEX_ID == 0) ||
    (COLOR.g > 0.5 && VERTEX_ID == 1) ||
    (COLOR.b > 0.5 && VERTEX_ID == 2) ||
    (COLOR.a > 0.5 && VERTEX_ID == 3)) {

    vec2 wpos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
    float amp = length(player_pos_and_vel.zw) * 0.001;
    vec2 dir = wpos - player_pos_and_vel.xy;
    warp = exp(-dot(dir, dir) * 0.0001) * amp;
    VERTEX = VERTEX + dir * warp;
  }
}

void fragment() {
  vec2 bl = smoothstep(vec2(0), vec2(line_width), UV);       // bottom-left
  vec2 tr = smoothstep(vec2(0), vec2(line_width),1.0-UV);   // top-right
  vec2 c = abs(UV - vec2(0.5)); // corners
  vec4 line_color = mix(color_0, vec4(1), warp * c.x * c.y * 2.0);
  if (debug) {
    if (UV.x < 0.5 && UV.y < 0.5) {
      COLOR.rgb = vec3(round(COLOR.r));
    } else if (UV.x >= 0.5 && UV.y < 0.5) {
      COLOR.rgb = vec3(round(COLOR.a));
    } else if (UV.x < 0.5 && UV.y >= 0.5) {
      COLOR.rgb = vec3(round(COLOR.g));
    } else {
      COLOR.rgb = vec3(round(COLOR.b));
    }
    COLOR.a = 1.0;
  } else {
    COLOR.rgba = mix(line_color, color_1, bl.x * bl.y * tr.x * tr.y);
  }
}
