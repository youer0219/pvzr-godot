shader_type canvas_item;

uniform float speed = 0.5;

void fragment()
{
	ivec2 txsize = textureSize(TEXTURE,0);
	int framesize = (txsize.y/3);
	float t = 0.0;
	float fract_value = fract(TIME*speed);
	if (fract_value<0.3){
		t=0.0;
	}
	else{
		if (fract_value<0.6){
			t=(float(framesize)/float(txsize.y));
		}
		else{
			if (fract_value<0.9){
				t=(float(framesize*2)/float(txsize.y));
			}
		}
	}
	vec2 iuv = vec2(UV.x,UV.y+(t));
	COLOR = texture(TEXTURE,iuv);
}