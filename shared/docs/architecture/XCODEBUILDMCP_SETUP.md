# XcodeBuildMCP Setup and Usage Guide

## What is XcodeBuildMCP?

XcodeBuildMCP is a Model Context Protocol (MCP) server that provides Xcode-related tools for integration with AI assistants like Claude Code, Cursor, Windsurf, and Claude Desktop. It allows you to build, test, and deploy iOS apps directly from your AI-powered editor without switching to Xcode.

## Installation

### Option 1: Using NPM (Recommended)
The MCP configuration has been created at `.mcp/config.json` which uses npx to run the latest version:

```json
{
  "mcpServers": {
    "XcodeBuildMCP": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest"]
    }
  }
}
```

### Option 2: Using mise
If you prefer using mise (a polyglot dev tool manager), update the config to:

```json
{
  "mcpServers": {
    "XcodeBuildMCP": {
      "command": "mise",
      "args": ["x", "npm:xcodebuildmcp@1.9.0", "--", "xcodebuildmcp"]
    }
  }
}
```

## Available Commands

Once XcodeBuildMCP is configured, your AI assistant can use these commands:

### Swift Package Manager Commands
- **Run Tests**: Execute test suites with filtering and parallel execution
- **Run Executables**: Execute package binaries with timeout handling
- **Clean Artifacts**: Remove build artifacts for fresh builds
- **Process Management**: List and stop long-running processes

### Simulator Commands
- **List Simulators**: View available iOS simulators
- **Boot Simulator**: Start a specific simulator
- **Install App**: Deploy apps to simulators
- **Launch App**: Run apps on simulators
- **Capture Logs**: Get runtime logs from simulators

### Build Commands
- **Build for Simulator**: Build the perspective app for iOS Simulator
- **Build for Device**: Build for physical iOS devices (requires code signing)

## Usage Examples

When working with your AI assistant, you can ask it to:

1. **Build the app**:
   "Build the perspective app for iPhone 15 Pro simulator"

2. **Run tests**:
   "Run all tests in the perspective project"

3. **Deploy and test**:
   "Install and launch the perspective app on the simulator"

4. **Clean build**:
   "Clean the build artifacts and rebuild"

## Prerequisites

- Xcode must be installed on your system
- For device deployment, code signing must be configured in Xcode
- Node.js (for npx) or mise must be installed

## Troubleshooting

If you encounter issues, run the diagnostic tool:

```bash
# Using npx
npx xcodebuildmcp@latest xcodebuildmcp-diagnostic

# Using mise
mise x npm:xcodebuildmcp@1.9.0 -- xcodebuildmcp-diagnostic
```

## Important Notes

1. XcodeBuildMCP automatically skips macro validation to avoid errors with Swift Macros
2. Code signing must be configured in Xcode before using device deployment features
3. The tool integrates seamlessly with Swift Package Manager projects

## Benefits

- Build and test iOS apps without leaving your AI-powered editor
- Reduce context switching between Xcode and your code editor
- Automate common iOS development tasks through AI assistance
- Streamline the development workflow for Swift Package Manager projects