// sdf.glsl

float map(vec3 p) {
    float xPos = 1.8;
    float size = 1.6;
    float d0 = sdSphere(p - vec3(2.4*xPos*2.*(1.1*iSlider-0.5), 0.0, 0.80), size+0.5);
    float d1 = sdSphere(p - vec3(-2.4*xPos, 0.0, 0.0), size);
    float d2 = sdBox(p - vec3(-0.8*xPos, 0.0, 0.0), vec3(size));
    float d3 = sdSphere(p - vec3(0.8*xPos, 0.0, 0.0), size);
    float d4 = sdBox(p - vec3(2.4*xPos, 0.0, 0.0), vec3(size));
    float k = 0.2; // * (0.5 + sin(iTime) / 2.0);
    float op1 = opSmoothSubtraction(d0, d1, k);
    float op2 = opSmoothIntersection(d0, d2, k);
    float op3 = opSmoothIntersection(d0, d3, k);
    float op4 = opSmoothSubtraction(d0, d4, k);
    float u1 = opUnion(op1, op2);
    float u2 = opUnion(op3, op4);
    float u3 = opUnion(u1, u2);
    return u3;
}