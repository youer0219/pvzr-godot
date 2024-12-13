shader_type canvas_item;

uniform vec4 bottom_color: source_color;
uniform vec4 top_color: source_color;

uniform float beam_distance: hint_range(0.0, 0.3);
uniform float beam_height: hint_range(0.0, 0.1);
uniform float beam_width: hint_range(0.0, 0.5);
uniform int total_phases: hint_range(2, 20, 1);


float rand(float n){return fract(sin(n) * 43758.5453123);}


float noise(float p){
	float fl = floor(p);
  float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}


float fmod(float x, float y) {
	return x - floor(x / y) * y;
}


vec4 lerp(vec4 a, vec4 b, float w) {
	return a + w * (b - a);
}


void fragment() {
	float t = float(total_phases);
	float s = 1.0 / t;
	float d = fmod(UV.y, s);
	float i = floor(UV.y * t);
	float ci = i + 1.0;
	float cit = ci / t;
	float beam_pos = s - d - beam_distance;
	float effective_beam_width = beam_width * cit + sqrt(pow(beam_height / 2.0, 2.0) - pow(beam_pos - beam_height / 2.0, 2.0));
	float beam_x = fmod(TIME * noise(ci) * cit, 1.0);
	float best_distance = min(abs(beam_x - UV.x), 1.0 - abs(beam_x - UV.x));
	
	if (beam_pos >= 0.0 && beam_pos <= beam_height && 
		best_distance <= effective_beam_width) i++;
	
	
	i = clamp(i, 0.0, t - 1.0);
	
	COLOR = lerp(top_color, bottom_color, i / (t - 1.0));
}