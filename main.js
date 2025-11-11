async function loadShaderSource(path) {
  const response = await fetch(path);
  return await response.text();
}

async function createShaderProgram(gl) {
  const [vsSource, mainFrag, sdf, raymarch, lighting, camera, utils] = await Promise.all([
    loadShaderSource('shaders/main.vert'),
    loadShaderSource('shaders/main.frag'),
    loadShaderSource('shaders/sdf.glsl'),
    loadShaderSource('shaders/raymarch.glsl'),
    loadShaderSource('shaders/lighting.glsl'),
    loadShaderSource('shaders/camera.glsl'),
    loadShaderSource('shaders/utils.glsl'),
  ]);

  // Replace #include "..." manually
  let fragSource = mainFrag
    .replace('#include "utils.glsl"', utils)
    .replace('#include "sdf.glsl"', sdf)
    .replace('#include "camera.glsl"', camera)
    .replace('#include "raymarch.glsl"', raymarch)
    .replace('#include "lighting.glsl"', lighting);

  console.log('Original fragment shader:', mainFrag);
  console.log('After replacements:', fragSource);

  // Compile shaders
  const vertShader = compileShader(gl, gl.VERTEX_SHADER, vsSource);
  const fragShader = compileShader(gl, gl.FRAGMENT_SHADER, fragSource);
  const program = linkProgram(gl, vertShader, fragShader);
  
  return program;
}

function compileShader(gl, type, src) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, src);
  gl.compileShader(shader);
  
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    console.error('Shader compilation error:', gl.getShaderInfoLog(shader));
    return null;
  }
  
  return shader;
}

function linkProgram(gl, vs, fs) {
  const program = gl.createProgram();
  gl.attachShader(program, vs);
  gl.attachShader(program, fs);
  gl.linkProgram(program);
  
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    console.error('Program link error:', gl.getProgramInfoLog(program));
    return null;
  }
  
  return program;
}

// NEW: Create fullscreen quad
function createQuad(gl) {
  const positions = new Float32Array([
    -1, -1,
     1, -1,
    -1,  1,
     1,  1,
  ]);
  
  const buffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
  gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);
  
  return buffer;
}

// NEW: Main initialization and render loop
async function main() {
  const canvas = document.getElementById('glCanvas');
  if (!canvas) {
    console.error('Canvas not found!');
    return;
  }
  
  //const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
  const gl =
    canvas.getContext('webgl', { alpha: true }) ||
    canvas.getContext('experimental-webgl', { alpha: true });

  if (!gl) {
    console.error('WebGL not supported!');
    return;
  }
  
  console.log('WebGL context created');
  
  gl.enable(gl.BLEND); // Enable blending for transparency
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA); // Set blending function

  // Set canvas size
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  gl.viewport(0, 0, canvas.width, canvas.height);
  
  // Create shader program
  const program = await createShaderProgram(gl);
  if (!program) {
    console.error('Failed to create shader program');
    return;
  }
  
  gl.useProgram(program);
  
  // Create quad geometry
  const quadBuffer = createQuad(gl);
  
  // Get attribute and uniform locations
  const positionLoc = gl.getAttribLocation(program, 'position');
  const timeLoc = gl.getUniformLocation(program, 'iTime');
  const resolutionLoc = gl.getUniformLocation(program, 'iResolution');
  
  // Setup vertex attribute
  gl.bindBuffer(gl.ARRAY_BUFFER, quadBuffer);
  gl.enableVertexAttribArray(positionLoc);
  gl.vertexAttribPointer(positionLoc, 2, gl.FLOAT, false, 0, 0);
  
  // Handle window resize
  window.addEventListener('resize', () => {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewport(0, 0, canvas.width, canvas.height);
  });
  
  // Render loop
  const startTime = Date.now();
  
  function render() {
    const time = (Date.now() - startTime) / 1000.0;
    
    // Set uniforms
    if (timeLoc) gl.uniform1f(timeLoc, time);
    if (resolutionLoc) gl.uniform2f(resolutionLoc, canvas.width, canvas.height);
    
    // Clear and draw
    // gl.clearColor(0, 0, 0, 1);
    gl.clearColor(0, 0, 0, 0); // transparent background
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    
    requestAnimationFrame(render);
  }
  
  console.log('Starting render loop');
  render();
}

// Start when page loads
window.addEventListener('load', main);