shader_type canvas_item;

uniform float density = 120.0;    
uniform float brightness = 1.0;
uniform float parallax = 0.03;     
uniform vec2 camera_offset = vec2(0.0);

float hash(vec2 p){
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

void fragment(){
    vec2 uv = SCREEN_UV;
    
    vec2 p = (uv + camera_offset * parallax) * density;

    vec2 cell = floor(p);
    vec2 f = fract(p);

    float rnd = hash(cell);
    vec2 star_pos = vec2(hash(cell + 1.23), hash(cell + 4.56));
    
    float d = length(f - star_pos);
    float star = smoothstep(0.03, 0.0, d) * step(0.98, rnd); // poques cel·les tenen estrella
    
    COLOR = vec4(vec3(star * brightness), 1.0);
}
