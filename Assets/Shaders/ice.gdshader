shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D ice_texture : source_color, filter_nearest_mipmap;
uniform float refraction = 0.02;
uniform vec4 tint : source_color = vec4(0.7, 0.9, 1.0, 0.8);

uniform vec2 tiling = vec2(1.0);
uniform vec2 offset = vec2(0.0);

void fragment() {
    vec2 ice_uv = fract(UV * tiling + offset);

    vec3 ice = texture(ice_texture, ice_uv).rgb;

    // Use the noise texture as distortion
    vec2 distortion = (ice.rg * 2.0 - 1.0);

    vec4 scene = texture(SCREEN_TEXTURE, SCREEN_UV + distortion);

    vec4 tex = texture(TEXTURE, UV);

    vec3 color = scene.rgb * ice * tint.rgb;

    COLOR = vec4(color, tex.a * tint.a);
}