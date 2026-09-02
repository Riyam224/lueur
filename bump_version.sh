#!/bin/bash
# bump_version.sh — bumps the build number in pubspec.yaml before every
# Play Store / App Store upload, so you can never accidentally re-upload
# the same versionCode twice.
#
# Usage:
#   ./bump_version.sh              # bumps build number only (1.0.0+3 -> 1.0.0+4)
#   ./bump_version.sh patch        # bumps patch + build (1.0.0+3 -> 1.0.1+4)
#   ./bump_version.sh minor        # bumps minor + build (1.0.0+3 -> 1.1.0+4)
#   ./bump_version.sh major        # bumps major + build (1.0.0+3 -> 2.0.0+4)

set -e

PUBSPEC="pubspec.yaml"

if [ ! -f "$PUBSPEC" ]; then
  echo "Error: pubspec.yaml not found. Run this from your project root."
  exit 1
fi

CURRENT_LINE=$(grep "^version:" "$PUBSPEC")
CURRENT_VERSION=$(echo "$CURRENT_LINE" | sed 's/version: //')

VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

MAJOR=$(echo "$VERSION_NAME" | cut -d'.' -f1)
MINOR=$(echo "$VERSION_NAME" | cut -d'.' -f2)
PATCH=$(echo "$VERSION_NAME" | cut -d'.' -f3)

NEW_BUILD=$((BUILD_NUMBER + 1))

case "$1" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  "")
    ;;
  *)
    echo "Unknown argument: $1 (use: patch, minor, major, or nothing)"
    exit 1
    ;;
esac

NEW_VERSION_NAME="${MAJOR}.${MINOR}.${PATCH}"
NEW_VERSION="${NEW_VERSION_NAME}+${NEW_BUILD}"

sed -i.bak "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"
rm -f "${PUBSPEC}.bak"

echo "Version bumped: ${CURRENT_VERSION} -> ${NEW_VERSION}"
echo ""
echo "Next steps:"
echo "  git add pubspec.yaml"
echo "  git commit -m \"chore: bump version to ${NEW_VERSION}\""
echo "  flutter build appbundle --release"
