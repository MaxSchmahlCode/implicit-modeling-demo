// raymarch.glsl
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for(int i = 0; i < 128; i++) {
        vec3 p = ro + rd * t;
        float d = map(p);
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        t += d;
        if (t > 100.0) break;
    }
    return -1.0; // no hit
}
