# Project Analysis & Current State — Firefox Performant Privacy Edition

Date: 2026-04-24
Firefox: 150.0
Profile: `qnyf9tcf.default-release`
OS: Arch Linux (16 GB RAM target)

---

## 1. What This Project Does

This project hardens, debloats, and reskins Firefox using **three coordinated layers**:

| Layer | File(s) | Scope | Purpose |
|-------|---------|-------|---------|
| **Enterprise Policy** | `policies.json` → `/usr/lib/firefox/distribution/` | System-wide, locked | Hard locks for telemetry, AI, sync, search engines, DoH, extensions. Survives profile resets. |
| **User Preferences** | `user.js` → profile root | Per-profile | ~240 prefs covering performance, privacy, native vertical tabs, dark mode, URL bar, downloads, containers, etc. |
| **Chrome CSS** | `chrome/userChrome.css` + `zen-modules/` | Per-profile | Zen/Arc-inspired dark UI. Native vertical tabs, auto-hide navbar, rounded content frame, dark menus. |

All three layers are **fully deployed and synchronized** between the project directory and the active Firefox profile.

---

## 2. policies.json Analysis

**Location:** `/usr/lib/firefox/distribution/policies.json` (identical to project copy)

### Disabled / Locked
- Telemetry, Firefox Studies, Feedback commands
- Firefox Accounts / Sync (`DisableFirefoxAccounts: true`)
- Pocket (`DisablePocket: true`)
- Generative AI, AI Controls, AI Chatbot
- Password manager, form history, autofill (address & credit card)
- Master password creation, profile import/refresh
- Default-browser check, Firefox Screenshots
- Firefox Home bloat (sponsored stories, top sites, highlights, snippets) — **Locked**
- Tracking Protection — **Strict & Locked**
- HTTPS-Only Mode — **enabled**
- Network Prediction — **disabled**

### Sanitize on Shutdown
- Cache, Downloads, FormData, OfflineApps → **cleared**
- Cookies, History, Sessions, SiteSettings → **preserved**

### DNS-over-HTTPS
- **Enabled & Locked** to AdGuard DNS (`https://dns.adguard-dns.com/dns-query`)
- Because it is `Locked: true`, this **overrides** any per-profile DoH pref.

### Search Engines
- **Default:** Brave Search
- **PreventInstalls:** true
- **Removed:** Amazon.com, eBay, Bing, Perplexity, Wikipedia (en)
- **Added:** Brave Search (with inline base64 icon)

### Extensions (Auto-install)
24 extensions scheduled for install on startup, including:
uBlock Origin, Bitwarden, Dark Reader, Multi-Account Containers, Sidebery, Tridactyl (Vim), Violentmonkey, Stylus, SponsorBlock, Gesturefy, Page Assist, ZeroOmega, Raindrop.io, Obsidian Web Clipper, SnapLinksPlus, ScrollAnywhere, FoxyTab, FoxyLink, Floccus, Inoreader RSS, ContextSearch Web-Ext, TWP Translate, View Page Archive, **Userchrome Toggle Extended**.

Two are `force_installed` via `ExtensionSettings`:
- `userchrome-toggle-extended@n2ezr.ru`
- `uBlock0@raymondhill.net`

---

## 3. user.js Analysis

### Major Sections

| Section | Prefs | Focus |
|---------|-------|-------|
| Startup | 8 | Blank startup, no sponsored new-tab, no default-browser check |
| Geolocation | 3 | All geo providers disabled |
| Quieter Fox | 13 | No addon recommendations, no Normandy/Shield, no crash reporting, no captive portal |
| Safe Browsing | 2 | Remote download checks disabled; malware/phishing left at default |
| Native Vertical Tabs & Sidebar (FF136+) | 12 | `sidebar.revamp=true`, visibility=`expand-on-hover`, launcher debloated, animations off |
| Block Implicit Outbound | 5 | Prefetch, DNS prefetch, speculative connect all disabled |
| DNS / DoH | 5 | TRR mode 3 (always), NextDNS URI, large DNS cache |
| Location Bar / Search | 22 | ALL quick-suggest gates disabled, search suggestions off, maxRichResults=0 |
| Passwords / Forms | 12 | Autofill, capture, history, generation, breach alerts, sync → all disabled |
| Disk / Memory Cache | 7 | Disk cache off, 64 MB media cache, 256 MB RAM cache, 4 back/forward pages, 10 undo tabs |
| Performance | 11 | 60s session-store interval, tab unloading at 13 GB / 20%, 8 processes, 1800 max connections |
| HTTPS / SSL / TLS | 12 | OCSP stapling on / checking off, TLS 1.2 min, pinning level 2, HTTPS-Only, no background HTTP |
| Downloads | 5 | Inline PDF, no scripting, always ask for location & file type |
| Extensions | 2 | Scope=5, no third-party post-download prompt |
| DOM / Misc | 12 | Window resize blocked, punycode on, content-analysis off, CSP reporting off |
| Referers | 6 | Cross-origin strict, trimming policy 2 |
| Containers | 3 | User contexts enabled, OCSP cache partitioned |
| Permissions | 4 | Camera, mic, notifications, geo → default DENY |
| UI Behavior | 7 | No fullscreen animation, compact mode shown, legacy stylesheets on, dark scheme override |
| Media / WebRTC | 5 | ICE proxy-only, autoplay blocked, **default volume muted** (`media.volume_scale="0.0"`) |
| ETP | 2 | Strict mode, Global Privacy Control |
| Metrics Shutdown | 17 | Every telemetry channel, health report, archive, ping, coverage, DAP → disabled |
| Extras / Bloat | 33 | Welcome page, CFR, Mozilla promo, UITour, Firefox View, Sync engines, Translate, Pocket, AI/ML |
| Dark Mode | 3 | Force dark for websites (`content-override=0`), dark private windows off, system dark theme on |

---

## 4. Chrome / userChrome.css Analysis

**Architecture:**
```
chrome/
├── userChrome.css
└── zen-modules/
    ├── _variables.css
    ├── _base.css
    ├── _vertical-tabs.css
    ├── _navbar-autohide.css
    ├── _sidebar-separator.css
    ├── _urlbar.css
    ├── _content-frame.css
    └── _dark-ui.css
```

### Design
- Dark palette (`#050505` → `#2a2a2a`)
- Accent: `#4a90d9`
- Fast transitions: **50 ms** (≈5× faster than typical Zen themes)
- Rounded content frame with 6 px margin
- Thin scrollbars

### Compact vs Full Mode
Uses **Approach D** (native sidebar expand/collapse + forced thin strip):
- **Compact** (`sidebar-main:not([expanded])`): sidebar squeezed to 4 px, expands to 250 px on hover; navbar hidden above viewport, slides down on top-edge hover or `Ctrl+L`.
- **Full** (`sidebar-main[expanded]`): both tabbar and navbar always visible.
- Toggle: `Ctrl+Alt+Z` or sidebar toolbar button.

### Key CSS Techniques
- `top` positioning (not `transform: translateY`) for navbar hide, preserving hover zones and focus events.
- `:has()` selectors to link navbar visibility to URL-bar focus and open popups.
- Invisible `::after` pseudo-element at viewport top edge to trigger navbar hover.
- Standard sidebar (`#sidebar-box`) forced to **right** via absolute positioning, qualified with `[checked="true"]` to avoid click-blocking when closed.
- `@media -moz-pref("sidebar.verticalTabs")` guards horizontal tab-bar hiding.

---

## 5. Notable Findings & Observations

### A. Duplicate Preference
```javascript
// Line 269
user_pref("layout.css.prefers-color-scheme.content-override", 2);
// Line 371
user_pref("layout.css.prefers-color-scheme.content-override", 0);
```
The second (`0` = force dark) wins because it appears later. The first line should be removed to avoid confusion.

### B. DNS-over-HTTPS Conflict
- `user.js` sets `network.trr.uri` to **NextDNS**.
- `policies.json` locks DoH to **AdGuard DNS**.

Because the policy is `"Locked": true`, the AdGuard setting is enforced and the NextDNS pref in `user.js` has no effect.

### C. `DisableAccounts` Inconsistency in policies.json
```json
"DisableFirefoxAccounts": true,
"DisableAccounts": false
```
The newer `DisableAccounts` policy is left `false`, which means Mozilla Accounts UI is not fully hard-locked at the policy level (though `user.js` disables it via `identity.fxaccounts.enabled = false`).

### D. Misleading `user-overrides.js` Documentation
Both `user.js` comments and `SETUP.md` tell users to create `user-overrides.js` for custom tweaks. **Firefox does not read this file.** The arkenfox `updater.sh` script is required to merge it, but this project does not ship that script. This documentation is misleading for users who expect it to work out-of-the-box.

### E. Fragile Compact Mode (4 px Sidebar Strip)
The project squeezes the native sidebar to **4 px** in compact mode. This is documented in the skill as **experimental/fragile** because:
- Firefox 150's Lit-based `<sidebar-main>` component may fight forced width overrides via its resize observer.
- The native collapse/expand button can be clipped at 4 px, making the user rely entirely on `Ctrl+Alt-Z` to toggle modes.

### F. Aggressive Defaults Worth Noting
- `media.volume_scale = "0.0"` → All HTML5 media starts **muted**.
- `browser.urlbar.maxRichResults = 0` → URL bar dropdown is **completely empty** (no history, bookmarks, or search suggestions).
- `browser.download.useDownloadDir = false` → Always prompts for download location.
- `signon.rememberSignons = false` + policy lock → Password manager is fully inert.

### G. Potentially Dead-Weight Horizontal-Tab Prefs
These prefs apply to the horizontal tab bar, which is automatically hidden when native vertical tabs are on:
- `browser.tabs.tabMinWidth`
- `browser.tabs.tabMaxWidth`
- `browser.tabs.tabClipWidth`
- `browser.ctrlTab.previews`

They have no effect in vertical-tabs mode and could be removed for cleanliness.

### H. Profile Lock & Development History
- Profile lock file exists: `lock → 192.168.2.149:+234774` (Firefox is running or crashed uncleanly).
- Four `chrome.bak.*` directories exist, indicating active iterative development on the CSS.

---

## 6. Synchronisation Status

| Artifact | Project Dir | Deployed Location | Match? |
|----------|-------------|-------------------|--------|
| `user.js` | `/home/alex/projects/hermes-sandbox/user.js` | `~/.mozilla/firefox/qnyf9tcf.default-release/user.js` | **Yes** |
| `chrome/` | `/home/alex/projects/hermes-sandbox/chrome/` | `~/.mozilla/firefox/qnyf9tcf.default-release/chrome/` | **Yes** |
| `policies.json` | `/home/alex/projects/hermes-sandbox/policies.json` | `/usr/lib/firefox/distribution/policies.json` | **Yes** |

---

## 7. References Used

- **arkenfox** — https://github.com/arkenfox/user.js
- **Betterfox** — https://github.com/yokoffing/Betterfox
- **Mozilla Policy Reference** — https://firefox-admin-docs.mozilla.org/reference/policies/
- **Mozilla StaticPrefList** — https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
- **Vertical Tabs Bug** — https://bugzilla.mozilla.org/show_bug.cgi?id=1940631
