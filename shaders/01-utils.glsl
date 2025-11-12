// utils.glsl
float opUnion(float a, float b){ return min(a,b); }
float opSub(float a, float b){ return max(a, -b); }
float opIntersection(float a, float b){ return max(a,b); }

float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5*(d2 - d1)/k, 0.0, 1.0);
    return mix(d2, d1, h) - k*h*(1.0 - h);
}

float sdShell(float f, float thickness) {
    return abs(f) - thickness;
}

// ---------- SDF Primitives ----------
float sphereSDF(vec3 p, float r) { return length(p) - r; }
float boxSDF(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x,max(q.y,q.z)), 0.0);
}
float sdCylinder(vec3 p, float r, float halfh, int axis) {
    vec2 d;
    if (axis == 0)      d = vec2(length(p.yz) - r, abs(p.x) - halfh); // X axis
    else if (axis == 1) d = vec2(length(p.xz) - r, abs(p.y) - halfh); // Y axis
    else                d = vec2(length(p.xy) - r, abs(p.z) - halfh); // Z axis

    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}