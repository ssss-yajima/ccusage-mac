# Makefile for CCUsageMac

.PHONY: all build clean test release dmg sign notarize

# Configuration
APP_NAME = CCUsageMac
BUNDLE_ID = com.yajima.ccusage-mac
VERSION = $(shell grep 'let appVersion' CCUsageMac/Sources/App.swift | cut -d'"' -f2)
DEVELOPER_ID = "Developer ID Application: Your Name (TEAM_ID)"

# Build paths
BUILD_DIR = .build
RELEASE_DIR = release
APP_PATH = $(RELEASE_DIR)/$(APP_NAME).app
DMG_NAME = $(APP_NAME)-$(VERSION).dmg
DMG_PATH = $(RELEASE_DIR)/$(DMG_NAME)

# Build configuration
SWIFT_BUILD_FLAGS = -c release --arch arm64 --arch x86_64
CODESIGN_FLAGS = --force --deep --sign $(DEVELOPER_ID) --options runtime --entitlements CCUsageMac/CCUsageMac.entitlements

all: build

build:
	@echo "Building $(APP_NAME) for release..."
	cd CCUsageMac && swift build $(SWIFT_BUILD_FLAGS)

app: build
	@echo "Creating app bundle..."
	@mkdir -p $(APP_PATH)/Contents/MacOS
	@mkdir -p $(APP_PATH)/Contents/Resources
	
	# Copy binary
	@cp CCUsageMac/$(BUILD_DIR)/apple/Products/Release/$(APP_NAME) $(APP_PATH)/Contents/MacOS/
	
	# Create Info.plist
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(APP_PATH)/Contents/Info.plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(APP_PATH)/Contents/Info.plist
	@echo '<plist version="1.0">' >> $(APP_PATH)/Contents/Info.plist
	@echo '<dict>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>CFBundleExecutable</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <string>$(APP_NAME)</string>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>CFBundleIdentifier</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <string>$(BUNDLE_ID)</string>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>CFBundleName</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <string>$(APP_NAME)</string>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>CFBundleShortVersionString</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <string>$(VERSION)</string>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>CFBundleVersion</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <string>$(VERSION)</string>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>LSMinimumSystemVersion</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <string>13.0</string>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>LSUIElement</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <true/>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>NSHighResolutionCapable</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <true/>' >> $(APP_PATH)/Contents/Info.plist
	@echo '</dict>' >> $(APP_PATH)/Contents/Info.plist
	@echo '</plist>' >> $(APP_PATH)/Contents/Info.plist

sign: app
	@echo "Signing app bundle..."
	codesign $(CODESIGN_FLAGS) $(APP_PATH)
	@echo "Verifying signature..."
	codesign --verify --verbose $(APP_PATH)

dmg: sign
	@echo "Creating DMG..."
	@mkdir -p $(RELEASE_DIR)
	
	# Create a temporary DMG directory
	@rm -rf $(RELEASE_DIR)/dmg-temp
	@mkdir -p $(RELEASE_DIR)/dmg-temp
	@cp -R $(APP_PATH) $(RELEASE_DIR)/dmg-temp/
	
	# Create DMG
	hdiutil create -volname "$(APP_NAME)" -srcfolder $(RELEASE_DIR)/dmg-temp -ov -format UDBZ $(DMG_PATH)
	
	# Clean up
	@rm -rf $(RELEASE_DIR)/dmg-temp
	
	@echo "DMG created at: $(DMG_PATH)"

notarize: dmg
	@echo "Notarizing DMG..."
	xcrun notarytool submit $(DMG_PATH) \
		--apple-id $(APPLE_ID) \
		--password $(NOTARIZATION_PASSWORD) \
		--team-id $(TEAM_ID) \
		--wait
	
	@echo "Stapling notarization..."
	xcrun stapler staple $(DMG_PATH)

release: notarize
	@echo "Release build complete!"
	@echo "DMG: $(DMG_PATH)"
	@echo "SHA256: $$(shasum -a 256 $(DMG_PATH) | cut -d' ' -f1)"

clean:
	@echo "Cleaning build artifacts..."
	cd CCUsageMac && swift package clean
	rm -rf $(BUILD_DIR)
	rm -rf $(RELEASE_DIR)

test:
	@echo "Running tests..."
	cd CCUsageMac && swift test