# OpenWRT-CI · 自动化固件构建

<p>
  <a href="https://github.com/kunkun912/OpenWRT-CI/actions/workflows/OWRT-ALL.yml"><img src="https://github.com/kunkun912/OpenWRT-CI/actions/workflows/OWRT-ALL.yml/badge.svg?branch=main" alt="每日构建" /></a>
  <a href="https://github.com/kunkun912/OpenWRT-CI/releases"><img src="https://img.shields.io/github/v/release/kunkun912/OpenWRT-CI?style=flat-square&logo=github&color=blue" alt="最新版本" /></a>
  <img src="https://img.shields.io/badge/源码-VIKINGYFY%2Fimmortalwrt-informational?style=flat-square" alt="上游源码" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT" />
</p>

基于 [VIKINGYFY/OpenWRT-CI](https://github.com/VIKINGYFY/OpenWRT-CI) 的自用构建流水线。每日拉取上游 [immortalwrt](https://github.com/VIKINGYFY/immortalwrt) 源码（`owrt` 分支），按 `Config/` 下的模板生成 `.config`，构建 QUALCOMMAX、MEDIATEK、AIROHA、ROCKCHIP、X86 平台的固件并发布到 Release。

在官方流程之上，本仓库补充了自动化脚本与若干第三方插件，并已在京东云亚瑟（`qualcommax / ipq60xx / jdcloud_re-ss-01`）上完成真机验证。

> [!IMPORTANT]
> **本仓库为个人构建配置，非 OpenWrt / immortalwrt 官方发行版。** 固件按原样提供，不对任何机型作出可用性承诺；刷写前请确认机型、存储布局与 U-BOOT 状态，刷写风险由使用者自行承担。
>
> **不提供会员、激活码或付费解锁。** 项目完全免费，如遇以本项目名义收费的行为请提高警惕。
>
> 构建产物来源于上游源码与第三方插件仓库，相关权利归各自作者所有；本仓库的 MIT 许可仅覆盖本仓库中的配置与脚本。

## 功能概览

- **每日自动构建**：`Auto-Clean.yml` 每天 21:21 UTC（北京时间 05:21）触发，完成后以 `workflow_run` 串起各平台构建流程；单次失败不影响已发布的历史版本。
- **手动按需构建**：`WRT-TEST.yml` 支持指定平台与源码分支，`TEST=true` 时仅生成配置文件，不进入编译，用于在投入一小时编译时间前验证依赖关系。
- **多平台覆盖**：QUALCOMMAX、MEDIATEK、AIROHA、ROCKCHIP、X86，每个平台对应独立的一份或多份 `.config` 模板。
- **可复现的配置**：版本信息中的时间戳为编译开始时间，便于与上游提交记录对齐。
- **第三方插件集成**：通过 `Scripts/Packages.sh` 声明式拉取源码，配合 `Scripts/Handles.sh` 打补丁，无需在构建机上手工维护目录。

## 支持平台

| 平台 | 构建流程 | 配置模板 | 说明 |
|---|---|---|---|
| QUALCOMMAX | `QCA-ALL.yml` | `IPQ60XX-WIFI-YES/NO.txt`、`IPQ807X-WIFI-YES/NO.txt`、`IPQ53XX.txt`、`IPQ95XX.txt` | 高通 IPQ 系列，含京东云亚瑟等机型；`WIFI-YES` 保留 `kmod-ath11k` 与对应固件 |
| MEDIATEK | `MTK-ALL.yml` | `MEDIATEK-WIFI-YES/NO.txt` | 联发科路由器平台 |
| AIROHA | `AIROHA-ALL.yml` | `AIROHA-AN7581.txt`、`AIROHA-AN7583.txt` | Airoha 有线方案 |
| ROCKCHIP / X86 | `OWRT-ALL.yml` | `ROCKCHIP.txt`、`X86.txt` | 瑞芯微软路由与 x86_64 通用镜像 |

`WRT-CORE.yml` 为公共构建核心，被上述流程以 `uses:` 方式复用；`WRT-TEST.yml` 用于手动构建单个配置；`Cache-Clean.yml` 负责运行缓存清理。

所有平台共用 `Config/GENERAL.txt`，用于放置与平台无关的软件包选项。

## 集成插件

以下插件在上游默认未包含，由本仓库引入：

| 插件 | 上游仓库 | 用途 |
|---|---|---|
| 网易 UU 加速器 | [xiaodoudou/luci-app-uugamebooster](https://github.com/xiaodoudou/luci-app-uugamebooster) | 主机游戏加速，支持与 OpenClash、UA3F 共存 |
| UA3F | [SunBK201/UA3F](https://github.com/SunBK201/UA3F) | 上行 UA 重写，用于规避部分客户端的投放策略 |
| OpenClash | [vernesong/OpenClash](https://github.com/vernesong/OpenClash) | 透明代理与规则分流 |
| 皎月连 | [natpierce/luci-app-natpierce](https://github.com/natpierce/luci-app-natpierce) | 内网穿透 |

> [!NOTE]
> OpenClash 与 homeproxy 均为透明代理，可同时装入固件，但**运行时请只启用其中一个**。两者同时启用会造成 iptables / nftables 规则互相覆盖，导致转发异常。

各插件的依赖（`kmod-tun`、`unshare`、`libstdcpp`、`ipset`、`iptables-mod-*` 等）在上游 feed 中均已提供，无需额外引入软件源。

## 仓库结构

```
.github/
  workflows/         构建流水线定义（定时触发、平台矩阵、产物发布）
  scripts/           流水线公共脚本（如 i2c-tools 准备）
Scripts/
  Packages.sh        拉取第三方插件源码并提取包目录
  Handles.sh         对拉取到的包执行补丁，修正上游 Makefile 问题
  Settings.sh        修改固件默认设置（主机名、时区、主题等）
Config/
  *.txt              各平台的 .config 模板
  GENERAL.txt        全平台共用选项
```

## 构建流程

单次构建依次执行：

1. `scripts/feeds update -a` 与 `install -a`，同步上游软件源；
2. `Scripts/Packages.sh`，按声明拉取第三方插件并提取到 `package/`；
3. `Scripts/Handles.sh`，对插件 Makefile 打补丁；
4. `.github/scripts/prepare-i2c-tools.sh`，准备构建依赖；
5. 拼接 `Config/<平台>.txt` 与 `Config/GENERAL.txt` 生成 `.config`；
6. `Scripts/Settings.sh`，写入固件默认值；
7. `make defconfig && make -j$(nproc)`；
8. 产物打包并发布到 Release。

## 自定义

**添加插件**：在 `Scripts/Packages.sh` 中增加调用，并在 `Config/GENERAL.txt` 中启用对应 `CONFIG_PACKAGE_xxx=y`。

```bash
# 仅拉取源码、包目录位于仓库根目录
UPDATE_PACKAGE "UA3F" "SunBK201/UA3F" "master"

# 从仓库子目录中提取指定包
UPDATE_PACKAGE "uugamebooster" "xiaodoudou/luci-app-uugamebooster" "master" "pkg"
```

**修正上游 Makefile**：在 `Scripts/Handles.sh` 中追加 `FIX` 块，脚本在守卫目录存在时才执行，避免上游调整目录结构后构建中断。

```bash
FIX "<补丁名称>" "<守卫目录>" sed -i '<替换规则>' "<目标 Makefile>"
```

**调整固件默认值**：编辑 `Scripts/Settings.sh`，例如默认主机名、时区、软件源、LuCI 主题等。

## 产物与刷写

| 文件 | 用途 |
|---|---|
| `*-squashfs-factory.bin` | 原厂固件首刷 |
| `*-squashfs-sysupgrade.bin` | 已运行 OpenWrt 时升级，保留配置需自行确认兼容性 |

产物与校验值随 Release 一并发布。刷写前建议核对机型字符串与镜像内的设备名一致，并按机型要求选择对应的 U-BOOT 与刷写方式。

<details>
<summary><b>手动触发构建</b></summary>

在 Actions 页面选择 `WRT-TEST`，填写以下参数：

- `CONFIG`：平台配置名，如 `X86`、`IPQ60XX-WIFI-YES`；
- `SOURCE`：`VIKINGYFY/immortalwrt` 或其他兼容源；
- `BRANCH`：分支名，通常为 `owrt`；
- `TEST`：设为 `true` 时仅输出配置文件产物，不编译。

配置文件会作为 artifact 附在运行记录中，可用于检查选项是否按预期生效。

</details>

<details>
<summary><b>已知限制</b></summary>

- 构建依赖公共运行器，`ubuntu-latest` 镜像调整期间可能出现与代码无关的失败，重跑通常即可恢复。
- 部分上游 feed 使用不稳定的归档校验值，构建脚本已对相关包做本地修正，上游恢复后仍可保留。
- 固件体积受启用的插件数量影响明显，代理类插件与 Go 程序会显著增加镜像大小。

</details>

## 内容与责任使用

本仓库仅提供构建配置与脚本，不提供、托管或分发任何受版权保护的内容。固件中包含的第三方组件遵循各自的许可证。

请遵守所在地法律法规与上游项目的使用条款，不要将本仓库及其产物用于未授权的网络访问、商业分发或规避服务限制。第三方服务与软件源可能随时变更或不可用。

## 致谢与许可

- 上游源码：[VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt) · [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt)
- 流水线模板：[VIKINGYFY/OpenWRT-CI](https://github.com/VIKINGYFY/OpenWRT-CI)
- 构建工具链：[VIKINGYFY/OWRT-Tools](https://github.com/VIKINGYFY/OWRT-Tools) · [VIKINGYFY/packages](https://github.com/VIKINGYFY/packages)
- U-BOOT：[沉心（高通）](https://github.com/chenxin527/uboot-qsdk12.5-build) · [小猪（高通）](https://github.com/1980490718/u-boot-2016) · [UBOOT-CI（联发科）](https://github.com/VIKINGYFY/UBOOT-CI/releases)

本仓库以 [MIT](LICENSE) 许可发布，仅覆盖 `Scripts/`、`Config/` 与流水线定义；上游源码与第三方插件不受此许可约束。

## Star History

<a href="https://www.star-history.com/?repos=kunkun912%2FOpenWRT-CI&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=kunkun912/OpenWRT-CI&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=kunkun912/OpenWRT-CI&type=date&theme=light&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=kunkun912/OpenWRT-CI&type=date&legend=top-left" />
 </picture>
</a>
