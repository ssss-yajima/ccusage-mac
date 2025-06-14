# ccusage-mac

<div align="center">
  <img src="./docs/app-icon.png" width="128" height="128" alt="CCUsageMac Icon">
</div>

A macOS menu bar app that displays your Claude Code usage costs in real-time.

![](./docs/image.png)

English | [日本語](./docs/README-ja.md)

## Overview

ccusage-mac is a macOS menu bar application inspired by [ccusage](https://github.com/ryoppippi/ccusage). It reads Claude Code's locally stored usage data and displays your costs in the menu bar, updating automatically every 5 minutes.

## Features

- 📊 **Real-time Cost Display**: Shows today's usage cost in the menu bar
- 📅 **Weekly View**: See the last 7 days of usage in a table format
- 🔄 **Auto-refresh**: Updates every 5 minutes automatically
- 📈 **Detailed Breakdown**: View token usage details
- 🧠 **Model Tracking**: See which Claude models you've used (Opus, Sonnet, etc.)
- 🔒 **Privacy First**: No network access, no external servers

## Privacy & Security

**This app works completely offline:**
- No network requests are made
- No API keys required
- Simply reads JSONL files from `~/.claude/projects/`
- Your usage data never leaves your computer

## How It Works

The app calculates costs by:

1. **Reading local data**: Scans `~/.claude/projects/*/api_conversations/*.jsonl` files that Claude Code automatically generates
2. **Calculating costs**: Uses Anthropic's official pricing:
   - **Opus 4**: $15/MTok input, $75/MTok output
   - **Sonnet 4**: $3/MTok input, $15/MTok output
   - **Haiku 3.5**: $0.80/MTok input, $4/MTok output
3. **Deduplication**: Uses messageId:requestId hash to avoid counting duplicates
4. **Date filtering**: Matches dates using local timezone

## Installation

### Requirements

- macOS 13.0 (Ventura) or later
- Claude Code must be installed and have usage data

### Download from GitHub Releases (Recommended)

1. Go to [Releases](https://github.com/ssss-yajima/ccusage-mac/releases)
2. Download the latest `.dmg` file
3. Double-click the DMG and drag CCUsageMac to Applications
4. Launch CCUsageMac from Applications folder

**Important Security Note**: 
- On first launch, macOS may show a security warning since the app is not notarized
- Right-click (or Control-click) on the app and select "Open" from the context menu
- Click "Open" in the dialog that appears
- Alternatively, go to System Settings > Privacy & Security and click "Open Anyway"
- You only need to do this once on first launch


### Auto-start at Login

To launch CCUsageMac automatically when you log in:
1. Open System Settings > General > Login Items
2. Click the + button and add CCUsageMac

## Usage

1. Launch the app - you'll see a brain icon (🧠) with today's cost in your menu bar
2. Click the icon to view the last 7 days of usage:
   - Daily costs in a table format
   - Token usage breakdown (Input/Output/Cache)
   - Models used
   - Last update time
3. Click "Refresh" to manually update
4. Click "Quit" to exit the app


## Known Limitations

- Cost calculation may differ slightly from ccusage due to timing differences
- Requires Claude Code to be installed with existing usage data

## License

MIT License - see [LICENSE](LICENSE) file for details

## Acknowledgments

- [ccusage](https://github.com/ryoppippi/ccusage) - The original CLI tool that inspired this project
- [Anthropic](https://www.anthropic.com) for Claude and Claude Code

## Related Projects

- [ccusage](https://github.com/ryoppippi/ccusage) - CLI version with more features
- [Claude Code](https://claude.ai/code) - The AI coding assistant

