#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 iResolution; // used to be vec3
uniform float iTime;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = 0.5 + 0.5 * cos(1.0*iTime + uv.xyx + vec3(0,2,4));
    fragColor = vec4(col, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}
