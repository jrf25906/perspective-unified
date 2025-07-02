# Build Troubleshooting Guide

## Common Issue: "Multiple references with the same GUID"

### Problem Description
This error occurs when Xcode's project file gets corrupted with duplicate package references that have conflicting GUIDs. Common symptoms:
- `Could not compute dependency graph: unable to load transferred PIF`
- `The workspace contains multiple references with the same GUID`
- Build failures after adding/removing Swift packages

### Root Causes
1. **Multiple Package Additions**: Adding the same package multiple times through different methods
2. **Workspace Corruption**: Derived data or workspace files becoming corrupted
3. **Merge Conflicts**: Git merge conflicts in `.pbxproj` files
4. **User Data Pollution**: User-specific Xcode files interfering with project state

### Solutions

#### Quick Fix (Most Cases)
```bash
./clean-build.sh
```

#### Deep Clean (Severe Cases)
```bash
./clean-build.sh --reset-packages
```

#### Nuclear Option (Persistent GUID Conflicts)
```bash
./clean-build.sh --nuclear
```

#### Manual Resolution
1. **Clean everything**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   rm -rf perspective.xcodeproj/xcuserdata
   rm -rf perspective.xcodeproj/project.xcworkspace/xcuserdata
   ```

2. **Reset SPM if needed**:
   ```bash
   rm -rf perspective.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
   ```

3. **Re-resolve packages**:
   ```bash
   xcodebuild -project perspective.xcodeproj -resolvePackageDependencies
   ```

### Prevention Strategies

1. **Use the clean script** before major builds
2. **Don't commit user files** (covered by .gitignore)
3. **Add packages carefully** - remove old versions before adding new ones
4. **Regular cleanup** - run cleanup script weekly during active development

### Package Management Best Practices

#### Adding New Packages
1. Clean the project first: `./clean-build.sh`
2. Add package through Xcode UI only
3. Verify build succeeds before committing
4. Commit the `.pbxproj` and `Package.resolved` changes together

#### Removing Packages
1. Remove through Xcode UI only
2. Clean the project: `./clean-build.sh --reset-packages`
3. Verify build succeeds
4. Commit changes

#### Current Package Dependencies
- GoogleSignIn (Authentication)
- KeychainAccess (Secure storage)
- All Google dependencies are managed automatically

### Emergency Recovery

If the project becomes completely unbuildable:

1. **Restore from backup**:
   ```bash
   cp perspective.xcodeproj/project.pbxproj.backup perspective.xcodeproj/project.pbxproj
   ```

2. **Nuclear option** - recreate package references:
   - Remove all package references from project
   - Clean everything
   - Re-add packages one by one
   - Test build after each addition

### Files to Monitor
- `perspective.xcodeproj/project.pbxproj` - Main project file
- `perspective.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` - Package versions
- Derived data size (if growing excessively)

### Red Flags
- Project file size growing unexpectedly
- Multiple entries for same package in project.pbxproj
- Build times increasing significantly
- Packages not resolving consistently