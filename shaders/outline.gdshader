shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 line_color : source_color = vec4(0.09, 0.075, 0.063, 1.0);

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	vec2 px = SCREEN_PIXEL_SIZE;
	float edge = max(
		max(textureLod(screen_texture, SCREEN_UV + vec2(px.x, 0.0), 0.0).a, textureLod(screen_texture, SCREEN_UV - vec2(px.x, 0.0), 0.0).a),
		max(textureLod(screen_texture, SCREEN_UV + vec2(0.0, px.y), 0.0).a, textureLod(screen_texture, SCREEN_UV - vec2(0.0, px.y), 0.0).a));
	if (c.a > 0.0001) {
		c.rgb /= c.a;
		COLOR *= c;
	} else {
		COLOR = vec4(line_color.rgb, edge * COLOR.a);
	}
}
