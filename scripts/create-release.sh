#!/bin/bash
# Script to create release files locally

set -e

VERSION=${1:-"1.0.0"}

echo "Creating release for version $VERSION..."

# Build the app
echo "Building app..."
./scripts/build-local.sh

# Create ZIP
echo "Creating ZIP file..."
cd release
zip -r "CCUsageMac-v$VERSION.zip" CCUsageMac.app
cd ..

# Create DMG
echo "Creating DMG file..."
mkdir -p dmg-temp
cp -R release/CCUsageMac.app dmg-temp/
hdiutil create -volname "CCUsageMac" -srcfolder dmg-temp -ov -format UDZO "release/CCUsageMac-v$VERSION.dmg"
rm -rf dmg-temp

echo "Release files created:"
echo "  - release/CCUsageMac-v$VERSION.zip"
echo "  - release/CCUsageMac-v$VERSION.dmg"
echo ""
echo "To create a GitHub release:"
echo "1. git tag -a v$VERSION -m 'Release version $VERSION'"
echo "2. git push origin v$VERSION"
echo "3. Upload the files to the GitHub release page"