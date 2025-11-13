// sdf.glsl

float map(vec3 p) {
    float d1 = sdSphere(p - vec3(-0.5, 0.5, 0.0), 1.3);
    float d2 = sdBox(p - vec3(0.5, -0.5, 0.0), vec3(1.0));
    float su = opSmoothUnion(d1, d2, 0.25 * iSlider);
    return su;
}
