const float pi = atan(1.0) * 4.0;
uniform float wave_phase     = 0.0;
uniform float wave_division  = 18.0;
uniform float wave_strength  = 0.2;
uniform float wave_length    = 0.5;
uniform float wave_precision = 4.0;
vec4 effect( vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord ) {
  float wave  = floor( (scrCoord.y / love_ScreenSize.y) * wave_division) / wave_division;
  float stepx = wave / wave_length;
  float phase = radians(floor( degrees(wave_phase) / wave_precision ) * wave_precision);
  texCoord.x += sin( (phase + stepx) * pi ) * wave_strength;
  return Texel(tex, texCoord) * color;
}
