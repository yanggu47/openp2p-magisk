#!/system/bin/sh
# 在模块挂载后立即修复权限
# 解决unzip解压后权限丢失的问题

MODDIR=${0%/*}

# 修复所有可执行文件的权限
chmod 755 "${MODDIR}"/*.sh "${MODDIR}/openp2p" 2>/dev/null
