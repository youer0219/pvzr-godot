shader_type canvas_item;

uniform float outline_width = 1.0;
uniform vec4 outline_color:source_color = vec4(0,0,0,1);

void fragment() {
	vec2 uv = UV;
	
	vec2 uv_up = uv + vec2(0,TEXTURE_PIXEL_SIZE.y) * outline_width;
	vec2 uv_down = uv + vec2(0,-TEXTURE_PIXEL_SIZE.y) * outline_width;
	vec2 uv_left = uv + vec2(TEXTURE_PIXEL_SIZE.x,0) * outline_width;
	vec2 uv_right = uv + vec2(-TEXTURE_PIXEL_SIZE.x,0) * outline_width;
	
	vec4 color_up = texture(TEXTURE,uv_up);
	vec4 color_down = texture(TEXTURE,uv_down);
	vec4 color_left = texture(TEXTURE,uv_left);
	vec4 color_right = texture(TEXTURE,uv_right);
	
	vec4 outline = color_up + color_down + color_left + color_right;
	outline.rbg = outline_color.rbg;
	outline.a = min(outline.a,1);
	
	vec4 original_color = texture(TEXTURE,UV);
	COLOR = mix(outline , original_color , original_color.a);
}

