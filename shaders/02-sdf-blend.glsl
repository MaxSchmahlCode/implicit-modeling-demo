// sdf.glsl

float map(vec3 p) {

    // Parameters
    float lObject = 1.20;
    float xPos = 2.0;

    // Rotation & Translation
    vec3 pSphere = p - vec3(-xPos, 0.0, 0.0);
    vec3 pBox = p - vec3(0.0, 0.0, 0.0);
    pBox.xy = rot2(2.0 * 3.1415/8.) * pBox.xy; // roll around z
    vec3 pCylinder = p - vec3(xPos, 0.0, 0.0);
    pCylinder.xy = rot2(-2.0 * 3.1415/8.) * pCylinder.xy; // roll around z
    
    // Primitives
    float d1 = sdSphere(pSphere, 1.2 * lObject);
    float d2 = sdBox(pBox, vec3(lObject));
    float d3 = sdCylinderY(pCylinder, lObject, 0.9 * lObject);

    // Smooth Union
    float su = opSmoothUnion(d1, d2, .5 * iSlider);
    su = opSmoothUnion(su, d3, 0.5 * iSlider);
    
    return su;
}
