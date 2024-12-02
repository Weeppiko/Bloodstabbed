uniform vec2  resolution;
uniform float sharpness;
vec2 sharpen(vec2 pix_coord) {
  vec2 norm = (fract(pix_coord) - 0.5) * 2.0;
  vec2 norm2 = norm * norm;
  return floor(pix_coord) + norm * pow(norm2, vec2(sharpness, sharpness)) / 2.0 + 0.5;
}
vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {
  vec4 pixel = Texel(tex, sharpen(texCoord * resolution) / resolution);
  return pixel * color;
}

