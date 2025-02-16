shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

//uniform vec4 texColor : hint_color;
uniform sampler2D grain;


float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
 vec4 texColor = vec4(0);
 vec2 uv = UV;
 vec2 samplePosition = UV/.8;
 float whiteNoise = 9999.0;

 // дрожание строк влево-вправо line jittering
 samplePosition.x = samplePosition.x+(rand(vec2(TIME,UV.y))-0.5)/3.0;

 // дрожание всей картинки вверх-вниз image jittering
 samplePosition.y = samplePosition.y+(rand(vec2(TIME))-0.5)/64.0 - .7;

 // добавление цветного шума каждой строке color noise for each line
 texColor = texColor + (vec4(-0.5)+vec4(rand(vec2(UV.y,TIME)),rand(vec2(UV.y,TIME+1.0)),rand(vec2(UV.y,TIME+2.0)),0))*0.1;

 // Сэмплирование текстуры или создание белого пиксела (статичная белая полоска внизу) sample texture for static white pattern
 whiteNoise = rand(vec2(floor(samplePosition.y),floor(samplePosition.x*40.0))+vec2(TIME,0));
 if (whiteNoise > 11.5-30.0*samplePosition.y || whiteNoise < 1.5-5.0*samplePosition.y) {
     // Сэмпл текстуры
  samplePosition.y = samplePosition.y + .5; //небольшой ненужный фикс small fix (may not needs)
  texColor = texColor + texture(grain, vec2(samplePosition.x-.02, samplePosition.y+.25)*.8);
 } else {
     // белый цвет white color
     texColor = vec4(1);
 }

 vec2 screen = SCREEN_UV;
 screen.x = screen.x+(rand(vec2(TIME,SCREEN_UV.y))-0.5)/64.0;
 screen.y = screen.y+(rand(vec2(TIME))-0.5)/64.0;

 COLOR.rgb = textureLod(SCREEN_TEXTURE,screen,0.0).rgb;
 COLOR.rgb = mix(COLOR.rgb, texColor.rgb, texColor.a);
}