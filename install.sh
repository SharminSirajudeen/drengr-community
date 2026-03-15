#!/bin/bash
set -euo pipefail

REPO="SharminSirajudeen/drengr-community"
INSTALL_DIR="/usr/local/bin"
BINARY="drengr"

cleanup() {
  rm -rf "$TMP_DIR"
}

fatal() {
  echo "Error: $1" >&2
  exit 1
}

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    case "$ARCH" in
      arm64)  TARGET="aarch64-apple-darwin" ;;
      x86_64) TARGET="x86_64-apple-darwin" ;;
      *)      fatal "Unsupported macOS architecture: $ARCH" ;;
    esac
    ;;
  Linux)
    case "$ARCH" in
      x86_64|amd64) TARGET="x86_64-unknown-linux-gnu" ;;
      aarch64|arm64) TARGET="aarch64-unknown-linux-gnu" ;;
      *)            fatal "Unsupported Linux architecture: $ARCH" ;;
    esac
    ;;
  *)
    fatal "Unsupported OS: $OS. Drengr supports macOS and Linux."
    ;;
esac

echo ""
echo "Drengr — Proprietary Software"
echo "By continuing, you agree to the Terms of Use at https://drengr.dev/terms"
echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
echo ""
sleep 5

echo "Detected platform: ${OS} ${ARCH} (${TARGET})"

# Allow version pinning: DRENGR_VERSION=v0.1.0 curl ... | bash
if [ -n "${DRENGR_VERSION:-}" ]; then
  VERSION="$DRENGR_VERSION"
  # Validate version format (vX.Y.Z with optional pre-release suffix)
  if ! echo "$VERSION" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$'; then
    fatal "Invalid version format: $VERSION (expected vX.Y.Z)"
  fi
  echo "Using pinned version: ${VERSION}"
else
  # Fetch latest release tag
  echo "Fetching latest release..."
  LATEST_URL="https://api.github.com/repos/${REPO}/releases/latest"

  CURL_OPTS=(-fsSL)
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    CURL_OPTS+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
  fi

  RELEASE_JSON="$(curl "${CURL_OPTS[@]}" "$LATEST_URL")" \
    || fatal "Could not fetch latest release. Check your internet connection."

  if command -v jq >/dev/null 2>&1; then
    VERSION="$(echo "$RELEASE_JSON" | jq -r '.tag_name')"
  else
    VERSION="$(echo "$RELEASE_JSON" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
  fi

  if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    if echo "$RELEASE_JSON" | grep -qi "rate limit"; then
      fatal "GitHub API rate limit exceeded. Try again in a few minutes, or set GITHUB_TOKEN."
    fi
    fatal "Could not determine latest version. Is there a published release at github.com/${REPO}?"
  fi
  echo "Latest version: ${VERSION}"
fi

# Download
ARCHIVE="drengr-${VERSION}-${TARGET}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE}"

TMP_DIR="$(mktemp -d)"
trap cleanup EXIT

echo "Downloading ${ARCHIVE}..."
curl -fsSL -o "${TMP_DIR}/${ARCHIVE}" "$DOWNLOAD_URL" \
  || fatal "Download failed. The release may not have a binary for ${TARGET}."

# Verify checksum (mandatory — refuse to install unverified binary)
SHA_URL="${DOWNLOAD_URL}.sha256"
if ! curl -fsSL -o "${TMP_DIR}/${ARCHIVE}.sha256" "$SHA_URL" 2>/dev/null; then
  fatal "Could not fetch checksum file. Refusing to install unverified binary."
fi

cd "$TMP_DIR"
if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 -c "${ARCHIVE}.sha256" >/dev/null 2>&1 \
    || fatal "Checksum verification failed. The download may be corrupted."
elif command -v sha256sum >/dev/null 2>&1; then
  sha256sum -c "${ARCHIVE}.sha256" >/dev/null 2>&1 \
    || fatal "Checksum verification failed. The download may be corrupted."
else
  fatal "No checksum tool found (shasum/sha256sum). Cannot verify download integrity."
fi
echo "Checksum verified."
cd - >/dev/null

# Extract
tar xzf "${TMP_DIR}/${ARCHIVE}" --no-same-owner -C "$TMP_DIR" \
  || fatal "Failed to extract archive."

[ -f "${TMP_DIR}/${BINARY}" ] || fatal "Binary not found in archive."
chmod +x "${TMP_DIR}/${BINARY}"

# Install
if [ ! -d "$INSTALL_DIR" ]; then
  echo "${INSTALL_DIR} does not exist. Creating it..."
  sudo mkdir -p "$INSTALL_DIR"
fi

echo "Installing to ${INSTALL_DIR}/${BINARY}..."
if [ -w "$INSTALL_DIR" ]; then
  mv "${TMP_DIR}/${BINARY}" "${INSTALL_DIR}/${BINARY}"
else
  sudo mv "${TMP_DIR}/${BINARY}" "${INSTALL_DIR}/${BINARY}"
fi

# Verify
if command -v drengr >/dev/null 2>&1; then
  echo ""
  echo "✓ Installed successfully: $(drengr --version)"
  echo ""
  echo "Next: run 'drengr doctor' to check your setup."
else
  echo ""
  echo "Installed to ${INSTALL_DIR}/${BINARY}."
  echo "Make sure ${INSTALL_DIR} is in your PATH."
fi
