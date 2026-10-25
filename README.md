# 🚀 kunkun912 / OpenWRT-CI

> **基于 [VIKINGYFY/OpenWRT-CI](https://github.com/VIKINGYFY/OpenWRT-CI) 的个性化调教定制版**  
> 专为告别网络玄学冲突、畅快联机开黑与特定校园网/认证环境量身打磨！🛠️✨

---

## 🧐 本仓库在原版（VIKINGYFY）基础上的魔改清单

### 1. 🧬 UA3F 专属生存环境改造（防宿舍阿姨抓包认证）
* **彻底物理超度 `mwan3`（多线负载均衡）**：
  * *为什么？* 原版默认塞了 `mwan3`，但它跟 `ua3f`（User-Agent 防检测伪装）简直是命犯天煞孤星，规则冲突容易导致网页反复横跳或 UA 泄露。为了校园网/单线稳定伪装，直接在配置中连根拔起！
* **默认开启 UA 深度伪装 (`ua3f`)**：
  * 宿舍上网冲浪必备神器，伪装 UA 顺滑无感。
* **主动物理关闭硬加速（NSS / PPE / Flow Offload）**：
  * 谁不知道 NSS 硬件加速快？但硬件加速旁路了 Linux Netfilter 协议栈，数据包根本不走 CPU 和 iptables/nftables，导致 `ua3f` 根本捉不到包去改 UA！
  * 宁可牺牲一点微不足道的跑分，也要换取 100% 稳如老狗的 UA 伪装率。

### 2. 🎮 满血主机/联机游戏支持（网易 UU 主机加速器）
* **接入最新维护源**：选用 `xiaodoudou/luci-app-uugamebooster` (v2.1 稳定版)，修复了原生 ARM 架构的架构检测以及守护进程逻辑。
* **全家桶依赖一次性喂饱**：
  * 内核驱动：`kmod-tun`, `kmod-ipt-nat`
  * 系统工具与网络：`ca-bundle`, `unshare`, `ip-full`, `nftables`, `iptables`
  * 运行时与界面：`luci-compat`, `libstdcpp6`
  * 无论是 Switch、PS5、Xbox 还是 SteamDeck，主机加速即插即用，再也不用手动去 SSH 后台敲命令救活插件了。

### 3. 🌐 穿透与科学网络和谐共存
* **皎月连内网穿透 (`luci-app-natpierce`)**：一键 P2P 穿透回家，无需公网 IP。
* **保留 OpenClash**：科学冲浪与国内外流量智能分流，与 UU、UA3F 相安无事。

### 4. 🪓 斩除祖传编译暗坑（血与泪的修复记录）
* **修好 `UPDATE_PACKAGE` 的“自杀式清理” Bug**：
  * 原版的包提取函数在提取像 `uugamebooster`、`luci-app-natpierce` 这种“仓库名与插件名一模一样”的独立插件时，刚拷贝完子目录，反手就是一个 `rm -rf` 把自己同名目录直接蒸发了！修复后采用独立临时隔离拉取，插件再也不会失踪！
* **清除 Windows 恶魔代码 UTF-8 BOM 字节**：
  * 抹除了 `Config/GENERAL.txt` 等文件的 `EF BB BF` 幽灵字符，防止 `make defconfig` 报 `missing separator. Stop.` 暴毙。
* **恢复并优化 `Auto-Clean`**：
  * 自动化清理旧 releases 与 workflow 运行垃圾，云编译不再撑爆仓库配额。

---

## 💡 刷机与升级指南（请默念三遍）

> ⚠️ **强烈提醒**：升级固件时，**请务必【取消勾选】“保留配置”**！
> 
> 因为本固件删除了 `mwan3`、重构了网络加速链条并注入了 UU 依赖，保留旧配置就像把柴油车的变速箱塞进电动车——百分之百会出现网络假死或玄学冲突！
> 请使用 `*-sysupgrade.bin` 包在后台干净刷入，重启后重新配置拨号即可。

---

## 📌 上游与官方资源

- **上游 CI 架构**：[VIKINGYFY/OpenWRT-CI](https://github.com/VIKINGYFY/OpenWRT-CI)
- **底层 ImmortalWrt**：[VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt) / [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt)
- **U-Boot 推荐**：
  - 高通系列（IPQ60xx / IPQ807x）：沉心 / 小猪 U-Boot
  - 联发科系列（MT798x）：VIKINGYFY UBOOT-CI

---

*给生活添点折腾，愿你的路由器永不红灯，Ping 值永远个位数！* 🍻