#version 300 es
precision highp float;

uniform vec2 iResolution;
uniform float iTime;
uniform float iSlider;
uniform float iRayFactor;

out vec4 fragColor;
// out vec3 gl_FragCoord;

#include "01-utils.glsl"
#include "02-sdf.glsl"
#include "03-camera.glsl"
#include "04-raymarch.glsl"
#include "05-lighting.glsl"

void main() {

    vec2 uv = (gl_FragCoord.xy - 0.5 * iResolution.xy) / iResolution.y; // Normalized coordinates

    // vec2 uv = (gl_FragCoord.xy / iResolution) * 2.0 - 1.0;
    // uv.x *= iResolution.x / iResolution.y;

    vec3 camPos = 2.0*vec3(0.8, 0.8, 4.2); // Camera position (ro)
    vec3 target = vec3(0.0, 0.0, 0.0); // Look-at target
    mat3 cam = cameraMatrix(camPos, target, 0.0); // Camera matrix
    // vec3 rd = normalize(cam * vec3(uv, 1.0)); // Ray direction

    // --- Orthographic projection ---
    // Move the ray origin laterally across the view plane
    // vec3 rayOrigin = ro + cam * vec3(uv, 0.0);
    // All rays go in same direction
    // vec3 rayDir = normalize(cam * vec3(0.0, 0.0, -1.0));

    float uOrtho = 1.0;  // 0 = perspective, 1 = orthographic

    vec3 ro, rd;
    if (uOrtho > 0.5) {
        // orthographc
        ro = camPos + cam * vec3(4.0*uv, 0.0);
        rd = normalize(cam * vec3(0.0, 0.0, 1.0));
    } else {
        // perspective
        ro = camPos;
        rd = normalize(cam * vec3(uv, -1.5));
    }

    vec3 hitPos; // To store hit position
    float minDist; // To store minimum distance to surface
    float t = raymarch( ro, rd, hitPos, minDist); // Perform raymarching
    float k = 2.50;
    float aa = fwidth(minDist) * k;
    // float aa = max(0.0, min(1.0, fwidth(d) * 0.75)); // tune 0.75 as needed
    float alpha = 1.0 - smoothstep(0.0, aa, minDist);
    // float alpha = 1.0 - smoothstep(-aa, aa, minDist);

    if (t > 0.0) {
        vec3 n = calcNormal(hitPos); // Calculate normal at hit position
        //vec3 color = phong(hitPos, n, ro, vec3(2.0, 4.0, 1.0)); // Apply Phong lighting
        vec3 color = mattediffuse(hitPos, n, vec3(2.0, 4.0, 10.0)); // Apply matte diffuse lighting
        fragColor = vec4(pow(color, vec3(0.4545)), 1.0); // Gamma correction

        // edge = smoothstep(th1, th2, minDist - dNear)
        // fragColor = mix(colorNear, colorFar, edge)

    } else {
        vec3 n = calcNormal(hitPos);
        vec3 color = mattediffuse(hitPos, n, vec3(2.0, 4.0, 10.0));
        vec3 black = vec3(0.0);
        fragColor = vec4(pow(black, vec3(0.4545)), alpha);

        // gl_FragColor = vec4(getDirectionalColor(rd), 1.0);
        // fragColor = vec4(0.0, 0.0, 0.0, 0.0); // Set transparent background
        // fragColor = vec4(minDist * 10.0);
    }
}