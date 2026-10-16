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

#修改mini-diskmanager菜单位置
FIX "mini-diskmanager" "$PACKAGE_PATH/luci-app-mini-diskmanager" sed -i "s/services/system/g" \
	"$PACKAGE_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"

#修改natmapt菜单位置
FIX "natmapt" "$PACKAGE_PATH/luci-app-natmapt" sed -i "s/network/services/g" \
	"$PACKAGE_PATH/luci-app-natmapt/root/usr/share/luci/menu.d/luci-app-natmap.json"

#修复Rust编译失败
FIX "rust" "$FEEDS_PATH/packages/lang/rust" sed -i 's/ci-llvm=true/ci-llvm=false/g' \
	"$FEEDS_PATH/packages/lang/rust/Makefile"

#3) frpc 文件冲突：superzjg/luci-app-frpc 自带 init.d/config 完整方案，
#   feeds 的 frpc 只保留 /usr/bin/frpc 二进制，frps 不受影响
FRP_MK="$FEEDS_PATH/packages/net/frp/Makefile"
if grep -q 'INSTALL_BIN)  \./files/\$(2)\.init' "$FRP_MK" 2>/dev/null; then
	sed -i \
		-e 's|\t\$(INSTALL_CONF) \./files/\$(2)\.config .*|\tif [ "$(2)" != "frpc" ]; then $(INSTALL_CONF) ./files/$(2).config $(1)/etc/config/$(2); fi|' \
		-e 's|\t\$(INSTALL_BIN)  \./files/\$(2)\.init .*|\tif [ "$(2)" != "frpc" ]; then $(INSTALL_BIN)  ./files/$(2).init   $(1)/etc/init.d/$(2); fi|' \
		-e 's|if \[ -r \./files/\$(2)\.uci-defaults \]; then|if [ "$(2)" != "frpc" ] \&\& [ -r ./files/$(2).uci-defaults ]; then|' \
		"$FRP_MK"
	echo "feeds frpc init/config overlap has been fixed!"
fi
