# 🌟 Svelte 3D Scrollytelling

An interactive 3D scrollytelling experience built with Svelte 5, Three.js, and WebGL. Navigate through a miniature Japanese town with smooth camera movements synchronized to your scroll position.

![Demo](https://img.shields.io/badge/demo-live-brightgreen)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- **🎬 Dramatic Camera Movements**: Cinematic orbital camera paths with smooth transitions
- **🎮 Interactive 3D Scene**: High-quality GLB model at 1:1 scale without distortion
- **📱 Responsive Design**: Split-screen layout (40% content, 60% 3D scene) on desktop, stacked on mobile
- **⚡ Performance Optimized**: Throttled scroll events with requestAnimationFrame
- **🎨 Modern UI**: Glass-morphism design with backdrop blur effects
- **🔧 Flexible Configuration**: Story steps defined inline for easy customization
- **📐 Precise Scroll Mapping**: Perfect synchronization between scroll position and camera
- **🎯 TypeScript Support**: Full type safety throughout the codebase

## 🚀 Quick Start

### Prerequisites

- Node.js 20+ 
- npm or yarn
- Modern web browser with WebGL support

### Installation

```bash
# Clone the repository
git clone https://github.com/amcaw/svelte-3d-scrollytelling.git
cd svelte-3d-scrollytelling

# Install dependencies
npm install

# Start development server
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

## 🏗️ Project Structure

```
src/
├── lib/
│   └── ScrollyD.svelte          # Main scrollytelling component
├── WorkingLib/                  # Backup/development components
│   ├── ThrelteGlobe.svelte     # Original 3D globe component
│   ├── BelgiumMap.svelte       # 2D map component
│   └── Helper.svelte           # Debug helper component
├── routes/
│   └── +page.svelte            # Main page
└── static/                     # Static assets
```

## 🎮 How It Works

The scrollytelling experience consists of:

1. **3D Model Loading**: LittlestTokyo GLB model from Three.js examples
2. **Camera Path**: Predefined camera positions and rotations for smooth navigation
3. **Scroll Synchronization**: Real-time camera updates based on scroll progress
4. **Story Steps**: Text content that appears alongside the 3D scene

### Camera System

The camera follows a dramatic orbital path through 10 cinematic positions:
- **Front View** → **Dramatic Right Swing** → **Full Right Side** → **Swooping Behind** → **Full Back View** → **Left Side Approach** → **Full Left Side** → **High Dramatic Angle** → **Close Detail Dive** → **Final Cinematic Overview**

Each transition is smoothly interpolated using cubic easing functions with precise scroll mapping that returns to the exact starting position when scrolling back to the top.

## 🛠️ Development

### Available Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build
npm run check        # Run Svelte type checking
npm run check:watch  # Watch mode for type checking
```

### Technology Stack

- **Frontend**: Svelte 5, TypeScript
- **3D Graphics**: Three.js, WebGL
- **Build Tool**: Vite
- **Deployment**: Static site compatible

### Key Components

#### ScrollyD.svelte
The main component now features:
- **Flexible Props**: Accepts story steps as props for easy customization
- **Optimized Layout**: 40% left content area, 60% right 3D scene
- **1:1 Model Scale**: Natural model proportions without distortion
- **Precise Scroll Mapping**: Linear progression from 0 to 1 with perfect top/bottom alignment
- **Three.js Scene**: Automatic setup with proper aspect ratio handling
- **Mobile Responsive**: Stacked layout for smaller screens

#### Story Steps Configuration (New Inline Format)
```svelte
<!-- In your +page.svelte -->
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
  // ... more steps
]} />
```

## 🔧 Customization

### Adding New Story Steps

Story steps are now defined inline in your page for easy customization:

```svelte
<!-- In src/routes/+page.svelte -->
<ScrollyD storySteps={[
  {
    title: "Your Custom Title",
    content: "Your story content here...",
    cameraPosition: [x, y, z],
    cameraRotation: [rx, ry, rz]
  },
  // Add more steps...
]} />
```

### Camera Position Guidelines

- **cameraPosition**: `[x, y, z]` coordinates (multiplied by baseDistance=150)
  - `x`: Left (-) to Right (+)
  - `y`: Down (-) to Up (+) 
  - `z`: Forward (-) to Back (+)
- **cameraRotation**: `[rx, ry, rz]` angles in radians
  - `rx`: Pitch (look up/down)
  - `ry`: Yaw (look left/right)
  - `rz`: Roll (tilt)

### Changing the 3D Model

Replace the GLB URL in `ScrollyD.svelte`:
```javascript
loader.load('your-model-url.glb', (gltf) => {
  model = gltf.scene;
  model.scale.set(1, 1, 1); // Keep at 1:1 scale
  model.position.y = 0;
  scene.add(model);
});
```

### Layout Customization

Modify these CSS variables in `ScrollyD.svelte`:
- **Desktop Layout**: `vis-container` left position (default: 30vw)
- **Foreground Width**: `.foreground` width (default: 40vw)
- **Base Distance**: `baseDistance` for camera scaling (default: 150)
- **Model Scale**: Keep at `1, 1, 1` for no distortion

## 🆕 Recent Improvements

### v1.1.0 - Enhanced Scrollytelling Experience

- **🎯 Fixed Initial Camera Position**: The camera now properly starts at the first step view on page load
- **📐 Improved Scroll Calculation**: Perfect linear mapping from scroll position to camera progress (0 to 1)
- **🎬 Dramatic Camera Movements**: More cinematic orbital paths with swooping and dramatic angles
- **🎨 Split-Screen Layout**: Optimized 40% content / 60% 3D scene layout for better visual balance
- **📱 Enhanced Mobile Experience**: Responsive design with stacked layout for mobile devices
- **🔧 Inline Story Configuration**: Story steps now defined directly in component usage for easier editing
- **⚡ Performance Optimizations**: Improved scroll handling with requestAnimationFrame
- **🎮 1:1 Model Scale**: Natural model proportions without distortion
- **🧹 Production Ready**: Removed debug console logs for clean production code

### Key Fixes

- **Scroll-to-Top Behavior**: Camera now correctly returns to the first step when scrolling back to the top
- **Aspect Ratio Handling**: Proper camera aspect ratio for the 3D scene area
- **Initial Load Consistency**: The default view now matches the first story step exactly
- **Smooth Transitions**: All camera movements use cubic easing for cinematic quality

## 📦 Building for Production

```bash
# Build the project
npm run build

# Preview the build
npm run preview
```

The built files will be in the `build/` directory, ready for deployment to any static hosting service.

## 🚢 Deployment

This project is configured for static deployment and works with:
- **Vercel**: Zero-config deployment
- **Netlify**: Drag and drop build folder
- **GitHub Pages**: Enable in repository settings
- **Any static hosting**: Upload build folder contents

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Three.js](https://threejs.org/) for 3D graphics
- [Svelte](https://svelte.dev/) for the reactive framework
- [LittlestTokyo](https://github.com/mrdoob/three.js/tree/dev/examples/models/gltf) model from Three.js examples
- Inspired by modern scrollytelling techniques
