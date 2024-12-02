uniform sampler2D palette;
uniform float offset;
vec4 effect(vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords) {
  vec4 pixel = Texel(tex, texture_coords) * color;
  pixel = vec4( Texel( palette, vec2(pixel.r, offset) ).rgb, 1.0);
  return pixel;
}
