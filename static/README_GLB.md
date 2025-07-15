# GLB Model Instructions

## Adding Your GLB Model

1. **Get a GLB model**: 
   - Download a 3D Earth/Globe model from sites like:
     - [Sketchfab](https://sketchfab.com/3d-models/earth) (search for "earth" or "globe")
     - [Poly Haven](https://polyhaven.com/) 
     - [Free3D](https://free3d.com/)
   - Or create your own in Blender and export as GLB

2. **Place the file**:
   - Save your GLB file as `globe.glb` in this `/static/` directory
   - Update the path in `ThrelteGlobe.svelte` from `/path/to/your/globe.glb` to `/globe.glb`

3. **Model Requirements**:
   - Should be centered at origin (0,0,0)
   - Reasonable size (scale 1-2 units)
   - Earth/globe-like appearance for best results

## Quick Test Model

If you don't have a GLB file, you can:
1. Download a free Earth model from Sketchfab
2. Or use a simple sphere with earth texture
3. Place it in this directory as `globe.glb`

## Example Models to Try

- **NASA Earth**: Search for "NASA Earth" on Sketchfab
- **Stylized Earth**: Look for cartoon or low-poly earth models
- **Realistic Earth**: High-detail earth models with continents

The component will automatically load and display your GLB model with smooth rotation animations tied to scroll position.