#!/bin/bash
# 私有扩展脚本
# 此文件不会被 git 跟踪（建议加入 .gitignore）
# 由 Scripts/Packages.sh 末尾自动 source

# ===== 应用过滤（OAF 家长控制，旧版 oaf-6.1 分支）=====
# 用 destan19 上游版本替换 feeds 里的旧版
# 删除列表：luci-app-appfilter / open-app-filter / oaf / luci-app-oaf
UPDATE_PACKAGE "openappfilter" "destan19/OpenAppFilter" "master" "" "luci-app-appfilter open-app-filter oaf"

# ===== frp 内网穿透客户端（可选）=====
# kuoruan/openwrt-frpc 仓库已 404，改用 superzjg/luci-app-frpc_frps（TOML 配置，适配新版 frp）
# 注意：此仓库只带 LuCI 前端，frpc 二进制由 feeds 的 frp 包提供（PRIVATE.txt 里 CONFIG_PACKAGE_frpc=y）
UPDATE_PACKAGE "luci-app-frpc" "superzjg/luci-app-frpc_frps" "main" "" "luci-app-frpc"
# 配套 Config/PRIVATE.txt 里需要：
# CONFIG_PACKAGE_frpc=y
# CONFIG_PACKAGE_luci-app-frpc=y
