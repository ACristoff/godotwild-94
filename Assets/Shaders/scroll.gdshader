shader_type canvas_item;

uniform sampler2D texture_to_scroll;
uniform sampler2D gradient_texture : source_color;

uniform float scroll_speed = 0.1;
uniform float angle_degrees : hint_range(0.0, 360.0) = 0.0;

uniform float repeat_x : hint_range(1.0, 20.0) = 20.0;
uniform float repeat_y : hint_range(1.0, 20.0) = 12.0;
uniform float row_offset : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float angle_rad = radians(angle_degrees);
    vec2 direction = vec2(cos(angle_rad), sin(angle_rad));

    vec2 uv = UV - TIME * scroll_speed * direction;

    float row = floor(uv.y * repeat_y);
    if (mod(row, 2.0) > 0.5) {
        uv.x += row_offset / repeat_x;
    }

    uv = fract(uv * vec2(repeat_x, repeat_y));

    vec2 tex_size = vec2(textureSize(texture_to_scroll, 0));
    uv = (floor(uv * tex_size) + 0.5) / tex_size;

    vec4 tex = texture(texture_to_scroll, uv);

    // Sample a GradientTexture2D using the sprite's UV.
    vec4 gradient = texture(gradient_texture, vec2(0.5, UV.y));

    COLOR = tex * gradient;
}