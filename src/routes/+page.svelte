<script lang="ts">


  import ScrollyDAnimated from '$lib/ScrollyDAnimated.svelte';
  import ScrollyD from '$lib/ScrollyD.svelte';
</script>

<main>
 
  <!--

  <ScrollyD storySteps={[
    {
      title: "Welcome to Tokyo",
      content: "Step into a miniature version of Tokyo, where every building tells a story and every street corner holds memories.",
      cameraPosition: [0, 1, 4],
      cameraRotation: [-0.2, 0, 0]
    },
    {
      title: "Eastern District",
      content: "Moving to the eastern part of our miniature city, where traditional architecture meets modern design.",
      cameraPosition: [3.5, 1.5, 3],
      cameraRotation: [-0.4, 0.8, 0]
    },
    {
      title: "Commercial Quarter",
      content: "This is the bustling commercial district, filled with tiny shops and businesses that bring the city to life.",
      cameraPosition: [4, 1, 0],
      cameraRotation: [-0.3, 1.57, 0]
    },
    {
      title: "Residential Area",
      content: "Behind the commercial facade lies a peaceful residential area where families live and children play.",
      cameraPosition: [3, 2, -2.5],
      cameraRotation: [-0.6, 2.4, 0]
    },
    {
      title: "Historic Center",
      content: "The historic heart of our miniature Tokyo, where old temples and traditional buildings preserve the city's heritage.",
      cameraPosition: [0, 1.5, -4],
      cameraRotation: [-0.3, 3.14, 0]
    },
    {
      title: "Western Gardens",
      content: "The western side features beautiful miniature gardens and parks, offering tranquil spaces in the urban environment.",
      cameraPosition: [-3.5, 1.5, -2],
      cameraRotation: [-0.4, 3.8, 0]
    },
    {
      title: "Cultural District",
      content: "Here you'll find museums, theaters, and cultural centers that make this miniature city come alive.",
      cameraPosition: [-4, 1, 0],
      cameraRotation: [-0.3, 4.71, 0]
    },
    {
      title: "City Overview",
      content: "Rising high above the city, we can see how all the districts connect to form one harmonious miniature metropolis.",
      cameraPosition: [0, 4, 2],
      cameraRotation: [-1.2, 0, 0]
    },
    {
      title: "Street Level",
      content: "Coming down to street level, you can almost hear the sounds of daily life in this incredibly detailed miniature world.",
      cameraPosition: [1.5, 0.5, 2.5],
      cameraRotation: [-0.1, 0.6, 0]
    },
    {
      title: "Farewell Tokyo",
      content: "As our journey ends, we pull back to take one last look at this magical miniature Tokyo, where every detail tells a story.",
      cameraPosition: [0, 2, 5],
      cameraRotation: [-0.5, 0, 0]
    }
  ]} />

    -->



  <ScrollyDAnimated 
    enableRotation={false}
    rotationSpeed={0.01}
    storySteps={[
      {
        title: "Introduction",
        content: "Welcome to our interactive 3D animation experience. This model demonstrates how complex mechanical parts can move in sync with your scroll.",
        cameraPosition: [0, 1, 4],
        cameraRotation: [-0.2, 0, 0]
      },
      {
        title: "Component Analysis",
        content: "As you scroll, watch how individual components separate and move. Each part follows a carefully choreographed animation sequence.",
        cameraPosition: [3.5, 1.5, 3],
        cameraRotation: [-0.4, 0.8, 0]
      },
      {
        title: "Detailed Inspection",
        content: "From this angle, you can see the intricate details of each component. Notice how the textures and materials are preserved during animation.",
        cameraPosition: [4, 1, 0],
        cameraRotation: [-0.3, 1.57, 0]
      },
      {
        title: "Assembly Process",
        content: "The animation shows how complex assemblies come together. Each movement is calculated to demonstrate the relationship between parts.",
        cameraPosition: [3, 2, -2.5],
        cameraRotation: [-0.6, 2.4, 0]
      },
      {
        title: "Technical Overview",
        content: "This rear view reveals the internal mechanisms and how they interact during the animation sequence.",
        cameraPosition: [0, 1.5, -4],
        cameraRotation: [-0.3, 3.14, 0]
      },
      {
        title: "Final Assembly",
        content: "Watch as all components come together in their final positions, completing the animation cycle.",
        cameraPosition: [-3.5, 1.5, -2],
        cameraRotation: [-0.4, 3.8, 0]
      }
    ]} 
  />


 

</main>

<style>
  main {
    width: 100%;
    margin: 0;
    padding: 0;
  }
</style>