#!/usr/bin/env bash
set -euo pipefail
SOURCE_DIR="${1:-openwrt}"
OUT_DIR="${2:-release}"
SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
TARGET="$SOURCE_DIR/bin/targets/x86/64"
[ -d "$TARGET" ] || { echo "ERROR: firmware directory missing: $TARGET" >&2; exit 1; }

found=0
shopt -s nullglob
for f in "$TARGET"/*combined*.img.gz "$TARGET"/*combined*.img "$TARGET"/*.manifest; do
  cp -f "$f" "$OUT_DIR/"
  [[ "$f" == *combined*.img* ]] && found=1
done
[ "$found" -eq 1 ] || { echo 'ERROR: no x86 combined disk image found' >&2; exit 1; }

{
  printf 'iStoreOS: https://github.com/istoreos/istoreos\n'
  printf 'iStoreOS branch: istoreos-25.12\n'
  printf 'iStoreOS commit: '; git -C "$SOURCE_DIR" rev-parse HEAD
  if [ -d "$SOURCE_DIR/feeds/qmodem/.git" ]; then
    printf 'QModem: https://github.com/LianXia233/QModem\n'
    printf 'QModem commit: '; git -C "$SOURCE_DIR/feeds/qmodem" rev-parse HEAD
  fi
  printf 'Target: x86/64\n'
  printf 'Generated: '; date -u '+%Y-%m-%dT%H:%M:%SZ'
} > "$OUT_DIR/build-info.txt"

( cd "$OUT_DIR" && sha256sum * > sha256sums )
printf '\n==> Firmware release files:\n'
ls -lh "$OUT_DIR"
