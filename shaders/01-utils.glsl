// utils.glsl
float opUnion(float a, float b){ return min(a,b); }
float opSub(float a, float b){ return max(a, -b); }
float opIntersection(float a, float b){ return max(a,b); }

float opSmoothUnion_(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5*(d2 - d1)/k, 0.0, 1.0);
    return mix(d2, d1, h) - k*h*(1.0 - h);
}

float opSmoothUnion( float d1, float d2, float k ) {
    k += 0.001;
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}

float opSmoothSubtraction( float d1, float d2, float k ) {
    return -opSmoothUnion(d1,-d2,k);
}

float opSmoothIntersection( float d1, float d2, float k ) {
    return -opSmoothUnion(-d1,-d2,k);
}

float sdShell(float f, float thickness) {
    return abs(f) - thickness;
}


mat2 rot2(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s,
                s,  c);
}

// ---------- SDF Primitives ----------
float sdSphere(vec3 p, float r) { return length(p) - r; } // sphereSDF -> sdSphere
float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x,max(q.y,q.z)), 0.0);
}
float sdCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x,d.y), 0.0) + length(max(d,0.0));
}
float sdCylinder(vec3 p, float r, float halfh, int axis) {
    vec2 d;
    if (axis == 0)      d = vec2(length(p.yz) - r, abs(p.x) - halfh); // X axis
    else if (axis == 1) d = vec2(length(p.xz) - r, abs(p.y) - halfh); // Y axis
    else                d = vec2(length(p.xy) - r, abs(p.z) - halfh); // Z axis

    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdCylinderY(vec3 p, float r, float halfh){
    vec2 d = vec2(length(vec2(p.x,p.z)) - r, abs(p.y) - halfh);
    return min(max(d.x,d.y), 0.0) + length(max(d,0.0));
}

float sdGyroid(vec3 p, float freq, float thickness) {
    // Normalize p to the gyroid period
    vec3 q = p * freq;
    // Distance-like combination of sines; the absolute combination approximates a surface
    float val = sin(q.x) * cos(q.y) + sin(q.y) * cos(q.z) + sin(q.z) * cos(q.x);
    // Convert a scalar field into a pseudo-distance
    // The following is a common trick: distance ~ magnitude of field minus thickness
    return abs(val) - thickness;
}

// Simple skeletal overlay: a thin network along the gyroid’s ridges
float gyroidRidge(vec3 p, float freq, float ridgeThick) {
    vec3 q = p * freq;
    // Ridge lines occur where the gyroid value is near zero; project to a 1D skeleton along those loci
    float v = sin(q.x) * cos(q.y) + sin(q.y) * cos(q.z) + sin(q.z) * cos(q.x);
    // Create a narrow band around zero: smaller than gyroid thickness
    return abs(v) - ridgeThick;
}
/////////////////
float gyroidF(vec3 p, float freq) {
    vec3 q = p * freq;
    // f = sin(x)cos(y) + sin(y)cos(z) + sin(z)cos(x)
    return sin(q.x)*cos(q.y) + sin(q.y)*cos(q.z) + sin(q.z)*cos(q.x);
}

// analytic gradient of gyroidF (w.r.t coordinates scaled by freq)
vec3 gyroidGrad(vec3 p, float freq) {
    vec3 q = p * freq;
    // df/dx = cos(x)cos(y) - sin(z)sin(x)
    float dfx = cos(q.x)*cos(q.y) - sin(q.z)*sin(q.x);
    // df/dy = -sin(x)sin(y) + cos(y)cos(z)
    float dfy = -sin(q.x)*sin(q.y) + cos(q.y)*cos(q.z);
    // df/dz = -sin(y)sin(z) + cos(z)cos(x)
    float dfz = -sin(q.y)*sin(q.z) + cos(q.z)*cos(q.x);
    // chain rule: derivative wrt p = freq * derivative wrt q
    return vec3(dfx, dfy, dfz) * freq;
}

// approximate signed distance to the gyroid surface
float gyroidSDF(vec3 p, float freq) {
    float f = gyroidF(p, freq);
    vec3 g = gyroidGrad(p, freq);
    float gnorm = max(length(g), 1e-6); // avoid div-by-zero
    return f / gnorm;
}

// skeletal field: returns a smooth occupancy (0..1) for a thin band around the gyroid.
// If you want a sign-preserving SDF, use gyroidSDF directly.
float skeletalGyroidField(vec3 p, float freq, float thickness) {
    float sd = gyroidSDF(p, freq);
    // we want a thin band around the surface: thickness is half-bandwidth
    // use smoothstep to get smooth falloff. smaller thickness => thinner skeleton.
    float band = 1.0 - smoothstep(0.0, thickness, abs(sd));
    return band; // 1.0 on the mid-surface, ->0 outside band
}

/* Example usage in a fragment shader ray-marcher:
   - use gyroidSDF() as the distance estimator for marching to the surface,
   - or sample skeletalGyroidField() in a volume ray-march / density -> color mapping
*/