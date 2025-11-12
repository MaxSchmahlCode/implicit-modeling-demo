// sdf.glsl

float map(vec3 p) {
    float d1 = sphereSDF(p - vec3(0.5, -0.5, 0.0), 1.3);
    float d2 = boxSDF(p - vec3(-0.5, 0.5, 0.0), vec3(1.0));
    // float su = opSmoothUnion(d1, d2, 0.5);
    float su = opSmoothUnion(d1, d2, iSlider);
    return su;
}
