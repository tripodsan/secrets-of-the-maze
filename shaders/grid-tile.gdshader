shader_type canvas_item;

global uniform vec4 player_pos_and_vel;
global uniform vec2 portal_pos;
global uniform vec2 maze_scale;

uniform float line_width = 0.01;
uniform vec4 color_0 : source_color;
uniform vec4 color_1 : source_color;
uniform bool debug = false;

varying float warp;
varying float portal_warp;

void vertex() {
  // lock sides based on vertext color: RGBA. > 50% means no lock, < 50% means lock
  // the color is pass with the modulate propery of the tiles.
  // R: top-left, G: bottom-left: B: bottom-right, A: top-right
  if (
    (COLOR.r > 0.5 && VERTEX_ID == 0) ||
    (COLOR.g > 0.5 && VERTEX_ID == 1) ||
    (COLOR.b > 0.5 && VERTEX_ID == 2) ||
    (COLOR.a > 0.5 && VERTEX_ID == 3)) {
    vec4 ppv = player_pos_and_vel;
    vec2 pp = portal_pos;
    vec2 ms = maze_scale;
    //pp = vec2(8800, -2212);
    //ms = vec2(0.5, 0.5);
    //ppv = vec4(8500.0, -2212, 1500.0, 1500.0) *ms.x;

    vec2 wpos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
    vec2 dir_player = wpos - ppv.xy;
    vec2 dir_portal = wpos - pp.xy;
    float dist_portal = dot(dir_portal, dir_portal) / (ms.x*ms.x);

    portal_warp = exp(-dist_portal * 0.00005) * 1.1;
    VERTEX += - dir_portal * portal_warp + portal_warp * vec2(0.0, 200.0);

    if (dist_portal >= 55000.0) {
      float  dist_player = dot(dir_player, dir_player) / (ms.x * ms.x);
      float amp = length(ppv.zw) * 0.001;
      warp = exp(-dist_player * 0.0001) * amp;
      VERTEX += dir_player * warp;
    }
  } else {
    warp = 0.0;
    portal_warp = 0.0;  
  }
}

void fragment() {
  vec2 bl = smoothstep(vec2(0), vec2(line_width), UV);       // bottom-left
  vec2 tr = smoothstep(vec2(0), vec2(line_width),1.0-UV);   // top-right
  vec2 c = abs(UV - vec2(0.5)); // corners
  vec4 line_color = mix(color_0, vec4(1), warp * c.x * c.y * 2.0);
  line_color = mix(line_color, vec4(1), portal_warp);
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
    float pulse = sin(TIME * 2.0)*0.2 + 0.8;
    COLOR.rgba = mix(line_color, color_1 + vec4(portal_warp * pulse), bl.x * bl.y * tr.x * tr.y);
    //COLOR.rgb = vec3(warp);
    //COLOR.a = 0.9;
  }
}
