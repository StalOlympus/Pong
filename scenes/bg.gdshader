shader_type canvas_item;

uniform vec4 dark_color : source_color = vec4(0.02, 0.02, 0.04, 1.0);
uniform vec4 accent_color : source_color = vec4(0.05, 0.05, 0.1, 1.0);
uniform float vignette_intensity : hint_range(0.0, 5.0) = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // Create subtle pattern
    vec2 uv = UV;
    
    // Vignette effect
    vec2 vign_uv = uv * 2.0 - 1.0;
    float vign = length(vign_uv);
    vign = smoothstep(0.2, 2.0, vign);
    
    // Mix colors with vignette
    vec4 color = mix(dark_color, accent_color, 
        sin(uv.x * 4.0 + TIME * 0.1) * sin(uv.y * 4.0 + TIME * 0.1) * 0.1);
    
    // Apply vignette
    color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), vign * vignette_opacity);
    
    COLOR = color;
}
