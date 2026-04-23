# Firefox Performant Privacy Edition — Complete Setup Guide

## What You Get

A lean, mean Firefox with:
- **~170 prefs** (no bloat, no breakage)
- All telemetry killed
- All AI features blocked
- All sync/passwords/translate/Pocket removed
- HTTPS-Only enforced
- **Native vertical tabs** (Firefox 136+) with clean modern sidebar
- Memory-tuned for **16 GB RAM**
- Network & cache optimized for speed

---

## Quick Start

1. **Restart Firefox** (already running from earlier)
2. Open `about:config` → Accept the risk
3. Open `about:preferences#privacy` → Click **Enable** on ETP Strict
4. Look for 🔒 HTTPS-Only badge in address bar
5. Enable native vertical tabs: `View → Sidebar → Vertical Tabs`

---

## Native Vertical Tabs & Modern Sidebar (FF136+)

This config enables the **native** vertical tabs feature — no extensions needed.

### Enabling
1. Go to `View → Sidebar → Vertical Tabs` (or right-click the tab bar)
2. The sidebar launches on the left with tabs stacked vertically
3. Use `View → Sidebar` to toggle Bookmarks / History panels in the same sidebar

### What's pre-configured
- `sidebar.revamp` = true (enables the modern sidebar)
- `sidebar.main.tools` = history, bookmarks only (no AI Chat, no Synced Tabs bloat)
- `sidebar.visibility` = always-show (sidebar stays open)
- `sidebar.revamp.defaultLauncherVisible` = false (cleaner launcher)
- Sidebar animations disabled
- Width set to 280 px

### Switching back
If you ever want horizontal tabs back:
- `View → Sidebar → Vertical Tabs` to toggle off
- Or add to `user-overrides.js`:
  ```javascript
  user_pref("sidebar.revamp", false);
  ```

---

## Customization

### Change DoH Provider (DNS over HTTPS)

Edit `user-overrides.js`:

```javascript
// Cloudflare
user_pref("network.trr.uri", "https://1.1.1.1/dns-query");

// Or Quad9
user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");
```

Restart Firefox.

### Re-enable Safe Browsing (Malware/Phishing)

Add to `user-overrides.js`:
```javascript
user_pref("browser.safebrowsing.malware.enabled", true);
user_pref("browser.safebrowsing.phishing.enabled", true);
```

### Restore Bookmarks Toolbar

```javascript
user_pref("browser.bookmarks.showDesktopBookmarks", true);
```

### Adjust Sidebar Width

```javascript
user_pref("browser.sidebar.width", 320);  // wider
```

### Limit RAM Further (if needed)

Defaults are already tuned for 16 GB. To reduce:
```javascript
user_pref("browser.cache.memory.capacity", 131072);  // 128 MB (default auto ~32 MB)
user_pref("browser.sessionstore.max_tabs_undo", 0);  // no closed-tab history
user_pref("browser.sessionhistory.max_total_viewers", 2);  // less back/forward cache
```

---

## Verify Installation

### Check that bloat is truly gone:
- No sync icon (shouldn't see Firefox account avatar in top-right)
- No translate button (shouldn't see translation popups)
- No password manager prompts
- No Pocket saves
- No AI Chat in sidebar

### Run these test sites:
- https://browserleaks.com/ → check Canvas, WebGL, Fonts
- https://coveryourtracks.eff.org/ → should show "Your browser is well-protected"
- https://www.dnsleaktest.com/ → should show DoH provider, not your ISP

---

## File Layout

| File | Purpose |
|------|---------|
| `user.js` | Main config (~170 prefs) |
| `user-overrides.js` | Your personal tweaks (never overwritten) |
| `chrome/userChrome.css` | Modern dark UI + sidebar polish |
| `reference-betterfox/` | Cloned Betterfox repo (reference) |
| `reference-arkenfox/` | Cloned arkenfox repo (reference) |
| `reference-mozilla-all.js.tmp` | Mozilla all.js preview (reference) |
| `reference-mozilla-StaticPrefList.yaml` | Mozilla pref list preview (reference) |

**Profile path:**
`~/.mozilla/firefox/<profile>/`

---

## Troubleshooting

### Site broken by ETP (Enhanced Tracking Protection)
1. Click the shield icon in address bar
2. Click "Turn off protection for this site" (temporary)
3. OR create a permanent exception in `user-overrides.js` (rarely needed)

### HTTPS-Only not working?
Check `about:config`:
- `dom.security.https_only_mode` should be `true`
- Some corporate/ISP proxies intercept HTTPS — you may need to disable

### Want to undo everything?
```bash
# Remove custom files
rm ~/.mozilla/firefox/<profile>/user.js
rm ~/.mozilla/firefox/<profile>/user-overrides.js
rm -r ~/.mozilla/firefox/<profile>/chrome/
```

Then restart Firefox. Default prefs will return on next restart.

### Vertical tabs not showing?
- Make sure you're on **Firefox 136+** (`Help → About Firefox`)
- Check `about:config` → `sidebar.revamp` should be `true`
- Use the menu: `View → Sidebar → Vertical Tabs`

---

## Credits & Sources

- **arkenfox** — https://github.com/arkenfox/user.js (privacy reference)
- **Betterfox** — https://github.com/yokoffing/Betterfox (practical core + performance)
- **Mozilla Vertical Tabs** — https://bugzilla.mozilla.org/show_bug.cgi?id=1940631
- **Mozilla StaticPrefList** — https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
- **Mozilla all.js** — https://hg.mozilla.org/mozilla-central/raw-file/tip/modules/libpref/init/all.js

---

**License:** MIT — Use, modify, share freely.
