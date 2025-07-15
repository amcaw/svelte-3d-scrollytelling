# 📖 Usage Guide - Svelte 3D Scrollytelling

This guide will walk you through setting up, developing, and deploying your Svelte 3D Scrollytelling project like a professional developer.

## 🚀 Getting Started

### 1. Create the GitHub Repository

Since GitHub CLI is not available, create the repository manually:

1. Go to [GitHub](https://github.com) and sign in to your account
2. Click the "+" icon in the top right corner
3. Select "New repository"
4. Fill in the details:
   - **Repository name**: `svelte-3d-scrollytelling`
   - **Description**: `Interactive 3D scrollytelling experience with Three.js and Svelte`
   - **Visibility**: Public
   - **Do NOT initialize** with README, .gitignore, or license (we have these already)
5. Click "Create repository"

### 2. Push Your Code

```bash
# Push to GitHub (you're already set up for this)
git push -u origin main

# Create and push a tag for v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0: Initial release with 3D scrollytelling"
git push origin v1.0.0
```

### 3. Create a GitHub Release

1. Go to your repository on GitHub
2. Click "Releases" in the right sidebar
3. Click "Create a new release"
4. Choose tag: `v1.0.0`
5. Release title: `v1.0.0 - Initial Release`
6. Description:
```markdown
## 🎉 Initial Release

This is the first release of Svelte 3D Scrollytelling featuring:

### ✨ Features
- Interactive 3D scrollytelling with smooth camera movements
- LittlestTokyo 3D model with optimized loading
- Responsive design for all devices
- Performance-optimized scroll handling
- TypeScript support throughout

### 🛠️ Technical Details
- Built with Svelte 5 and Three.js
- DRACO compression for efficient model loading
- Cubic easing for smooth animations
- Static site deployment ready

### 📦 Installation
```bash
git clone https://github.com/amcaw/svelte-3d-scrollytelling.git
cd svelte-3d-scrollytelling
npm install
npm run dev
```

### 🚀 Demo
Visit the live demo: [Add your deployment URL here]
```

## 🔧 Development Workflow

### Branch Strategy

```bash
# Create feature branch
git checkout -b feature/new-camera-path

# Work on your feature...
git add .
git commit -m "feat: add new camera path with 10 steps"

# Push feature branch
git push origin feature/new-camera-path

# Create Pull Request on GitHub
# After merge, update main branch
git checkout main
git pull origin main
git branch -d feature/new-camera-path
```

### Commit Convention

Use conventional commits for better versioning:

```bash
# Features
git commit -m "feat: add new 3D model loader"

# Bug fixes
git commit -m "fix: resolve camera jump on mobile"

# Documentation
git commit -m "docs: update README with new features"

# Performance
git commit -m "perf: optimize scroll event handling"

# Refactoring
git commit -m "refactor: simplify camera interpolation logic"
```

### Version Management

```bash
# Update version in package.json
npm version patch   # 1.0.0 -> 1.0.1
npm version minor   # 1.0.1 -> 1.1.0
npm version major   # 1.1.0 -> 2.0.0

# Push with tags
git push origin main --tags
```

## 🏗️ Project Structure Deep Dive

```
svelte-3d-scrollytelling/
├── src/
│   ├── lib/
│   │   └── ScrollyD.svelte          # Main component
│   ├── WorkingLib/                  # Development backups
│   │   ├── ThrelteGlobe.svelte     # Original 3D globe
│   │   ├── BelgiumMap.svelte       # 2D map component
│   │   └── Helper.svelte           # Debug helper
│   ├── routes/
│   │   └── +page.svelte            # Main page
│   └── static/                     # Static assets
├── docs/                           # Documentation
├── CHANGELOG.md                    # Version history
├── LICENSE                         # MIT license
├── README.md                       # Main documentation
└── USAGE_GUIDE.md                 # This guide
```

## 🎨 Customization Guide

### Adding New Story Steps

1. **Edit ScrollyD.svelte**:
```typescript
const storySteps = [
  // ... existing steps
  {
    title: "New Perspective",
    content: "Description of the new view...",
    cameraPosition: [1, 2, 3],
    cameraRotation: [-0.3, 0.5, 0]
  }
];
```

2. **Test your changes**:
```bash
npm run dev
```

3. **Commit your changes**:
```bash
git add .
git commit -m "feat: add new perspective story step"
```

### Changing the 3D Model

1. **Update the model URL** in `ScrollyD.svelte`:
```javascript
loader.load('https://your-model-url.glb', (gltf) => {
  // Model loaded
});
```

2. **Adjust scale if needed**:
```javascript
const fixedScale = 0.05; // Adjust based on your model
```

3. **Update camera positions** to fit your model:
```javascript
let baseDistance = 20.0; // Increase for larger models
```

### Performance Optimization

1. **Throttle scroll events** (already implemented):
```javascript
let scrollTimeout: number | null = null;
function handleScroll() {
  if (scrollTimeout) return;
  scrollTimeout = requestAnimationFrame(() => {
    updateCameraFromScroll();
    scrollTimeout = null;
  });
}
```

2. **Optimize model loading**:
```javascript
// Use DRACO compression (already implemented)
const dracoLoader = new DRACOLoader();
dracoLoader.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.6/');
```

## 🚀 Deployment Options

### 1. Vercel (Recommended)
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Follow prompts, then your site is live!
```

### 2. Netlify
```bash
# Build first
npm run build

# Drag and drop the 'build' folder to https://app.netlify.com/drop
```

### 3. GitHub Pages
1. Go to repository Settings
2. Scroll to "Pages" section
3. Source: Deploy from a branch
4. Branch: main, folder: /build
5. Save

### 4. Custom Server
```bash
# Build for production
npm run build

# Upload 'build' folder contents to your server
```

## 🔍 Debugging Tips

### Common Issues

1. **Model not loading**:
   - Check browser console for CORS errors
   - Verify GLB URL is accessible
   - Test with a simple model first

2. **Camera jumping**:
   - Check scroll progress calculation
   - Verify camera positions are reasonable
   - Add console logs to debug values

3. **Performance issues**:
   - Use browser dev tools Performance tab
   - Check for memory leaks
   - Optimize model size

### Debug Mode

Add temporary debug logging:
```javascript
console.log('Camera position:', camera.position.toArray());
console.log('Scroll progress:', globalScrollProgress);
```

## 📊 Analytics & Monitoring

### Adding Google Analytics

1. **Install gtag**:
```bash
npm install gtag
```

2. **Add to app.html**:
```html
<script async src="https://www.googletagmanager.com/gtag/js?id=YOUR_GA_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'YOUR_GA_ID');
</script>
```

### Performance Monitoring

Track scroll performance:
```javascript
// Add to ScrollyD.svelte
const performanceObserver = new PerformanceObserver((list) => {
  const entries = list.getEntries();
  entries.forEach(entry => {
    if (entry.duration > 16) { // > 60fps
      console.warn('Slow scroll event:', entry.duration);
    }
  });
});
performanceObserver.observe({ entryTypes: ['measure'] });
```

## 🤝 Contributing Guidelines

### For Contributors

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Make changes with tests**
4. **Follow commit conventions**
5. **Push and create PR**

### Code Style

- Use TypeScript for type safety
- Follow Svelte conventions
- Keep components focused and reusable
- Add comments for complex logic
- Test on multiple devices

## 🆘 Troubleshooting

### Build Issues
```bash
# Clear cache
rm -rf node_modules package-lock.json
npm install

# Check for TypeScript errors
npm run check
```

### Git Issues
```bash
# Reset to clean state
git reset --hard HEAD
git clean -fd

# Fix commit author
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

## 📚 Resources

- [Svelte Documentation](https://svelte.dev/docs)
- [Three.js Documentation](https://threejs.org/docs/)
- [Vite Documentation](https://vitejs.dev/guide/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

## 🎯 Next Steps

1. **Deploy your site** using one of the options above
2. **Add custom domain** if desired
3. **Set up CI/CD** for automatic deployments
4. **Add analytics** to track usage
5. **Collect feedback** and iterate

---

**Happy coding! 🚀**

*This guide covers professional development practices for your Svelte 3D Scrollytelling project. Follow these patterns for maintainable, scalable code.*