# Firefox Performant Privacy Edition

A hardened, debloated, and reskinned Firefox configuration — native vertical tabs, dark Zen/Arc-inspired UI, telemetry killed, privacy locked, memory-tuned for 16 GB.

Built from curated arkenfox + Betterfox recommendations, with custom Chrome CSS for a modern look.

---

## Features

| Layer | What's done |
|-------|-------------|
| **Privacy** | All telemetry, studies, crash reporting, Pocket, Translate, AI/ML features blocked. HTTPS-Only enforced. DoH locked to AdGuard DNS. ETP Strict + Global Privacy Control. |
| **Security** | OCSP stapling, TLS 1.2 minimum, certificate pinning enforcement, HTTPS-Only mode, safe negotiation required. |
| **Performance** | Disk cache off (256 MB RAM cache), 8 content processes, 1800 max connections, tab unloading at 13 GB / 20%, 60s session-store interval. |
| **UI** | Zen/Arc-inspired dark theme everywhere. Native vertical tabs (FF136+). Auto-hide navbar. Rounded content frame with 6 px margin. Dark scrollbars. |
| **Degoogled** | No Safe Browsing remote checks, no autofill, no form history, no password manager. |
| **Search** | Brave Search default. Removed Amazon, eBay, Bing, Perplexity, Wikipedia. |
| **Extensions** | 24 curated extensions auto-installed — uBlock Origin (forced), Bitwarden, Dark Reader, Multi-Account Containers, Sidebery, Tridactyl, SponsorBlock, and more. |

---

## Quick Start

```bash
# Deploy to your default Firefox profile (auto-detected)
./deploy.sh

# Preview what would be deployed without copying
./deploy.sh --dry-run

# Target a specific profile
./deploy.sh --profile my-custom-profile
```

Then restart Firefox and:
1. Open `about:config` → Accept the risk
2. Enable vertical tabs: `View → Sidebar → Vertical Tabs`
3. Verify: `about:networking#dns` should show TRR active (AdGuard DNS)

> `deploy.sh` copies all three layers — `user.js`, `chrome/` CSS, and `policies.json` (system-wide, needs `sudo`). See `./deploy.sh --help` for details.

---

## Architecture

This project configures Firefox at three coordinated layers:

```
                ┌──────────────────────────────┐
                │   policies.json               │  ← System-wide, survives profile resets
                │   /usr/lib/firefox/dist/      │     Locked: telemetry, DoH, tracking,
                │                               │     extensions, search, AI, sync
                ├──────────────────────────────┤
                │   user.js                     │  ← Per-profile preferences
                │   ~/.mozilla/firefox/*/       │     ~240 prefs: performance, privacy,
                │                               │     UI, vertical tabs, dark mode, etc.
                ├──────────────────────────────┤
                │   chrome/*.css                │  ← Per-profile UI skinning
                │   ~/.mozilla/firefox/*/chrome  │     Dark Zen theme, auto-hide navbar,
                │                               │     rounded content, sidebar polish
                └──────────────────────────────┘
```

### Layer 1 — Enterprise Policy (`policies.json`)

Hard-locked system-wide settings that survive profile creation/reset:

| Policy | Setting |
|--------|---------|
| Telemetry, Studies, Feedback | Disabled |
| Firefox Accounts / Sync | Fully disabled (`DisableAccounts: true`) |
| Pocket, AI/ML features | Disabled |
| Password manager, Autofill | Disabled |
| DoH (DNS over HTTPS) | **AdGuard DNS** — enabled & locked |
| Tracking Protection | **Strict** — enabled & locked |
| HTTPS-Only Mode | Enabled |
| Firefox Home bloat | Sponsored stories, Top Sites, Highlights — all disabled & locked |
| Search | **Brave Search** default; Amazon, Bing, eBay, Perplexity, Wikipedia removed |
| Extensions | 24 auto-installed (2 force-installed: uBlock Origin, Userchrome Toggle Extended) |

### Layer 2 — User Preferences (`user.js`)

~240 prefs organized into sections — every section documented with inline comments:

| Section | Focus |
|---------|-------|
| Startup | Blank page, no sponsored new-tab, no default-browser check |
| Geolocation | All geo providers disabled |
| Quieter Fox | No addon recommendations, no Normandy/Shield, no captive portal |
| Safe Browsing | Remote download checks disabled; malware/phishing at default |
| Vertical Tabs | `sidebar.revamp=true`, expand-on-hover, launcher debloated |
| Implicit Outbound | Prefetch, DNS prefetch, speculative connect — all off |
| DNS / DoH | TRR mode 3 (always), AdGuard DNS, large DNS cache |
| Location Bar | All quick-suggest gates disabled, history/bookmark suggestions **enabled** |
| Passwords / Forms | Autofill, capture, generation, breach alerts — all off |
| Disk / Memory Cache | Disk cache off, 256 MB RAM cache, 4 back/forward pages |
| Performance | 60s session-store interval, tab unloading at 13 GB / 20%, 8 processes |
| HTTPS / SSL / TLS | OCSP stapling, TLS 1.2 min, pinning level 2, HTTPS-Only |
| Media / WebRTC | Autoplay blocked, **default volume muted**, ICE proxy-only |
| ETP | Strict mode + Global Privacy Control |
| Metrics Shutdown | Every telemetry channel, health report, ping, coverage — disabled |
| Extras / Bloat | Welcome page, CFR, UITour, Firefox View, Sync, Translate, Pocket, AI — killed |
| Dark Mode | Force dark for websites, system dark theme |

### Layer 3 — Chrome CSS (`chrome/`)

Modular Zen/Arc-inspired dark UI. 10 CSS files organized in `chrome/zen-modules/`:

```
chrome/
├── userChrome.css          ← Entry point, imports all modules
├── userContent.css         ← New tab page (solid black)
└── zen-modules/
    ├── _variables.css       ← Color palette, dimensions, timing
    ├── _base.css            ← Window background, bloat hiding, horizontal tab hiding
    ├── _vertical-tabs.css   ← Native vertical tab sidebar: compact/full modes, tab styling
    ├── _navbar-autohide.css ← Navbar slides up, shows on top-edge hover or Ctrl+L
    ├── _sidebar-separator.css  ← Sidebar/bookmarks panel dividers
    ├── _urlbar.css          ← Dark URL bar, focused accent glow, dropdown styling
    ├── _content-frame.css   ← Rounded 6px content margin, black bezel fix
    └── _dark-ui.css         ← Panels, menus, tooltips, scrollbars, find bar
```

**Design highlights:**
- Dark palette `#050505` → `#2a2a2a`, accent `#4a90d9`
- Fast 50 ms transitions (≈5× faster than typical Zen themes)
- Rounded content frame with 6 px margin and 10 px border-radius
- Navbar auto-hides above viewport, triggered by top-edge hover zone or `Ctrl+L`
- Standard sidebar (Bookmarks/History) forced to the **right** side

#### Compact vs Full Mode

| Mode | Sidebar | Navbar | Toggle |
|------|---------|--------|--------|
| **Compact** (default) | 4 px strip, expands to 250 px on hover | Hidden, slides down on top-edge hover | `Ctrl+Alt+Z` or toolbar button |
| **Full** | Always visible at 250 px | Always visible | `Ctrl+Alt+Z` or toolbar button |

The toggle uses the **Userchrome Toggle Extended** extension (auto-installed). Style 1 = Compact, style off = Full.

---

## Customization

### Changing preferences

Edit `user.js` directly — the whole project is version-controlled, so you can track changes with `git diff`.

**Common tweaks:**

```javascript
// Re-enable Safe Browsing (if you're OK with Google)
user_pref("browser.safebrowsing.malware.enabled", true);
user_pref("browser.safebrowsing.phishing.enabled", true);

// Change DNS provider
user_pref("network.trr.uri", "https://cloudflare-dns.com/dns-query");

// Restore bookmarks toolbar
user_pref("browser.bookmarks.showDesktopBookmarks", true);

// Limit RAM further (for 8 GB systems)
user_pref("browser.cache.memory.capacity", 131072);
user_pref("browser.sessionstore.max_tabs_undo", 5);
```

After editing, run `./deploy.sh` to sync and restart Firefox.

### Changing the CSS theme

Edit files in `chrome/zen-modules/`. The modular architecture keeps changes isolated:
- Colors → `_variables.css`
- Tab spacing → `_vertical-tabs.css`
- Navbar behavior → `_navbar-autohide.css`
- Content margin → `_content-frame.css`

After editing, copy to profile or run `./deploy.sh`.

### Returning to defaults

```bash
rm -r ~/.mozilla/firefox/<profile>/user.js
rm -r ~/.mozilla/firefox/<profile>/chrome/
```

Restart Firefox. Default preferences return on next restart. System-wide policies in `/usr/lib/firefox/distribution/policies.json` can be removed with `sudo rm`.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **Site broken by ETP** | Click shield icon in URL bar → Turn off protection for this site |
| **HTTPS-Only not working** | Check `about:config` → `dom.security.https_only_mode` should be `true`. Corporate/ISP proxies may intercept HTTPS. |
| **Vertical tabs not showing** | Need Firefox 136+. Check `about:config` → `sidebar.revamp = true`. Enable via `View → Sidebar → Vertical Tabs`. |
| **DoH not working** | Check `about:networking#dns` → should show "TRR: Active (3)". Policy overrides user prefs — edit `policies.json` to change provider. |
| **Media has no sound** | `media.volume_scale = "0.0"` mutes all HTML5 media by default. Change to `"1.0"` in `user.js`. |

### Test sites

- https://browserleaks.com/ — Canvas, WebGL, Fonts fingerprinting
- https://coveryourtracks.eff.org/ — EFF tracker test
- https://www.dnsleaktest.com/ — Should show AdGuard DNS, not your ISP

---

## Development & Debugging

### Marionette screenshot tool

The `firefox-screenshot/` directory contains a Python tool for capturing the Firefox chrome UI via Marionette:

```bash
cd firefox-screenshot
uv sync
uv run python screenshot_userchrome.py
```

Useful for visually testing `userChrome.css` tweaks without manual screenshotting.

**Prerequisites:** Firefox with Marionette, `uv` for Python, and `toolkit.legacyUserProfileCustomizations.stylesheets = true`.

### Technical notes

- Firefox 150+ removed `nsIStyleSheetService`, so `userChrome.css` **cannot be hot-reloaded**. Edit the file, then restart Firefox (or let the screenshot tool restart it).
- The `<tab>` element in XUL has intrinsic 8 px padding that CSS `padding` cannot override. The project compensates with negative `margin` on the inner `.tab-stack`.

---

## File Layout

```
├── deploy.sh              ← Sync script (auto-detect profile, deploy all layers)
├── user.js                ← ~240 preferences (~400 lines)
├── policies.json          ← Enterprise policy (133 lines)
├── chrome/
│   ├── userChrome.css     ← Main CSS entry point
│   ├── userContent.css    ← New tab page styling
│   └── zen-modules/       ← 8 modular CSS files
├── firefox-screenshot/    ← Marionette-based chrome screenshot tool
└── .gitignore
```

Reference directories (`reference-betterfox/`, `reference-arkenfox/`, `reference-ff-ultima/`) are gitignored — cloned during development for research.

---

## Credits & Sources

- [arkenfox/user.js](https://github.com/arkenfox/user.js) — Comprehensive privacy reference
- [Betterfox](https://github.com/yokoffing/Betterfox) — Practical privacy/performance prefs
- [Mozilla Vertical Tabs (FF136+)](https://bugzilla.mozilla.org/show_bug.cgi?id=1940631) — Native sidebar redesign
- [Mozilla Policy Reference](https://mozilla.github.io/policy-templates/) — Enterprise policy docs
- [Mozilla StaticPrefList](https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml) — Complete preference reference

---

**License:** MIT — Use, modify, share freely.
