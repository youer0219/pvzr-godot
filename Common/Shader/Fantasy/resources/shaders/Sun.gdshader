shader_type canvas_item;

uniform vec4 color: source_color;
uniform float radius = 0.4;
uniform float ray_distance = 0.05;
uniform float ray_width = 0.05;
uniform int total_rays: hint_range(0, 10, 2);
uniform float time_scale = 1.0;


float fmod(float x, float y) {
	return x - floor(x / y) * y;
}


bool is_angle_valid(float a, float d) {
	if (a < 0.0) {
		a += 2.0 * PI;
	}

	float r = ray_width / 2.0;
	float extra_a = sqrt(pow(r, 2.0) - pow(abs(d - r), 2.0)) * PI;

	float total_spacing = 2.0 * PI / float(total_rays);
	float ray_length = total_spacing / 2.0;
	float center = fmod(-TIME * time_scale, total_spacing);
	float left_limit = center - ray_length / 2.0 - extra_a;
	float right_limit = center + ray_length / 2.0 + extra_a;

	float m = fmod(a, total_spacing);

	return m >= left_limit && m <= right_limit || m >= left_limit + total_spacing || m <= right_limit - total_spacing;
}


void fragment() {
	float x = UV.x - 0.5;
	float y = UV.y - 0.5;
	float d = sqrt(pow(x, 2.0) + pow(y, 2.0));
	float angle = atan(y / x);

	float lower_border = radius + ray_distance + ray_width;
	float upper_border = radius + ray_distance;

	if (d <= radius || d >= upper_border && d <= lower_border && is_angle_valid(angle, d - radius - ray_distance)) {
		COLOR = color;
	} else {
		COLOR = vec4(0.0);
	}
}