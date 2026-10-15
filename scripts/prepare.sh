#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-openwrt}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
cd "$SOURCE_DIR"

echo "==> Upstream: $(git rev-parse HEAD)"
echo "==> Add modified QModem feed"
# Keep official iStoreOS 25.12 feed definitions unchanged; append one extra feed.
if ! grep -qE '^src-git qmodem ' feeds.conf.default; then
  printf '\nsrc-git qmodem https://github.com/LianXia233/QModem.git;main\n' >> feeds.conf.default
fi

./scripts/feeds update -a
./scripts/feeds install -a

cp "$REPO_DIR/configs/x86-64.config" .config
make defconfig

# Stop early if important packages are unavailable or disabled by Kconfig.
required=(
  CONFIG_TARGET_x86_64
  CONFIG_PACKAGE_qmodem
  CONFIG_PACKAGE_luci-app-qmodem-next
  CONFIG_PACKAGE_kmod-rtw89-8852be
  CONFIG_PACKAGE_kmod-rtw89-8922ae
  CONFIG_PACKAGE_kmod-mt7915e
  CONFIG_PACKAGE_kmod-mt7921e
  CONFIG_PACKAGE_kmod-mt7925e
  CONFIG_PACKAGE_kmod-ath11k-pci
  CONFIG_PACKAGE_kmod-iwlwifi
)
for item in "${required[@]}"; do
  if ! grep -qx "${item}=y" .config; then
    echo "ERROR: ${item} is missing after make defconfig." >&2
    echo "Please check the selected feeds, package dependencies and upstream changes." >&2
    exit 1
  fi
done

if ! grep -qx 'CONFIG_GRUB_EFI_IMAGES=y' .config; then
  echo 'ERROR: UEFI image option was lost.' >&2
  exit 1
fi

printf '\n==> Firmware config OK; selected packages:\n'
grep -E '^CONFIG_PACKAGE_(qmodem|luci-app-qmodem-next|kmod-rtw89-8852be|kmod-rtw89-8922ae|kmod-mt7915e|kmod-ath11k-pci)=' .config || true
df -h .
