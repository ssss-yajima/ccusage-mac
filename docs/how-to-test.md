# CCUsageMac Testing Guide

## 1. Starting the Application

### Launch from Command Line
```bash
cd CCUsageMac
.build/release/CCUsageMac
```

### Launch from Finder (Recommended)
1. Open `CCUsageMac/.build/release/` in Finder
2. Double-click `CCUsageMac`
3. On first launch, you may see "Cannot be opened because the developer cannot be verified"
   - Go to System Settings > Privacy & Security > Security
   - Click "Open Anyway" next to ""CCUsageMac" was blocked from use because it is not from an identified developer"

## 2. Verification Points

### Menu Bar Check
1. Verify that a brain icon (🧠) and cost amount appear in the menu bar at the top of the screen
2. Initial launch may show "$0.00" or "$--"

### Claude Code Data Verification
The app requires Claude Code usage history to function properly:

```bash
# Check Claude Code data directory
ls -la ~/.claude/projects/
```

If no data exists, use Claude Code first, then check again.

### Detail View Verification
1. Click the menu bar icon
2. Verify that a popover window appears
3. The following information should be displayed:
   - Total Cost (today's total usage cost)
   - Token Usage (breakdown of token usage)
   - Models Used (models utilized)
   - Last updated time

### Refresh Functionality
1. Click the refresh button (🔄) in the top right of the popover
2. Verify that data is reloaded
3. Auto-refresh occurs every 5 minutes

## 3. Troubleshooting

### When Cost Differs from ccusage
- CCUsageMac aggregates "today's" data in local timezone (e.g., Japan time)
- JSONL file timestamps are in UTC format, which may cause slight differences at date boundaries
- For more accurate daily aggregation, consider using the ccusage command-line tool

### When "$--" is Displayed
- An error has occurred. Open the popover to check the error details
- Common causes:
  - Claude Code is not installed
  - `~/.claude/projects/` directory doesn't exist
  - No data for today yet

### When App Won't Launch
```bash
# Run directly to check for errors
./CCUsageMac/.build/release/CCUsageMac
```

### When Data Doesn't Update
1. Do some work in Claude Code
2. Click the manual refresh button
3. If still not updating, restart the app

### How to Quit the App
1. Open the popover
2. Click the "Quit" button in the bottom right

## 4. Checking Logs

If problems occur, check logs in Console app:

1. Open Applications > Utilities > Console.app
2. Select your Mac from the left sidebar
3. Enter "CCUsageMac" in the search field
4. Review error messages

## 5. Uninstalling

To remove the app:
```bash
# Terminate the process
pkill CCUsageMac

# Remove files (for built binary only)
rm CCUsageMac/.build/release/CCUsageMac
```