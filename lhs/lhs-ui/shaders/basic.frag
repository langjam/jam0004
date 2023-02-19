precision mediump float;

uniform float u_time;

float rand(vec2 co);

void main() {
  float offset = rand(vec2(0.0, 1.0));
  
  float r = sin(u_time * 0.0003);
  float g = sin(u_time * 0.0005);
  float b = sin(u_time * 0.0007);
  float a = offset;

  gl_FragColor = vec4(r, g, b, a);
}

float rand(vec2 co) {
  return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
