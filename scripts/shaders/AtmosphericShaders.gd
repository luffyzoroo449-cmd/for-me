## AtmosphericShaders.gd
## Central reference for high-fidelity 2D shader logic.
## Copy these into individual .gdshader files in Godot.

# --- 1. RIM LIGHT (For Hero Visibility) ---
# canvas_item / billboard
# uniform vec4 rim_color : source_color = vec4(1.0, 0.8, 0.4, 1.0);
# uniform float rim_width : hint_range(0, 10) = 2.0;
# void fragment() {
#     vec4 col = texture(TEXTURE, UV);
#     if (col.a > 0.1) {
#         float au = texture(TEXTURE, UV + vec2(0, TEXTURE_PIXEL_SIZE.y * rim_width)).a;
#         float ad = texture(TEXTURE, UV - vec2(0, TEXTURE_PIXEL_SIZE.y * rim_width)).a;
#         float al = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x * rim_width, 0)).a;
#         float ar = texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x * rim_width, 0)).a;
#         if (au*ad*al*ar < 1.0) { COLOR = mix(col, rim_color, 0.5); }
#     }
# }

# --- 2. HEAT DISTORTION (For Lava Beast) ---
# uniform sampler2D noise;
# void fragment() {
#     vec2 distort = texture(noise, UV + TIME * 0.1).rg * 0.05;
#     COLOR = texture(SCREEN_TEXTURE, SCREEN_UV + distort);
# }

# --- 3. WET SHINE (For Water Phantom / Rain) ---
# uniform float shine_speed = 2.0;
# void fragment() {
#     float shine = step(0.5, sin(UV.x * 10.0 + TIME * shine_speed));
#     COLOR.rgb += shine * 0.2; # Add slight white glint
# }
