# Firefox userChrome Screenshot Tool

Programmatically capture screenshots of the Firefox browser UI (chrome) via Marionette. Useful for testing and iterating on `userChrome.css` tweaks.

## Prerequisites

- Modern Firefox (tested on 150+)
- `uv` for Python environment management
- `toolkit.legacyUserProfileCustomizations.stylesheets = true` in your Firefox profile

## Setup

```bash
cd firefox-screenshot
uv sync
```

## Usage

```bash
uv run python firefox-screenshot/screenshot_userchrome.py
```

This will:
1. Launch Firefox with Marionette + remote system access enabled
2. Switch to chrome context (accessing the browser UI, not web content)
3. Capture a full screenshot of the Firefox chrome window
4. Save it to `firefox-screenshot/userchrome_screenshot.png`
5. Terminate Firefox

## Key Technical Notes

- **Marionette port:** 2828 (default)
- **Chrome context:** Required to screenshot the browser UI instead of web content
- **`--remote-allow-system-access`:** Modern Firefox requires this flag alongside `--marionette` for chrome context access
- **Hot-reloading `userChrome.css`:** Not possible in Firefox 150+ (`nsIStyleSheetService` was removed). For testing CSS changes, edit the file and let the script restart Firefox automatically.

## Files

| File | Purpose |
|------|---------|
| `firefox-screenshot/screenshot_userchrome.py` | Main automation script |
| `firefox-screenshot/userchrome_screenshot.png` | Output screenshot (generated) |
