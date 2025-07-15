<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import * as d3 from 'd3';

  let globeContainer: HTMLDivElement;
  let selectedCountry: string | null = null;
  let currentStep = 0;
  let projection: d3.GeoProjection;
  let countries: d3.Selection<SVGPathElement, any, SVGGElement, unknown>;
  let svg: d3.Selection<SVGSVGElement, unknown, HTMLElement, any>;
  let path: d3.GeoPath<any, d3.GeoPermissibleObjects>;
  let globe: d3.Selection<SVGCircleElement, unknown, HTMLElement, any>;
  

  // Story steps with different globe positions
  const storySteps: Array<{
    title: string;
    content: string;
    rotation: [number, number, number];
  }> = [
    {
      title: "North America",
      content: "Home to diverse landscapes, from the Arctic tundra to tropical beaches, North America is a continent of contrasts.",
      rotation: [100, -45, 0]
    },
    {
      title: "North America",
      content: "Home to diverse landscapes, from the Arctic tundra to tropical beaches, North America is a continent of contrasts.",
      rotation: [100, -45, 0]
    },
    {
      title: "South America",
      content: "The land of the Amazon rainforest, Andes mountains, and vibrant cultures that span from Colombia to Chile.",
      rotation: [60, 15, 0]
    },
    {
      title: "Europe",
      content: "A continent rich in history, art, and culture, where ancient civilizations meet modern innovation.",
      rotation: [-10, -50, 0]
    },
    {
      title: "Africa",
      content: "The cradle of humanity, home to the Sahara desert, diverse wildlife, and incredible cultural diversity.",
      rotation: [-20, -10, 0]
    },
    {
      title: "Asia",
      content: "The largest continent, featuring the highest mountains, vast deserts, and home to over half the world's population.",
      rotation: [-70, -30, 0]
    },
    {
      title: "Australia & Oceania",
      content: "The land down under, with unique wildlife, coral reefs, and thousands of Pacific islands.",
      rotation: [-150, 30, 0]
    }
  ];

  function rotateGlobe(targetRotation: [number, number, number]) {
    if (!projection || !countries || !svg) return;
    
    isScrollAnimating = true;
    
    const currentRotation = projection.rotate();
    const interpolateRotation = d3.interpolate(currentRotation, targetRotation);
    
    const duration = 1500;
    const startTime = Date.now();
    
    // Custom easing function (ease-in-out-cubic)
    function easeInOutCubic(t: number): number {
      return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
    }
    
    function animate() {
      if (!isScrollAnimating) return; // Stop if user starts dragging
      
      const elapsed = Date.now() - startTime;
      const t = Math.min(elapsed / duration, 1);
      const easedT = easeInOutCubic(t);
      
      const currentRot = interpolateRotation(easedT);
      projection.rotate(currentRot);
      
      // Update all geographic elements
      countries.attr('d', path as any);
      svg.select('.graticule').attr('d', path as any);
      
      if (t < 1) {
        requestAnimationFrame(animate);
      } else {
        isScrollAnimating = false;
        // Process next queued animation if any
        setTimeout(() => processAnimationQueue(), 50);
      }
    }
    
    animate();
  }

  let isScrollAnimating = false;
  let animationQueue: number[] = [];

  function processAnimationQueue() {
    if (animationQueue.length === 0 || isScrollAnimating) return;
    
    const nextStep = animationQueue.shift();
    if (nextStep !== undefined && nextStep !== currentStep && nextStep >= 0 && nextStep < storySteps.length) {
      currentStep = nextStep;
      const step = storySteps[nextStep];
      if (step) {
        rotateGlobe(step.rotation);
      }
    }
  }

  function setupIntersectionObserver() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const stepIndex = parseInt(entry.target.getAttribute('data-step') || '0');
          if (stepIndex !== currentStep && stepIndex >= 0 && stepIndex < storySteps.length) {
            // Clear any queued animations and queue this one
            animationQueue = [stepIndex];
            
            // Only start animation if not already animating
            if (!isScrollAnimating) {
              processAnimationQueue();
            }
          }
        }
      });
    }, {
      threshold: 0.5,
      rootMargin: '-20% 0px -20% 0px'
    });

    // Observe all story steps
    document.querySelectorAll('.story-step').forEach((step) => {
      observer.observe(step);
    });

    return observer;
  }

 

  function resizeGlobe() {
    if (!svg || !projection || !countries) return;
    
    const width = window.innerWidth;
    const height = window.innerHeight;
    
    svg
      .attr('width', width)
      .attr('height', height)
      .attr('viewBox', `0 0 ${width} ${height}`);
    
    projection
      .scale(Math.min(width, height) / 2.5) // Much bigger scale - was /4, now /2.5
      .translate([width / 2, height / 2]);
    
    // Update globe circle
    if (globe) {
      globe
        .attr('cx', width / 2)
        .attr('cy', height / 2)
        .attr('r', projection.scale());
    }
    
    // Update all paths
    countries.attr('d', path as any);
    svg.select('.graticule').attr('d', path as any);
  }

  onMount(async () => {
    // Make fully responsive
    const container = d3.select(globeContainer);
    
    // Use full viewport dimensions
    const width = window.innerWidth;
    const height = window.innerHeight;
    const sensitivity = 75;

    svg = container
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .attr('viewBox', `0 0 ${width} ${height}`)
      .style('width', '100%')
      .style('height', '100%')
      .style('display', 'block') as any;

    projection = d3.geoOrthographic()
      .scale(Math.min(width, height) / 2.5) // Much bigger scale - was /4, now /2.5
      .center([0, 0])
      .rotate([0, -30])
      .translate([width / 2, height / 2]);

    const initialScale = projection.scale();
    path = d3.geoPath().projection(projection);

    // Ocean background
    globe = svg.append('circle')
      .attr('fill', '#4a90e2')
      .attr('stroke', '#2c5282')
      .attr('stroke-width', 2)
      .attr('r', initialScale)
      .attr('cx', width / 2)
      .attr('cy', height / 2);

    // Add graticule (grid lines)
    const graticule = d3.geoGraticule();
    
    svg.append('path')
      .datum(graticule)
      .attr('class', 'graticule')
      .attr('d', path)
      .style('fill', 'none')
      .style('stroke', '#ccc')
      .style('stroke-width', 0.5)
      .style('opacity', 0.3);

    try {
      const worldData = await d3.json('/world.geojson') as any;
      
      const map = svg.append('g');
      
      // Draw countries
      countries = map.selectAll('path')
        .data(worldData.features)
        .enter()
        .append('path')
        .attr('d', path as any)
        .attr('fill', '#2d5016')
        .attr('stroke', '#1a2e05')
        .attr('stroke-width', 0.5)
        .style('cursor', 'pointer')
        .on('mouseover', function(_event, d: any) {
          selectedCountry = d.properties.name;
          d3.select(this)
            .transition()
            .duration(200)
            .attr('fill', '#ff6b6b')
            .attr('stroke', '#c92a2a')
            .attr('stroke-width', 2);
        })
        .on('mouseout', function(_event, _d: any) {
          selectedCountry = null;
          d3.select(this)
            .transition()
            .duration(200)
            .attr('fill', '#2d5016')
            .attr('stroke', '#1a2e05')
            .attr('stroke-width', 0.5);
        })
        .on('click', function(_event, d: any) {
          // Just show country info on click, no zoom
          console.log('Clicked country:', d.properties.name);
        });

      // Add drag behavior for globe rotation only
      let isDragging = false;

      const drag = d3.drag()
        .on('start', function() {
          isDragging = true;
          isScrollAnimating = false; // Stop scroll animations when user drags
          animationQueue = []; // Clear any queued animations
        })
        .on('drag', function(event: any) {
          if (!isDragging) return;
          
          const rotate = projection.rotate();
          const k = sensitivity / projection.scale();
          projection.rotate([
            rotate[0] + event.dx * k,
            rotate[1] - event.dy * k
          ]);
          
          // Update all paths with the new projection
          countries.attr('d', path as any);
          svg.select('.graticule').attr('d', path as any);
        })
        .on('end', function() {
          isDragging = false;
        });

      // Apply drag only to the globe circle, not the entire SVG
      globe.call(drag as any);

      // Disable auto-rotation for scrollytelling
      // Auto-rotation will be controlled by scroll position

      // Setup intersection observer after DOM is ready
      setTimeout(() => {
        setupIntersectionObserver();
      }, 100);

      // Add window resize handler
      window.addEventListener('resize', resizeGlobe);

    } catch (error) {
      console.error('Error loading world data:', error);
    }
  });
  
  // Cleanup on component destroy
  onDestroy(() => {
    window.removeEventListener('resize', resizeGlobe);
  });
</script>

<div class="scrollytelling-container">
  <!-- Fixed globe in background -->
  <div class="globe-fixed" bind:this={globeContainer}></div>
  
  <!-- Story steps in foreground -->
  <div class="story-container">
    {#each storySteps as step, index (index)}
      <div class="story-step" data-step={index}>
        <div class="step-content">
          <h2>{step.title}</h2>
          <p>{step.content}</p>
          {#if selectedCountry}
            <div class="country-highlight">
              <strong>Highlighted: {selectedCountry}</strong>
            </div>
          {/if}
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
  
  .globe-fixed {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    z-index: 1;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    overflow: hidden;
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
  }
  
  .step-content {
    background: rgba(255, 255, 255, 0.95);
    padding: 2rem;
    border-radius: 12px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    max-width: 400px;
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
  
  .country-highlight {
    margin-top: 1rem;
    padding: 0.5rem;
    background-color: #ff6b6b;
    color: white;
    border-radius: 6px;
    font-size: 0.9rem;
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