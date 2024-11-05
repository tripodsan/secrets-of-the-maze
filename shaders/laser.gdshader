shader_type canvas_item;

uniform sampler2D laserTexture: repeat_enable;

void fragment() {
  float a = texture(laserTexture, vec2(UV.x-TIME, UV.y)).a;
  COLOR = a*vec4(1.0-UV.x*0.5, 0.5, 1.0-UV.x*0.5, UV.x*2.0);
}
