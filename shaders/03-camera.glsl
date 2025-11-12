// camera.glsl
mat3 cameraMatrix(vec3 ro, vec3 target, float roll) {
    vec3 cw = normalize(target - ro);
    vec3 cp = vec3(sin(roll), cos(roll), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    return mat3(cu, cv, cw);
}

mat3 cameraMatrix_(vec3 ro, vec3 target, float roll) {
    vec3 cw = normalize(target - ro);          // forward
    vec3 up = vec3(0.0, 1.0, 0.0);             // world up
    vec3 cu = normalize(cross(up, cw));        // right
    vec3 cv = cross(cw, cu);                   // true up

    // Apply roll around forward axis
    float s = sin(roll);
    float c = cos(roll);
    mat3 rollMat = mat3(
        c, -s, 0.0,
        s,  c, 0.0,
        0.0, 0.0, 1.0
    );
    return mat3(cu, cv, cw) * rollMat;
}

vec3 getDirectionalColor(vec3 rd) {
    // Debug: color by ray direction
    // gray: (-z) rd=vec(0,0,-1)
    // red: (+x)
    // green: (+y)
    // blue: (+z)
    vec3 color = 0.5 + 0.5 * rd; // remap from [-1,1] to [0,1]
    return color;
}