// camera.glsl
mat3 cameraMatrix(vec3 ro, vec3 target, float roll) {
    vec3 cw = normalize(target - ro);
    vec3 cp = vec3(sin(roll), cos(roll), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = cross(cu, cw);
    return mat3(cu, cv, cw);
}
