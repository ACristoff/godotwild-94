shader_type canvas_item;

uniform vec4 from_color : source_color;
uniform vec4 to_color : source_color;

uniform vec4 modulate_from_color : source_color;
uniform vec4 modulate_color : source_color = vec4(1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    bool replace_match =
        tex.r == from_color.r &&
        tex.g == from_color.g &&
        tex.b == from_color.b;

    bool modulate_match =
        tex.r == modulate_from_color.r &&
        tex.g == modulate_from_color.g &&
        tex.b == modulate_from_color.b;

    if (replace_match) {
        tex.rgb = to_color.rgb;
    }
    else if (modulate_match) {
        tex.rgb *= modulate_color.rgb;
    }

    COLOR = tex;
}