// sdf.glsl

float map(vec3 p) {

    // Parameters
    float xPos = 1.1;
    float size = 1.2;
    vec3 p1 = p - vec3(-2.4*xPos, 0.0, 0.0);
    vec3 p2 = p - vec3(-0.8*xPos, 0.0, 0.0);
    vec3 p3 = p - vec3(0.8*xPos, 0.0, 0.0);
    vec3 p4 = p - vec3(2.4*xPos, 0.0, -0.1);

    p2.xz = rot2(iTime/10.0) * p2.xz;
    p4.xz = rot2(iTime/10.0) * p4.xz;

    // Primitives
    float d0 = sdSphere(p - vec3(2.4*xPos*2.*(iSlider-0.5), 0.0, 0.80), size+0.4);
    float d1 = sdSphere(p1, size);
    float d2 = sdBox(p2, vec3(size));
    float d3 = sdSphere(p3, size);
    float d4 = sdBox(p4, vec3(size));

    // Boolean Operations
    float op1 = opSub(d1, d0);
    float op2 = opIntersection(d2, d0);
    float op3 = opIntersection(d3, d0);
    float op4 = opSub(d4, d0);
    float u1 = opUnion(op1, op2);
    float u2 = opUnion(op3, op4);
    float u3 = opUnion(u1, u2);
    
    return u3;
}
