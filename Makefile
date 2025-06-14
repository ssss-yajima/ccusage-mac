# Simple Makefile for CCUsageMac

.PHONY: all build clean test release

# Configuration
APP_NAME = CCUsageMac
VERSION = $(shell grep 'let appVersion' CCUsageMac/Sources/App.swift | cut -d'"' -f2)

# Build paths
BUILD_DIR = .build
RELEASE_DIR = release
APP_PATH = $(RELEASE_DIR)/$(APP_NAME).app

all: build

build:
	@echo "Building $(APP_NAME)..."
	cd CCUsageMac && swift build -c release

app: build
	@echo "Creating app bundle..."
	@mkdir -p $(APP_PATH)/Contents/MacOS
	@mkdir -p $(APP_PATH)/Contents/Resources
	
	# Copy binary
	@cp CCUsageMac/$(BUILD_DIR)/release/$(APP_NAME) $(APP_PATH)/Contents/MacOS/
	
	# Create Info.plist
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(APP_PATH)/Contents/Info.plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(APP_PATH)/Contents/Info.plist
	@echo '<plist version="1.0">' >> $(APP_PATH)/Contents/Info.plist
	@echo '<dict>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>CFBundleExecutable</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <string>$(APP_NAME)</string>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <key>CFBundleIdentifier</key>' >> $(APP_PATH)/Contents/Info.plist
	@echo '    <string>com.yajima.ccusage-mac</string>' >> $(APP_PATH)/Contents/Info.plist
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
	@echo "App bundle created at: $(APP_PATH)"

release: app
	@echo "Creating release files..."
	@cd $(RELEASE_DIR) && zip -r "$(APP_NAME)-v$(VERSION).zip" $(APP_NAME).app
	@mkdir -p dmg-temp
	@cp -R $(APP_PATH) dmg-temp/
	@hdiutil create -volname "$(APP_NAME)" -srcfolder dmg-temp -ov -format UDZO "$(RELEASE_DIR)/$(APP_NAME)-v$(VERSION).dmg"
	@rm -rf dmg-temp
	@echo "Release files created:"
	@echo "  - $(RELEASE_DIR)/$(APP_NAME)-v$(VERSION).zip"
	@echo "  - $(RELEASE_DIR)/$(APP_NAME)-v$(VERSION).dmg"

clean:
	@echo "Cleaning build artifacts..."
	cd CCUsageMac && swift package clean
	rm -rf $(BUILD_DIR)
	rm -rf $(RELEASE_DIR)

test:
	@echo "Running tests..."
	cd CCUsageMac && swift test