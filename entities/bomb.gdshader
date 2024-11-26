shader_type canvas_item;

void fragment() {
  COLOR = mix(vec4(0.0), vec4(1.0, 0.5, 1.0, 1.0), sin(TIME*10.0)) * COLOR * 2.0;
}
