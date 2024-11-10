shader_type canvas_item;

void fragment() {
    // Sample the texture at the current UV coordinates
    vec4 tex_color = texture(TEXTURE, FRAGCOORD.xy / SCREEN_PIXEL_SIZE);

    // Output the color from the texture
    COLOR = tex_color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
