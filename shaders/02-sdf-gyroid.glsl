// sdf.glsl

float map(vec3 p) {
    // vec3 pGyroid = 
    float lBox = 1.5;
    float freq = 6.0 * 3.1415 / lBox; // + 1.0 * sin(p.x);
    float thickness = 0.5 + 2.0*iSlider; // - 0.5 * iSlider + length(p.xy);
    float d0 = sdGyroid(p, freq, thickness);
    float d1 = gyroidSDF(p, freq);
    float dx = skeletalGyroidField(p, freq, thickness);
    float d2 = sdBox(p - vec3(0.0, 0.0, 0.0), vec3(lBox));
    // float su = opSmoothUnion(d1, d2, 0.5);
    float d = opSmoothIntersection(d0, d2, 0.1);
    return d;
}
