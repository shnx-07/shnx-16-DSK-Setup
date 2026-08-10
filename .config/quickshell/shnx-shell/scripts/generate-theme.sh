#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="${HOME}/.config/quickshell/shnx-shell"
MATUGEN_CONFIG="${HOME}/.config/matugen/config.toml"

CANDIDATE_FILE="${HOME}/.config/matugen/generated/MatugenPalette.candidate.qml"
LIVE_FILE="${PROJECT_ROOT}/theme/generated/MatugenPalette.qml"
BACKUP_FILE="${PROJECT_ROOT}/theme/generated/MatugenPalette.last-valid.qml"

log() {
  printf '[generate-theme] %s\n' "$*"
}

fail() {
  printf '[generate-theme] ERROR: %s\n' "$*" >&2
  exit 1
}

usage() {
  printf 'Usage: %s <wallpaper-image>\n' "$(basename "$0")"
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

SOURCE_IMAGE="$1"

command -v matugen >/dev/null 2>&1 ||
  fail "Matugen is not installed or is not available in PATH."

[[ -f "$MATUGEN_CONFIG" ]] ||
  fail "Matugen configuration not found: $MATUGEN_CONFIG"

[[ -f "$SOURCE_IMAGE" ]] ||
  fail "Wallpaper source does not exist: $SOURCE_IMAGE"

mkdir -p "$(dirname "$CANDIDATE_FILE")"
mkdir -p "$(dirname "$LIVE_FILE")"

rm -f "$CANDIDATE_FILE"

log "Generating palette from: $SOURCE_IMAGE"

matugen image \
  --config "$MATUGEN_CONFIG" \
  --mode dark \
  --source-color-index 0 \
  "$SOURCE_IMAGE"

[[ -s "$CANDIDATE_FILE" ]] ||
  fail "Matugen did not produce a non-empty candidate palette."

required_roles=(
  primary
  on_primary
  primaryContainer
  on_primary_container

  secondary
  on_secondary
  secondaryContainer
  on_secondary_container

  tertiary
  on_tertiary
  tertiaryContainer
  on_tertiary_container

  background
  on_background

  surface
  surfaceDim
  surfaceBright
  surfaceContainerLowest
  surfaceContainerLow
  surfaceContainer
  surfaceContainerHigh
  surfaceContainerHighest

  on_surface
  on_surface_variant

  inverseSurface
  inverse_on_surface
  inversePrimary

  outline
  outlineVariant
  shadow
  scrim

  error
  on_error
  errorContainer
  on_error_container

  success
  on_success
  successContainer
  on_success_container

  warning
  on_warning
  warningContainer
  on_warning_container

  info
  on_info
  infoContainer
  on_info_container
)

for palette_name in darkPalette lightPalette; do
  if ! grep -Eq \
    "readonly[[:space:]]+property[[:space:]]+QtObject[[:space:]]+${palette_name}[[:space:]]*:" \
    "$CANDIDATE_FILE"; then
    fail "Candidate palette is missing nested palette: $palette_name"
  fi
done

for role in "${required_roles[@]}"; do
  role_count="$(
    grep -Ec \
      "readonly[[:space:]]+property[[:space:]]+color[[:space:]]+${role}[[:space:]]*:" \
      "$CANDIDATE_FILE" ||
      true
  )"

  if [[ "$role_count" -lt 2 ]]; then
    fail "Candidate palette must expose role '$role' in both dark and light palettes."
  fi
done

if ! grep -Eq '^[[:space:]]*pragma[[:space:]]+Singleton' "$CANDIDATE_FILE"; then
  fail "Candidate palette is missing 'pragma Singleton'."
fi

if ! grep -Eq '^[[:space:]]*import[[:space:]]+QtQuick' "$CANDIDATE_FILE"; then
  fail "Candidate palette is missing the QtQuick import."
fi

if ! grep -Eq '^[[:space:]]*QtObject[[:space:]]*\{' "$CANDIDATE_FILE"; then
  fail "Candidate palette does not contain a QtObject root."
fi

invalid_hex_line="$(
  grep -En \
    'readonly[[:space:]]+property[[:space:]]+color.*"#[^"]*"' \
    "$CANDIDATE_FILE" |
    grep -Ev '"#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?"' ||
    true
)"

if [[ -n "$invalid_hex_line" ]]; then
  printf '%s\n' "$invalid_hex_line" >&2
  fail "Candidate palette contains an invalid hex color."
fi

if [[ -f "$LIVE_FILE" ]]; then
  cp -f "$LIVE_FILE" "$BACKUP_FILE"
fi

temporary_live_file="${LIVE_FILE}.tmp.$$"

cp "$CANDIDATE_FILE" "$temporary_live_file"
chmod 0644 "$temporary_live_file"

mv -f "$temporary_live_file" "$LIVE_FILE"

log "Palette committed successfully:"
log "$LIVE_FILE"
