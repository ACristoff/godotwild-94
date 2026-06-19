shader_type canvas_item;
// License: CC0
// Author: Ultipuk, https://ultipuk.xyz
// Link: https://godotshaders.com/shader/transition-with-a-pattern-texture/

//#define USE_BACKGROUND_TEXTURE
//#define USE_CLOSING
//#define REMOVE_DISTORTION

uniform float progress: hint_range(0.0, 1.0) = 0.0;
uniform float width: hint_range(0.0, 1.0) = 0.5;
uniform sampler2D tile_texture: source_color, repeat_disable, filter_nearest;
uniform float tile_pixel_size = 32.0;
uniform float tile_grown_scale: hint_range(0.0, 16.0) = 2.0;
uniform sampler2D transition_texture: filter_nearest;
#ifdef USE_BACKGROUND_TEXTURE
uniform sampler2D background_texture: source_color, filter_nearest;
#endif

void fragment() {
	// Snap FRAGCOORD to the pixel grid before computing tile UV
	vec2 pixel_pos = floor(FRAGCOORD.xy);

	vec2 tile_uv = vec2(
		fract(pixel_pos.x / tile_pixel_size),
		fract(pixel_pos.y / tile_pixel_size)
	);

#ifdef REMOVE_DISTORTION
	vec2 tiles = vec2(1.0 / SCREEN_PIXEL_SIZE / tile_pixel_size);
	vec2 transition_uv = ceil(UV * tiles) / tiles;
#else
	vec2 transition_uv = UV;
#endif

#ifdef USE_CLOSING
	float part, transition;

	if (progress > 0.5) {
		part = (1.0 - (progress - 0.5) * 2.0) * (1.0 + 2.0 * width) - width;
		transition = 1.0 - texture(transition_texture, transition_uv).r;
	} else {
		part = 2.0 * progress * (1.0 + 2.0 * width) - width;
		transition = texture(transition_texture, transition_uv).r;
	}
#else
	float part = progress * (1.0 + 2.0 * width) - width;
	float transition = texture(transition_texture, transition_uv).r;
#endif

	float window = max(0.0, min(1.0, width + (part - transition) / width));

	tile_uv = tile_uv * 2.0 - 1.0;
	tile_uv /= window * tile_grown_scale;
	tile_uv = (tile_uv + 1.0) * 0.5;

	// Snap final UV to texel centers of tile_texture
	vec2 tex_size = vec2(textureSize(tile_texture, 0));
	tile_uv = (floor(tile_uv * tex_size) + 0.5) / tex_size;

#ifdef USE_BACKGROUND_TEXTURE
	vec4 tile = texture(tile_texture, tile_uv) * texture(background_texture, UV);
#else
	vec4 tile = texture(tile_texture, tile_uv);
#endif

	COLOR *= tile;
}