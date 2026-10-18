#!/usr/bin/env bash

set -euo pipefail

SOURCE_REPO="Kartax/tokenmeter"
ASSET_NAME="TokenMeter.dmg"
REQUESTED_TAG="${1:-}"
TAP_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CASK_PATH="$TAP_ROOT/Casks/tokenmeter.rb"

if [[ -n "$REQUESTED_TAG" && ! "$REQUESTED_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "!! Expected a stable release tag such as v0.1.0, got: $REQUESTED_TAG" >&2
  exit 1
fi

if [[ -n "$REQUESTED_TAG" ]]; then
  RELEASE_ENDPOINT="repos/$SOURCE_REPO/releases/tags/$REQUESTED_TAG"
else
  RELEASE_ENDPOINT="repos/$SOURCE_REPO/releases/latest"
fi

if ! RELEASE_JSON="$(gh api "$RELEASE_ENDPOINT" 2>/dev/null)"; then
  echo "!! No stable release ${REQUESTED_TAG:-(latest)} found on $SOURCE_REPO; nothing to update." >&2
  exit 1
fi
TAG="$(jq -er '.tag_name' <<<"$RELEASE_JSON")"
DRAFT="$(jq -r '.draft' <<<"$RELEASE_JSON")"
PRERELEASE="$(jq -r '.prerelease' <<<"$RELEASE_JSON")"

if [[ "$DRAFT" != "false" || "$PRERELEASE" != "false" ]]; then
  echo "!! Refusing non-stable release $TAG (draft=$DRAFT, prerelease=$PRERELEASE)." >&2
  exit 1
fi
if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "!! Stable release tag must use vMAJOR.MINOR.PATCH: $TAG" >&2
  exit 1
fi
if [[ -n "$REQUESTED_TAG" && "$TAG" != "$REQUESTED_TAG" ]]; then
  echo "!! GitHub returned $TAG for requested tag $REQUESTED_TAG." >&2
  exit 1
fi

ASSET_COUNT="$(jq --arg name "$ASSET_NAME" '[.assets[] | select(.name == $name)] | length' <<<"$RELEASE_JSON")"
if [[ "$ASSET_COUNT" != "1" ]]; then
  echo "!! Expected exactly one $ASSET_NAME asset on $TAG, found $ASSET_COUNT." >&2
  exit 1
fi

DOWNLOAD_URL="$(jq -er --arg name "$ASSET_NAME" '.assets[] | select(.name == $name) | .browser_download_url' <<<"$RELEASE_JSON")"
REPORTED_DIGEST="$(jq -er --arg name "$ASSET_NAME" '.assets[] | select(.name == $name) | .digest' <<<"$RELEASE_JSON")"
if [[ ! "$REPORTED_DIGEST" =~ ^sha256:([0-9a-f]{64})$ ]]; then
  echo "!! GitHub did not report a SHA-256 digest for $ASSET_NAME on $TAG." >&2
  exit 1
fi
SHA256="${BASH_REMATCH[1]}"
VERSION="${TAG#v}"

if [[ -f "$CASK_PATH" ]]; then
  EXISTING_VERSION="$(awk -F'"' '/^  version "/ { print $2; exit }' "$CASK_PATH")"
  EXISTING_SHA256="$(awk -F'"' '/^  sha256 "/ { print $2; exit }' "$CASK_PATH")"
  if [[ -z "$EXISTING_VERSION" || -z "$EXISTING_SHA256" ]]; then
    echo "!! Could not read the existing cask version and checksum." >&2
    exit 1
  fi
  if [[ "$EXISTING_VERSION" == "$VERSION" ]]; then
    if [[ "$EXISTING_SHA256" != "$SHA256" ]]; then
      echo "!! Refusing changed checksum for already-published version $VERSION." >&2
      exit 1
    fi
    echo "==> tokenmeter $VERSION is already current"
    exit 0
  fi
  if ! ruby -e 'require "rubygems"; exit(Gem::Version.new(ARGV[0]) > Gem::Version.new(ARGV[1]) ? 0 : 1)' \
      "$VERSION" "$EXISTING_VERSION"; then
    echo "!! Refusing cask downgrade from $EXISTING_VERSION to $VERSION." >&2
    exit 1
  fi
fi

WORK_DIR="$(mktemp -d)"
MOUNT_DIR="$WORK_DIR/mount"
DMG="$WORK_DIR/$ASSET_NAME"
MOUNTED=0
cleanup() {
  if [[ "$MOUNTED" == "1" ]]; then
    hdiutil detach "$MOUNT_DIR" >/dev/null 2>&1 || true
  fi
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

mkdir -p "$MOUNT_DIR"
echo "==> Downloading $SOURCE_REPO $TAG"
curl --fail --location --silent --show-error --output "$DMG" "$DOWNLOAD_URL"
ACTUAL_SHA256="$(shasum -a 256 "$DMG" | awk '{ print $1 }')"
if [[ "$ACTUAL_SHA256" != "$SHA256" ]]; then
  echo "!! Downloaded SHA-256 $ACTUAL_SHA256 does not match GitHub digest $SHA256." >&2
  exit 1
fi

xcrun stapler validate "$DMG"
hdiutil attach -readonly -nobrowse -mountpoint "$MOUNT_DIR" "$DMG" >/dev/null
MOUNTED=1
codesign --verify --deep --strict --verbose=2 "$MOUNT_DIR/TokenMeter.app"
spctl -a -t exec -vvv "$MOUNT_DIR/TokenMeter.app"
hdiutil detach "$MOUNT_DIR" >/dev/null
MOUNTED=0

mkdir -p "$(dirname "$CASK_PATH")"
cat >"$CASK_PATH" <<CASK
cask "tokenmeter" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/Kartax/tokenmeter/releases/download/v#{version}/TokenMeter.dmg"
  name "TokenMeter"
  desc "Menu bar meter for AI subscription quotas"
  homepage "https://kartax.github.io/tokenmeter/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "TokenMeter.app"

  uninstall quit: "org.kartax.TokenMeter"

  zap trash: [
    "~/Library/Application Support/TokenMeter",
    "~/Library/Preferences/org.kartax.TokenMeter.plist",
  ]
end
CASK

echo "==> Prepared tokenmeter $VERSION ($SHA256)"
