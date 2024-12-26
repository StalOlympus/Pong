shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);     // Green
uniform vec4 bottom_color : source_color = vec4(0.0, 0.5, 0.0, 1.0);  // Dark Green
uniform float edge_thickness = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);    // White

void fragment() {
    float position = UV.y;
    vec4 gradient_color = mix(bottom_color, top_color, position);

    // Calculate distance from the edge
    float dist_edge = min(UV.x, 1.0 - UV.x);
    float edge = smoothstep(edge_thickness, edge_thickness + 0.01, dist_edge);

    // Mix edge color and gradient color
    COLOR = mix(edge_color, gradient_color, edge);
}
