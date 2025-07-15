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
  let baseDistance = 15.0; // Base distance for responsive scaling (moderate distance for LittlestTokyo)

  // Story steps with relative camera positions (will be multiplied by responsive distance)
  const storySteps: Array<{
    title: string;
    content: string;
    cameraPosition: [number, number, number];
    cameraRotation: [number, number, number];
  }> = [
    {
      title: "Front View",
      content: "Starting our journey with a direct front view of the miniature town.",
      cameraPosition: [0, 1, 3],
      cameraRotation: [-0.3, 0, 0]
    },
    {
      title: "Right Side",
      content: "Moving to the right side to see the town from a different angle.",
      cameraPosition: [2.1, 1, 2.1],
      cameraRotation: [-0.3, 0.785, 0]
    },
    {
      title: "Back View",
      content: "Continuing around to view the town from behind.",
      cameraPosition: [0, 1, -3],
      cameraRotation: [-0.3, 3.14, 0]
    },
    {
      title: "Left Side",
      content: "Completing the orbit by viewing from the left side.",
      cameraPosition: [-2.1, 1, 2.1],
      cameraRotation: [-0.3, -0.785, 0]
    },
    {
      title: "Elevated View",
      content: "Rising up for a higher perspective of the entire town layout.",
      cameraPosition: [0, 2.5, 3],
      cameraRotation: [-0.6, 0, 0]
    },
    {
      title: "Close Detail",
      content: "Moving in closer to explore the intricate architectural details.",
      cameraPosition: [1, 0.5, 2],
      cameraRotation: [-0.2, 0.4, 0]
    },
    {
      title: "Final Overview",
      content: "Ending with a comprehensive view that showcases the entire miniature world.",
      cameraPosition: [0, 1.5, 3.5],
      cameraRotation: [-0.4, 0, 0]
    }
  ];

  function setupScrollListener() {
    // Set initial camera position smoothly
    globalScrollProgress = 0;
    updateCameraFromGlobalProgress(0);
    
    function updateCameraFromScroll() {
      if (!camera) return;
      
      const storyContainer = document.querySelector('.story-container');
      if (!storyContainer) return;
      
      // Use more precise scroll calculation
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
      const windowHeight = window.innerHeight;
      
      // Calculate scroll progress based on story container position
      const containerRect = storyContainer.getBoundingClientRect();
      const containerTop = scrollTop + containerRect.top;
      const containerHeight = storyContainer.scrollHeight;
      
      // Start progress when container enters viewport, end when it exits
      const scrollStart = Math.max(0, containerTop - windowHeight);
      const scrollEnd = containerTop + containerHeight;
      const scrollRange = scrollEnd - scrollStart;
      
      // Calculate smooth progress
      const currentScroll = scrollTop + windowHeight / 2;
      const rawProgress = (currentScroll - scrollStart) / scrollRange;
      
      // Apply smooth clamping without hard stops
      const oldProgress = globalScrollProgress;
      globalScrollProgress = Math.max(0, Math.min(1, rawProgress));
      
      // Only update if there's a meaningful change
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
    const segmentLength = 1 / numSegments;
    
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
    
    // Update camera position and rotation smoothly
    camera.position.set(scaledPosition[0], scaledPosition[1], scaledPosition[2]);
    camera.rotation.set(rotation[0], rotation[1], rotation[2]);
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
      
      // Create camera with initial position at first step
      camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      
      // Set camera to first step position
      const firstStep = storySteps[0];
      camera.position.set(
        firstStep.cameraPosition[0] * baseDistance,
        firstStep.cameraPosition[1] * baseDistance,
        firstStep.cameraPosition[2] * baseDistance
      );
      camera.rotation.set(
        firstStep.cameraRotation[0],
        firstStep.cameraRotation[1],
        firstStep.cameraRotation[2]
      );
      
      // Initialize global scroll progress
      globalScrollProgress = 0;
      
      // Create renderer
      renderer = new THREE.WebGLRenderer({ canvas: canvasElement, antialias: true });
      renderer.setSize(window.innerWidth, window.innerHeight);
      renderer.setClearColor(0x1a1a2e);
      
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
          const fixedScale = 0.08;
          model.scale.set(fixedScale, fixedScale, fixedScale);
          model.position.y = -2;
          scene.add(model);
          
          // Setup scroll listener after model is loaded
          setTimeout(() => {
            const cleanup = setupScrollListener();
            window.addEventListener('beforeunload', cleanup);
          }, 100);
        },
        (progress) => {
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
          camera.aspect = window.innerWidth / window.innerHeight;
          camera.updateProjectionMatrix();
          renderer.setSize(window.innerWidth, window.innerHeight);
          
          // Keep model scale consistent on resize
          if (model) {
            const fixedScale = 0.08; // Same fixed scale
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
      
      isLoading = false;
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

<div class="scrollytelling-container">
  <!-- Fixed 3D model in background -->
  <div class="threlte-fixed">
    <canvas bind:this={canvasElement} class="three-canvas" style="display: {isLoading || hasError ? 'none' : 'block'}"></canvas>
    
    {#if isLoading}
      <div class="loading-fallback">
        <h2>Loading 3D Model...</h2>
        <p>Initializing Three.js and loading GLB model</p>
      </div>
    {:else if hasError}
      <div class="error-fallback">
        <h2>3D Model Error</h2>
        <p>{errorMessage}</p>
        <p>Please check the console for details</p>
      </div>
    {/if}
  </div>

  <!-- Story steps in foreground -->
  <div class="story-container">
    {#each storySteps as step, index}
      <div class="story-step" data-step={index}>
        <div class="step-content">
          <h2>{step.title}</h2>
          <p>{step.content}</p>
        </div>
      </div>
    {/each}
  </div>
</div>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    overflow-x: hidden;
  }
  
  .scrollytelling-container {
    position: relative;
    width: 100%;
    min-height: 100vh;
    overflow-x: hidden;
  }
  
  .threlte-fixed {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    z-index: 1;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    overflow: hidden;
  }
  
  .three-canvas {
    display: block;
    width: 100%;
    height: 100%;
  }
  
  .story-container {
    position: relative;
    z-index: 2;
    width: 100%;
    max-width: 100%;
    overflow-x: hidden;
  }
  
  .story-step {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    padding: 2rem;
    margin-left: 50%;
    width: 45%;
    box-sizing: border-box;
  }
  
  .step-content {
    background: rgba(255, 255, 255, 0.95);
    padding: 2rem;
    border-radius: 12px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    max-width: 400px;
    box-sizing: border-box;
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
  
  .loading-fallback h2 {
    font-size: 2rem;
    margin-bottom: 1rem;
    color: #4a90e2;
  }
  
  .error-fallback h2 {
    font-size: 2rem;
    margin-bottom: 1rem;
    color: #ff6b6b;
  }
  
  .loading-fallback p,
  .error-fallback p {
    font-size: 1.1rem;
    margin-bottom: 1rem;
    opacity: 0.8;
  }

  
  @media (max-width: 768px) {
    .story-step {
      margin-left: 0;
      width: 100%;
      justify-content: center;
      padding: 1rem;
      box-sizing: border-box;
    }
    
    .step-content {
      max-width: 90%;
      margin: 0 auto;
      box-sizing: border-box;
    }
    
    .step-content h2 {
      font-size: 1.5rem;
    }
    
    .step-content p {
      font-size: 1rem;
    }
  }
  
  @media (max-width: 480px) {
    .story-step {
      padding: 0.5rem;
      box-sizing: border-box;
    }
    
    .step-content {
      padding: 1.5rem;
      max-width: 95%;
      box-sizing: border-box;
    }
    
    .step-content h2 {
      font-size: 1.3rem;
    }
    
    .step-content p {
      font-size: 0.9rem;
    }
  }
</style>