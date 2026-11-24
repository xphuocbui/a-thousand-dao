// canvas_map_terrain.gdshader - Claude for the user, 2026-11-23. Target: desktop, Forward+ and Compatibility, one
// full-screen canvas quad; about 14 texture samples a pixel (4 biome blends x 2 scales, elevation x 5, coast, river,
// noise x 2, sea ripples). The map's near terrain, Paradox style (user 2026-11-23: the painted near layer did not follow the biome data; picked
// "Paradox-style shader"). Every pixel reads the game's own data: the biome under it picks the texture (blended at
// borders with a noise-broken edge), the true elevation lights the relief, the signed distance to the true coast
// places the shore, the sea floor depth colours the water, and the river cells draw the rivers. Nothing is painted
// into fixed geography, so the terrain matches the data at every zoom. Display only.
shader_type canvas_item;

varying vec2 local_pos;   // the node's local px: tile coordinates come from it, whatever texture a draw call uses

const vec3 LUMA = vec3(0.3, 0.5, 0.2);
const float HEIGHT_BIAS = 0.4;       // added to texture light in the border weight

group_uniforms view;
uniform vec2 rect_size = vec2(1920.0, 1080.0);    // the node's size in px
uniform vec2 map_origin = vec2(0.0);               // local px of the map's top-left corner (tile 0, 0)
uniform float px_per_tile = 12.0;                  // screen px per game tile now
uniform vec2 grid = vec2(540.0, 360.0);            // game tiles
uniform vec2 fine = vec2(2160.0, 1440.0);          // data texels
group_uniforms data;
uniform sampler2D biome_map : filter_nearest;      // R8: biome id / 255
uniform sampler2D coast_map : filter_linear;       // RF: signed distance to the coast in tiles, + water
uniform sampler2D elev_map : filter_linear;        // RF: metres
uniform sampler2D river_map : filter_linear;       // R8 at 2x: traced river lines, width by flow
uniform sampler2D relief_map : filter_linear;      // RG8 at 2x: R = soft multi-light shade x 127.5, G = slope x 4
uniform sampler2D noise_map : filter_linear, repeat_enable;
uniform sampler2DArray biome_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
group_uniforms look;
uniform bool painted_land = false;     // true: the land is the painted texture of each draw call (user 2026-11-23:
                                        // "paint the land, and let sea be automated by our game"); false: biome textures
uniform float tex_tiles = 6.0;          // game tiles one texture repeat covers
uniform float edge_noise = 0.9;         // how far (fine texels) biome borders wander at the fine scale
uniform float edge_warp = 2.6;          // and at the broad scale
uniform float blend_sharpness = 1.6;    // bilinear weights raised to this: narrower borders between biomes
uniform float foam_strength = 0.7;      // surf along the shore
uniform float shore_tint = 0.5;         // lighter shallow water near the shore
uniform float shore_width = 0.8;        // tiles of that fringe
uniform float river_strength = 1.0;     // how strongly the game draws the rivers over the land
uniform float river_cut = 0.3;          // where the blurred river line is cut: higher = thinner
uniform float ripple_strength = 0.5;    // how much the sea texture's ripples show (paper style: low)
uniform float paper_grain = 0.0;        // parchment grain in the water (paper style)
uniform float ink_strength = 0.0;       // the inked coastline (paper style)
uniform float ink_width = 0.05;         // its half-width, tiles
uniform vec3 ink_col : source_color = vec3(0.22, 0.16, 0.10);
uniform float depth_from = 30.0;        // metres where the water starts to deepen in colour
uniform float depth_full = 3000.0;      // and is fully deep
uniform float relief = 1.0;             // baked hillshade strength
uniform float snow_from = 3300.0;       // metres where snow starts on peaks
uniform float snow_full = 4600.0;       // and covers them
uniform float rock_slope = 0.35;        // slope (0..1) where bare rock shows through any biome
uniform float macro_var = 0.12;         // large-scale colour variation at middle zoom
uniform vec3 beach_col : source_color = vec3(0.80, 0.74, 0.58);
uniform float relief_scale = 0.0035;    // metres to slope
uniform vec3 light_dir = vec3(-0.6, -0.7, 0.8);
uniform vec3 shallow_col : source_color = vec3(0.30, 0.62, 0.66);
uniform vec3 mid_col : source_color = vec3(0.10, 0.36, 0.52);
uniform vec3 deep_col : source_color = vec3(0.04, 0.15, 0.32);
uniform vec3 foam_col : source_color = vec3(0.88, 0.93, 0.92);
uniform vec3 river_col : source_color = vec3(0.16, 0.42, 0.58);
// the alive layer (user 2026-11-23: "animated water, cloud shadows, seasonal snow, chimney smoke"; AliveLayer sets
// alive_time each frame and holds it still under reduced motion; snow_shift_c follows the season turn)
group_uniforms alive;
uniform float alive_time = 0.0;          // seconds; 0 and still under reduced motion
uniform float water_motion = 0.0;       // drifting ripples on the sea and lakes (0 = still)
uniform float water_glint = 0.0;        // small light glints on the water
uniform float river_flow = 0.0;         // a slow shimmer along the rivers
uniform float cloud_shadow = 0.0;       // how dark the drifting cloud shadows are (0 = none)
uniform float cloud_scale = 0.02;       // noise repeats per tile: lower = bigger clouds
uniform vec2 cloud_wind = vec2(0.6, 0.15);   // tiles per second the cloud field drifts
uniform float cloud_cover = 0.55;       // noise level where a cloud starts: higher = fewer clouds
uniform sampler2D temp_map : filter_linear;  // R8 per game tile: mean temperature, C = value * 255 / 2 - 50
uniform float snow_shift_c = 0.0;       // this season's offset to the mean temperature (winter < 0)
uniform float snow_on_c = 1.0;          // temperature where the seasonal snow starts
uniform float snow_full_c = -3.0;       // and covers the land
uniform float snow_strength = 0.0;      // how strongly the snow covers the painted land (0 = off)
uniform vec3 snow_col : source_color = vec3(0.95, 0.95, 0.93);
uniform vec3 snow_hatch_col : source_color = vec3(0.55, 0.66, 0.78);

float id_at(ivec2 c) {
	c = clamp(c, ivec2(0), ivec2(fine) - 1);
	return floor(texelFetch(biome_map, c, 0).r * 255.0 + 0.5);
}

vec3 tex_at(vec2 uv, float id) {
	// two scales, one rotated, so the repeat does not show at continent zoom
	vec3 a = texture(biome_tex, vec3(uv, id)).rgb;
	vec2 r = vec2(uv.x * 0.8 - uv.y * 0.6, uv.x * 0.6 + uv.y * 0.8) * 0.37 + 0.31;
	vec3 b = texture(biome_tex, vec3(r, id)).rgb;
	return mix(a, b, 0.35);
}

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec2 px = local_pos;
	vec2 t = (px - map_origin) / px_per_tile;          // game tile coordinates
	vec2 fu = t * 4.0 / fine;                          // data uv
	vec2 nz = texture(noise_map, t * 0.07).rg * 2.0 - 1.0;
	vec2 nz2 = texture(noise_map, t * 0.43 + 0.5).rg * 2.0 - 1.0;
	// land: blend the four nearest data cells' textures, borders broken up by noise and by the textures' own light
	// borders wander at two scales (a broad warp and a fine one), so the data's 4 px cells never show as blocks
	vec2 warp = texture(noise_map, t * 0.018 + 0.2).rg * 2.0 - 1.0;
	vec2 g = t * 4.0 - 0.5 + warp * edge_warp + (nz * 0.8 + nz2 * 0.4) * edge_noise;
	ivec2 i0 = ivec2(floor(g));
	vec2 fr = fract(g);
	vec2 uv = t / tex_tiles;
	float ids[4] = float[4](id_at(i0), id_at(i0 + ivec2(1, 0)), id_at(i0 + ivec2(0, 1)), id_at(i0 + ivec2(1, 1)));
	float ws[4] = float[4]((1.0 - fr.x) * (1.0 - fr.y), fr.x * (1.0 - fr.y), (1.0 - fr.x) * fr.y, fr.x * fr.y);
	// four samples written out (no texture reads in a loop); the weight favours the texture whose light is higher,
	// so a border follows tree crowns and rock rather than a straight blend
	vec3 c0 = tex_at(uv, ids[0]);
	vec3 c1 = tex_at(uv, ids[1]);
	vec3 c2 = tex_at(uv, ids[2]);
	vec3 c3 = tex_at(uv, ids[3]);
	vec4 h = vec4(dot(c0, LUMA), dot(c1, LUMA), dot(c2, LUMA), dot(c3, LUMA));
	vec4 w = pow(vec4(ws[0], ws[1], ws[2], ws[3]), vec4(blend_sharpness)) * (HEIGHT_BIAS + h);
	vec3 land = (c0 * w.x + c1 * w.y + c2 * w.z + c3 * w.w) / max(dot(w, vec4(1.0)), 1e-4);
	// large, soft colour variation so a forest or a steppe is not one flat colour at middle zoom
	vec3 macro = texture(noise_map, t * 0.011 + 0.7).rgb * 2.0 - 1.0;
	land *= 1.0 + macro_var * vec3(macro.r, macro.r * 0.7 + macro.g * 0.3, macro.g * 0.6);
	// the land's shape from the true elevation: bare rock on steep slopes, snow on high peaks, then the baked soft
	// hillshade (three lights, from tools/asset-pipeline/map/terrain/bake_data.py)
	float e = texture(elev_map, fu).r;
	vec2 rl = texture(relief_map, fu).rg;
	float slope = rl.g * 0.25;
	vec3 rock = tex_at(uv * 1.3, 11.0);
	land = mix(land, rock, smoothstep(rock_slope, rock_slope + 0.2, slope + nz2.x * 0.05) * 0.85);
	float snow = smoothstep(snow_from, snow_full, e + nz.y * 300.0) * (1.0 - smoothstep(0.55, 0.9, slope) * 0.5);
	land = mix(land, tex_at(uv, 15.0) * 1.05, snow);
	land *= mix(1.0, clamp(rl.r * 2.0, 0.35, 1.6), relief);
	if (painted_land) {   // a uniform branch: the whole draw takes one side
		land = texture(TEXTURE, UV).rgb;
	}
	// seasonal snow (alive layer): where this season's temperature is below snow_on_c, a paper-white wash with fine
	// blue ink hatching; the edge wanders with the noise so it is not a contour line
	float tc = texture(temp_map, t / grid).r * 127.5 - 50.0 + snow_shift_c + (nz.x * 0.8 + nz2.y * 0.4) * 1.2;
	float sn = (1.0 - smoothstep(snow_full_c, snow_on_c, tc)) * snow_strength;   // edges in order: full (colder) < on
	float hatch = smoothstep(0.82, 0.95, sin((t.x * 0.9 + t.y * 0.5) * 18.0 + nz2.x * 2.0) * 0.5 + 0.5);
	land = mix(land, mix(snow_col, snow_hatch_col, hatch * 0.35) * (0.96 + 0.08 * nz2.y), sn);
	// rivers
	float rv = texture(river_map, fu).r;   // traced lines: no noise offset, so a river never breaks
	// rivers from the traced lines (connected exactly as the data): drawn by the game over painted land too; the
	// alive layer moves a slow light shimmer along them
	float flow = texture(noise_map, t * 0.55 + vec2(alive_time * 0.045, alive_time * 0.03)).r - 0.5;
	vec3 rcol = river_col * (1.0 + flow * 0.5 * river_flow);
	land = mix(land, rcol, smoothstep(river_cut, river_cut + 0.18, rv) * river_strength);
	// water: depth colour, the sea texture's ripples, shallows and surf along the true coast
	float d = texture(coast_map, fu).r + nz.x * 0.08;  // + water, tiles
	float depth = max(0.0, -min(e, 0.0));
	// depth deepens the colour gently (the shelf stays a hint, not a bright band); the turquoise is a narrow fringe by
	// distance from the shore (shore_tint, shore_width), like the painting's shallows
	vec3 water = mix(mid_col, deep_col, smoothstep(depth_from, depth_full, depth));
	// the ripples: two layers drifting apart slowly (alive layer water_motion), so the sea moves without a direction
	vec2 drift = vec2(alive_time * 0.004, alive_time * 0.0025) * water_motion;
	vec3 rip = mix(tex_at(uv * 1.7 + drift, 18.0), tex_at(uv * 1.3 - drift * 1.3 + 0.37, 18.0), 0.5 * step(0.001, water_motion));
	float rip_l = dot(rip, vec3(0.33)) / max(0.05, dot(texture(biome_tex, vec3(0.5, 0.5, 18.0), 8.0).rgb, vec3(0.33)));
	water *= 1.0 + (rip_l - 1.0) * (ripple_strength + 0.1 * water_motion);
	// glints: small soft highlights that come and go with the drifting noise
	// (fine-scale, and only close in: at continent zoom they would read as pale blotches across the sea)
	float gl = texture(noise_map, t * 1.6 + vec2(alive_time * 0.05, -alive_time * 0.033)).g
		* texture(noise_map, t * 1.1 - vec2(alive_time * 0.028, alive_time * 0.041) + 0.3).r;
	water += vec3(smoothstep(0.46, 0.56, gl) * water_glint * smoothstep(0.1, 0.6, d) * smoothstep(12.0, 22.0, px_per_tile));
	water *= 1.0 + (nz2.x * 0.5) * paper_grain;   // a faint parchment grain under a paper-style sea
	water = mix(water, shallow_col, (1.0 - smoothstep(0.0, shore_width, d)) * shore_tint);
	float foam = (1.0 - smoothstep(0.0, 0.12, d)) * smoothstep(-0.02, 0.02, d) * (0.55 + 0.45 * nz2.y);
	water = mix(water, foam_col, clamp(foam, 0.0, 1.0) * foam_strength);
	// shores: a thin pale beach where the coast is gentle, rock where it is steep; the land darkens at the waterline
	float shore = smoothstep(-0.22, -0.04, d) * (1.0 - smoothstep(-0.04, 0.0, d) * 0.3);
	float steep = smoothstep(0.15, 0.35, slope);
	land = mix(land, mix(beach_col * (0.9 + 0.2 * nz2.y), rock, steep), shore * 0.75);
	float wet = smoothstep(-0.06, 0.0, d);
	land *= 1.0 - 0.15 * wet;
	vec3 col = mix(land, water, smoothstep(-0.02, 0.02, d));
	// an ink line on the true coast (paper style): darkest at d = 0, about ink_width tiles wide
	col = mix(col, ink_col, ink_strength * (1.0 - smoothstep(0.0, ink_width, abs(d))));
	// cloud shadows (alive layer): two octaves of the noise drifting with the wind, soft-edged, over land and water
	vec2 cw = t * cloud_scale + cloud_wind * cloud_scale * alive_time;
	float cl = texture(noise_map, cw).r * 0.65 + texture(noise_map, cw * 2.3 + 0.41).g * 0.35;
	col *= 1.0 - smoothstep(cloud_cover, cloud_cover + 0.18, cl) * cloud_shadow;
	bool inside = t.x >= 0.0 && t.y >= 0.0 && t.x < grid.x && t.y < grid.y;
	COLOR = vec4(inside ? col : deep_col, 1.0);
}
