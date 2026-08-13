shader_type spatial;
render_mode cull_front;

uniform sampler2D atom_data;
uniform int atom_count = 0;
uniform int bond_count = 0;
uniform float smooth_factor = 0.5;

varying vec3 camera_pos_world;
varying vec3 vertex_pos_world;

void vertex() {
    camera_pos_world = INV_VIEW_MATRIX[3].xyz;
    vertex_pos_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

float sdSphere(vec3 p, vec4 atom) {
	return length(p - atom.xyz) - atom.w;
}

float map_molecule(vec3 p) {
    float min_dist = 10000.0;
    
    for (int i = 0; i < atom_count; i++) {
        vec4 atom = texelFetch(atom_data, ivec2(i, 0), 0);
        float atom_dist = sdSphere(p, atom);
		min_dist = min(min_dist, atom_dist);
    }
	
	float bond_radius = 0.15;
    for (int i = 0; i < bond_count; i++) {
        ivec2 bond_indices = ivec2(texelFetch(atom_data, ivec2(i, 2), 0).xy);
        vec3 atom_a = texelFetch(atom_data, ivec2(bond_indices.x, 0), 0).xyz;
        vec3 atom_b = texelFetch(atom_data, ivec2(bond_indices.y, 0), 0).xyz;
        
        float bond_dist = sdCapsule(p, atom_a, atom_b, bond_radius);
        
        min_dist = min(min_dist, bond_dist);
    }
	
    return min_dist;
}

vec3 calc_normal(vec3 p) {
    vec2 e = vec2(0.01, 0.0);
    return normalize(vec3(
        map_molecule(p + e.xyy) - map_molecule(p - e.xyy),
        map_molecule(p + e.yxy) - map_molecule(p - e.yxy),
        map_molecule(p + e.yyx) - map_molecule(p - e.yyx)
    ));
}

vec3 get_molecule_color(vec3 p) {
    float min_dist = 10000.0;
    vec3 final_color = vec3(1.0);

    for (int i = 0; i < atom_count; i++) {
        vec4 atom = texelFetch(atom_data, ivec2(i, 0), 0);
        float d = length(p - atom.xyz) - atom.w;
        
        if (d < min_dist) {
            min_dist = d;
            final_color = texelFetch(atom_data, ivec2(i, 1), 0).rgb;
        }
    }
    return final_color;
}

void fragment() {
    vec3 ro_local = (inverse(MODEL_MATRIX) * vec4(camera_pos_world, 1.0)).xyz;
    vec3 rd_local = normalize((inverse(MODEL_MATRIX) * vec4(vertex_pos_world, 1.0)).xyz - ro_local);
    
    float t = 0.0;
    bool hit = false;
    vec3 p = ro_local;
    
    for(int i = 0; i < 100; i++) {
        p = ro_local + rd_local * t;
        float d = map_molecule(p);
        
        if(d < 0.001) {
            hit = true;
            break;
        }
        
        t += d;
        
        if(t > 100.0) {
            break;
        }
    }
    
    if(!hit) {
        discard;
    }
    
    ALBEDO = get_molecule_color(p);
    NORMAL = calc_normal(p);
    
    NORMAL = (VIEW_MATRIX * MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz;
}