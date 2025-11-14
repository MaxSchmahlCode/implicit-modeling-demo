// sdf.glsl

float map(vec3 p) {
    float lMin = 1.8;
    float rSphere = 1.3;
    float d0 = sdSphere(p - vec3(2.4*lMin*2.*(iSlider-0.5), 0.0, 0.50), rSphere+0.5);
    float d1 = sdSphere(p - vec3(-2.4*lMin, 0.0, 0.0), rSphere);
    float d2 = sdBox(p - vec3(-0.8*lMin, 0.0, 0.0), vec3(1.0));
    float d3 = sdSphere(p - vec3(0.8*lMin, 0.0, 0.0), rSphere);
    float d4 = sdBox(p - vec3(2.4*lMin, 0.0, 0.0), vec3(1.0));

    float op1 = opSub(d1, d0);
    float op2 = opIntersection(d2, d0);
    float op3 = opIntersection(d3, d0);
    float op4 = opSub(d4, d0);
    float u1 = opUnion(op1, op2);
    float u2 = opUnion(op3, op4);
    float u3 = opUnion(u1, u2);
    return u3;
}
