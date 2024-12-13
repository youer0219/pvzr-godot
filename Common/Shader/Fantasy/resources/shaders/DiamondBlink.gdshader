shader_type canvas_item;

uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;

// Size of each diamond, in pixels.
uniform float diamondPixelSize = 10.0;

void fragment() {
	float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
	float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);
	
	if ((xDistance + yDistance + UV.x + UV.y > (TIME - (2.0 * floor(TIME / 2.0))) * 3.0) || xDistance + yDistance + UV.x + UV.y < (TIME - (2.0 * floor(TIME / 2.0))) * 3.0 - 2.0) {
		COLOR = color1;
	} else {
		COLOR = color2;
	}
}