// raymarch.glsl
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0; // distance along ray
    for(int i = 0; i < 200; i++) {
        vec3 p = ro + rd * t; // current sample position in world space
        float d = map(p); // signed distance from p to nearest surface
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        t += d;
        if (t > 100.0) break;
    }
    return -1.0; // no hit
}