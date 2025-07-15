# 🌟 Svelte 3D Scrollytelling

An interactive 3D scrollytelling experience built with Svelte 5, Three.js, and WebGL. Navigate through a miniature Japanese town with smooth camera movements synchronized to your scroll position.

![Demo](https://img.shields.io/badge/demo-live-brightgreen)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- **🎬 Smooth Scrollytelling**: Camera movements perfectly synchronized with scroll position
- **🎮 Interactive 3D Scene**: High-quality GLB model with responsive controls
- **📱 Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **⚡ Performance Optimized**: Throttled scroll events and efficient rendering
- **🎨 Modern UI**: Clean, minimal interface with smooth animations
- **🔧 TypeScript Support**: Full type safety throughout the codebase

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

The camera follows a continuous path through 7 key positions:
- Front View → Right Side → Back View → Left Side → Elevated View → Close Detail → Final Overview

Each transition is smoothly interpolated using cubic easing functions.

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
The main component handling:
- Three.js scene setup
- 3D model loading with DRACO compression
- Scroll event handling and camera interpolation
- Responsive design and performance optimization

#### Story Steps Configuration
```typescript
const storySteps = [
  {
    title: "Front View",
    content: "Starting our journey...",
    cameraPosition: [0, 1, 3],
    cameraRotation: [-0.3, 0, 0]
  },
  // ... more steps
];
```

## 🔧 Customization

### Adding New Story Steps

1. Add new step to `storySteps` array in `ScrollyD.svelte`
2. Define `cameraPosition` and `cameraRotation` 
3. Update step content and title

### Changing the 3D Model

Replace the GLB URL in the `GLTFLoader.load()` call:
```javascript
loader.load('your-model-url.glb', (gltf) => {
  // Model loaded
});
```

### Adjusting Camera Behavior

Modify these parameters in `ScrollyD.svelte`:
- `baseDistance`: Overall camera distance from model
- `fixedScale`: 3D model scale
- `easeInOutCubic()`: Animation easing function

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

## 📞 Support

If you have any questions or need help:
- Create an [issue](https://github.com/amcaw/svelte-3d-scrollytelling/issues)
- Check the [documentation](https://github.com/amcaw/svelte-3d-scrollytelling/wiki)

---

**Made with ❤️ by [amcaw](https://github.com/amcaw)**
