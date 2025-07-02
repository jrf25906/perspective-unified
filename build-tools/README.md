# Build Tools

This directory contains build and asset generation tools for the Perspective app.

## Files

### Lottie Animation Builder
- **`build.js`** - Lottie animation build script for splash screen

## Usage

### Lottie Animation Build
```bash
# Run the build script
node build-tools/build.js
```

This script processes Lottie animations for the app's splash screen and welcome experience.

## Dependencies

The build scripts may require additional npm packages. Install them as needed:
```bash
npm install lottie-web
# Add other dependencies as required
```

## Notes

These build tools were consolidated from various locations during project organization. They support the asset pipeline for the iOS and web versions of the Perspective app.