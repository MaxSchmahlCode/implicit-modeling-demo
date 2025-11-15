// sdf.glsl

float map(vec3 p) {

    // Parameters
    float lBox = 3.5;
    float freq = 6.0 * 3.1415 / lBox;
    float thickness = 0.5 + 1.3 * 0.5;
    float PI = 3.1415;

    // Geometry
    float distCenter = p.x - lBox * (2.0 * iSlider - 1.0); // horizontal distance from p to 
    float shape = 1.0 - pow(abs(distCenter/2.0), 3.5) / 2.0; // shaping function
    float d0 = sdGyroid(p, freq, shape * thickness); // gyroid gradient
    float g1 = sdGyroid(p, 2.0 * freq, thickness); // gyroid for pattern
    float d2 = sdBox(p - vec3(0.0), vec3(lBox, lBox / 2.0, lBox / 5.0)); // box
    float i3 = opSmoothIntersection(g1, d2, 0.1); // gyroid 
    float u2 = opSmoothUnion(i3, d2, 0.02); // patternd box
    float s1 = opSmoothSubtraction(d0, u2, 0.1); // subtracted results in skeletal gyroid
    
    return s1;
}
