shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


//defines the coefficient
uniform float coeff : hint_range(0, .5);


//chromatic aberration
uniform float aberration_amount = 1.0;
uniform sampler2D aberration_offset_texture : source_color;

//blur
uniform vec2 blur_center = vec2( 0.5, 0.5 );
uniform float blur_power : hint_range( 0.0, 1.0 ) = 0.01;
uniform int sampling_count : hint_range( 1, 64 ) = 6;

void fragment(){
	//gets the SCREEN_UV
	vec2 suv = SCREEN_UV;

	//side maps 0.0>1.0 into -1.0>1.0
	//side as in "-1.0 is the left side, 1.0 is the right one"
	float side = (SCREEN_UV.y * 2.0) - 1.0;

	//mountain maps 0.0>1.0 into a 0.0>0.0, where the mid-value is 1.0.
	float mountain = -abs((SCREEN_UV.x * 2.0) - 1.0) + 1.0;

	//maps mountain into a sine-wave's first ramp
	mountain = mountain * PI/2.0;

	//newv says 'how much should the pixel be moved based in its position?'
	//mountain defines the amount, coeff scales it and 'sin' smooths it out.
	//the multiplication with PI/2.0 is mandatory for sin to work
	float newv = coeff * sin(mountain);

	//modifies the screen uv saved before
	//(newv * side) applies the effect on both left and right.
	//if 'side' wasn't here, the effect would be applied only one way.
	//even more important is the subtraction with 'coeff*size'.
	//this scales the shader up and down so that you don't end up with borders.
	suv.y += ((newv * side) - (coeff*side));

	/*blur*/
	vec2 direction = suv - blur_center;
	vec3 c = vec3( 0.0, 0.0, 0.0 );
	float f = 1.0 / float( sampling_count );
	for( int i=0; i < sampling_count; i++ ) {
		c += texture( SCREEN_TEXTURE, suv - blur_power * direction * float(i) ).rgb * f;

	}
	COLOR.rgb = c;

	/*chromatic aberration*/
	//vec4 texture_color = texture(SCREEN_TEXTURE, suv);
	//vec4 color = texture_color;
	//
	//float adjusted_amount = aberration_amount * texture(aberration_offset_texture, suv).r / 100.0;
	//color.r = texture(SCREEN_TEXTURE, vec2(suv.x + adjusted_amount, suv.y)).r;
	//color.g = texture(SCREEN_TEXTURE, suv).g;
	//color.b = texture(SCREEN_TEXTURE, vec2(suv.x - adjusted_amount, suv.y)).b;
	//
	//COLOR = color;



}