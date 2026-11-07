# OpenWRT-CI · 一个懒人专用的自动编固件流水线

> 每天早上 5 点，GitHub 的服务器替你起床干活，你负责睡觉。
> 编完的固件自己躺在 Release 里，像冰箱里留好的早饭。

[![Build](https://img.shields.io/badge/build-daily%2005%3A00-blue)](https://github.com/kunkun912/OpenWRT-CI/actions)
[![Source](https://img.shields.io/badge/source-VIKINGYFY%2Fimmortalwrt-informational)](https://github.com/VIKINGYFY/immortalwrt)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## 这玩意儿是干嘛的

一个 fork 自 [VIKINGYFY/OpenWRT-CI](https://github.com/VIKINGYFY/OpenWRT-CI) 的自动编译仓库。

说人话：**上游源码一更新，它就自动把固件编出来**，覆盖四个系列——

`MEDIATEK` · `QUALCOMMAX` · `ROCKCHIP` · `X86`

固件信息里显示的时间是「编译开始时间」，不是「你下载的时间」，也不是「你生日」。用来核对上游源码提交到哪天了。

> 顺便一提，这个仓库是在京东云亚瑟（`qualcommax / ipq60xx / jdcloud_re-ss-01`）上真机验证过的，不是编完就扔的。

---

## 前排提示（先看这段，能少问一半问题）

- 这是**自用固件**，不是发行版。不保证任何机型都能亮，刷砖了别找我，找 U-BOOT。
- 原厂固件首刷用 `factory`，已经是 OpenWrt 的用 `sysupgrade`。**别刷反，刷反了就得拆机。**
- 每日构建是「跟着上游源码跑」，所以偶尔会因为上游某个提交抽风而失败 —— 这在开源界叫「不是你的问题」。

---

## 这个 fork 加了什么料

2026 年 11 月基于自用需求补齐的插件（上游默认没有）：

| 插件 | 来源 | 干嘛的 |
|---|---|---|
| 网易 UU 加速器 | [xiaodoudou/luci-app-uugamebooster](https://github.com/xiaodoudou/luci-app-uugamebooster) | 主机加速，切区服不用再开电脑 |
| UA3F | [SunBK201/UA3F](https://github.com/SunBK201/UA3F) | 把 UA 换成 iPhone，某些 App 就不再给你塞广告了 |
| OpenClash | [vernesong/OpenClash](https://github.com/vernesong/OpenClash) | 老牌透明代理，懂的都懂 |
| 皎月连 | [natpierce/luci-app-natpierce](https://github.com/natpierce/luci-app-natpierce) | 内网穿透，出门在外也能摸到家里的路由器 |

**已知的相爱相杀**：OpenClash 和 homeproxy 都是透明代理，装是可以一起装，**开的时候只开一个**。两个同时开，它们会在 iptables 里互相拽头发，结果就是谁都连不上。

UU 加速器这边也做了共存适配，和 OpenClash、UA3F 一起跑不会互相踩脚（真机测过）。

---

## 想自己改？三个文件夹搞定

```
.github/workflows/   流水线剧本（几点跑、编哪些系列、怎么发 Release）
Scripts/             Packages.sh 拉第三方插件 · Handles.sh 打补丁 · Settings.sh 改固件默认值
Config/              每个系列的 .config 模板 + GENERAL.txt（所有系列共用的包清单）
```

想加插件就三步：`Packages.sh` 里拉源码 → `GENERAL.txt` 里开 `CONFIG_PACKAGE_xxx=y` → 推上去。

想手动跑一次？Actions 页面点 `Run workflow`，把 `TEST=true` 勾上就只生成配置文件不编译，适合先验证「我的依赖对不对」这种哲学问题。

---

## 上游与致谢

- 源码：[VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt)（自用版）/ [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt)（官方版）
- 本地编译工具链：[VIKINGYFY/OWRT-Tools](https://github.com/VIKINGYFY/OWRT-Tools)
- 自用修改版插件：[VIKINGYFY/packages](https://github.com/VIKINGYFY/packages)
- U-BOOT：高通版看[沉心](https://github.com/chenxin527/uboot-qsdk12.5-build) / [小猪](https://github.com/1980490718/u-boot-2016)，联发科看 [UBOOT-CI](https://github.com/VIKINGYFY/UBOOT-CI/releases) 或 [官方](https://drive.wrt.moe/uboot/mediatek)

没有上游这套自动构建，就没有这个仓库；没有原作者熬夜填的坑，这个 README 也不用写这么长。

---

## Star History

<a href="https://www.star-history.com/?repos=kunkun912%2FOpenWRT-CI&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=kunkun912/OpenWRT-CI&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=kunkun912/OpenWRT-CI&type=date&theme=light&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=kunkun912/OpenWRT-CI&type=date&legend=top-left" />
 </picture>
</a>

---

<p align="center"><sub>如果这份固件让你少折腾了一个晚上，点个 Star 就当请作者喝杯水。</sub></p>
