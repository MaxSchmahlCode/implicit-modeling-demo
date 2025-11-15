// sdf.glsl

float map(vec3 p) {
    // vec3 pGyroid = 
    float lBox = 1.5;
    float freq = 6.0 * 3.1415 / lBox; // + 1.0 * sin(p.x);
    float thickness = 0.5 + 1.3*0.5; // - 0.5 * iSlider + length(p.xy);
    float PI = 3.1415;
    vec3 pCenter = vec3(-lBox + 2.0 * lBox * iSlider, 0.5, 0.);
    float distCenter = length(p.xy - pCenter.xy);
    float s1 = 1.0 - pow(abs(sin(distCenter / 4.0)), 3.5) / 2.0; // shaping function
    float s2 = 1.0 - pow(abs(distCenter/1.0), 3.5) / 2.0; // shaping function
    float d0 = -sdGyroid(p, freq, s2 * thickness);
    // float d1 = gyroidSDF(p, freq);
    // float dx = skeletalGyroidField(p, freq, thickness);
    float d2 = sdBox(p - vec3(0.0, 0.0, 0.0), vec3(lBox, lBox / 2.0, lBox));
    // float su = opSmoothUnion(d1, d2, 0.5);
    float d = opSmoothIntersection(d0, d2, 0.1);
    // float d = opSmoothSubtraction(d0, d2, 0.1);
    return d;
}
