#!/bin/bash

# Setup labels for automated release workflow
# Usage: bash .github/setup-labels.sh

echo "Setting up GitHub labels for automated release workflow..."

# Release type labels
gh label create "release:major" --description "Major version bump (breaking changes)" --color "b60205" 2>/dev/null || echo "Label 'release:major' already exists"
gh label create "release:minor" --description "Minor version bump (new features)" --color "0e8a16" 2>/dev/null || echo "Label 'release:minor' already exists"
gh label create "release:patch" --description "Patch version bump (bug fixes)" --color "fbca04" 2>/dev/null || echo "Label 'release:patch' already exists"
gh label create "release:skip" --description "Skip automatic release" --color "eeeeee" 2>/dev/null || echo "Label 'release:skip' already exists"

# PR categorization labels
gh label create "breaking-change" --description "Breaking change" --color "d73a4a" 2>/dev/null || echo "Label 'breaking-change' already exists"
gh label create "feature" --description "New feature" --color "a2eeef" 2>/dev/null || echo "Label 'feature' already exists"
gh label create "enhancement" --description "Enhancement to existing feature" --color "84b6eb" 2>/dev/null || echo "Label 'enhancement' already exists"
gh label create "bug" --description "Bug fix" --color "d73a4a" 2>/dev/null || echo "Label 'bug' already exists"
gh label create "fix" --description "General fix" --color "d4c5f9" 2>/dev/null || echo "Label 'fix' already exists"
gh label create "documentation" --description "Documentation changes" --color "0075ca" 2>/dev/null || echo "Label 'documentation' already exists"
gh label create "ci" --description "CI/CD changes" --color "555555" 2>/dev/null || echo "Label 'ci' already exists"

echo "✅ Label setup complete!"
echo ""
echo "Usage:"
echo "1. When creating a PR, add one of these labels:"
echo "   - release:major - For breaking changes (1.0.0 → 2.0.0)"
echo "   - release:minor - For new features (1.0.0 → 1.1.0)"
echo "   - release:patch - For bug fixes (1.0.0 → 1.0.1)"
echo "   - release:skip - To skip automatic release"
echo ""
echo "2. Additionally, categorize your PR with:"
echo "   - breaking-change - For breaking changes"
echo "   - feature/enhancement - For new features or improvements"
echo "   - bug/fix - For bug fixes"
echo "   - documentation - For docs changes"
echo "   - ci - For CI/CD changes"