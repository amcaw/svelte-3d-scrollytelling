<script lang="ts">
  import ScrollyD from '$lib/ScrollyD.svelte';
</script>

<ScrollyD storySteps={[
  {
    title: "Front View",
    content: "Starting our journey with a direct front view of the miniature town.",
    cameraPosition: [0, 1, 4],
    cameraRotation: [-0.2, 0, 0]
  },
  {
    title: "Dramatic Right Swing",
    content: "Sweeping dramatically to the right side with a bold camera movement.",
    cameraPosition: [3.5, 1.5, 3],
    cameraRotation: [-0.4, 0.8, 0]
  },
  {
    title: "Full Right Side",
    content: "Complete right side view showing the town from a perpendicular angle.",
    cameraPosition: [4, 1, 0],
    cameraRotation: [-0.3, 1.57, 0]
  },
  {
    title: "Swooping Behind",
    content: "Sweeping around to the back with an elevated perspective.",
    cameraPosition: [3, 2, -2.5],
    cameraRotation: [-0.6, 2.4, 0]
  },
  {
    title: "Full Back View",
    content: "Complete rear view of the town from a dramatic angle.",
    cameraPosition: [0, 1.5, -4],
    cameraRotation: [-0.3, 3.14, 0]
  },
  {
    title: "Left Side Approach",
    content: "Moving to the left side with a sweeping motion.",
    cameraPosition: [-3.5, 1.5, -2],
    cameraRotation: [-0.4, 3.8, 0]
  },
  {
    title: "Full Left Side",
    content: "Complete left side view showing the opposite perspective.",
    cameraPosition: [-4, 1, 0],
    cameraRotation: [-0.3, 4.71, 0]
  },
  {
    title: "High Dramatic Angle",
    content: "Soaring high above for a bird's eye view of the entire town.",
    cameraPosition: [0, 4, 2],
    cameraRotation: [-1.2, 0, 0]
  },
  {
    title: "Close Detail Dive",
    content: "Diving in close to explore the intricate details of the miniature world.",
    cameraPosition: [1.5, 0.5, 2.5],
    cameraRotation: [-0.1, 0.6, 0]
  },
  {
    title: "Final Cinematic Overview",
    content: "Ending with a cinematic wide shot that captures the entire magical scene.",
    cameraPosition: [0, 2, 5],
    cameraRotation: [-0.5, 0, 0]
  }
]} />