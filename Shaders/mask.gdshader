shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform vec3 tint : source_color;

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);
	COLOR.a = texture(TEXTURE, UV).a;
	COLOR.rgb += tint.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
