// Asynchronously fetch shader sources
async function loadShaderSource(path) {
  const response = await fetch(path);
  return await response.text();
}

// Load multiple shader source files
async function createShaderProgram(gl, sdfPath = 'shaders/02-sdf.glsl') {
  const [vsSource, mainFrag, utils, sdf, camera, raymarch, lighting] = await Promise.all([
    loadShaderSource('shaders/main.vert'),
    loadShaderSource('shaders/main.frag'),
    loadShaderSource('shaders/01-utils.glsl'),
    loadShaderSource(sdfPath),
    loadShaderSource('shaders/03-camera.glsl'),
    loadShaderSource('shaders/04-raymarch.glsl'),
    loadShaderSource('shaders/05-lighting.glsl'),
  ]);

  // Replace #include in fetched files manually
  let fragSource = mainFrag
    .replace('#include "01-utils.glsl"', utils)
    .replace('#include "02-sdf.glsl"', sdf)
    .replace('#include "03-camera.glsl"', camera)
    .replace('#include "04-raymarch.glsl"', raymarch)
    .replace('#include "05-lighting.glsl"', lighting);

  // Debug: Log the final fragment shader source code
  // console.log('Original fragment shader:', mainFrag);
  // console.log('After replacements:', fragSource);

  // Compile shaders
  const vertShader = compileShader(gl, gl.VERTEX_SHADER, vsSource);
  const fragShader = compileShader(gl, gl.FRAGMENT_SHADER, fragSource);
  const program = linkProgram(gl, vertShader, fragShader);
  
  return program;
}

// Setup shader
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

// Link program
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

// Create fullscreen quad vertex buffer (geometry on which shaders run)
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

// Main initialization and render loop
// Accept canvas and slider elements from the caller so we don't rely on a hard-coded id
export async function main(canvas, slider, sdfPath, rayFactor) {
  if (!canvas) {
    console.error('Canvas not found!');
    return;
  }
  
  const gl =
    canvas.getContext('webgl2', { alpha: true}); // ||
    //canvas.getContext('experimental-webgl', { alpha: true});

  if (!gl) {
    console.error('WebGL not supported!');
    return;
  }

  console.log('WebGL context created');
  
  gl.enable(gl.BLEND); // Enable blending for transparency
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA); // Set blending function

  // Set actual drawing buffer size to match CSS displayed size
  const cssWidth = canvas.clientWidth;
  const cssHeight = canvas.clientHeight;
  canvas.width = cssWidth;
  canvas.height = cssHeight;
  // Update WebGL viewport to match canvas size
  gl.viewport(0, 0, canvas.width, canvas.height);

  // Create shader program
  const program = await createShaderProgram(gl, sdfPath);
  if (!program) {
    console.error('Failed to create shader program');
    return;
  }
  
  gl.useProgram(program);
  
  // Create quad geometry
  const quadBuffer = createQuad(gl);
  
  // Get attribute and uniform locations
  const positionLoc = gl.getAttribLocation(program, 'position'); // What is 'position' for?
  const timeLoc = gl.getUniformLocation(program, 'iTime');
  const resolutionLoc = gl.getUniformLocation(program, 'iResolution');
  const sliderLoc = gl.getUniformLocation(program, 'iSlider');
  const rayFactorLoc = gl.getUniformLocation(program, 'iRayFactor');
  
  // Setup vertex attribute
  gl.bindBuffer(gl.ARRAY_BUFFER, quadBuffer);
  gl.enableVertexAttribArray(positionLoc);
  gl.vertexAttribPointer(positionLoc, 2, gl.FLOAT, false, 0, 0);
  
  // Works great
  // window.addEventListener('resize', () => resizeCanvas(canvas, gl)); // resize when window changes
  // resizeCanvas(canvas, gl); // resize when loaded

  // Render loop
  const startTime = Date.now();

  function render() {
    const time = (Date.now() - startTime) / 1000.0;

    // Set uniforms
    gl.uniform1f(timeLoc, time);
    gl.uniform2f(resolutionLoc, canvas.width, canvas.height);
    gl.uniform1f(sliderLoc, parseFloat(slider.value));
    gl.uniform1f(rayFactorLoc, parseFloat(rayFactor));

    // Clear and draw
    gl.clearColor(0, 0, 0, 0); // transparent background
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    requestAnimationFrame(render);
  }

  console.log('Starting render loop');
  render();
}

// Start when page loads
// window.addEventListener('load', () => {
//   main(document.getElementById('canvas0'), document.getElementById('slider0'), 'shaders/02-sdf-diff.glsl', 1.0);
//   main(document.getElementById('canvas1'), document.getElementById('slider1'), 'shaders/02-sdf-blend.glsl', 1.0);
//   main(document.getElementById('canvas2'), document.getElementById('slider2'), 'shaders/02-sdf-pulley.glsl', 1.0);
//   main(document.getElementById('canvas3'), document.getElementById('slider3'), 'shaders/02-sdf-gyroid.glsl', 0.1);
//   main(document.getElementById('canvas4'), document.getElementById('slider4'), 'shaders/02-sdf-manifold.glsl', 1.0);
// });

// export function main(canvas, slider, shader, scale) {
//   // your initialization logic...
// }

// // Make global for calls from outside modules
window.main = main;