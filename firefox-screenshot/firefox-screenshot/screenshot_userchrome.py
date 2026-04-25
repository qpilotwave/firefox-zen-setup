#!/usr/bin/env python3
"""
Screenshot Firefox userChrome UI via Marionette.

Usage:
    uv run python screenshot_userchrome.py

Prerequisites:
    - Firefox with Marionette support (modern Firefox ships this)
    - toolkit.legacyUserProfileCustomizations.stylesheets = true in about:config
"""

import base64
import os
import subprocess
import sys
import time
from pathlib import Path

from marionette_driver.marionette import Marionette

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
PROFILE_PATH = Path.home() / ".mozilla/firefox/qnyf9tcf.default-release"
SCREENSHOT_PATH = Path(__file__).parent / "userchrome_screenshot.png"
MARIONETTE_PORT = 2828


def wait_for_marionette(timeout: float = 30.0) -> bool:
    """Poll until Marionette accepts a session."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            client = Marionette(host="localhost", port=MARIONETTE_PORT)
            client.start_session()
            client.delete_session()
            return True
        except Exception:
            time.sleep(0.5)
    return False


def ensure_firefox_running() -> subprocess.Popen | None:
    """Launch Firefox with Marionette if not already running."""
    if wait_for_marionette(timeout=2.0):
        print("[*] Connected to existing Firefox Marionette session.")
        return None

    print("[*] No Marionette session found; launching Firefox …")
    cmd = [
        "firefox",
        "--marionette",
        "--remote-allow-system-access",
        "--profile",
        str(PROFILE_PATH),
        "--new-instance",
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    if wait_for_marionette(timeout=30.0):
        print(f"[*] Firefox launched (pid={proc.pid}) and Marionette ready.")
        return proc

    proc.terminate()
    raise RuntimeError("Firefox did not start Marionette in time.")


def screenshot_ui() -> bytes:
    """Connect to Marionette, switch to chrome context, and take a screenshot."""
    client = Marionette(host="localhost", port=MARIONETTE_PORT)
    client.start_session()
    print("[*] Marionette session started.")

    # Switch to chrome context so we target the browser UI, not web content.
    client.set_context(client.CONTEXT_CHROME)
    print("[*] Context switched to CHROME.")

    # Take the screenshot.
    # In chrome context Marionette's screenshot command captures the top-level
    # chrome window (browser.xhtml) which includes the full Firefox UI:
    # toolbars, tabs, sidebars, etc.
    print("[*] Capturing screenshot …")
    b64_data = client.screenshot(format="base64", full=True)
    client.delete_session()
    return base64.b64decode(b64_data)


def inject_test_style(client: Marionette, css: str) -> str:
    """Inject a <style> tag into the chrome DOM for quick visual tests.

    Note: userChrome.css rules may override injected styles due to specificity.
    For true userChrome.css testing, edit the file and restart Firefox.
    """
    client.set_context(client.CONTEXT_CHROME)
    script = f"""
let doc = window.document;
let style = doc.createElement("style");
style.textContent = {css!r};
doc.documentElement.appendChild(style);
return "style injected";
"""
    return client.execute_script(script)


def main() -> int:
    proc = ensure_firefox_running()
    try:
        png_bytes = screenshot_ui()
        SCREENSHOT_PATH.write_bytes(png_bytes)
        print(f"[*] Screenshot saved: {SCREENSHOT_PATH.resolve()}")
        print(f"[*] Size: {len(png_bytes)} bytes")
    finally:
        if proc is not None:
            print(f"[*] Terminating Firefox (pid={proc.pid}) …")
            proc.terminate()
            try:
                proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                proc.kill()
    return 0


if __name__ == "__main__":
    sys.exit(main())
