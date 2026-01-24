shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, depth_test_disabled;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear, repeat_disable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D gradient_mix : repeat_disable, filter_linear;

/*gradient*/
uniform sampler2D gradient_near: source_color;
uniform sampler2D gradient_far: source_color;
uniform float fog_length: hint_range(0.0, .02);

void vertex() {
	POSITION = vec4(VERTEX,	1.0);
}

void fragment() {
	/* gradient*/
	vec3 original = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 gradient_albedo;

	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc=vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX* vec4(ndc, 1.0);
	view.xyz /= view.w;
	depth = -view.z;


	//float fog = depth * fog_lenght;
	float fog = texture(gradient_mix, vec2(depth * fog_length,1.0)).r;

	float grayscale = dot(original,vec3(0.299,0.587,0.114));
	// go to end (1.0) of the gradient causes weirdness so stop at 0.98
	grayscale = clamp(grayscale,0.01,0.98);
	vec3 near_color = texture(gradient_near,vec2(grayscale,0.0)).rgb;
	vec3 far_color = texture(gradient_far,vec2(grayscale,0.0)).rgb;

	gradient_albedo = mix(near_color, far_color,clamp(fog,0.0,1.0));

	// find luminosity
	//https://sot.com.sg/hsl/
	float _sat = 0.0;
	float _min;
	_min = min(original.r, original.g);
	_min = min(_min, original.b);
	float _max;
	_max = max(original.r, original.g);
	_max = max(_max, original.b);

	float _lum = _max - _min;
	_lum = smoothstep(0.05, 0.2,_lum);

	gradient_albedo = mix(gradient_albedo,original,_lum);
	ALBEDO = gradient_albedo;
}
