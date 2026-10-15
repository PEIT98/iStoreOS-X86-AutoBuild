# iStoreOS 25.12 x86-64 自动编译

基于 [iStoreOS 官方源码](https://github.com/istoreos/istoreos) 的 `istoreos-25.12` 分支，使用 GitHub Actions 编译通用 **x86-64** 固件。个性化改动只保留在本仓库，不直接修改官方源码。

## 默认集成

- iStoreOS / iStore / LuCI 与 x86-64 BIOS、UEFI 磁盘镜像（以实际编译结果为准）
- [FUjr/QModem](https://github.com/FUjr/QModem) 官方原版：`qmodem` + `luci-app-qmodem-next`；官方保留旧版 Lua 页面，本固件仅选择 Next 界面
- 5G/4G USB 模组：QMI、MBIM、NCM、ECM、RNDIS、USB 串口，以及华为 NCM、Sierra 驱动
- PCIe 模组：内核自带的 Qualcomm MHI 控制/MBIM 驱动，以及 MediaTek T7xx（如 FM350）驱动
- Realtek RTL8852AE / 8852BE / 8852CE / 8922AE Wi-Fi
- MediaTek MT7916 / MT7921 / MT7925 Wi-Fi
- Qualcomm QCNFA765（`ath11k-pci` + WCN6855 固件）
- Intel AX200 / AX210 / BE200 Wi-Fi；Intel e1000e / igb / igc / ixgbe 和 Realtek r8169 以太网

配置文件在 `configs/x86-64.config`。QModem 的 PCIe 自动扫描沿用官方默认配置；官方“通用 PCIe 驱动”选项依赖 iStoreOS 25.12 中不存在的 `kmod-mhi-wwan`，所以这里直接选择内核自带的 MHI 驱动，未修改官方 QModem。PCIe 模组需切到驱动支持的模式（常见为 MBIM），具体以模组型号为准。有线网卡 r8125、r8126 暂不默认开启。

## 构建操作

1. 在本仓库进入 **Actions → Build iStoreOS 25.12 x86_64 → Run workflow**。
2. 仅手动执行 `Run workflow` 时编译。修改代码或配置后不会自动触发 Actions。
3. 成功后从 **Releases** 下载刷机镜像，或在该次运行的 **Artifacts** 下载文件。
4. 如果添加新驱动，编辑 `configs/x86-64.config` 中的 `CONFIG_PACKAGE_...` 配置，系统会通过 `make defconfig` 处理依赖。

## 工程结构

| 路径 | 用途 |
| --- | --- |
| `.github/workflows/build.yml` | GitHub Actions 构建、收集并发布 |
| `configs/x86-64.config` | x86-64 机型、QModem 与网卡包选择 |
| `scripts/prepare.sh` | 添加官方 QModem Feed，更新 feeds，校验软件包 |
| `scripts/collect.sh` | 收集镜像、哈希、manifest 与源码版本信息 |

## 注意事项

- 本固件基于 iStoreOS **25.12 / Linux 6.12**，使用 **APK** 软件包管理；不能把 24.10 的 IPK 内核驱动混装进来。
- 官方 QModem 仓库的许可证也包含**禁止商业使用**的额外限制，使用和分发前请核对官方 [LICENSE](https://github.com/FUjr/QModem/blob/main/LICENSE)。
- 网卡驱动已选中不代表设备必然支持 AP / 160MHz，也不代表 5G 模组可直接拨号；仍受驱动、固件和硬件限制。
- GitHub 免费 Runner 的磁盘、运行时长等存在限制；**仓库配置已提交不代表整套固件已经编译成功**。
- 官方与 QModem 主分支可能继续更新；发布产物中的 `build-info.txt` 记录具体提交版本，便于追溯。
- x86 镜像刷盘会覆盖目标磁盘分区表，操作前务必备份。
