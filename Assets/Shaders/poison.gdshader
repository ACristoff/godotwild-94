shader_type canvas_item;

uniform vec4 bottom_color: source_color = vec4(1.0);
uniform vec4 top_color: source_color = vec4(vec3(0.0), 1.0);
uniform sampler2D tex : filter_nearest;
uniform int layer_count: hint_range(2, 80, 1);
uniform float time_scale: hint_range(0.0, 1.0) = 0.2;
uniform float base_intensity: hint_range(0.0, 1.0) = 0.5;
uniform float size: hint_range(0.00001, 1.0) = 0.1;

// Pixelation controls
uniform vec2 rect_size = vec2(512.0, 512.0); // set to your ColorRect's actual "size" property in the Inspector
uniform float pixel_scale = 3.0; // matches the node's scale factor, so blocks land on real screen pixels

vec4 lerp(vec4 a, vec4 b, float w) {
	return a + w * (b - a);
}

float fmod(float x, float y) {
	return x - floor(x / y) * y;
}

float rand(float n){return fract(sin(n) * 43758.5453123);}

bool cloud_layer(float x, float y, float h) {
	return y - sqrt((1.0 - pow(y - h, 2.0))) * base_intensity * texture(tex, vec2(fmod(x / size + rand(h), 1.0), fmod(y / size - TIME * time_scale, 1.0))).r < h;
}

void fragment() {
	// How many pixel "blocks" fit across the rect, accounting for the node's own scale
	vec2 grid = rect_size / pixel_scale;

	// Snap UV down to that block grid — this is the pixelation step
	vec2 pixelated_uv = floor(UV * grid) / grid;

	float y = 1.0 - pixelated_uv.y;
	for (int i = 0; i < layer_count; i++) {
		float h = float(i) / float(layer_count - 1);
		if (cloud_layer(pixelated_uv.x, y, h)) {
			COLOR = lerp(bottom_color, top_color, h);
			break;
		}
	}
}
