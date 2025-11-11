precision highp float;

uniform vec2 iResolution;
uniform float iTime;

#include "utils.glsl"
#include "sdf.glsl"
#include "camera.glsl"
#include "raymarch.glsl"
#include "lighting.glsl"

// out vec4 fragColor;

// void main() {
//     // TEST: Simple color based on position
//     vec2 uv = gl_FragCoord.xy / iResolution.xy;
//     gl_FragColor = vec4(uv.x, uv.y, 0.0, 1.0);
//     return; // Remove this line once test works
    
//     // ... rest of your code
// }

void main() {

    vec2 uv = (gl_FragCoord.xy - 0.5 * iResolution.xy) / iResolution.y; // Normalized coordinates

    // vec3 ro = vec3(0.0, 2.0, 5.0); // Camera position
    // vec3 target = vec3(0.0, 1.0, 0.0); // Look-at target
    // mat3 cam = cameraMatrix(ro, target, 0.0); // Camera matrix
    // vec3 rd = normalize(cam * vec3(uv, -1.5)); // Ray direction

    vec3 ro = vec3(0.0, 1.0, 5.0);  // Move back more
    vec3 rd = normalize(vec3(uv, -1.0)); // Simple perspective

    vec3 hitPos; // To store hit position
    float t = raymarch(ro, rd, hitPos); // Perform raymarching

    if (t > 0.0) {
        vec3 n = calcNormal(hitPos); // Calculate normal at hit position
        //vec3 color = phong(hitPos, n, ro, vec3(2.0, 4.0, 1.0)); // Apply Phong lighting
        vec3 color = mattediffuse(hitPos, n, vec3(2.0, 4.0, 10.0)); // Apply matte diffuse lighting
        gl_FragColor = vec4(pow(color, vec3(0.4545)), 1.0); // Gamma correction
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0); // Set transparent background
    }
    // gl_FragColor = vec4(color, 0.0);
    // gl_FragColor = vec4(distToScene * 0.1, 0.0, 0.0, 0.0);
}