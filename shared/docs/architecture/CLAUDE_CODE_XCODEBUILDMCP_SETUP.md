# Claude Code XcodeBuildMCP Setup Guide

This guide will walk you through setting up XcodeBuildMCP in Claude Code to enable iOS development capabilities directly within your AI assistant.

## Prerequisites

1. **Claude Code** installed and running
2. **Xcode** installed on your Mac
3. **Node.js** installed (for npx command)
   - Check with: `node --version`
   - Install from: https://nodejs.org/ if needed

## Step 1: Locate Claude Code Configuration

Claude Code stores its configuration in your home directory. The config file location is:

```
~/.config/claude/claude_desktop_config.json
```

## Step 2: Edit Configuration

1. **Open Terminal** and create the config directory if it doesn't exist:
   ```bash
   mkdir -p ~/.config/claude
   ```

2. **Edit the configuration file**:
   ```bash
   # Using nano (simple)
   nano ~/.config/claude/claude_desktop_config.json
   
   # Or using VS Code
   code ~/.config/claude/claude_desktop_config.json
   
   # Or using any text editor
   open -e ~/.config/claude/claude_desktop_config.json
   ```

3. **Add or update the configuration** with the following content:

   If the file is empty or doesn't exist, use this complete configuration:
   ```json
   {
     "mcpServers": {
       "XcodeBuildMCP": {
         "command": "npx",
         "args": [
           "-y",
           "xcodebuildmcp@latest"
         ]
       }
     }
   }
   ```

   If the file already has content, add XcodeBuildMCP to the existing mcpServers section:
   ```json
   {
     "mcpServers": {
       "existing-server": {
         // ... existing configuration ...
       },
       "XcodeBuildMCP": {
         "command": "npx",
         "args": [
           "-y",
           "xcodebuildmcp@latest"
         ]
       }
     }
   }
   ```

## Step 3: Save and Restart Claude Code

1. **Save the configuration file**
2. **Completely quit Claude Code**:
   - Right-click on Claude Code in the dock
   - Select "Quit" (not just close the window)
3. **Restart Claude Code**

## Step 4: Verify Installation

Once Claude Code restarts, you can verify XcodeBuildMCP is working by asking Claude to:

1. "Can you check if XcodeBuildMCP is available?"
2. "List available iOS simulators using XcodeBuildMCP"
3. "What XcodeBuildMCP tools are available?"

## Alternative Installation Method: Using mise

If you prefer using mise (a polyglot runtime manager) instead of npx:

1. **Install mise** (if not already installed):
   ```bash
   curl https://mise.jdx.dev/install.sh | sh
   ```

2. **Update the configuration** to use mise:
   ```json
   {
     "mcpServers": {
       "XcodeBuildMCP": {
         "command": "mise",
         "args": [
           "x",
           "npm:xcodebuildmcp@1.9.0",
           "--",
           "xcodebuildmcp"
         ]
       }
     }
   }
   ```

## Available Commands After Setup

Once configured, you can ask Claude Code to:

### Build Commands
- "Build the perspective app for simulator"
- "Build for iPhone 15 Pro"
- "Clean and rebuild the project"

### Test Commands
- "Run all tests"
- "Run tests for a specific module"
- "Run tests in parallel"

### Simulator Commands
- "List available simulators"
- "Boot iPhone 15 simulator"
- "Install the app on simulator"
- "Launch the app"
- "Capture simulator logs"

### Swift Package Commands
- "Run swift build"
- "Clean swift package"
- "Update package dependencies"

## Troubleshooting

### Issue: XcodeBuildMCP commands not recognized

1. **Check configuration file syntax**:
   ```bash
   cat ~/.config/claude/claude_desktop_config.json | jq .
   ```
   If you see a syntax error, fix the JSON formatting.

2. **Ensure Claude Code was fully restarted**:
   - Quit Claude Code completely (not just close window)
   - Check Activity Monitor to ensure no Claude processes are running
   - Restart Claude Code

3. **Verify Node.js/npx is installed**:
   ```bash
   which npx
   npx --version
   ```

### Issue: "xcodebuild" errors

1. **Ensure Xcode is installed**:
   ```bash
   xcode-select -p
   ```

2. **Accept Xcode license** (if needed):
   ```bash
   sudo xcodebuild -license accept
   ```

3. **Install Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```

### Issue: Permission errors

Run the XcodeBuildMCP diagnostic tool:
```bash
npx xcodebuildmcp@latest xcodebuildmcp-diagnostic
```

This will check your system configuration and report any issues.

## Security Note

XcodeBuildMCP requests xcodebuild to skip macro validation to avoid errors when building projects that use Swift Macros. This is normal and expected behavior.

## Next Steps

After successful setup:

1. Navigate to your perspective project in Claude Code
2. Try building the app: "Build perspective for iPhone 15 Pro simulator"
3. Run tests: "Run all tests in the perspective project"
4. Deploy to simulator: "Install and launch perspective on the simulator"

## Additional Resources

- XcodeBuildMCP GitHub: https://github.com/cameroncooke/XcodeBuildMCP
- MCP Documentation: https://modelcontextprotocol.com/
- Claude Code Documentation: https://docs.anthropic.com/en/docs/claude-code