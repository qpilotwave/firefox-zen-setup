# Reference Material

This directory contains cloned/copied reference files for Firefox configuration research.

## Cloned Repositories

### reference-betterfox/
**Source:** https://github.com/yokoffing/Betterfox  
**Commit:** latest (shallow clone)  
**Purpose:** Practical privacy/performance prefs without breakage.

Key files examined:
- `user.js` — Core 104 prefs
- `Fastfox.js` — Speed/network tuning
- `Peskyfox.js` — UI bloat removal
- `Securefox.js` — Security hardening

### reference-arkenfox/
**Source:** https://github.com/arkenfox/user.js  
**Commit:** latest (shallow clone)  
**Purpose:** Comprehensive privacy reference (1265 prefs).

Key sections used:
- 0100–0900 — Startup, geo, telemetry, search, passwords
- 1000 — Disk avoidance
- 1200 — HTTPS/SSL/TLS
- 1600 — Referers
- 1700 — Containers
- 2600 — Miscellaneous hardening
- 2700 — ETP Strict
- 2800 — Sanitizing
- 8500 — Telemetry shutdown

## Mozilla Official Documentation

### StaticPrefList.yaml
**Source:** https://hg.mozilla.org/mozilla-central/raw-file/tip/modules/libpref/init/StaticPrefList.yaml  
**Purpose:** Complete list of all Firefox preferences with types, defaults, and descriptions.

### all.js
**Source:** https://hg.mozilla.org/mozilla-central/raw-file/tip/modules/libpref/init/all.js  
**Purpose:** Default preference values shipped with Firefox.

## Key Discoveries

### Native Vertical Tabs (FF136+)
Firefox 136 introduced native vertical tabs via the sidebar revamp.

Key prefs:
- `sidebar.revamp` — enables modern sidebar infrastructure
- `sidebar.visibility` — `always-show`, `expand-on-hover`, or `hide-sidebar`
- `sidebar.main.tools` — controls which tools appear in sidebar launcher
- `sidebar.revamp.defaultLauncherVisible` — show/hide launcher by default

### Memory Tuning for 16 GB
Based on Betterfox Fastfox.js recommendations:
- `browser.low_commit_space_threshold_mb` = 13107 (16 GB * 4/5)
- `browser.cache.memory.capacity` = 262144 (256 MB RAM cache)
- `browser.sessionhistory.max_total_viewers` = 4 (down from 8)

### Hardening Additions from arkenfox
Added to base config:
- `security.cert_pinning.enforcement_level` = 2
- `security.ssl.require_safe_negotiation` = true
- `dom.disable_window_move_resize` = true
- `extensions.enabledScopes` = 5
- `network.IDN_show_punycode` = true
- `privacy.globalprivacycontrol.enabled` = true
- `security.csp.reporting.enabled` = false
