shader_type canvas_item;
uniform float scroll_speed : hint_range(0, 2) = 0.08;
uniform float angle_degrees : hint_range(0, 360) = 45.0;
uniform float repeat_x : hint_range(1, 20) = 20;
uniform float repeat_y : hint_range(1, 20) = 12;
uniform float row_offset : hint_range(0, 1) = 1;
uniform sampler2D texture_to_scroll;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    float angle_rad = radians(angle_degrees);
    vec2 direction = vec2(cos(angle_rad), sin(angle_rad));
    vec2 offset_uv = UV - (TIME * scroll_speed * direction);
    float offset = fract(floor(offset_uv.y * repeat_y) * 0.5) > 0.0 ? (row_offset * 0.324) : 0.0;
    offset_uv.x += offset;
    vec2 scaled_uv = vec2(fract(offset_uv.x * repeat_x),
                          fract(offset_uv.y * repeat_y));
    vec2 tex_size = vec2(textureSize(texture_to_scroll, 0));
    vec2 snappedUV = (floor(scaled_uv * tex_size) + 0.5) / tex_size;
    COLOR = texture(texture_to_scroll, snappedUV) * tint_color;
}