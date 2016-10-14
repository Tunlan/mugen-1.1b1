/* Perspective modes:
 *  PERSPECTIVE_NONE
 *  PERSPECTIVE_STANDARD
 *  PERSPECTIVE_EVEN (default)
 *
 * Index color mode:
 *  INDEX_STANDARD
 *  INDEX_GEFORCE7
 *  INDEX_SAFE (default)
 *
 * Palfx disabling:
 *  PALFX_DISABLE
 *  PALFX_DISABLE_COLORBAL
 *  PALFX_DISABLE_INVERTALL
 *
 */
#version 120
#pragma optimize(on)
////*EB_DEFINES*////

//precision mediump float;

uniform sampler2D texunit0;
uniform sampler1D texunit1;
uniform bool mask;

uniform vec3 add;
uniform vec3 mul;
uniform bool invertall;
uniform float colorbal;
uniform float src_alphamul;

uniform vec2 texsize;

#if defined(INDEX_STANDARD) // This works on Radeon Mobility 1400 and is faster
  #define index_correction(a)   (a)
#elif defined(INDEX_GEFORCE7) // GeForce 7, some ATI 4xxx, possibly GeForce 6
  #define index_correction(a)   ((a) * 255.99 / 256.0)
#else // INDEX_SAFE -- Radeon Mobility HD 3400
  #define index_correction(a)   ((a) * 255.1 / 256.0)
#endif

/*
 * Applies color saturation to the color.
 */
void apply_colorbal(inout vec4 color)
{
  if (colorbal != 1.0) {
    float grey;
    grey = color.r * .3125 + color.g * .4375 + color.b * .25;
    color.rgb = mix(vec3(grey, grey, grey), color.rgb, colorbal);
  }
}

/*
 * Applies invertall to the color.
 */
void apply_invertall(inout vec4 color)
{
  if (invertall)
#if !defined(PREMUL)
    color.rgb = 1.0 - color.rgb;
#else
    color.rgb = color.a - color.rgb;
#endif
}

/*
 * Applies palfx to the color.
 */
void palfx(inout vec4 color)
{
#if !defined(PALFX_DISABLE_COLORBAL)
  apply_colorbal(color);
#endif
  
#if !defined(PALFX_DISABLE_INVERTALL)
  apply_invertall(color);
#endif
    
#if !defined(PREMUL)
  color.rgb = (color.rgb + add) * mul;
#else
  color.rgb = (color.rgb + color.a * add) * mul;
#endif
  
  //Clamp:Required//color = clamp(color, 0.0, 1.0);
}

/*
 * Get nearest-neightbor color.  Performs fragment discard if masking is on.
 */
vec4 nearest()
{
#if defined(PERSPECTIVE_NONE)
  vec4 idxv = texture2D(texunit0, gl_TexCoord[0].st);
#elif defined(PERSPECTIVE_STANDARD)
  vec4 idxv = texture2D(texunit0, gl_TexCoord[0].st / gl_TexCoord[0].q);
#else // PERSPECTIVE_EVEN
  vec4 idxv = texture2D(texunit0, vec2(gl_TexCoord[0].s / gl_TexCoord[0].q, gl_TexCoord[0].t));
#endif
  float idx = idxv.r;

  /*if (mask && idx == 0.0) {
    discard;
  }*/

  vec4 color = texture1D(texunit1, index_correction(idx));
#if defined(PREMUL)
  if (mask)
    color.rgb *= color.a;
#endif

  // Non-masked forces alpha to 1
  if (!mask)
    color.a = 1.0;

  // Hack to mask transparency when src_alphamul+dst_alphamul != 1 or 2
  if (color.a == 0.0)
    discard;

#if !defined(PREMUL)
  color.a *= src_alphamul;
#else
  color *= src_alphamul;
#endif

  return color;
}

/*
 * Shader converting 8-bit indexed color to RGBA.
 */
void main()
{
  vec4 color = nearest();

#if !defined(PALFX_DISABLE)
  palfx(color);
#endif
 
  gl_FragColor = color;
}