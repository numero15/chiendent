//https://www.youtube.com/watch?v=YwnVl2YHXBc&list=PLzQ63V56PL8eArJHC9e_NAbuzJ0k4HXC7

shader_type spatial;
uniform sampler2D noise : source_color;
uniform float  offset_x : hint_range(0.0, 10.0) = 0.0;
uniform float  offset_y : hint_range(0.0, 10.0) = 0.0;
uniform float  offset_z : hint_range(0.0, 10.0) = 0.0;
uniform int  total_stripes : hint_range(1, 20) = 1;
uniform int  total_columns : hint_range(1, 20) = 1;
uniform sampler2D wall_albedo_01;
uniform sampler2D wall_albedo_02;
uniform int  thickness_01 : hint_range(0, 20) = 1;
uniform int  thickness_column : hint_range(0, 20) = 1;
uniform sampler2D window_albedo_01;
uniform sampler2D window_albedo_02;
uniform int  windows_scale : hint_range(1, 5) = 1;
uniform sampler2D roof_albedo_01;
uniform sampler2D roof_albedo_02;

varying vec3 pos;
varying vec3 mesh_normal;

vec2 scale(vec2 uv, float x, float y)
{
	mat2 scale = mat2(vec2(x, 0.0), vec2(0.0, y));
	uv = uv * scale;
	return uv;
}

vec3 compute_albedo(vec2 plan){
	vec3 _albedo;
	vec2 or_pos = plan;
	//revert y for some reason
	or_pos.y = -or_pos.y;
	vec2 base_uv = or_pos;
	base_uv.x += offset_x;
	base_uv.y += offset_y;

	float baseY_window ;
	if(base_uv.y>0.0){
		 baseY_window = floor(floor(base_uv.y )/float(total_stripes))*float(total_stripes);/* other_stripe_height/2 + total_height/2*/ ;}
	else{ 
		baseY_window = ceil((base_uv.y)/float(total_stripes))*float(total_stripes);}

	
	//wall
	if(
		mod(base_uv.y,float(total_stripes))<float(thickness_01) // horizontal stripe
		||
		mod(base_uv.x,float(total_columns))<float(thickness_column) // verical column
		){
		/* for random tiling*/
		float lineY = floor((floor(or_pos.y + baseY_window + offset_y )/float(windows_scale)))*float(windows_scale);
		float lineX = floor(floor(or_pos.x + offset_x)/float(windows_scale))*float(windows_scale);
		vec2 sec_uv = vec2(lineX/10.0,lineY/10.0);
		vec3 r_c = texture(noise,sec_uv).rgb;
		//ALBEDO = r_c;
	if(r_c.x>.5){_albedo = texture(wall_albedo_01,base_uv).rgb;}
		else{_albedo = texture(wall_albedo_02,base_uv).rgb;}
	}

	//windows
	else{
		float centerY = 0.0;
		base_uv=vec2(base_uv.x,base_uv.y - baseY_window +centerY);
		base_uv = scale(base_uv, 1.0/float(windows_scale),  1.0/float(windows_scale));
		_albedo = texture(wall_albedo_01,base_uv).rgb;

		/* for random tiling*/
		float lineY = floor((floor(or_pos.y + baseY_window + offset_y +centerY)/float(windows_scale)))*float(windows_scale);
		float lineX = floor(floor(or_pos.x + offset_x)/float(windows_scale))*float(windows_scale);
		vec2 sec_uv = vec2(lineX/10.0,lineY/10.0);
		vec3 r_c = texture(noise,sec_uv).rgb;
		//ALBEDO = r_c;
		if(r_c.x>.5){_albedo = texture(window_albedo_01,base_uv).rgb;}
		else{_albedo = texture(window_albedo_02,base_uv).rgb;}
	}
	/*if(abs(baseX - pos.x) <.020 ){
		ALBEDO = vec3(1.0,0.0,0.0);
		}
		if(abs(baseY - pos.y) <.020  ){
		ALBEDO = vec3(1.0,0.0,0.0);
		}*/	
	
	return _albedo;
}

vec3 compute_albedo_roof(){
	vec3 _albedo;
	vec2 or_pos = pos.xz;
	vec2 base_uv = or_pos;
	base_uv.x += offset_x;
	base_uv.y += offset_z;

	float baseY_window ;
	if(base_uv.y>0.0){ baseY_window = floor(base_uv.y );}
	else{ baseY_window = ceil(base_uv.y);}
	
	//roof	
	/* for random tiling*/
	float lineY = floor(floor(or_pos.y + offset_z ));
	float lineX = floor(floor(or_pos.x + offset_x));
	vec2 sec_uv = vec2(lineX/10.0,lineY/10.0);
	vec3 r_c = texture(noise,sec_uv).rgb;
	if(r_c.x>.5){_albedo = texture(roof_albedo_01,base_uv).rgb;}
	else{_albedo = texture(roof_albedo_02,base_uv).rgb;}
	
	return _albedo;
}


void vertex() {
	pos = VERTEX;
	mesh_normal = abs(NORMAL);
}

void fragment() {
	vec3 _albedo = mix(compute_albedo(pos.xy), compute_albedo(pos.zy), mesh_normal.x);
	_albedo = mix(_albedo, compute_albedo_roof(), mesh_normal.y);
	ALBEDO =_albedo;
}
