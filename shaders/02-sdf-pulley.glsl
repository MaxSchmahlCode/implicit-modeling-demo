float map(vec3 p_){
    // Scale geometry
    float scalingFactor = 3.5;
    vec3 p = p_ / scalingFactor;

    // Geometric Parameters
    float dt = 0.1;
    float bucket = floor(iSlider / dt);
    float stepSize = 0.1;
    float stepper = stepSize * bucket;

    // Geometric Parameters
    float beltWidth = 0.5;

    float bodyRadius = 0.5 + stepper; //1.5; // outside radius
    float bodyHalfHeight = beltWidth / 2.0 + 0.02; // without hub

    float hubRadius = 0.3 + 0.1 * stepper;
    float hubHalfHeight = bodyHalfHeight + 0.1;
    float heightDifference = hubHalfHeight - bodyHalfHeight;

    float teethCount = 20. + 40. * stepper; // 64.;
    float teethRadius = 0.05;
    float teethHalfheight = beltWidth / 2.0;
    float rimThickness = 0.01;
    
    float innerHoleRadius = 0.06; // central bore
    
    // Start with main body
    float body = sdCylinderY(p, bodyRadius, bodyHalfHeight);

    // Add central hub
    vec3 hubCenter = p - vec3(0.0, heightDifference, 0.0);
    float hub = sdCylinderY(hubCenter, hubRadius, hubHalfHeight);
    float base = opSmoothUnion(body, hub, 0.01);
    
    // Subtract cylinders in cylindrical pattern
    float angle = atan(p.z, p.x);
    float radius = length(p.xz);
    float a = mod(angle, 6.28318 / teethCount) - 3.14159 / teethCount;
    vec3 q = vec3(cos(a) * radius - bodyRadius, p.y, sin(a) * radius); // Transform to local space
    float sdCylPattern = sdCylinderY(q, teethRadius, teethHalfheight); // define cylinder
    float withTeeth = opSub(base, sdCylPattern); // subtract teeth

    // Add rim by subtracting combined cylinders
    float outerCyl = sdCylinderY(p, bodyRadius + 0.01, teethHalfheight);
    float innerCyl = sdCylinderY(p, bodyRadius - 0.02, teethHalfheight);
    float torusLike = opSub(outerCyl, innerCyl);
    float withRims = opSmoothSubtraction(torusLike, withTeeth, 0.001);

    // Subtract central bore (axial hole)
    float cylHeight = hubHalfHeight + heightDifference + 0.02;
    float bore = sdCylinderY(p, innerHoleRadius, cylHeight);
    float withBore = opSub(withRims, bore);

    // Scaling
    float scaledResult = scalingFactor * withBore;
    return scaledResult;
}