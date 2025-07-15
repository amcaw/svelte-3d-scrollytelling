<script lang="ts">
  export let camera: any = null;
  export let model: any = null;
  export let duckModel: any = null; // Keep for backward compatibility
  export let controls: any = null;
  
  // Use whichever model prop is provided
  $: activeModel = model || duckModel;
  
  let debugMode = false;
  let debugCamera = { x: 0, y: 0, z: 15 };
  let debugRotation = { x: 0, y: 0, z: 0 };
  let debugObjectPosition = { x: 0, y: -2, z: 0 };
  let debugObjectRotation = { x: 0, y: 0, z: 0 };
  let debugObjectScale = 0.05;

  // Apply debug values to camera and object
  function applyDebugCamera() {
    if (camera && debugMode) {
      camera.position.set(debugCamera.x, debugCamera.y, debugCamera.z);
      camera.rotation.set(debugRotation.x, debugRotation.y, debugRotation.z);
    }
  }

  function applyDebugObject() {
    if (activeModel && debugMode) {
      activeModel.position.set(debugObjectPosition.x, debugObjectPosition.y, debugObjectPosition.z);
      activeModel.rotation.set(debugObjectRotation.x, debugObjectRotation.y, debugObjectRotation.z);
      activeModel.scale.set(debugObjectScale, debugObjectScale, debugObjectScale);
    }
  }

  function syncFromControls() {
    if (camera && controls) {
      debugCamera.x = parseFloat(camera.position.x.toFixed(1));
      debugCamera.y = parseFloat(camera.position.y.toFixed(1));
      debugCamera.z = parseFloat(camera.position.z.toFixed(1));
      debugRotation.x = parseFloat(camera.rotation.x.toFixed(2));
      debugRotation.y = parseFloat(camera.rotation.y.toFixed(2));
      debugRotation.z = parseFloat(camera.rotation.z.toFixed(2));
    }
    if (activeModel) {
      debugObjectPosition.x = parseFloat(activeModel.position.x.toFixed(1));
      debugObjectPosition.y = parseFloat(activeModel.position.y.toFixed(1));
      debugObjectPosition.z = parseFloat(activeModel.position.z.toFixed(1));
      debugObjectRotation.x = parseFloat(activeModel.rotation.x.toFixed(2));
      debugObjectRotation.y = parseFloat(activeModel.rotation.y.toFixed(2));
      debugObjectRotation.z = parseFloat(activeModel.rotation.z.toFixed(2));
    }
  }

  function copyToClipboard(text: string) {
    navigator.clipboard?.writeText(text);
  }

  function resetDebugValues() {
    debugCamera = { x: 0, y: 0, z: 15 };
    debugRotation = { x: 0, y: 0, z: 0 };
    debugObjectPosition = { x: 0, y: -2, z: 0 };
    debugObjectRotation = { x: 0, y: 0, z: 0 };
    debugObjectScale = 0.05;
    applyDebugCamera();
    applyDebugObject();
    if (controls) {
      controls.reset();
    }
  }

  function enableDebugMode() {
    debugMode = true;
    if (controls) {
      controls.enabled = true;
      syncFromControls();
    }
  }

  function disableDebugMode() {
    debugMode = false;
    if (controls) {
      controls.enabled = false;
    }
  }

  // Reactive statements
  $: if (debugMode && camera) {
    camera.position.set(debugCamera.x, debugCamera.y, debugCamera.z);
    camera.rotation.set(debugRotation.x, debugRotation.y, debugRotation.z);
  }
  
  $: if (debugMode && activeModel) {
    activeModel.position.set(debugObjectPosition.x, debugObjectPosition.y, debugObjectPosition.z);
    activeModel.rotation.set(debugObjectRotation.x, debugObjectRotation.y, debugObjectRotation.z);
    activeModel.scale.set(debugObjectScale, debugObjectScale, debugObjectScale);
  }

  // Export current values as formatted strings
  $: cameraPositionString = `[${debugCamera.x}, ${debugCamera.y}, ${debugCamera.z}]`;
  $: cameraRotationString = `[${debugRotation.x.toFixed(2)}, ${debugRotation.y.toFixed(2)}, ${debugRotation.z.toFixed(2)}]`;
  $: objectPositionString = `[${debugObjectPosition.x}, ${debugObjectPosition.y}, ${debugObjectPosition.z}]`;
  $: objectRotationString = `[${debugObjectRotation.x.toFixed(2)}, ${debugObjectRotation.y.toFixed(2)}, ${debugObjectRotation.z.toFixed(2)}]`;

  // Export the camera position/rotation values for story steps
  $: storyStepValues = `{
  title: "Step Title",
  content: "Step description...",
  cameraPosition: ${cameraPositionString},
  cameraRotation: ${cameraRotationString}
}`;

  // Export all values as JSON
  $: allValuesJson = JSON.stringify({
    camera: debugCamera,
    rotation: debugRotation,
    objectPosition: debugObjectPosition,
    objectRotation: debugObjectRotation,
    objectScale: debugObjectScale
  }, null, 2);

  // Export the component to parent
  export { debugMode };
</script>

<!-- Debug Panel -->
{#if debugMode}
  <div class="debug-panel">
    <div class="debug-header">
      <h3>3D Debug Helper</h3>
      <button on:click={disableDebugMode} class="debug-close">×</button>
    </div>
    
    <div class="debug-info">
      <p><strong>Mouse Controls:</strong> Drag to rotate, wheel to zoom, right-drag to pan</p>
      <button on:click={syncFromControls} class="sync-btn">Sync from Mouse</button>
    </div>

    <!-- Copy-Paste Values Section -->
    <div class="values-section">
      <h4>📋 Copy Values</h4>
      
      <div class="value-box">
        <label>Story Step Format:</label>
        <textarea readonly>{storyStepValues}</textarea>
        <button on:click={() => copyToClipboard(storyStepValues)} class="copy-btn">Copy</button>
      </div>

      <div class="value-row">
        <div class="value-box small">
          <label>Camera Position:</label>
          <input readonly value={cameraPositionString} />
          <button on:click={() => copyToClipboard(cameraPositionString)} class="copy-btn-small">📋</button>
        </div>
        <div class="value-box small">
          <label>Camera Rotation:</label>
          <input readonly value={cameraRotationString} />
          <button on:click={() => copyToClipboard(cameraRotationString)} class="copy-btn-small">📋</button>
        </div>
      </div>

      <div class="value-row">
        <div class="value-box small">
          <label>Object Position:</label>
          <input readonly value={objectPositionString} />
          <button on:click={() => copyToClipboard(objectPositionString)} class="copy-btn-small">📋</button>
        </div>
        <div class="value-box small">
          <label>Object Scale:</label>
          <input readonly value={debugObjectScale.toString()} />
          <button on:click={() => copyToClipboard(debugObjectScale.toString())} class="copy-btn-small">📋</button>
        </div>
      </div>

      <div class="value-box">
        <label>All Values (JSON):</label>
        <textarea readonly rows="8">{allValuesJson}</textarea>
        <button on:click={() => copyToClipboard(allValuesJson)} class="copy-btn">Copy JSON</button>
      </div>
    </div>

    <!-- Slider Controls -->
    <div class="debug-section">
      <h4>Camera Position</h4>
      <div class="debug-controls">
        <label>X: <input type="range" bind:value={debugCamera.x} min="-5" max="5" step="0.1" /></label>
        <span>{debugCamera.x}</span>
        <label>Y: <input type="range" bind:value={debugCamera.y} min="-5" max="5" step="0.1" /></label>
        <span>{debugCamera.y}</span>
        <label>Z: <input type="range" bind:value={debugCamera.z} min="0.5" max="10" step="0.1" /></label>
        <span>{debugCamera.z}</span>
      </div>
    </div>

    <div class="debug-section">
      <h4>Camera Rotation</h4>
      <div class="debug-controls">
        <label>X: <input type="range" bind:value={debugRotation.x} min="-3.14" max="3.14" step="0.1" /></label>
        <span>{debugRotation.x.toFixed(2)}</span>
        <label>Y: <input type="range" bind:value={debugRotation.y} min="-3.14" max="3.14" step="0.1" /></label>
        <span>{debugRotation.y.toFixed(2)}</span>
        <label>Z: <input type="range" bind:value={debugRotation.z} min="-3.14" max="3.14" step="0.1" /></label>
        <span>{debugRotation.z.toFixed(2)}</span>
      </div>
    </div>

    <div class="debug-section">
      <h4>Object Position</h4>
      <div class="debug-controls">
        <label>X: <input type="range" bind:value={debugObjectPosition.x} min="-3" max="3" step="0.1" /></label>
        <span>{debugObjectPosition.x}</span>
        <label>Y: <input type="range" bind:value={debugObjectPosition.y} min="-3" max="3" step="0.1" /></label>
        <span>{debugObjectPosition.y}</span>
        <label>Z: <input type="range" bind:value={debugObjectPosition.z} min="-3" max="3" step="0.1" /></label>
        <span>{debugObjectPosition.z}</span>
      </div>
    </div>

    <div class="debug-section">
      <h4>Object Scale</h4>
      <div class="debug-controls">
        <label>Scale: <input type="range" bind:value={debugObjectScale} min="0.1" max="3" step="0.1" /></label>
        <span>{debugObjectScale}</span>
      </div>
    </div>

    <div class="debug-actions">
      <button on:click={resetDebugValues} class="debug-btn">Reset</button>
    </div>
  </div>
{:else}
  <!-- Debug mode toggle button -->
  <button on:click={enableDebugMode} class="debug-toggle">Debug Helper</button>
{/if}

<style>
  /* Debug Panel Styles */
  .debug-toggle {
    position: fixed;
    top: 20px;
    left: 20px;
    z-index: 1000;
    background: rgba(255, 255, 255, 0.9);
    color: #333;
    border: 2px solid #007acc;
    border-radius: 8px;
    padding: 0.5rem 1rem;
    cursor: pointer;
    font-weight: bold;
    transition: all 0.3s ease;
  }

  .debug-toggle:hover {
    background: #007acc;
    color: white;
  }

  .debug-panel {
    position: fixed;
    top: 20px;
    left: 20px;
    width: 400px;
    max-height: 90vh;
    overflow-y: auto;
    background: rgba(0, 0, 0, 0.95);
    color: white;
    border-radius: 12px;
    padding: 1rem;
    z-index: 1000;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
  }

  .debug-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.3);
    padding-bottom: 0.5rem;
  }

  .debug-header h3 {
    margin: 0;
    color: #00ff88;
  }

  .debug-close {
    background: #ff4444;
    color: white;
    border: none;
    border-radius: 50%;
    width: 30px;
    height: 30px;
    cursor: pointer;
    font-size: 1.2rem;
    font-weight: bold;
  }

  .debug-info {
    background: rgba(0, 255, 136, 0.1);
    border: 1px solid rgba(0, 255, 136, 0.3);
    border-radius: 8px;
    padding: 0.75rem;
    margin-bottom: 1rem;
  }

  .debug-info p {
    margin: 0 0 0.5rem 0;
    font-size: 0.8rem;
    color: #00ff88;
  }

  .sync-btn {
    background: #00ff88;
    color: #000;
    border: none;
    border-radius: 6px;
    padding: 0.4rem 0.8rem;
    cursor: pointer;
    font-size: 0.8rem;
    font-weight: bold;
  }

  /* Values Section */
  .values-section {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 8px;
    padding: 1rem;
    margin-bottom: 1rem;
    border: 2px solid #ffaa00;
  }

  .values-section h4 {
    margin: 0 0 1rem 0;
    color: #ffaa00;
    font-size: 1rem;
  }

  .value-box {
    margin-bottom: 0.75rem;
    background: rgba(0, 0, 0, 0.3);
    border-radius: 6px;
    padding: 0.5rem;
    position: relative;
  }

  .value-box.small {
    margin-bottom: 0.5rem;
  }

  .value-box label {
    display: block;
    font-size: 0.75rem;
    color: #ccc;
    margin-bottom: 0.25rem;
    font-weight: bold;
  }

  .value-box textarea,
  .value-box input {
    width: 100%;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 4px;
    padding: 0.4rem;
    color: #ffaa00;
    font-family: monospace;
    font-size: 0.8rem;
    resize: none;
    box-sizing: border-box;
  }

  .value-box textarea {
    min-height: 60px;
  }

  .value-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 0.5rem;
  }

  .copy-btn {
    background: #ffaa00;
    color: #000;
    border: none;
    border-radius: 4px;
    padding: 0.3rem 0.6rem;
    cursor: pointer;
    font-size: 0.75rem;
    font-weight: bold;
    margin-top: 0.25rem;
    width: 100%;
  }

  .copy-btn-small {
    background: #ffaa00;
    color: #000;
    border: none;
    border-radius: 4px;
    padding: 0.2rem 0.4rem;
    cursor: pointer;
    font-size: 0.7rem;
    position: absolute;
    right: 0.5rem;
    top: 1.5rem;
    width: 30px;
  }

  .debug-section {
    margin-bottom: 1rem;
    padding: 0.5rem;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 8px;
  }

  .debug-section h4 {
    margin: 0 0 0.5rem 0;
    color: #88ccff;
    font-size: 0.9rem;
  }

  .debug-controls {
    display: flex;
    flex-direction: column;
    gap: 0.3rem;
  }

  .debug-controls label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.8rem;
  }

  .debug-controls input[type="range"] {
    flex: 1;
    height: 20px;
  }

  .debug-controls span {
    min-width: 40px;
    text-align: right;
    font-family: monospace;
    color: #ffaa00;
  }

  .debug-actions {
    display: flex;
    gap: 0.5rem;
    margin-top: 1rem;
  }

  .debug-btn {
    flex: 1;
    background: #007acc;
    color: white;
    border: none;
    border-radius: 6px;
    padding: 0.5rem;
    cursor: pointer;
    font-size: 0.8rem;
  }
</style>