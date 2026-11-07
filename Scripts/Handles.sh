#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

FEEDS_PATH="./feeds"
PACKAGE_PATH="./package"

#修补命令统一入口：FIX <名称> <守卫目录> <命令...>
#守卫目录不存在时直接跳过，保证在 bash -e 下不中断
FIX() {
	local NAME=$1
	local GUARD=$2
	shift 2

	[ -d "$GUARD" ] || return 0

	echo " "
	if "$@"; then
		echo "$NAME has been fixed!"
	else
		echo "$NAME fix failed; continuing!"
	fi
}

#修改argon主题字体和颜色
FIX "theme-argon" "$PACKAGE_PATH/luci-theme-argon" sed -i \
	"s/primary '.*'/primary '#31a1a1'/g; s/'0.2'/'0.5'/g; s/'none'/'bing'/g; s/'600'/'normal'/g" \
	"$PACKAGE_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"

#修改aurora菜单式样
FIX "theme-aurora" "$PACKAGE_PATH/luci-app-aurora-config" find \
	"$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/aurora/" -type f -name '*.template' -exec sed -i \
	"s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +

#修改vantage进度条标签字体（anothaDev/luci-theme-vantage#52）
FIX "theme-vantage" "$PACKAGE_PATH/luci-theme-vantage" sed -i \
	-e '/^\/\* progress bars: thin track/,$ { /^\.cbi-progressbar::before {/,/^}/ { s/^[[:space:]]*font: 500 var(--fs-micro)\/1\.2 var(--mono);/\tfont: inherit; line-height: normal;/; } }' \
	"$PACKAGE_PATH/luci-theme-vantage/luci-theme-vantage/htdocs/luci-static/vantage/vantage.css"

#修改mini-diskmanager菜单位置
FIX "mini-diskmanager" "$PACKAGE_PATH/luci-app-mini-diskmanager" sed -i "s/services/system/g" \
	"$PACKAGE_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"

#修改natmapt菜单位置
FIX "natmapt" "$PACKAGE_PATH/luci-app-natmapt" sed -i "s/network/services/g" \
	"$PACKAGE_PATH/luci-app-natmapt/root/usr/share/luci/menu.d/luci-app-natmap.json"

#修正uugamebooster依赖名：新版目标里libstdcpp6已并入libstdcpp，否则make报 dependency does not exist
FIX "uugamebooster-libstdcpp" "$PACKAGE_PATH/luci-app-uugamebooster" sed -i \
	"s/+libstdcpp6/+libstdcpp/g" \
	"$PACKAGE_PATH/luci-app-uugamebooster/Makefile"

#修正uugamebooster脚本权限：源仓库里uu-detect/uu-view等是644，cp -p会保留权限，不补执行位会导致插件跑不起来
FIX "uugamebooster-exec" "$PACKAGE_PATH/luci-app-uugamebooster" chmod +x \
	"$PACKAGE_PATH/luci-app-uugamebooster/root/etc/init.d/uuplugin" \
	"$PACKAGE_PATH/luci-app-uugamebooster/root/usr/libexec/uuplugin/uu-detect" \
	"$PACKAGE_PATH/luci-app-uugamebooster/root/usr/libexec/uuplugin/uu-view" \
	"$PACKAGE_PATH/luci-app-uugamebooster/root/usr/libexec/uuplugin/uu-openclash-sync" \
	"$PACKAGE_PATH/luci-app-uugamebooster/root/usr/libexec/uuplugin/uu-ua3f-sync" \
	"$PACKAGE_PATH/luci-app-uugamebooster/root/usr/libexec/uuplugin/xt/iptables"

#删除uugamebooster的postinst：打镜像时会在宿主机root下执行chmod，目标文件不存在会直接让make失败
FIX "uugamebooster-postinst" "$PACKAGE_PATH/luci-app-uugamebooster" sed -i \
	'/^define Package\/.*\/postinst$/,/^endef$/d' \
	"$PACKAGE_PATH/luci-app-uugamebooster/Makefile"

#删除natpierce缺失的htdocs安装段：上游仓库根本没有htdocs目录，$(CP) ./htdocs/* 会报 cannot stat
FIX "natpierce-htdocs" "$PACKAGE_PATH/luci-app-natpierce" sed -i \
	'/INSTALL_DIR) \$(1)\/www\//d; /CP) \.\/htdocs/d' \
	"$PACKAGE_PATH/luci-app-natpierce/Makefile"

#删除natpierce的postinst：打镜像时会在宿主机执行 /usr/share/natpierce/update.sh，文件不存在导致安装失败
FIX "natpierce-postinst" "$PACKAGE_PATH/luci-app-natpierce" sed -i \
	'/^define Package\/luci-app-natpierce\/postinst$/,/^endef$/d' \
	"$PACKAGE_PATH/luci-app-natpierce/Makefile"

#修正luci集合里的空主题名：上游feed快照写成 "+luci-theme- \"，会让package/install报 luci-theme- (no such package)
for THEME_MAKEFILE in "$FEEDS_PATH"/luci/collections/*/Makefile; do
	[ -f "$THEME_MAKEFILE" ] || continue
	FIX "luci-theme-fix-$(basename "$(dirname "$THEME_MAKEFILE")")" "$(dirname "$THEME_MAKEFILE")" \
		sed -i 's|+luci-theme- |+luci-theme-bootstrap |g' "$THEME_MAKEFILE"
done
