# ccusage-mac

A macOS menu bar app that displays your Claude Code usage costs in real-time.

![](./docs/image.png)

## Overview

ccusage-mac is a macOS menu bar application inspired by [ccusage](https://github.com/ryoppippi/ccusage). It reads Claude Code's locally stored usage data and displays today's costs in your menu bar, updating automatically every 5 minutes.

## Features

- 📊 **Real-time Cost Display**: Shows today's usage cost in the menu bar
- 🔄 **Auto-refresh**: Updates every 5 minutes automatically
- 📈 **Detailed Breakdown**: Click to see token usage details
- 🧠 **Model Tracking**: See which Claude models you've used (Opus, Sonnet, etc.)
- 🔒 **No API Key Required**: Uses Claude Code's existing local data

## Installation

### Requirements

- macOS 13.0 (Ventura) or later
- Claude Code must be installed and have usage data

### Download from GitHub Releases (Recommended)

1. Go to [Releases](https://github.com/ssss-yajima/ccusage-mac/releases)
2. Download the latest `.dmg` or `.zip` file
3. Open the downloaded file:
   - **DMG**: Double-click and drag CCUsageMac to Applications
   - **ZIP**: Double-click to unzip, then move CCUsageMac to Applications
4. Launch CCUsageMac from Applications folder

**Note**: On first launch, macOS will show a security warning. Go to System Settings > Privacy & Security and click "Open Anyway".

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/ssss-yajima/ccusage-mac.git
cd ccusage-mac
```

2. Build and create app:
```bash
./scripts/build-local.sh
```

3. Run the application:
```bash
open release/CCUsageMac.app
```

### Auto-start at Login

To launch CCUsageMac automatically when you log in:
1. Open System Settings > General > Login Items
2. Click the + button and add CCUsageMac

## Usage

1. Launch the app - you'll see a brain icon (🧠) with today's cost in your menu bar
2. Click the icon to view detailed information:
   - Total cost for today
   - Token usage breakdown (Input/Output/Cache)
   - Models used
   - Last update time
3. The app updates automatically every 5 minutes
4. Click "Quit" in the popover to exit

## How It Works

CCUsageMac reads the JSONL files that Claude Code automatically generates in `~/.claude/projects/`. It calculates costs using the same pricing as Claude's API:

- **Opus 4**: $15/MTok input, $75/MTok output
- **Sonnet 4**: $3/MTok input, $15/MTok output
- **Haiku 3.5**: $0.80/MTok input, $4/MTok output

The app uses the same date filtering logic as ccusage to ensure consistency.

## Development

### Project Structure

```
ccusage-mac/
├── CCUsageMac/              # Swift package
│   ├── Sources/
│   │   ├── App.swift        # Main application
│   │   ├── MenuBarView.swift # Menu bar UI
│   │   ├── ContentView.swift # Popover content
│   │   └── ...
│   └── Package.swift
├── docs/                    # Documentation
└── README.md
```

### Building for Development

```bash
swift build
swift run
```

### Running Tests

```bash
swift test
```

## Known Limitations

- Shows only today's usage (daily/monthly views coming soon)
- Cost calculation may differ slightly from ccusage due to timing differences
- Requires Claude Code to be installed with existing usage data

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

MIT License - see [LICENSE](LICENSE) file for details

## Acknowledgments

- [ccusage](https://github.com/ryoppippi/ccusage) - The original CLI tool that inspired this project
- [Anthropic](https://www.anthropic.com) for Claude and Claude Code

## Related Projects

- [ccusage](https://github.com/ryoppippi/ccusage) - CLI version with more features
- [Claude Code](https://claude.ai/code) - The AI coding assistant

