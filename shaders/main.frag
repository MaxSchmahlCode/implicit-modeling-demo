precision highp float;

uniform vec2 iResolution;
uniform float iTime;
uniform float iSlider;
uniform float iRayFactor;

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
    float t = raymarch(ro, rd, hitPos); // Perform raymarching


    if (t > 0.0) {
        vec3 n = calcNormal(hitPos); // Calculate normal at hit position
        //vec3 color = phong(hitPos, n, ro, vec3(2.0, 4.0, 1.0)); // Apply Phong lighting
        vec3 color = mattediffuse(hitPos, n, vec3(2.0, 4.0, 10.0)); // Apply matte diffuse lighting
        gl_FragColor = vec4(pow(color, vec3(0.4545)), 1.0); // Gamma correction

        /* // 1. Compute surface normal
        vec3 n = calcNormal(hitPos);

        // 2. Compute base shaded color
        vec3 color = mattediffuse(hitPos, n, vec3(2.0, 4.0, 10.0));

        // 3. Compute final SDF distance at the hit point
        //    This MUST match the main SDF used in raymarching
        float d = map(hitPos);   // <--- IMPORTANT

        // 4. Antialiasing width based on pixel derivatives
        float aa = fwidth(d);

        // 5. Smooth edge alpha: 0 at surface, fade across aa
        float edge = smoothstep(0.0, aa, d);

        float alpha = 1.0 - edge;  // opaque at surface, fade away

        // 6. Gamma-correct + proper alpha
        gl_FragColor = vec4(pow(color, vec3(0.4545)), alpha); */

    } else {
        // gl_FragColor = vec4(getDirectionalColor(rd), 1.0);
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0); // Set transparent background
    }
}