function resizeCanvas(canvas, gl) {
  // Get CSS display size
  const width = canvas.clientWidth;
  const height = canvas.clientHeight;

  // Calculate aspect ratio you want, e.g., 1:1 for square
  const aspectRatio = 1;

  let newWidth = width;
  let newHeight = newWidth / aspectRatio;

  if (newHeight > height) {
    newHeight = height;
    newWidth = newHeight * aspectRatio;
  }

  // Set internal size to avoid stretching
  if (canvas.width !== newWidth || canvas.height !== newHeight) {
    canvas.width = newWidth;
    canvas.height = newHeight;
    gl.viewport(0, 0, newWidth, newHeight);
  }
}

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

  // Replace #include "..." manually
  let fragSource = mainFrag
    .replace('#include "01-utils.glsl"', utils)
    .replace('#include "02-sdf.glsl"', sdf)
    .replace('#include "03-camera.glsl"', camera)
    .replace('#include "04-raymarch.glsl"', raymarch)
    .replace('#include "05-lighting.glsl"', lighting);

  // Debug: Log the final fragment shader source
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
async function main(canvas, slider, sdfPath) {
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
  // canvas.width = window.innerWidth;
  // canvas.height = window.innerHeight;
  // gl.viewport(0, 0, canvas.width, canvas.height);

  // const canvas = document.getElementById('canvas1');
  // const gl = canvas.getContext('webgl');

  // Set actual drawing buffer size to match CSS displayed size
  // const cssWidth = canvas.clientWidth;
  // const cssHeight = canvas.clientHeight;
  // canvas.width = cssWidth;
  // canvas.height = cssHeight;

  // Update WebGL viewport to match canvas size
  // gl.viewport(0, 0, canvas.width, canvas.height);

  // Create shader program
  // const sdfPath = 'shaders/02-sdf.glsl'; // Default SDF path
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
  
  // Setup vertex attribute
  gl.bindBuffer(gl.ARRAY_BUFFER, quadBuffer);
  gl.enableVertexAttribArray(positionLoc);
  gl.vertexAttribPointer(positionLoc, 2, gl.FLOAT, false, 0, 0);
  
  // Handle window resize
  // window.addEventListener('resize', () => {
  //   canvas.width = window.innerWidth;
  //   canvas.height = window.innerHeight;
  //   gl.viewport(0, 0, canvas.width, canvas.height);
  // });

  // gl.viewport(0, 0, 300, 300);
  
  window.addEventListener('resize', () => resizeCanvas(canvas, gl));
  // resizeCanvas(canvas, gl);

  // Render loop
  const startTime = Date.now();

  function render() {
    const time = (Date.now() - startTime) / 1000.0;

    // Set uniforms
    // if (timeLoc) gl.uniform1f(timeLoc, time);
    // if (resolutionLoc) gl.uniform2f(resolutionLoc, canvas.width, canvas.height);
    // if (sliderLoc) gl.uniform1f(sliderLoc, parseFloat(slider.value));
    gl.uniform1f(timeLoc, time);
    gl.uniform2f(resolutionLoc, canvas.width, canvas.height);
    gl.uniform1f(sliderLoc, parseFloat(slider.value));

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
//window.addEventListener('load', main);
window.addEventListener('load', () => {
  main(document.getElementById('canvas1'), document.getElementById('slider1'), 'shaders/02-sdf.glsl');
  main(document.getElementById('canvas2'), document.getElementById('slider2'), 'shaders/02-sdf-pulley.glsl');
  main(document.getElementById('canvas3'), document.getElementById('slider3'), 'shaders/02-sdf-manifold.glsl');
});