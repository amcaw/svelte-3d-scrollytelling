<script lang="ts">
  import { onDestroy } from 'svelte';
  
  let hasError = false;
  let errorMessage = '';
  let isLoading = true;
  let canvasElement: HTMLCanvasElement;
  let scene: any;
  let camera: any;
  let renderer: any;
  let model: any;
  let animationId: number;
  let initialized = false;
  let controls: any;
  let globalScrollProgress = 0; // 0-1 progress through entire journey
  let baseDistance = 8.0; // Optimal distance for Tokyo house

  // Props for story steps
  export let storySteps: Array<{
    title: string;
    content: string;
    cameraPosition: [number, number, number];
    cameraRotation: [number, number, number];
  }> = [];

  function setupScrollListener() {
    // Ensure camera starts at exact first step position
    globalScrollProgress = 0;
    if (storySteps.length > 0) {
      updateCameraFromGlobalProgress(0);
    }
    
    function updateCameraFromScroll() {
      if (!camera) return;
      
      const sectionContainer = canvasElement.closest('.section-container');
      if (!sectionContainer) return;
      
      // Use more precise scroll calculation
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
      
      // Use the original working approach: calculate relative to foreground container
      const storyContainer = sectionContainer.querySelector('.foreground');
      if (!storyContainer) return;
      
      // Calculate scroll progress based on story container position
      const containerHeight = storyContainer.scrollHeight;
      const containerTop = (storyContainer as HTMLElement).offsetTop;
      
      // Start progress relative to this container
      const scrollStart = containerTop;
      const scrollEnd = containerTop + containerHeight;
      const scrollRange = scrollEnd - scrollStart;
      
      // Calculate progress directly from scroll position
      const rawProgress = (scrollTop - scrollStart) / scrollRange;
      
      // Apply smooth clamping without hard stops
      const oldProgress = globalScrollProgress;
      globalScrollProgress = Math.max(0, Math.min(1, rawProgress));
      
      // Use smaller threshold for smoother updates but add momentum
      if (Math.abs(oldProgress - globalScrollProgress) > 0.001) {
        updateCameraFromGlobalProgress(globalScrollProgress);
      }
    }
    
    // Optimize scroll handling with requestAnimationFrame
    let ticking = false;
    function handleScroll() {
      if (!ticking) {
        requestAnimationFrame(() => {
          updateCameraFromScroll();
          ticking = false;
        });
        ticking = true;
      }
    }
    
    window.addEventListener('scroll', handleScroll);
    
    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }
  
  function updateCameraFromGlobalProgress(progress: number) {
    if (!camera) return;
    
    // Clamp progress between 0 and 1
    progress = Math.max(0, Math.min(1, progress));
    
    // Calculate which segment of the path we're in
    const numSegments = storySteps.length - 1;
    
    // Find the two keyframes we're interpolating between
    let fromIndex, toIndex, localProgress;
    
    if (progress >= 1) {
      // At the end, use last two steps
      fromIndex = storySteps.length - 2;
      toIndex = storySteps.length - 1;
      localProgress = 1;
    } else {
      // Calculate segment index and local progress within that segment
      const segmentFloat = progress * numSegments;
      fromIndex = Math.floor(segmentFloat);
      toIndex = Math.min(fromIndex + 1, storySteps.length - 1);
      localProgress = segmentFloat - fromIndex;
    }
    
    const fromStep = storySteps[fromIndex];
    const toStep = storySteps[toIndex];
    
    // Apply smooth easing to local progress
    const easedProgress = easeInOutCubic(localProgress);
    
    // Interpolate position smoothly
    const position = [
      fromStep.cameraPosition[0] + (toStep.cameraPosition[0] - fromStep.cameraPosition[0]) * easedProgress,
      fromStep.cameraPosition[1] + (toStep.cameraPosition[1] - fromStep.cameraPosition[1]) * easedProgress,
      fromStep.cameraPosition[2] + (toStep.cameraPosition[2] - fromStep.cameraPosition[2]) * easedProgress
    ];
    
    // Interpolate rotation with angle wrapping
    const rotation = [
      interpolateAngle(fromStep.cameraRotation[0], toStep.cameraRotation[0], easedProgress),
      interpolateAngle(fromStep.cameraRotation[1], toStep.cameraRotation[1], easedProgress),
      interpolateAngle(fromStep.cameraRotation[2], toStep.cameraRotation[2], easedProgress)
    ];
    
    // Apply the camera transformation
    const scaledPosition = [
      position[0] * baseDistance,
      position[1] * baseDistance,
      position[2] * baseDistance
    ];
    
    // Use lerp for smoother camera movement
    const lerpFactor = 0.15; // Adjust for smoothness vs responsiveness
    camera.position.lerp({
      x: scaledPosition[0],
      y: scaledPosition[1], 
      z: scaledPosition[2]
    }, lerpFactor);
    
    // Smooth rotation interpolation
    const targetRotation = { x: rotation[0], y: rotation[1], z: rotation[2] };
    camera.rotation.x += (targetRotation.x - camera.rotation.x) * lerpFactor;
    camera.rotation.y += (targetRotation.y - camera.rotation.y) * lerpFactor;
    camera.rotation.z += (targetRotation.z - camera.rotation.z) * lerpFactor;
  }
  
  function easeInOutCubic(t: number): number {
    return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
  }
  
  function interpolateAngle(from: number, to: number, t: number): number {
    // Handle angle wrapping for smooth rotation
    let diff = to - from;
    
    // Choose shortest path around circle
    if (diff > Math.PI) {
      diff -= 2 * Math.PI;
    } else if (diff < -Math.PI) {
      diff += 2 * Math.PI;
    }
    
    return from + diff * t;
  }

  async function initThreeJS() {
    if (initialized) return;
    initialized = true;
    
    try {
      
      // Import Three.js, GLTFLoader, DRACOLoader, and OrbitControls
      const THREE = await import('three');
      const { GLTFLoader } = await import('three/examples/jsm/loaders/GLTFLoader.js');
      const { DRACOLoader } = await import('three/examples/jsm/loaders/DRACOLoader.js');
      const { OrbitControls } = await import('three/examples/jsm/controls/OrbitControls.js');
      
      // Create scene
      scene = new THREE.Scene();
      
      // Create camera with aspect ratio adjusted for the display area
      const visWidth = window.innerWidth; // Full width since vis-container is full width
      const isMobile = window.innerWidth <= 768;
      const aspectWidth = isMobile ? visWidth : visWidth * 0.6; // Full width on mobile, 60vw on desktop
      camera = new THREE.PerspectiveCamera(75, aspectWidth / window.innerHeight, 0.1, 1000);
      
      // Initialize global scroll progress (camera will be set by scroll listener)
      globalScrollProgress = 0;
      
      // Create renderer with full width
      renderer = new THREE.WebGLRenderer({ canvas: canvasElement, antialias: true });
      renderer.setSize(visWidth, window.innerHeight);
      renderer.setClearColor(0x1a1a2e);
      
      // Set camera viewport to focus on the right area (desktop) or full width (mobile)
      const leftOffset = isMobile ? 0 : window.innerWidth * 0.4; // No offset on mobile
      const rightWidth = isMobile ? window.innerWidth : window.innerWidth * 0.6; // Full width on mobile
      renderer.setViewport(leftOffset, 0, rightWidth, window.innerHeight);
      
      // Setup OrbitControls for mouse interaction
      controls = new OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true;
      controls.dampingFactor = 0.05;
      controls.enableZoom = true;
      controls.enableRotate = true;
      controls.enablePan = true;
      controls.enabled = false; // Disabled by default
      
      // Add lights
      const directionalLight = new THREE.DirectionalLight(0xffffff, 1.5);
      directionalLight.position.set(10, 10, 10);
      scene.add(directionalLight);
      
      const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
      scene.add(ambientLight);
      
      // Setup DRACO loader for compressed models
      const dracoLoader = new DRACOLoader();
      dracoLoader.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.6/');
      
      // Load the 3D GLB model
      const loader = new GLTFLoader();
      loader.setDRACOLoader(dracoLoader);
      loader.load(
        'https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/models/gltf/LittlestTokyo.glb',
        (gltf) => {
          model = gltf.scene;
          
          // Set fixed model scale for consistency across devices
          const fixedScale = 0.04;
          model.scale.set(fixedScale, fixedScale, fixedScale);
          model.position.y = -2;
          scene.add(model);
          
          // Setup scroll listener after model is loaded
          setTimeout(() => {
            const cleanup = setupScrollListener();
            window.addEventListener('beforeunload', cleanup);
            
            // Ensure camera is at first step position after everything is ready
            setTimeout(() => {
              // Set camera directly to first position without lerp for initial load
              if (storySteps.length > 0) {
                const firstStep = storySteps[0];
                const initialPosition = [
                  firstStep.cameraPosition[0] * baseDistance,
                  firstStep.cameraPosition[1] * baseDistance,
                  firstStep.cameraPosition[2] * baseDistance
                ];
                
                // Set camera position and rotation directly (no lerp on initial load)
                camera.position.set(initialPosition[0], initialPosition[1], initialPosition[2]);
                camera.rotation.set(firstStep.cameraRotation[0], firstStep.cameraRotation[1], firstStep.cameraRotation[2]);
              }
              
              // Now that everything is ready, show the canvas
              isLoading = false;
            }, 100);
          }, 200);
        },
        (_progressEvent) => {
          // Loading progress (silent)
        },
        (error) => {
          console.error('Error loading 3D model:', error);
          // Fallback to a simple cube if model loading fails
          const geometry = new THREE.BoxGeometry(1, 1, 1);
          const material = new THREE.MeshStandardMaterial({ color: 0xffd700 });
          model = new THREE.Mesh(geometry, material);
          scene.add(model);
        }
      );
      
      // Animation loop
      function animate() {
        animationId = requestAnimationFrame(animate);
        
        if (controls) {
          controls.update(); // Required for damping
        }
        
        renderer.render(scene, camera);
      }
      
      animate();
      
      // Handle window resize
      resizeHandler = () => {
        if (camera && renderer) {
          const visWidth = window.innerWidth; // Full width
          const isMobile = window.innerWidth <= 768;
          const aspectWidth = isMobile ? visWidth : visWidth * 0.6; // Full width on mobile, 60vw on desktop
          camera.aspect = aspectWidth / window.innerHeight;
          camera.updateProjectionMatrix();
          renderer.setSize(visWidth, window.innerHeight);
          
          // Update viewport based on device
          const leftOffset = isMobile ? 0 : window.innerWidth * 0.4; // No offset on mobile
          const rightWidth = isMobile ? window.innerWidth : window.innerWidth * 0.6; // Full width on mobile
          renderer.setViewport(leftOffset, 0, rightWidth, window.innerHeight);
          
          // Keep model scale consistent on resize
          if (model) {
            const fixedScale = 0.04; // Same smaller fixed scale
            model.scale.set(fixedScale, fixedScale, fixedScale);
            
            // Trigger initial scroll update
            setTimeout(() => {
              const event = new Event('scroll');
              window.dispatchEvent(event);
            }, 100);
          }
        }
      };
      
      window.addEventListener('resize', resizeHandler);
    } catch (error) {
      hasError = true;
      isLoading = false;
      errorMessage = 'Failed to load 3D libraries: ' + (error as Error).message;
      console.error('Three.js loading error:', error);
    }
  }

  // Watch for canvas element to be available
  $: if (canvasElement && !initialized) {
    initThreeJS();
  }

  let resizeHandler: (() => void) | null = null;

  onDestroy(() => {
    if (animationId) {
      cancelAnimationFrame(animationId);
    }
    if (renderer) {
      renderer.dispose();
    }
    if (resizeHandler) {
      window.removeEventListener('resize', resizeHandler);
    }
  });
</script>

<section class="section-container">
  <!-- Fixed 3D model in sticky background -->
  <div class="sticky-background">
    <div class="vis-container">
      <canvas bind:this={canvasElement} class="three-canvas" style="display: {isLoading || hasError ? 'none' : 'block'}"></canvas>
      
      {#if isLoading}
        <div class="loading-fallback">
          <div class="loader-spinner"></div>
        </div>
      {:else if hasError}
        <div class="error-fallback">
          <h2>3D Model Error</h2>
          <p>{errorMessage}</p>
          <p>Please check the console for details</p>
        </div>
      {/if}
    </div>
  </div>

  <!-- Story steps in foreground -->
  <div class="foreground" style="display: {isLoading ? 'none' : 'block'}">
    {#each storySteps as step, index}
      <div class="step" data-step={index}>
        <div class="step-content">
          <h2>{step.title}</h2>
          <p>{step.content}</p>
        </div>
      </div>
    {/each}
  </div>
</section>

<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  :global(body) { overflow-x: hidden; margin: 0; padding: 0; }
  :global(html) { margin: 0; padding: 0; }
  
  .section-container { 
    position: relative; 
    width: 100vw; 
    font-family: 'Montserrat', sans-serif;
    margin: 0;
    padding: 0;
  }
  
  .sticky-background {
    position: sticky; 
    top: 0; 
    left: 0;
    height: 100vh; 
    width: 100vw; 
    z-index: 1;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  }
  
  .vis-container {
    position: absolute; 
    top: 0; 
    left: 0; 
    right: 0; 
    bottom: 0; 
    overflow: hidden;
  }
  
  .three-canvas {
    display: block;
    width: 100%;
    height: 100%;
  }
  
  .foreground {
    position: relative; 
    z-index: 2; 
    width: 40vw;
    left: 0;
    top: 0;
    margin: 0;
    padding: 0;
    margin-top: -100vh;
  }
  
  .step {
    width: 100%; 
    height: 100vh;
    display: flex; 
    align-items: center; 
    justify-content: center;
    padding: 1rem;
    margin: 0;
  }
  
  .step-content {
    background-color: rgba(255, 255, 255, 0.95); 
    -webkit-backdrop-filter: blur(10px);
    backdrop-filter: blur(10px);
    color: black;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 12px;
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    justify-content: center;
    z-index: 10;
    text-align: left;
    width: 90%;
    max-width: none;
    margin: 0 auto;
  }
  
  .step-content h2 {
    margin: 0 0 1rem 0;
    color: #2d3748;
    font-size: 2rem;
    font-weight: bold;
  }
  
  .step-content p {
    margin: 0;
    color: #4a5568;
    font-size: 1.1rem;
    line-height: 1.6;
  }
  
  .loading-fallback,
  .error-fallback {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100vh;
    color: white;
    text-align: center;
    padding: 2rem;
  }
  
  .loader-spinner {
    width: 50px;
    height: 50px;
    border: 3px solid rgba(255, 255, 255, 0.3);
    border-top: 3px solid #ffffff;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
  
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
  
  .error-fallback h2 {
    font-size: 2rem;
    margin-bottom: 1rem;
    color: #ff6b6b;
  }
  
  .error-fallback p {
    font-size: 1.1rem;
    margin-bottom: 1rem;
    opacity: 0.8;
  }

  
  @media (max-width: 768px) {
    .sticky-background {
      position: sticky;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
    }
    
    .vis-container {
      left: 0;
    }
    
    .foreground {
      width: 100vw;
    }
    
    .step {
      height: 100vh;
    }
    
    .step-content {
      font-size: 1rem; 
      padding: 1rem; 
      width: 95%;
      background-color: rgba(255, 255, 255, 0.9);
    }
    
    .step-content h2 {
      font-size: 1.3rem;
    }
    
    .step-content p {
      font-size: 0.9rem;
    }
  }
  
  @media (max-width: 480px) {
    .step-content {
      padding: 0.8rem;
      width: 95%;
      font-size: 0.8rem;
    }
    
    .step-content h2 {
      font-size: 1.1rem;
    }
    
    .step-content p {
      font-size: 0.8rem;
    }
  }
</style>