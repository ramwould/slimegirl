shader_type canvas_item;

const vec4 replacement_color = vec4(1.0, 1.0, 1.0, 1.0);
const float super_dim_amount = 0.35;

uniform bool use_extra_color_1 = false;
uniform bool use_extra_color_2 = false;
uniform vec4 extra_replace_color_1 : hint_color  = vec4(1.0, 0.0, 1.0, 1.0);
uniform vec4 extra_replace_color_2 : hint_color  = vec4(1.0, 0.0, 1.0, 1.0);

uniform vec4 color: hint_color = vec4(1.0);
uniform vec4 extra_color_1: hint_color = vec4(1.0);
uniform vec4 extra_color_2: hint_color = vec4(1.0);

uniform float max_color_distance = 0.01;

uniform bool super_dim = false;
uniform bool use_outline = false;

uniform vec4 outline_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

bool same_color(vec3 color1, vec3 color2) {
	return distance(color1, color2) < max_color_distance;
}

bool is_outline_color(vec3 col) {
	if (same_color(col, replacement_color.rgb))
		return true;
	if (same_color(col, extra_replace_color_1.rgb))
		return true;	
	if (same_color(col, extra_replace_color_2.rgb))
		return true;
	return false;
}

const vec4 hsv_tolerance = vec4(0.1, 0.5, 0.35, 0.0);
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void fragment() {
	vec4 col = texture(TEXTURE, UV);
	COLOR = col;
	
	if (same_color(col.rgb, replacement_color.rgb)) {
		COLOR.rgb = color.rgb;
		COLOR.a = texture(TEXTURE, UV).a;
	}
	if (use_extra_color_1 && same_color(col.rgb, extra_replace_color_1.rgb)) {
		COLOR.rgb = extra_color_1.rgb;
		COLOR.a = texture(TEXTURE, UV).a;
	}
	if (use_extra_color_2 && same_color(col.rgb, extra_replace_color_2.rgb)) {
		COLOR.rgb = extra_color_2.rgb;
		COLOR.a = texture(TEXTURE, UV).a;
	}

//	vec4 col_hsv = vec4(rgb2hsv(col.rgb),col.a);
//	vec4 rcol_hsv = vec4(rgb2hsv(extra_replace_color_1.rgb),extra_replace_color_1.a);
//	vec3 col_diff = col_hsv.rgb-rcol_hsv.rgb;
//	if (all(lessThanEqual(abs(col_diff), hsv_tolerance.rgb))) {
//		vec3 tgt_hsv = rgb2hsv(extra_color_1.rgb);
//		vec3 hsv_final = tgt_hsv.rgb+((col_diff*tgt_hsv.b));
//		COLOR.rgb = hsv2rgb(hsv_final);
//		COLOR.a = texture(TEXTURE, UV).a;
//	}

    if (use_outline && col.a == 0.0) {
	    float size_x = 1.0 / float(textureSize(TEXTURE, 0).x);
	    float size_y = 1.0 / float(textureSize(TEXTURE, 0).y);

	    float alpha = 0.0;

	    vec4 right = texture(TEXTURE, UV + vec2(size_x, 0.0));
	    vec4 left = texture(TEXTURE, UV + vec2(-size_x, 0.0));
	    vec4 down = texture(TEXTURE, UV + vec2(0.0, size_y));
	    vec4 up = texture(TEXTURE, UV + vec2(0.0, -size_y));
		
	    alpha += float(right.a > 0.0 && is_outline_color(right.rgb));
	    alpha += float(left.a > 0.0 && is_outline_color(left.rgb));
	    alpha += float(down.a > 0.0 && is_outline_color(down.rgb));
	    alpha += float(up.a > 0.0 && is_outline_color(up.rgb));

	    vec4 tl = texture(TEXTURE, UV + vec2(-size_x, -size_y));
	    vec4 tr = texture(TEXTURE, UV + vec2(size_x, -size_y));
	    vec4 bl = texture(TEXTURE, UV + vec2(-size_x, size_y));
	    vec4 br = texture(TEXTURE, UV + vec2(size_x, size_y));
		
	    alpha += float(tl.a > 0.0 && is_outline_color(tl.rgb));
	    alpha += float(tr.a > 0.0 && is_outline_color(tr.rgb));
	    alpha += float(bl.a > 0.0 && is_outline_color(bl.rgb));
	    alpha += float(br.a > 0.0 && is_outline_color(br.rgb));
		if (alpha > 0.0) {
			COLOR = vec4(outline_color.rgb, outline_color.a);
		}
	}
}

