/*shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform vec4 outline_color : source_color;
uniform float outline_width = 2.0;
uniform bool constant_width = true;
uniform bool outline_enabled = true;

void fragment() {
	vec4 pixelatedtext = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec2 pixel_size = 1.0 / VIEWPORT_SIZE;
	ALBEDO = pixelatedtext.rgb;
	for(int y = -1*int(outline_width); y <= 1*int(outline_width); y++)
	for(int x = -1*int(outline_width); x <= 1*int(outline_width); x++)
	{
		vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x),float(y)) * pixel_size );
		if(tex.a == 0.0 && SCREEN_UV.x + float(x) * pixel_size.x < 1.0 && SCREEN_UV.x + float(x) * pixel_size.x > 0.0 && SCREEN_UV.y + float(y) * pixel_size.y < 1.0 && SCREEN_UV.y + float(y) * pixel_size.y > 0.0 && outline_enabled)
		{
			ALBEDO = outline_color.rgb;
			ALPHA = outline_color.a;
		}
	}
	
}*/

shader_type spatial;
render_mode cull_front, unshaded;

uniform vec4 outline_color : source_color;
uniform float outline_width = 1.0;
uniform bool outline_enabled = true;

void vertex() {
	if(outline_enabled){
		
		vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
		vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
	
		vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 2.0;
	
		clip_position.xy += offset;
	
		POSITION = clip_position;
	}
}

void fragment() {
	if(outline_enabled){
		ALBEDO = outline_color.rgb;
		if (outline_color.a < 1.0) {
			ALPHA = outline_color.a;
		}
	}
}