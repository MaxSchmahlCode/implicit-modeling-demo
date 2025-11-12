float map(vec3 p){
    // Geometric Parameters
    float bodyRadius = 0.3; // without rim
    float bodyHalfHeight = 0.12; // without hub

    float hubRadius = 0.2;
    float hubHalfHeight = 0.18;
    float heightDifference = hubHalfHeight - bodyHalfHeight;

    float teethCount = 32.;
    float teethRadius = 0.15;
    float teethHalfheight = 0.02;
    float rimThickness = 0.01;
    
    float innerHoleRadius = 0.06; // central bore
    
    // Start with main body
    float body = sdCylinderY(p, bodyRadius, bodyHalfHeight);

    // Add central hub
    vec3 hubCenter = p - vec3(0.0, heightDifference, 0.0);
    float hub = sdCylinderY(hubCenter, hubRadius, hubHalfHeight);
    float base = opUnion(body, hub);
    
    // Subtract cylinders in cylindrical pattern
    float angle = atan(p.z, p.x);
    float radius = length(p.xz);
    float a = mod(angle, 6.28318 / teethCount) - 3.14159 / teethCount;
    vec3 q = vec3(cos(a) * radius - bodyRadius, p.y, sin(a) * radius); // Transform to local space
    float sdCylPattern = sdCylinder(q, teethRadius, teethHalfheight); // define cylinder
    float withTeeth = opSub(base, sdCylPattern); // subtract teeth

    // Add thin rim at top and bottom
    vec3 yPosition = vec3(0.0, bodyHalfHeight - rimThickness, 0.0);
    float rim1 = sdCylinderY(p+yPosition, bodyRadius + rimThickness, rimThickness);
    float withRim1 = opUnion(withTeeth, rim1);
    float rim2 = sdCylinderY(p-yPosition, bodyRadius + rimThickness, rimThickness);
    float withRims = opUnion(withRim1, rim2);

    // Subtract central bore (axial hole)
    float bore = sdCylinderY(p - yPosition, innerHoleRadius, hubHalfHeight + heightDifference + 0.02);
    float withBore = opSub(withRims, bore);
    return withBore;
}