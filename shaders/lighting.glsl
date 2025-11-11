// lighting.glsl
vec3 calcNormal(vec3 p) {
    const vec2 e = vec2(1.0, -1.0) * 0.5773 * 0.0005;
    return normalize(e.xyy * map(p + e.xyy) +
                     e.yyx * map(p + e.yyx) +
                     e.yxy * map(p + e.yxy) +
                     e.xxx * map(p + e.xxx));
}

vec3 phong(vec3 p, vec3 n, vec3 ro, vec3 lightPos) {
    vec3 l = normalize(lightPos - p); // light direction
    vec3 v = normalize(ro - p); // view direction
    vec3 r = reflect(-l, n); // reflection direction
    float diff = max(dot(n, l), 0.0); // diffuse term
    float spec = pow(max(dot(r, v), 0.0), 32.0); // specular term
    return vec3(1.0) * diff + vec3(1.0) * spec; // white light
}

vec3 mattediffuse(vec3 p, vec3 n, vec3 lightPos) {
    vec3 l = normalize(lightPos - p); // light direction
    float diff = max(dot(n, l), 0.0); // diffuse term
    return vec3(0.2, 0.2, 0.2) * diff; // grey matte color
}