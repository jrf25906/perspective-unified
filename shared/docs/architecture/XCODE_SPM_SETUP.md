# Xcode Swift Package Manager Setup Instructions

Follow these steps to configure your Xcode project to use Swift Package Manager:

## Step 1: Close Xcode
Close the perspective project if it's currently open in Xcode.

## Step 2: Clean Build Folder
1. Open Xcode
2. Open the perspective.xcodeproj
3. Go to Product → Clean Build Folder (⇧⌘K)

## Step 3: Remove Existing Package Dependencies (if any)
1. In the Project Navigator, select the project file (perspective at the top)
2. Select the perspective target
3. Go to the "General" tab
4. Scroll down to "Frameworks, Libraries, and Embedded Content"
5. Remove any package-related frameworks if present

## Step 4: Add Local Package
1. In Xcode, go to File → Add Package Dependencies...
2. Click "Add Local..." button at the bottom
3. Navigate to and select the perspective folder (the root folder containing Package.swift)
4. Click "Add Package"

## Step 5: Configure Package Products
1. In the dialog that appears, ensure "perspective" library is checked
2. Add it to the "perspective" target
3. Click "Add Package"

## Step 6: Clean and Build
1. Product → Clean Build Folder (⇧⌘K)
2. Product → Build (⌘B)

## Step 7: Resolve Package Dependencies
If Xcode doesn't automatically resolve dependencies:
1. File → Packages → Resolve Package Versions
2. Wait for all dependencies to download

## Troubleshooting

### If you see "Missing package product" errors:
1. File → Packages → Reset Package Caches
2. File → Packages → Resolve Package Versions
3. Clean and rebuild

### If GoogleSignIn requires additional setup:
1. GoogleSignIn may require a GoogleService-Info.plist file (already present in the project)
2. You may need to add URL schemes to Info.plist for Google Sign-In

### If build still fails:
1. Check that the iOS Deployment Target matches (iOS 15.0 or later)
2. Ensure Swift Language Version is set to 5.0 or later
3. Try deleting DerivedData:
   - ~/Library/Developer/Xcode/DerivedData/
   - Find and delete the perspective-* folder

## Expected Result
After following these steps, your project should:
- Use the local Package.swift for dependency management
- Successfully import KeychainAccess, GoogleSignIn, and Charts
- Build without "No such module" errors