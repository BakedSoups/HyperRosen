shader_type spatial;
render_mode unshaded, depth_test_disabled;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float dream_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float color_shift : hint_range(0.0, 1.0) = 0.3;
uniform float glow_amount : hint_range(0.0, 1.0) = 0.4;
uniform float time_scale : hint_range(0.1, 2.0) = 0.5;

void vertex() {
    POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
    float time = TIME * time_scale;

    // Get base UV coordinates
    vec2 uv = SCREEN_UV;

    // Create dreamy wave effect
    vec2 wave_offset;
    wave_offset.x = sin(time + uv.y * 4.0) * 0.003 * dream_intensity;
    wave_offset.y = cos(time + uv.x * 4.0) * 0.003 * dream_intensity;

    // Color shifting
    vec2 uv_r = uv + wave_offset + vec2(0.002 * color_shift, 0.0);
    vec2 uv_b = uv + wave_offset - vec2(0.002 * color_shift, 0.0);

    // Sample colors with offset
    vec4 tex_color = texture(SCREEN_TEXTURE, uv + wave_offset);
    float r = texture(SCREEN_TEXTURE, uv_r).r;
    float b = texture(SCREEN_TEXTURE, uv_b).b;

    // Create base color with chromatic aberration
    vec3 final_color = vec3(r, tex_color.g, b);

    // Add pink and blue tinting
    float pink_intensity = (sin(time * 0.5) * 0.5 + 0.5) * glow_amount;
    float blue_intensity = (cos(time * 0.5) * 0.5 + 0.5) * glow_amount;

    final_color += vec3(1.0, 0.4, 0.8) * pink_intensity; // Pink tint
    final_color += vec3(0.4, 0.6, 1.0) * blue_intensity; // Blue tint

    // Add vignette effect
    float vignette = 1.0 - length(uv - 0.5);
    vignette = smoothstep(0.0, 0.8, vignette);
    final_color *= mix(1.0, vignette, 0.3);

    ALBEDO = final_color;
    ALPHA = 1.0;
}