#define SDF_PX 8.0
#define EDGE_GAMMA 0.105
#define FONT_SIZE 48.0
uniform sampler2D u_sdf_map;

layout(std140) uniform commonUniforms {
  vec4 u_stroke_color;
  vec2 u_sdf_map_size;
  float u_raisingHeight;
  float u_stroke_width;
  float u_halo_blur;
  float u_gamma_scale;
};


in vec4 v_color;
in vec4 v_stroke_color;
in vec2 v_uv;
in float v_gamma_scale;
in float v_fontScale;


#pragma include "picking"
out vec4 outputColor;

void main() {
  // get style data mapping

  // get sdf from atlas
  float dist = texture(SAMPLER_2D(u_sdf_map), v_uv).a;

  lowp float buff = (6.0 - u_stroke_width / v_fontScale) / SDF_PX;
  highp float gamma = (u_halo_blur * 1.19 / SDF_PX + EDGE_GAMMA) / (v_fontScale * u_gamma_scale) / 1.0;

  highp float gamma_scaled = gamma * v_gamma_scale;

  highp float alpha = smoothstep(buff - gamma_scaled, buff + gamma_scaled, dist);

  outputColor = mix(v_color, v_stroke_color, smoothstep(0., 0.5, 1.- dist));

  outputColor.a *= alpha;
   // 作为 mask 模板时需要丢弃透明的像素
  if (outputColor.a < 0.01) {
    discard;
  }
  outputColor = filterColor(outputColor);
}
