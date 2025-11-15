// sdf.glsl

float map(vec3 p) {
    // parameters
    float lBox = 3.5;
    float freq = 6.0 * 3.1415 / lBox; // + 1.0 * sin(p.x);
    float thickness = 0.5 + 1.3*0.5; // - 0.5 * iSlider + length(p.xy);
    float PI = 3.1415;

    // calculation
    vec3 pCenter = vec3(-lBox + 2.0 * lBox * iSlider, 0.5, 0.);
    // vec3 pCenter2 = vec3(-pCenter.x, pCenter.yz);
    // float distCenter = length(p.xy - pCenter.xy);
    float distCenter = p.x - pCenter.x;
    // float distCenter2 = p.x - pCenter2.x;
    // float s1 = 1.0 - pow(abs(distCenter/2.0 * sin(iTime/4.0)), 3.5) / 2.0; // shaping function
    float shape2 = 1.0 - pow(abs(distCenter/2.0), 3.5) / 2.0; // shaping function
    // float shape3 = 1.0 - pow(abs(distCenter2/2.0), 3.5) / 2.0; // shaping function
    // float s3 = pow(abs(distCenter / 2.0), 1.0);
    float d0 = sdGyroid(p, freq, shape2 * thickness);
    float g1 = sdGyroid(p, 2.0 * freq, thickness);
    float d2 = sdBox(p - vec3(0.0), vec3(lBox, lBox / 2.0, lBox / 5.0)); // box
    float i3 = opSmoothIntersection(g1, d2, 0.1); // gyroid box
    float u2 = opSmoothUnion(i3, d2, 0.02); // patternd box
    float s1 = opSmoothSubtraction(d0, u2, 0.1); // subtracted 
    
    return s1;
}
