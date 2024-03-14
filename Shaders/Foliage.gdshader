shader_type canvas_item;

uniform vec4 light_color : source_color;
uniform float wind_speed = 0.5;
uniform float elasticity = 2.5;


void vertex() {
	if (VERTEX.y < 0.0){
		VERTEX += vec2(sin(TIME * wind_speed) * elasticity, 0);
	}
	
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	//vec3 color_wo_red = COLOR.rgb * vec3(0, 1, 1);
	//COLOR.rgb = color_wo_red;
	//float amount_of_red_and_blue = length(color_wo_red);
	//float mask = step(0.1, amount_of_red_and_blue);
	//COLOR.rgb = vec3(mask);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
