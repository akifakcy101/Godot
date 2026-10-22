shader_type canvas_item;
render_mode unshaded;

uniform vec4 tint : source_color = vec4(1.0, 0.30, 0.30, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.55;
uniform float edge_width : hint_range(0.0, 0.25) = 0.10;

uniform vec4 edge_top    : source_color = vec4(0.30, 1.00, 0.53, 1.0);
uniform vec4 edge_right  : source_color = vec4(0.30, 0.62, 1.00, 1.0);
uniform vec4 edge_bottom : source_color = vec4(1.00, 0.30, 0.30, 1.0);
uniform vec4 edge_left   : source_color = vec4(1.00, 0.85, 0.30, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    vec3 col = mix(tex.rgb, tint.rgb, tint_strength);

    float w = edge_width;
    vec4 edge_color = vec4(0.0);

    if (UV.y < w) {
        edge_color = edge_top;
    } else if (UV.y > 1.0 - w) {
        edge_color = edge_bottom;
    } else if (UV.x < w) {
        edge_color = edge_left;
    } else if (UV.x > 1.0 - w) {
        edge_color = edge_right;
    }

    col = mix(col, edge_color.rgb, edge_color.a);
    COLOR = vec4(col, tex.a);
}