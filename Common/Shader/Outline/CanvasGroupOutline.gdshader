shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;
uniform bool add_margins = true; // only useful when inside is false

void vertex() {
	if (add_margins) {
		VERTEX += (UV * 2.0 - 1.0) * width;
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;

		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a == 0.0) == inside) {
				return true;
			}
		}
	}

	return false;
}

void fragment() {
	vec2 uv = SCREEN_UV;

    vec4 base_color = vec4(0.15);

   	if (base_color.a > 0.0001) {
        base_color.rgb /= base_color.a;
    }

	vec4 base_color2 = base_color;

	if (add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / SCREEN_PIXEL_SIZE + vec2(width * 2.0));

		uv = (uv - texture_pixel_size * width) * SCREEN_PIXEL_SIZE / texture_pixel_size;

		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
			base_color.a = 0.0;
		} else {
			base_color = textureLod(screen_texture, uv, 0.0);
		}
	} else {
		base_color = textureLod(screen_texture, uv, 0.0);
	}

	if ((base_color.a > 0.0) == inside && hasContraryNeighbour(uv, SCREEN_PIXEL_SIZE, screen_texture)) {
		base_color.rgb = inside ? mix(base_color.rgb, color.rgb, color.a) : color.rgb;
		base_color.a += (1.0 - base_color.a) * color.a;
	}

	COLOR = base_color;
}