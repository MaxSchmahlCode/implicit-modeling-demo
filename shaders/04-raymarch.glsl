// raymarch.glsl
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos, out float minDist) {

    float t = 0.0; // travelled distance along ray
    float d = 0.0; // distance to surface
    minDist = 1e10; // initialize with large number
    int nMarch = int(256./iRayFactor);
    for(int i = 0; i < nMarch; i++) {
        vec3 p = ro + iRayFactor * rd * t; // current sample position in world space

        d = map(p); // signed distance from p to nearest surface
        minDist = min(minDist, d);

        if (d < 0.001) {
            hitPos = p;
            return t;
        }

        t += d;

        if (t > 100.0) break;
    }
    return -1.0; // no hit
}