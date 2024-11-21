shader_type canvas_item;

//uniform float pixel_size = 0.01;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D text;

void fragment() {

	//float x = ((SCREEN_UV.x * SCREEN_PIXEL_SIZE.x) / pixel_size) / SCREEN_PIXEL_SIZE.x;
	//float y = ((SCREEN_UV.y * SCREEN_PIXEL_SIZE.y) / pixel_size) / SCREEN_PIXEL_SIZE.y;
	//float x = round(floor((SCREEN_UV.x * SCREEN_PIXEL_SIZE.x) / pixel_size) / SCREEN_PIXEL_SIZE.x);
	//float x = round(round(SCREEN_UV.x/0.01) / SCREEN_PIXEL_SIZE.x);

	//vec2 res = floor(SCREEN_UV / 100.0) * 100.0;


	//vec4 col = textureLod(screen_texture, res, 0.0);
	//vec4 col = textureLod(screen_texture, round(SCREEN_UV / pixel_size) * pixel_size, 0.0);
	float pixel_size = 0.005;
	vec4 col = textureLod(screen_texture, round(SCREEN_UV/pixel_size) * pixel_size, 0.0);
	//vec4 col = vec4(SCREEN_UV.x, SCREEN_UV.y, 0.0, 1.0);
	COLOR = col;
}
