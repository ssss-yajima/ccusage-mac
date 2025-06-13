#!/bin/bash
# Build script for local testing without code signing

set -e

echo "Building CCUsageMac locally..."

# Clean previous builds
rm -rf release
mkdir -p release

# Build the app
cd CCUsageMac
swift build -c release

# Create app bundle
APP_PATH="../release/CCUsageMac.app"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Copy binary
cp .build/release/CCUsageMac "$APP_PATH/Contents/MacOS/"

# Create Info.plist
cat > "$APP_PATH/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CCUsageMac</string>
    <key>CFBundleIdentifier</key>
    <string>com.yajima.ccusage-mac</string>
    <key>CFBundleName</key>
    <string>CCUsageMac</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "Build complete! App is at: release/CCUsageMac.app"
echo "To run: open release/CCUsageMac.app"