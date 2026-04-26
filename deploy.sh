#!/usr/bin/env bash
#
# deploy.sh — Firefox Performant Privacy Edition Deploy Script
#
# Deploys all three configuration layers to their correct locations:
#   1. user.js          → Firefox profile directory
#   2. chrome/          → Firefox profile directory (recursive)
#   3. policies.json    → Firefox installation distribution dir
#
# Usage:
#   ./deploy.sh              # Deploy to auto-detected default profile
#   ./deploy.sh --dry-run    # Show what would be deployed, don't copy
#   ./deploy.sh --profile PROFILENAME  # Deploy to a named profile
#
# Requirements:
#   - Bash 4+
#   - sudo (for policies.json deployment)
#   - rsync (for chrome/ directory sync)
#
# Environment variables:
#   FIREFOX_HOME   — override Firefox data directory (default: ~/.mozilla/firefox)
#   POLICIES_DIR   — override policies directory (default: auto-detect)
#   NO_POLICY      — set to 1 to skip policy deployment
# ==============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIREFOX_HOME="${FIREFOX_HOME:-$HOME/.mozilla/firefox}"
PROFILES_INI="$FIREFOX_HOME/profiles.ini"
DRY_RUN=false
SELECTED_PROFILE=""

# Formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { echo -e " ${GREEN}→${NC} $*"; }
warn()  { echo -e " ${YELLOW}⚠${NC} $*" >&2; }
err()   { echo -e " ${RED}✖${NC} $*" >&2; }
dry()   { echo -e "  ${YELLOW}(dry-run)${NC} $*"; }
header() { echo -e "\n${BOLD}$*${NC}\n$(printf '─%.0s' $(seq 1 ${#1}))"; }

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Deploy Firefox Performant Privacy Edition configuration files.

Options:
  --dry-run              Show what would be done without copying anything
  --profile PROFILENAME  Target a specific Firefox profile directory name
  -h, --help             Show this help message
EOF
    exit 0
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)  DRY_RUN=true; shift ;;
        --profile)  SELECTED_PROFILE="$2"; shift 2 ;;
        -h|--help)  usage ;;
        *)          err "Unknown option: $1"; usage ;;
    esac
done

# ---------------------------------------------------------------------------
# Detect Firefox profile
# ---------------------------------------------------------------------------
detect_profile() {
    header "1. Detecting Firefox Profile"

    if [[ -n "$SELECTED_PROFILE" ]]; then
        PROFILE_DIR="$FIREFOX_HOME/$SELECTED_PROFILE"
        if [[ ! -d "$PROFILE_DIR" ]]; then
            err "Profile directory not found: $PROFILE_DIR"
            exit 1
        fi
        info "Using specified profile: ${SELECTED_PROFILE}"
    else
        if [[ ! -f "$PROFILES_INI" ]]; then
            err "Firefox profiles.ini not found at $PROFILES_INI"
            err "Is Firefox installed? Set FIREFOX_HOME if using a custom location."
            exit 1
        fi

        # Find the active profile — look for Install section Default first,
        # fall back to legacy Default=1 profile.
        INSTALL_DEFAULT=$(grep -A1 '^\[Install' "$PROFILES_INI" | grep '^Default=' | cut -d= -f2 | head -1)

        if [[ -n "$INSTALL_DEFAULT" ]]; then
            PROFILE_PATH="$INSTALL_DEFAULT"
            info "Install-section default profile: ${BOLD}${PROFILE_PATH}${NC}"
        else
            # Fallback: use the first profile with Default=1
            PROFILE_PATH=$(grep -A2 '^\[Profile' "$PROFILES_INI" | grep -B1 'Default=1' | grep '^Path=' | cut -d= -f2 | head -1)

            if [[ -z "$PROFILE_PATH" ]]; then
                # Last resort: first profile with IsRelative=1
                PROFILE_PATH=$(grep '^Path=' "$PROFILES_INI" | head -1 | cut -d= -f2)
            fi
        fi

        if [[ -z "$PROFILE_PATH" ]]; then
            err "Could not detect default Firefox profile."
            err "Use --profile PROFILENAME to specify one manually."
            exit 1
        fi

        PROFILE_DIR="$FIREFOX_HOME/$PROFILE_PATH"
        if [[ ! -d "$PROFILE_DIR" ]]; then
            err "Detected profile directory does not exist: $PROFILE_DIR"
            exit 1
        fi

        info "Default profile: ${BOLD}${PROFILE_PATH}${NC}"
    fi

    echo "  Path: $PROFILE_DIR"
}

# ---------------------------------------------------------------------------
# Detect policies directory
# ---------------------------------------------------------------------------
detect_policies_dir() {
    header "2. Detecting Policies Directory"

    if [[ -n "${POLICIES_DIR:-}" ]]; then
        POLICIES_TARGET="$POLICIES_DIR"
    else
        # Common locations for Firefox distribution policies
        CANDIDATES=(
            "/usr/lib/firefox/distribution"
            "/usr/lib64/firefox/distribution"
            "/usr/lib/firefox-esr/distribution"
            "/usr/lib/firefox-developer-edition/distribution"
            "/snap/firefox/current/usr/lib/firefox/distribution"
            "/opt/firefox/distribution"
        )

        POLICIES_TARGET=""
        for dir in "${CANDIDATES[@]}"; do
            if [[ -d "$dir" ]]; then
                POLICIES_TARGET="$dir"
                break
            fi
        done

        if [[ -z "$POLICIES_TARGET" ]]; then
            # Check if policies.json already exists somewhere
            EXISTING=$(find /usr/lib /usr/share /opt -name "policies.json" -path "*/distribution/*" 2>/dev/null | head -1)
            if [[ -n "$EXISTING" ]]; then
                POLICIES_TARGET="$(dirname "$EXISTING")"
            fi
        fi
    fi

    if [[ -z "${POLICIES_TARGET:-}" ]]; then
        warn "Could not auto-detect Firefox distribution directory."
        warn "Set POLICIES_DIR environment variable, or use NO_POLICY=1 to skip."
        SKIP_POLICY=true
    else
        info "Policies directory: ${BOLD}${POLICIES_TARGET}${NC}"
        SKIP_POLICY=false
    fi
}

# ---------------------------------------------------------------------------
# Deploy user.js
# ---------------------------------------------------------------------------
deploy_user_js() {
    header "3. Deploying user.js"

    local src="$PROJECT_DIR/user.js"
    local dst="$PROFILE_DIR/user.js"

    if [[ ! -f "$src" ]]; then
        err "Source file not found: $src"
        return 1
    fi

    if $DRY_RUN; then
        dry "cp '$src' → '$dst'"
    else
        cp "$src" "$dst"
        info "Deployed user.js"
    fi

    # Verify
    if [[ -f "$dst" ]]; then
        local lines=$(wc -l < "$dst")
        echo "  $lines lines, $(du -h "$dst" | cut -f1)"
    else
        warn "user.js was not deployed (dry-run)"
    fi
}

# ---------------------------------------------------------------------------
# Deploy chrome/ directory
# ---------------------------------------------------------------------------
deploy_chrome() {
    header "4. Deploying Chrome CSS"

    local src="$PROJECT_DIR/chrome"
    local dst="$PROFILE_DIR/chrome"

    if [[ ! -d "$src" ]]; then
        err "Source directory not found: $src"
        return 1
    fi

    if $DRY_RUN; then
        dry "Syncing chrome/ directory..."
        for f in "$src"/*.css "$src"/zen-modules/*.css; do
            [[ -f "$f" ]] && dry "  $(basename "$(dirname "$f")")/$(basename "$f")"
        done
    else
        mkdir -p "$dst/zen-modules"
        cp "$src"/*.css "$dst/" 2>/dev/null || true
        cp "$src"/zen-modules/*.css "$dst/zen-modules/" 2>/dev/null || true
        info "Deployed chrome/ CSS"
    fi

    # Verify
    local src_count=$(find "$src" -name '*.css' | wc -l)
    local dst_count=$(find "$dst" -name '*.css' 2>/dev/null | wc -l)
    echo "  $src_count files in source → $dst_count files deployed"
}

# ---------------------------------------------------------------------------
# Deploy policies.json
# ---------------------------------------------------------------------------
deploy_policies() {
    header "5. Deploying policies.json"

    if [[ "${SKIP_POLICY:-false}" == "true" ]]; then
        warn "Skipping policy deployment (no target directory found)"
        return
    fi

    local src="$PROJECT_DIR/policies.json"
    local dst="$POLICIES_TARGET/policies.json"

    if [[ ! -f "$src" ]]; then
        err "Source file not found: $src"
        return 1
    fi

    if $DRY_RUN; then
        dry "sudo cp '$src' → '$dst'"
    else
        if command -v sudo &>/dev/null; then
            sudo cp "$src" "$dst"
            info "Deployed policies.json (system-wide, requires sudo)"
        else
            err "sudo required to deploy to $POLICIES_TARGET"
            return 1
        fi
    fi

    # Verify
    if [[ -f "$dst" ]]; then
        echo "  $(du -h "$dst" | cut -f1)"
        if [[ -n "${POLICIES_TARGET:-}" ]]; then
            echo "  Location: $dst"
        fi
    fi
}

# ---------------------------------------------------------------------------
# Show sync summary
# ---------------------------------------------------------------------------
show_summary() {
    header "6. Deployment Summary"

    if $DRY_RUN; then
        echo -e "  ${YELLOW}Dry-run mode${NC} — no files were copied."
    fi

    echo ""
    echo -e "  ${BOLD}user.js${NC}       → $PROFILE_DIR/user.js"
    echo -e "  ${BOLD}chrome/${NC}       → $PROFILE_DIR/chrome/"
    echo -e "  ${BOLD}policies.json${NC} → ${POLICIES_TARGET:-SKIPPED}/policies.json"
    echo ""

    echo -e "  ${BOLD}Post-deploy checklist:${NC}"
    echo "    1. Restart Firefox (or start it fresh)"
    echo "    2. Open about:config and accept the risk warning"
    echo "    3. If ETP Strict dialog appears, click Enable"
    echo "    4. Enable vertical tabs: View → Sidebar → Vertical Tabs"
    echo "    5. Verify: about:networking#dns should show TRR active"
    echo ""
}

# ===========================================================================
# Main
# ===========================================================================
main() {
    echo ""
    echo -e "${BOLD}🔥 Firefox Performant Privacy Edition — Deploy Tool${NC}"
    echo "  Project: $PROJECT_DIR"
    echo ""

    detect_profile
    detect_policies_dir
    deploy_user_js
    deploy_chrome
    deploy_policies
    show_summary
}

main
