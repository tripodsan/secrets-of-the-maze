shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform sampler2D tex;
uniform float time;
void fragment() {
  vec2 n = vec2(0.5, 0.5)-UV;
  float angle = atan(n.y/n.x);
  vec2 displace = sin(cos(time*2.0)*angle*5.0)*sin(cos(time*7.0)+angle*11.0)*n;
  vec2 displace2 = -cos(sin(time*3.0)*angle*4.0)*sin(cos(time*2.0)+angle*5.0)*n;
  //;
  vec4 c1 = texture(tex, (UV+displace*0.4));
  vec4 c2 = texture(tex, (UV+displace2*0.3));
  //COLOR = (c1+c2)*vec4(0.4, 1.0, 0.4, 1.0); 
  COLOR = (c1*vec4(1.0, 0.4, 1.0, 1.0))+(c2*vec4(0.4, 1.0, 0.4, 1.0)); 
 // Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
