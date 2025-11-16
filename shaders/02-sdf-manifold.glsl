
// Evaluate cubic Bezier at t using power-basis coefficients
vec3 bezierPoint(vec3 A, vec3 B, vec3 C, vec3 D, float t) {
    // ((A * t + B) * t + C) * t + D
    return ((A * t + B) * t + C) * t + D;
}

// First derivative of cubic Bezier
vec3 bezierTangent(vec3 A, vec3 B, vec3 C, float t) {
    // 3*A*t*t + 2*B*t + C
    return (3.0 * A * t * t) + (2.0 * B * t) + C;
}

// Second derivative of cubic Bezier
vec3 bezierSecond(vec3 A, vec3 B, float t) {
    // 6*A*t + 2*B
    return (6.0 * A * t) + (2.0 * B);
}

// Find approximate nearest t on cubic Bezier to point p.
// Uses coarse sampling then 5 Newton iterations constrained to [0,1].
float nearestTOnBezier(vec3 p, vec3 A, vec3 B, vec3 C, vec3 D) {
    // coarse sampling to get initial guess
    const int SAMPLES = 12;
    float bestT = 0.0;
    float bestDist2 = 1.0 / 0.0; // +inf
    for (int i = 0; i <= SAMPLES; ++i) {
        float t = float(i) / float(SAMPLES);
        vec3 q = bezierPoint(A, B, C, D, t);
        float d2 = dot(q - p, q - p);
        if (d2 < bestDist2) {
            bestDist2 = d2;
            bestT = t;
        }
    }

    // Newton refinement on function f(t) = dot(B(t)-p, B'(t))
    float t = bestT;
    for (int i = 0; i < 6; ++i) { // 6 iterations is safe and cheap
        vec3 q = bezierPoint(A, B, C, D, t);
        vec3 qd = bezierTangent(A, B, C, t);
        vec3 qdd = bezierSecond(A, B, t);

        vec3 r = q - p;
        float f = dot(r, qd);              // f(t)
        float df = dot(qd, qd) + dot(r, qdd); // f'(t)
        // protect against division by zero / tiny df
        if (abs(df) < 1e-8) break;

        float dt = f / df;
        t -= dt;
        // clamp into [0,1] and break if converged
        if (t <= 0.0) { t = 0.0; break; }
        if (t >= 1.0) { t = 1.0; break; }
        if (abs(dt) < 1e-6) break;
    }
    return clamp(t, 0.0, 1.0);
}

// Distance from point p to cubic Bezier curve defined by control points p0..p3
float distToBezier(vec3 p, vec3 p0, vec3 p1, vec3 p2, vec3 p3) {
    // convert control points to power-basis coefficients:
    // B(t) = ((A*t + B)*t + C)*t + D
    vec3 A = -p0 + 3.0*p1 - 3.0*p2 + p3;
    vec3 B = 3.0*p0 - 6.0*p1 + 3.0*p2;
    vec3 C = -3.0*p0 + 3.0*p1;
    vec3 D = p0;

    float t = nearestTOnBezier(p, A, B, C, D);
    vec3 q = bezierPoint(A, B, C, D, t);
    return length(p - q);
}

// Signed distance for a hollow/solid tube along cubic Bezier
// p       : query point
// p0..p3  : cubic Bezier control points (world space)
// rInner  : inner radius (pipe inner). Set 0.0 for solid tube.
// rOuter  : outer radius (pipe outer). Must be > rInner.
float sdTubeBezier(vec3 p, vec3 p0, vec3 p1, vec3 p2, vec3 p3, float rInner, float rOuter) {
    float d = distToBezier(p, p0, p1, p2, p3);
    // Hollow tube signed distance: negative between inner and outer radii.
    // The SDF for a shell is max(d - rOuter, rInner - d)
    // This is a true signed-distance (L_infty combination) for concentric radii.
    float outside = d - rOuter;
    float insideVoid = rInner - d;
    return max(outside, insideVoid);
}


/////////////////////////////////////////////////////////////////////////////////////
// Main SDF for manifold

float map(vec3 p){

    // Scale geometry
    float scalingFactor = 0.9;
    p = p / scalingFactor;
    // p.xz = rot2(0.1 * iTime) * p.xz;

    // Parameters
    float l1 = 1.8;
    float l2 = 1.8;
    float l3 = 1.8;

    float rInner = 0.0;
    float rOuter = 0.15;
    float shellThickness = 0.1;
    const int nCurves = 9;

    float rCyl = rOuter + shellThickness + 0.05;
    float hCyl = 0.4;

    float k = 0.2 * iSlider;

    vec3 listA[nCurves];
    vec3 listB[nCurves];
    // L1
    listA[1] = vec3(-l1, l2/2., 0.0);
    listB[1] = vec3(l1, l2/2., 0.0);
    // L2
    listA[2] = vec3(0.0,-l2, -l3/2.);
    listB[2] = vec3(-l1/2., +l2, -l3/2.);
    listA[3] = vec3(l1/2., -l2, -l3/4.);
    listB[3] = vec3(l1/2., l2, -l3/4.);
    listA[4] = vec3(l1/2., -l2, -3.*l3/4.);
    listB[4] = vec3(l1/2., l2, -3.*l3/4.);
    listA[5] = vec3(l1/2., -l2, l3/4.);
    listB[5] = vec3(l1/2., l2, l3/4.);
    // L3
    listA[6] = vec3(0.0, l2/4., -l3);
    listB[6] = vec3(0.0, -l2/4., l3);
    // Mixed
    listA[0] = vec3(-l1, +l2/2., 3.*l3/4.);
    listB[0] = vec3(l1/2., -l2, 3.*l3/4.);
    listA[7] = vec3(-l1/2., -l2/2., -l3);
    listB[7] = vec3(l1, -l2/2., l3/2.);
    listA[8] = vec3(-l1/2., 0.0, -l3);
    listB[8] = vec3(-l1/2., l2, +l3/2.);


    // Access
    vec3 firstA = listA[0];
    vec3 firstB = listB[0];

    vec3 p0 = vec3(0.0, l1, 0.0);
    vec3 p1 = vec3(0.0, 0.0, 0.0);
    vec3 p2 = vec3(l1/2., 0.0, 0.0);
    vec3 p3 = vec3(l1/2., -l1, 0.0);

    float bezier = sdTubeBezier(p, p0, p1, p2, p3, rInner, rOuter);
    // float withBezier = opUnion(withBore, bezier);

    float unifiedCurves = +1.0;
    float unifiedShells = +1.0;
    float unifiedCylinders = +1.0;
    int cylinderOrientation = 0;

    for(int i = 0; i < nCurves; i++) {
        
        p0 = listA[i];
        
        if(abs(listA[i][0]) == l1) {
            p1 = vec3(0.0, listA[i][1], listA[i][2]);
            cylinderOrientation = 0;
        }
        else if(abs(listA[i][1]) == l2) {
            p1 = vec3(listA[i][0], 0.0, listA[i][2]);
            cylinderOrientation = 1;
        }
        else if(abs(listA[i][2]) == l3) {
            p1 = vec3(listA[i][0], listA[i][1], 0.0);
            cylinderOrientation = 2;
        }
        vec3 pCylinder = listA[i];

        float firstCylinder = sdCylinder(p - p0, rCyl, hCyl, cylinderOrientation); //cylinderOrientation);
        unifiedCylinders = opUnion(unifiedCylinders, firstCylinder);

        if(abs(listB[i][0]) == l1) {
            p2 = vec3(0.0, listB[i][1], listB[i][2]);
            cylinderOrientation = 0;
        }
        else if(abs(listB[i][1]) == l2) {
            p2 = vec3(listB[i][0], 0.0, listB[i][2]);
            cylinderOrientation = 1;
        }
        else if(abs(listB[i][2]) == l3) {
            p2 = vec3(listB[i][0], listB[i][1], 0.0);
            cylinderOrientation = 2;
        }

        vec3 p3 = listB[i];

        float secondCylinder = sdCylinder(p - p3, rCyl, hCyl, cylinderOrientation); //cylinderOrientation);
        unifiedCylinders = opUnion(unifiedCylinders, secondCylinder);


        float bezier2 = sdTubeBezier(p, p0, p1, p2, p3, rInner, rOuter);
        unifiedCurves = opUnion(unifiedCurves, bezier2);

        float shelledBezier = sdShell(bezier2, shellThickness);
        unifiedShells = opSmoothUnion(unifiedShells, shelledBezier, k);
    };

    // Add shell
    float shelledCurves = sdShell(unifiedCurves, shellThickness);
    float shelledWithCylinder = opSmoothUnion(unifiedShells, unifiedCylinders, 0.02);
    float unifiedTubes = opSub(shelledWithCylinder, unifiedCurves);


    vec3 b = vec3(l1, l2, l3);
    float box = sdBox(p, b);
    float withBox = opIntersection(unifiedTubes, box);

    float scaledResult = scalingFactor * withBox;
    return scaledResult;
}
