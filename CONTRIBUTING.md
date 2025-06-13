# Contributing to ccusage-mac

Thank you for your interest in contributing to ccusage-mac! This guide will help you get started.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/ccusage-mac.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Commit your changes: `git commit -m "Add your descriptive commit message"`
6. Push to your fork: `git push origin feature/your-feature-name`
7. Create a Pull Request

## Development Setup

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15+ or Swift 5.9+
- Claude Code installed (for testing with real data)

### Building

```bash
cd CCUsageMac
swift build
```

### Testing

```bash
swift test
```

### Running

```bash
swift run
# or
.build/debug/CCUsageMac
```

## Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI for UI components
- Keep functions focused and single-purpose
- Add comments for complex logic
- Maintain existing code formatting

## Pull Request Guidelines

1. **One feature per PR**: Keep pull requests focused on a single feature or fix
2. **Update documentation**: If your change affects usage, update the README
3. **Add tests**: Include tests for new functionality
4. **Test thoroughly**: Ensure your changes work with real Claude Code data
5. **Follow existing patterns**: Match the coding style and patterns in the codebase

## Reporting Issues

When reporting issues, please include:

1. macOS version
2. Steps to reproduce the issue
3. Expected behavior
4. Actual behavior
5. Any error messages or logs
6. Screenshots if applicable

## Feature Requests

Feature requests are welcome! Please:

1. Check if the feature has already been requested
2. Provide a clear use case
3. Describe the expected behavior
4. Consider how it fits with the existing functionality

## Areas for Contribution

Here are some areas where contributions are particularly welcome:

- **UI/UX improvements**: Better visualizations, animations, or layouts
- **Performance optimization**: Faster JSONL parsing or data aggregation
- **New features**: Weekly/monthly views, export functionality, etc.
- **Bug fixes**: Check the issues list for known bugs
- **Documentation**: Improve clarity or add examples
- **Tests**: Increase test coverage

## Questions?

If you have questions about contributing, feel free to:

1. Open an issue with the "question" label
2. Check existing issues and pull requests
3. Review the documentation in the `docs/` folder

Thank you for contributing to make ccusage-mac better!