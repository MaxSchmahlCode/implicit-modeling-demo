// sdf.glsl

// ---------- utility ----------
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

// ---------- Scene SDF ----------
float map(vec3 p) {
    float d1 = sphereSDF(p - vec3(1.0, 0.0, 0.0), 1.0);
    float d2 = boxSDF(p - vec3(0.0, 1.0, 0.0), vec3(1.0));
    // float su = opSmoothUnion(d1, d2, 0.5);
    float su = opSmoothUnion(d1, d2, iSlider);
    return su;
}
