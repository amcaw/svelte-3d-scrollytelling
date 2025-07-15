# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-07-15

### Added
- Initial release of Svelte 3D Scrollytelling
- Interactive 3D scrollytelling experience with LittlestTokyo model
- Smooth camera movements synchronized to scroll position
- 7 predefined story steps with seamless transitions
- Responsive design optimized for all devices
- Performance-optimized scroll event handling
- TypeScript support throughout the codebase
- Professional project structure with WorkingLib backup components
- Comprehensive documentation and setup instructions
- MIT license

### Technical Features
- Three.js integration with GLTFLoader and DRACOLoader
- Custom scroll interpolation with cubic easing
- Fixed model scaling for consistent cross-device experience
- Efficient animation loop with requestAnimationFrame
- Proper cleanup and memory management
- Static site deployment compatibility

### Components
- `ScrollyD.svelte`: Main scrollytelling component
- `WorkingLib/`: Backup development components
  - `ThrelteGlobe.svelte`: Original 3D globe component
  - `BelgiumMap.svelte`: 2D map component
  - `Helper.svelte`: Debug helper component