# Homebrew Distribution Guide

This guide explains how to distribute CCUsageMac through Homebrew Cask.

## Prerequisites

1. **Apple Developer Account** (required for code signing and notarization)
   - Enroll at https://developer.apple.com
   - Annual fee: $99 USD

2. **Developer ID Certificate**
   - Create in Apple Developer portal
   - Install in Keychain Access

3. **GitHub Repository**
   - Public repository with releases

## Setup Process

### 1. Configure Developer ID

Update the `Makefile` with your Developer ID:

```makefile
DEVELOPER_ID = "Developer ID Application: Your Name (TEAM_ID)"
```

Find your Developer ID:
```bash
security find-identity -v -p codesigning
```

### 2. Create App-Specific Password

1. Go to https://appleid.apple.com
2. Sign in and go to "Sign-In and Security"
3. Create an app-specific password for notarization
4. Save it securely

### 3. Build and Sign Locally

```bash
# Test build without signing
./scripts/build-local.sh

# Build with signing (requires Developer ID)
make app
make sign
```

### 4. Create DMG and Notarize

```bash
# Set environment variables
export APPLE_ID="your-apple-id@example.com"
export TEAM_ID="YOUR_TEAM_ID"
export NOTARIZATION_PASSWORD="your-app-specific-password"

# Create notarized DMG
make release
```

### 5. Create GitHub Release

1. Tag your release:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. Create release on GitHub:
   - Go to Releases → New release
   - Choose the tag
   - Upload the DMG file
   - Add release notes

### 6. Update Homebrew Formula

1. Get the SHA256 of your DMG:
   ```bash
   shasum -a 256 release/CCUsageMac-1.0.0.dmg
   ```

2. Update `homebrew/ccusage-mac.rb`:
   - Replace `PLACEHOLDER_SHA256` with actual SHA256
   - Update version if needed

### 7. Submit to Homebrew Cask

1. Fork the Homebrew Cask repository:
   ```bash
   git clone https://github.com/Homebrew/homebrew-cask.git
   cd homebrew-cask
   ```

2. Create a new branch:
   ```bash
   git checkout -b add-ccusage-mac
   ```

3. Copy your formula:
   ```bash
   cp /path/to/ccusage-mac/homebrew/ccusage-mac.rb Casks/
   ```

4. Test locally:
   ```bash
   brew install --cask ./Casks/ccusage-mac.rb
   ```

5. Commit and push:
   ```bash
   git add Casks/ccusage-mac.rb
   git commit -m "Add ccusage-mac"
   git push origin add-ccusage-mac
   ```

6. Create pull request on GitHub

## GitHub Actions (Optional)

For automated releases, set up GitHub Secrets:

1. **BUILD_CERTIFICATE_BASE64**:
   ```bash
   base64 -i certificate.p12
   ```

2. **P12_PASSWORD**: Password for the certificate

3. **KEYCHAIN_PASSWORD**: Any secure password

4. **DEVELOPER_ID**: Your Developer ID string

5. **APPLE_ID**: Your Apple ID email

6. **TEAM_ID**: Your Apple Developer Team ID

7. **NOTARIZATION_PASSWORD**: App-specific password

## Troubleshooting

### Code Signing Issues

- Ensure certificate is in login keychain
- Check certificate hasn't expired
- Verify Developer ID matches exactly

### Notarization Failures

- Check entitlements file is correct
- Ensure all frameworks are signed
- Review Apple's notarization log

### Homebrew Submission

- Run `brew audit --cask ccusage-mac`
- Fix any style issues
- Ensure description is clear and concise

## Maintenance

### Updating Versions

1. Update version in `CCUsageMac/Sources/App.swift`
2. Create new release
3. Update Homebrew formula
4. Submit PR to Homebrew

### Security Updates

- Keep certificates current
- Renew Developer ID before expiration
- Update notarization process as Apple requires