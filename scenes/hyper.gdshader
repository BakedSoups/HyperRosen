shader_type spatial;
render_mode unshaded, depth_test_disabled;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float hyperbolic_factor : hint_range(0.1, 10.0) = 1.0;

void vertex() {
    POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
    // Get the screen UV coordinates
    vec2 uv = SCREEN_UV;

    // Calculate distance from center (0.5, 0.5)
    vec2 center_offset = uv - vec2(0.5);
    float dist = length(center_offset);

    // Apply hyperbolic distortion
    float scale = 1.0 / (1.0 + dist * hyperbolic_factor);
    vec2 distorted_uv = vec2(0.5) + center_offset * scale;

    // Sample the screen texture with our distorted coordinates
    vec4 screen_color = texture(SCREEN_TEXTURE, distorted_uv);

    // Output the final color
    ALBEDO = screen_color.rgb;
    ALPHA = 1.0;
}
