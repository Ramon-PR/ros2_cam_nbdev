#!/usr/bin/env bash
set -euo pipefail

# basic_install.sh
# Checks the OS, ensures curl and sudo are available,
# installs uv (Astral) via the official installer,
# and installs the appropriate Python through uv.

# ── Helpers ──────────────────────────────────────────────
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✔]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✘]${NC} $*"; }
cmd_exists() { command -v "$1" >/dev/null 2>&1; }

# ── 1. Detect OS ────────────────────────────────────────
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_NAME="${PRETTY_NAME:-$ID}"
  elif [ "$(uname)" = "Darwin" ]; then
    OS_ID="macos"
    OS_NAME="macOS $(sw_vers -productVersion 2>/dev/null || echo '')"
  else
    OS_ID="unknown"
    OS_NAME="$(uname -s)"
  fi
  echo "──────────────────────────────────"
  info "Detected OS: $OS_NAME ($OS_ID)"
  echo "──────────────────────────────────"
}

# ── 2. Detect package manager ───────────────────────────
detect_pkg_mgr() {
  if   cmd_exists apt-get; then PKG_MGR="apt"
  elif cmd_exists dnf;     then PKG_MGR="dnf"
  elif cmd_exists yum;     then PKG_MGR="yum"
  elif cmd_exists pacman;  then PKG_MGR="pacman"
  elif cmd_exists zypper;  then PKG_MGR="zypper"
  elif cmd_exists apk;     then PKG_MGR="apk"
  elif cmd_exists brew;    then PKG_MGR="brew"
  else PKG_MGR="unknown"
  fi
  info "Package manager: $PKG_MGR"
}

# ── 3. Install a system package ─────────────────────────
# Helper for non-interactive apt installs (avoids tzdata prompts)
apt_install() {
  sudo apt-get update -qq
  sudo apt-get -o Dpkg::Options::=--force-confdef \
               -o Dpkg::Options::=--force-confold \
               install -y -qq "$@"
}

apt_install_sudo() {
  apt-get update -qq
  apt-get -o Dpkg::Options::=--force-confdef \
          -o Dpkg::Options::=--force-confold \
          install -y -qq "$@"
}

pkg_install() {
  local pkg="$1"
  case "$PKG_MGR" in
    apt)    apt_install "$pkg" ;;
    dnf)    sudo dnf install -y -q "$pkg" ;;
    yum)    sudo yum install -y -q "$pkg" ;;
    pacman) sudo pacman -Sy --noconfirm "$pkg" ;;
    zypper) sudo zypper install -y "$pkg" ;;
    apk)    apk add --no-cache "$pkg" ;;
    brew)   brew install "$pkg" ;;
    *)      error "Cannot install '$pkg': unknown package manager."; return 1 ;;
  esac
}

# ── 4. Ensure sudo ──────────────────────────────────────
ensure_sudo() {
  if cmd_exists sudo; then
    info "sudo available."
    return
  fi
  warn "sudo not found. Attempting to install..."
  if [ "$(id -u)" -ne 0 ]; then
    error "Not running as root and sudo is not installed. Run this script as root first."
    exit 1
  fi
  case "$PKG_MGR" in
    apt)    apt_install_sudo sudo ;;
    dnf)    dnf install -y -q sudo ;;
    yum)    yum install -y -q sudo ;;
    pacman) pacman -Sy --noconfirm sudo ;;
    zypper) zypper install -y sudo ;;
    apk)    apk add --no-cache sudo ;;
    *)      error "Cannot install sudo automatically."; exit 1 ;;
  esac
  info "sudo installed."
}

# ── 5. Ensure curl ──────────────────────────────────────
ensure_curl() {
  if cmd_exists curl; then
    info "curl available."
    return
  fi
  warn "curl not found. Installing..."
  pkg_install curl
  if cmd_exists curl; then
    info "curl installed."
  else
    error "Failed to install curl."; exit 1
  fi
}

# ── 6. Ensure git ───────────────────────────────────────
ensure_git() {
  if cmd_exists git; then
    info "git available: $(git --version)"
    return
  fi
  warn "git not found. Installing..."
  pkg_install git
  if cmd_exists git; then
    info "git installed: $(git --version)"
  else
    error "Failed to install git."; exit 1
  fi
}

# ── 7. Install uv (Astral) ──────────────────────────────
ensure_uv() {
  if cmd_exists uv; then
    info "uv already installed: $(uv --version)"
    return
  fi
  warn "uv not found. Installing from https://astral.sh/uv ..."
  curl -LsSf https://astral.sh/uv/install.sh | sh

  # The installer puts uv in $HOME/.local/bin or $CARGO_HOME/bin
  export PATH="$HOME/.local/bin:${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"

  if cmd_exists uv; then
    info "uv installed: $(uv --version)"
  else
    error "uv installation failed."; exit 1
  fi
}

# ── 8. Install Python3 via system package manager ────────
ensure_python() {
  if cmd_exists python3; then
    info "python3 already available: $(python3 --version)"
    return
  fi
  warn "python3 not found. Installing with $PKG_MGR..."
  case "$PKG_MGR" in
    apt)    pkg_install python3 ;;
    dnf|yum) pkg_install python3 ;;
    pacman) pkg_install python ;;
    zypper) pkg_install python3 ;;
    apk)    pkg_install python3 ;;
    brew)   pkg_install python@3 ;;
    *)      error "Cannot install python3 automatically."; exit 1 ;;
  esac
  if cmd_exists python3; then
    info "python3 installed: $(python3 --version)"
  else
    error "Failed to install python3."; exit 1
  fi
}

# ── Main ─────────────────────────────────────────────────
main() {
  echo "Checking basic dependencies..."
  detect_os
  detect_pkg_mgr
  ensure_sudo
  ensure_curl
  ensure_git
  ensure_uv
  ensure_python

  echo ""
  echo "══════════════════════════════════"
  info "Environment ready:"
  echo "  curl    : $(curl --version | head -1)"
  echo "  git     : $(git --version)"
  echo "  uv      : $(uv --version)"
  echo "  python  : $(python3 --version)"
  echo "══════════════════════════════════"
}

main "$@"
